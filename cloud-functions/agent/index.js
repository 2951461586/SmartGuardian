const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok } = require('../shared/router');
const { badRequest } = require('../shared/errors');
const {
  assertStudentAccess,
  filterAlertsForUser,
  filterAttendanceForUser,
  filterHomeworkForUser,
  filterLeavesForUser,
  filterOrdersForUser,
  filterSessionsForUser,
  filterStudentsForUser,
  isAdmin,
  isParent,
  isTeacher
} = require('../shared/auth');
const { todayDate, nowIso } = require('../shared/time');
const { NAVIGATION_ROUTES } = require('./navigation-routes');
const { LOCAL_RULES_MODEL, callLlmAsync } = require('./llm-client');

const AGENT_ID = 'smartguardian-student-custody-agent';
const MAX_CONTEXT_ITEMS = 8;

const TASK_CHAT = 'CHAT';
const TASK_SUMMARY = 'SUMMARY';
const TASK_REPORT = 'REPORT';
const TASK_NAVIGATION = 'NAVIGATION';
const TASK_QA = 'QA';

// NAVIGATION_ROUTES imported from ./navigation-routes.js

function asString(value) {
  if (value === undefined || value === null) {
    return '';
  }
  return String(value);
}

function asNumber(value) {
  const numberValue = Number(value || 0);
  return Number.isNaN(numberValue) ? 0 : numberValue;
}

function isSameDate(value, date) {
  if (!value || !date) {
    return false;
  }
  return String(value).slice(0, 10) === date;
}

function includesText(message, keyword) {
  return message.toLowerCase().indexOf(keyword.toLowerCase()) >= 0;
}

function getStudentIds(students) {
  const ids = [];
  for (let i = 0; i < students.length; i++) {
    ids.push(Number(students[i].id));
  }
  return ids;
}

function containsStudentId(studentIds, studentId) {
  return studentIds.indexOf(Number(studentId)) >= 0;
}

function filterByStudents(records, studentIds) {
  if (studentIds.length === 0) {
    return records;
  }
  return records.filter((record) => containsStudentId(studentIds, record.studentId));
}

function limitItems(items, limit) {
  return items.slice(0, limit);
}

function statusCount(items, status) {
  return items.filter((item) => item.status === status).length;
}

function resolveLatestDate(dateValues) {
  let latest = '';
  for (let i = 0; i < dateValues.length; i++) {
    const value = asString(dateValues[i]).slice(0, 10);
    if (value && value > latest) {
      latest = value;
    }
  }
  return latest || todayDate();
}

function resolveBusinessDate(requestedDate, attendance, sessions, homework, timelines) {
  if (requestedDate) {
    return requestedDate;
  }

  const today = todayDate();
  const hasTodayData =
    attendance.some((item) => isSameDate(item.attendanceDate, today)) ||
    sessions.some((item) => isSameDate(item.sessionDate, today)) ||
    homework.some((item) => isSameDate(item.taskDate, today)) ||
    timelines.some((item) => isSameDate(item.bizDate, today));
  if (hasTodayData) {
    return today;
  }

  const dates = [];
  for (let i = 0; i < attendance.length; i++) {
    dates.push(attendance[i].attendanceDate);
  }
  for (let i = 0; i < sessions.length; i++) {
    dates.push(sessions[i].sessionDate);
  }
  for (let i = 0; i < homework.length; i++) {
    dates.push(homework[i].taskDate);
  }
  for (let i = 0; i < timelines.length; i++) {
    dates.push(timelines[i].bizDate);
  }
  return resolveLatestDate(dates);
}

function compactStudent(student) {
  return {
    id: student.id,
    name: student.name,
    grade: student.grade || '',
    className: student.className || '',
    healthNotes: student.healthNotes || ''
  };
}

function compactAttendance(record) {
  return {
    id: record.id,
    studentId: record.studentId,
    sessionId: record.sessionId,
    status: record.status,
    attendanceDate: record.attendanceDate || '',
    signInTime: record.signInTime || '',
    signOutTime: record.signOutTime || '',
    abnormalFlag: record.abnormalFlag === true,
    abnormalType: record.abnormalType || '',
    abnormalDesc: record.abnormalDesc || ''
  };
}

function compactHomework(task) {
  return {
    id: task.id,
    studentId: task.studentId,
    taskDate: task.taskDate || '',
    subject: task.subject || '',
    title: task.title || '',
    content: task.content || '',
    status: task.status || '',
    teacherId: task.teacherId || 0
  };
}

function compactSession(session) {
  return {
    id: session.id,
    sessionNo: session.sessionNo || '',
    sessionDate: session.sessionDate || '',
    startTime: session.startTime || '',
    endTime: session.endTime || '',
    teacherUserId: session.teacherUserId || 0,
    serviceProductId: session.serviceProductId || 0,
    location: session.location || '',
    status: session.status || ''
  };
}

function compactAlert(alert) {
  return {
    id: alert.id,
    studentId: alert.studentId,
    studentName: alert.studentName || '',
    alertType: alert.alertType || '',
    severity: alert.severity || '',
    title: alert.title || '',
    description: alert.description || '',
    suggestedAction: alert.suggestedAction || '',
    status: alert.status || '',
    createdAt: alert.createdAt || ''
  };
}

function compactMessage(message) {
  return {
    id: message.id,
    msgType: message.msgType || '',
    title: message.title || '',
    content: message.content || '',
    readStatus: message.readStatus === true,
    createdAt: message.createdAt || ''
  };
}

function compactOrder(order) {
  return {
    id: order.id,
    orderNo: order.orderNo || '',
    studentId: order.studentId,
    orderStatus: order.orderStatus || '',
    payStatus: order.payStatus || '',
    actualAmount: order.actualAmount || order.amount || 0,
    startDate: order.startDate || '',
    endDate: order.endDate || ''
  };
}

async function filterSessionsByStudents(sessions, studentIds) {
  if (studentIds.length === 0) {
    return sessions;
  }

  const roster = await store.listAsync('session_students');
  const sessionMap = {};
  for (let i = 0; i < roster.length; i++) {
    if (containsStudentId(studentIds, roster[i].studentId)) {
      sessionMap[Number(roster[i].sessionId)] = true;
    }
  }
  return sessions.filter((session) => sessionMap[Number(session.id)] === true);
}

async function buildAgentContextAsync(user, body) {
  const allStudents = await store.listAsync('students');
  let scopedStudents = await filterStudentsForUser(user, allStudents);
  const requestedStudentId = asNumber(body.studentId);

  if (requestedStudentId > 0) {
    await assertStudentAccess(user, requestedStudentId);
    scopedStudents = scopedStudents.filter((student) => Number(student.id) === requestedStudentId);
  }

  const studentIds = getStudentIds(scopedStudents);
  const allAttendance = await store.listAsync('attendance_records');
  const allHomework = await store.listAsync('homework_tasks');
  const allSessions = await store.listAsync('sessions');
  const allAlerts = await store.listAsync('alerts');
  const allOrders = await store.listAsync('orders');
  const allLeaves = await store.listAsync('leave_requests');
  const allMessages = await store.listAsync('messages');
  const allTimelines = await store.listAsync('student_timelines');

  let attendance = await filterAttendanceForUser(user, allAttendance);
  let homework = await filterHomeworkForUser(user, allHomework);
  let sessions = await filterSessionsForUser(user, allSessions);
  let alerts = await filterAlertsForUser(user, allAlerts);
  let orders = await filterOrdersForUser(user, allOrders);
  let leaves = await filterLeavesForUser(user, allLeaves);
  let timelines = filterByStudents(allTimelines, studentIds);
  let messages = allMessages.filter((message) => Number(message.userId) === Number(user.id));

  attendance = filterByStudents(attendance, studentIds);
  homework = filterByStudents(homework, studentIds);
  sessions = await filterSessionsByStudents(sessions, studentIds);
  alerts = filterByStudents(alerts, studentIds);
  orders = filterByStudents(orders, studentIds);
  leaves = filterByStudents(leaves, studentIds);

  if (isAdmin(user)) {
    messages = allMessages;
  }

  const date = resolveBusinessDate(asString(body.date), attendance, sessions, homework, timelines);
  const dateAttendance = attendance.filter((item) => isSameDate(item.attendanceDate, date));
  const dateHomework = homework.filter((item) => isSameDate(item.taskDate, date));
  const dateSessions = sessions.filter((item) => isSameDate(item.sessionDate, date));
  const activeAlerts = alerts.filter((item) => item.status === 'ACTIVE');
  const unreadMessages = messages.filter((item) => item.readStatus !== true);
  const pendingLeaves = leaves.filter((item) => item.status === 'PENDING');
  const pendingOrders = orders.filter((item) => item.orderStatus === 'PENDING' || item.payStatus === 'UNPAID');

  return {
    agentId: AGENT_ID,
    generatedAt: nowIso(),
    date,
    user: {
      id: user.id,
      realName: user.realName,
      roleType: user.roleType,
      orgId: user.orgId,
      schoolId: user.schoolId
    },
    students: limitItems(scopedStudents.map(compactStudent), MAX_CONTEXT_ITEMS),
    metrics: {
      studentCount: scopedStudents.length,
      sessionCount: dateSessions.length,
      attendanceTotal: dateAttendance.length,
      signedIn: statusCount(dateAttendance, 'SIGNED_IN'),
      signedOut: statusCount(dateAttendance, 'SIGNED_OUT'),
      absent: statusCount(dateAttendance, 'ABSENT') + statusCount(dateAttendance, 'NOT_SIGNED'),
      late: statusCount(dateAttendance, 'LATE'),
      leave: statusCount(dateAttendance, 'LEAVE'),
      abnormal: dateAttendance.filter((item) => item.abnormalFlag === true).length,
      homeworkTotal: dateHomework.length,
      homeworkPending: statusCount(dateHomework, 'PENDING'),
      homeworkInProgress: statusCount(dateHomework, 'IN_PROGRESS'),
      homeworkCompleted: statusCount(dateHomework, 'COMPLETED') + statusCount(dateHomework, 'CONFIRMED'),
      activeAlerts: activeAlerts.length,
      unreadMessages: unreadMessages.length,
      pendingLeaves: pendingLeaves.length,
      pendingOrders: pendingOrders.length
    },
    samples: {
      sessions: limitItems(dateSessions.map(compactSession), MAX_CONTEXT_ITEMS),
      attendance: limitItems(dateAttendance.map(compactAttendance), MAX_CONTEXT_ITEMS),
      homework: limitItems(dateHomework.map(compactHomework), MAX_CONTEXT_ITEMS),
      alerts: limitItems(activeAlerts.map(compactAlert), MAX_CONTEXT_ITEMS),
      messages: limitItems(unreadMessages.map(compactMessage), MAX_CONTEXT_ITEMS),
      orders: limitItems(pendingOrders.map(compactOrder), MAX_CONTEXT_ITEMS),
      leaves: limitItems(pendingLeaves, MAX_CONTEXT_ITEMS)
    },
    totals: {
      attendance: attendance.length,
      homework: homework.length,
      sessions: sessions.length,
      alerts: alerts.length,
      messages: messages.length,
      orders: orders.length,
      leaves: leaves.length,
      timelines: timelines.length
    }
  };
}

function normalizeTaskType(routeTask, bodyTask, message) {
  const declared = asString(routeTask || bodyTask).toUpperCase();
  if (declared === TASK_SUMMARY || declared === TASK_REPORT || declared === TASK_NAVIGATION || declared === TASK_QA) {
    return declared;
  }

  if (includesText(message, '导航') || includesText(message, '打开') || includesText(message, '跳转') || includesText(message, '去')) {
    return TASK_NAVIGATION;
  }
  if (includesText(message, '汇报') || includesText(message, '报告') || includesText(message, '报表')) {
    return TASK_REPORT;
  }
  if (includesText(message, '总结') || includesText(message, '今天') || includesText(message, '情况')) {
    return TASK_SUMMARY;
  }
  if (includesText(message, '为什么') || includesText(message, '怎么') || includesText(message, '如何') || includesText(message, '?') || includesText(message, '？')) {
    return TASK_QA;
  }
  return TASK_CHAT;
}

function roleCanUseRoute(user, route) {
  if (isParent(user)) {
    return route.roles.indexOf('PARENT') >= 0;
  }
  if (isTeacher(user)) {
    return route.roles.indexOf('TEACHER') >= 0;
  }
  return route.roles.indexOf('ADMIN') >= 0 || route.roles.indexOf(user.roleType) >= 0;
}

function scoreRoute(message, route) {
  let score = 0;
  for (let i = 0; i < route.keywords.length; i++) {
    if (includesText(message, route.keywords[i])) {
      score += route.keywords[i].length + 2;
    }
  }
  if (includesText(message, route.title)) {
    score += 8;
  }
  return score;
}

function resolveNavigationAction(user, message) {
  const usableRoutes = NAVIGATION_ROUTES.filter((route) => roleCanUseRoute(user, route));
  let bestRoute = usableRoutes.length > 0 ? usableRoutes[0] : null;
  let bestScore = 0;

  for (let i = 0; i < usableRoutes.length; i++) {
    const route = usableRoutes[i];
    const score = scoreRoute(message, route);
    if (score > bestScore) {
      bestRoute = route;
      bestScore = score;
    }
  }

  if (!bestRoute) {
    return null;
  }

  const title = bestScore > 0 ? bestRoute.title : '当前角色首页';
  return {
    type: 'NAVIGATE',
    title,
    routeUrl: bestRoute.routeUrl,
    moduleCode: bestRoute.moduleCode,
    confidence: bestScore > 0 ? 0.86 : 0.5,
    reason: bestScore > 0 ? `根据“${message}”匹配到${bestRoute.title}` : '未命中明确关键词，返回当前角色首页'
  };
}

function getStudentNameText(context) {
  if (context.students.length === 0) {
    return '当前作用域内学生';
  }
  return context.students.map((student) => student.name).join('、');
}

function buildAttendanceSentence(context) {
  const metrics = context.metrics;
  if (metrics.attendanceTotal === 0) {
    return `${context.date} 暂无考勤记录。`;
  }
  return `${context.date} 考勤 ${metrics.attendanceTotal} 条，已签到 ${metrics.signedIn} 人，已签退 ${metrics.signedOut} 人，缺勤/未签到 ${metrics.absent} 人，迟到 ${metrics.late} 人，异常 ${metrics.abnormal} 条。`;
}

function buildHomeworkSentence(context) {
  const metrics = context.metrics;
  if (metrics.homeworkTotal === 0) {
    return '今日暂无作业任务。';
  }
  return `作业 ${metrics.homeworkTotal} 项，待辅导 ${metrics.homeworkPending} 项，辅导中 ${metrics.homeworkInProgress} 项，已完成/确认 ${metrics.homeworkCompleted} 项。`;
}

function buildRiskSentence(context) {
  const metrics = context.metrics;
  const parts = [];
  if (metrics.activeAlerts > 0) {
    parts.push(`活跃告警 ${metrics.activeAlerts} 条`);
  }
  if (metrics.pendingLeaves > 0) {
    parts.push(`待处理请假 ${metrics.pendingLeaves} 条`);
  }
  if (metrics.pendingOrders > 0) {
    parts.push(`待处理订单/缴费 ${metrics.pendingOrders} 条`);
  }
  if (metrics.unreadMessages > 0) {
    parts.push(`未读消息 ${metrics.unreadMessages} 条`);
  }
  return parts.length > 0 ? `需要关注：${parts.join('，')}。` : '暂无必须立即处理的风险项。';
}

function buildLocalAnswer(context, taskType, message, action) {
  if (taskType === TASK_NAVIGATION) {
    if (action) {
      return `已为你定位到「${action.title}」，可打开 ${action.routeUrl} 继续处理。`;
    }
    return '暂未匹配到可导航页面，请换一种说法描述要打开的功能。';
  }

  const studentText = getStudentNameText(context);
  const opening = taskType === TASK_REPORT ? `这是${studentText}的托管汇报：` : `已汇总${studentText}的托管情况：`;
  const lines = [
    opening,
    buildAttendanceSentence(context),
    buildHomeworkSentence(context),
    buildRiskSentence(context)
  ];

  if (taskType === TASK_QA && message) {
    if (includesText(message, '作业')) {
      lines.push('问答建议：优先查看作业状态与老师反馈，必要时进入作业页确认完成情况。');
    } else if (includesText(message, '考勤') || includesText(message, '签到')) {
      lines.push('问答建议：优先核对签到/签退时间、班次和异常标记。');
    } else if (includesText(message, '缴费') || includesText(message, '订单')) {
      lines.push('问答建议：进入订单中心查看审核、支付和退款状态。');
    } else {
      lines.push('问答建议：当前回答基于你有权限访问的托管数据生成，可继续追问具体学生、日期或业务模块。');
    }
  }

  return lines.join('\n');
}

function buildSuggestions(user, context) {
  if (isParent(user)) {
    return [
      '总结今天孩子托管情况',
      context.metrics.unreadMessages > 0 ? '查看未读家校消息' : '导航到成长动态',
      context.metrics.activeAlerts > 0 ? '查看异常提醒' : '帮我打开请假申请'
    ];
  }
  if (isTeacher(user)) {
    return [
      '汇总今日班级考勤',
      context.metrics.homeworkPending > 0 ? '列出待辅导作业' : '打开作业管理',
      context.metrics.activeAlerts > 0 ? '处理异常告警' : '打开扫码签到'
    ];
  }
  return [
    '生成今日运营汇报',
    context.metrics.pendingOrders > 0 ? '查看待审核订单' : '打开运营报表',
    context.metrics.activeAlerts > 0 ? '查看告警中心' : '查看学生管理'
  ];
}

function buildCitations(context) {
  return [
    { label: 'students', count: context.metrics.studentCount },
    { label: 'attendance_records', count: context.metrics.attendanceTotal },
    { label: 'homework_tasks', count: context.metrics.homeworkTotal },
    { label: 'alerts', count: context.metrics.activeAlerts },
    { label: 'messages', count: context.metrics.unreadMessages }
  ];
}

// LLM functions (buildLlmSafeContext, getLlmConfig, callLlmAsync) imported from ./llm-client.js

async function buildAgentResponse(auth, body, routeTask) {
  const message = asString(body.message || body.question || body.prompt);
  const taskType = normalizeTaskType(routeTask, body.taskType, message);
  if ((taskType === TASK_CHAT || taskType === TASK_QA || taskType === TASK_NAVIGATION) && !message) {
    throw badRequest('message is required');
  }

  const context = await buildAgentContextAsync(auth.user, body);
  const navigationIntent =
    taskType === TASK_NAVIGATION ||
    includesText(message, '导航') ||
    includesText(message, '打开') ||
    includesText(message, '跳转') ||
    includesText(message, '去');
  const action = navigationIntent ? resolveNavigationAction(auth.user, message) : null;
  const actions = action ? [action] : [];
  const localAnswer = buildLocalAnswer(context, taskType, message, action);
  const llm = taskType === TASK_NAVIGATION ? null : await callLlmAsync(context, taskType, message, action);

  return ok({
    agentId: AGENT_ID,
    taskType,
    answer: llm ? llm.answer : localAnswer,
    source: llm ? 'LLM' : 'LOCAL_RULES',
    model: llm ? llm.model : LOCAL_RULES_MODEL,
    provider: llm ? llm.provider : 'local',
    generatedAt: context.generatedAt,
    contextDate: context.date,
    summary: {
      studentCount: context.metrics.studentCount,
      attendanceTotal: context.metrics.attendanceTotal,
      signedIn: context.metrics.signedIn,
      signedOut: context.metrics.signedOut,
      absent: context.metrics.absent,
      late: context.metrics.late,
      abnormal: context.metrics.abnormal,
      homeworkTotal: context.metrics.homeworkTotal,
      homeworkCompleted: context.metrics.homeworkCompleted,
      activeAlerts: context.metrics.activeAlerts,
      unreadMessages: context.metrics.unreadMessages,
      pendingLeaves: context.metrics.pendingLeaves,
      pendingOrders: context.metrics.pendingOrders
    },
    actions,
    suggestions: buildSuggestions(auth.user, context),
    citations: buildCitations(context)
  });
}

const routes = [
  {
    method: 'POST',
    path: '/api/v1/agent/chat',
    bodyRules: [{ name: 'message', type: 'string', required: true }],
    handler: async ({ body, auth }) => {
      return buildAgentResponse(auth, body, TASK_CHAT);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/agent/summary',
    handler: async ({ body, auth }) => {
      return buildAgentResponse(auth, body, TASK_SUMMARY);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/agent/report',
    handler: async ({ body, auth }) => {
      return buildAgentResponse(auth, body, TASK_REPORT);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/agent/navigation',
    bodyRules: [{ name: 'message', type: 'string', required: true }],
    handler: async ({ body, auth }) => {
      return buildAgentResponse(auth, body, TASK_NAVIGATION);
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
