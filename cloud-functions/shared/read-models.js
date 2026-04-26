const store = require('./store');
const { todayDate, formatMonth } = require('./time');

function getUser(id) {
  return store.findById('users', id);
}

async function getUserAsync(id) {
  return store.findByIdAsync('users', id);
}

function getStudent(id) {
  return store.findById('students', id);
}

async function getStudentAsync(id) {
  return store.findByIdAsync('students', id);
}

function getServiceProduct(id) {
  return store.findById('service_products', id);
}

async function getServiceProductAsync(id) {
  return store.findByIdAsync('service_products', id);
}

function getSession(id) {
  return store.findById('sessions', id);
}

async function getSessionAsync(id) {
  return store.findByIdAsync('sessions', id);
}

function getStudentView(student) {
  const guardian = getUser(student.guardianUserId);
  return {
    ...student,
    guardianName: guardian ? guardian.realName : '',
    guardianMobile: guardian ? guardian.mobile : ''
  };
}

async function getStudentViewAsync(student) {
  const guardian = await getUserAsync(student.guardianUserId);
  return {
    ...student,
    guardianName: guardian ? guardian.realName : '',
    guardianMobile: guardian ? guardian.mobile : ''
  };
}

function getServiceProductView(product) {
  return {
    ...product
  };
}

async function getServiceProductViewAsync(product) {
  return {
    ...product
  };
}

function getOrderView(order) {
  const student = getStudent(order.studentId);
  const service = getServiceProduct(order.serviceProductId);
  const guardian = student ? getUser(student.guardianUserId) : null;
  return {
    ...order,
    studentName: student ? student.name : '',
    guardianUserId: student ? student.guardianUserId : 0,
    guardianName: guardian ? guardian.realName : '',
    serviceProductName: service ? service.serviceName : ''
  };
}

async function getOrderViewAsync(order) {
  const student = await getStudentAsync(order.studentId);
  const service = await getServiceProductAsync(order.serviceProductId);
  const guardian = student ? await getUserAsync(student.guardianUserId) : null;
  return {
    ...order,
    studentName: student ? student.name : '',
    guardianUserId: student ? student.guardianUserId : 0,
    guardianName: guardian ? guardian.realName : '',
    serviceProductName: service ? service.serviceName : ''
  };
}

function getSessionView(session) {
  const service = getServiceProduct(session.serviceProductId);
  const teacher = session.teacherUserId ? getUser(session.teacherUserId) : null;
  return {
    ...session,
    serviceProductName: service ? service.serviceName : '',
    teacherId: session.teacherUserId || 0,
    teacherName: teacher ? teacher.realName : ''
  };
}

async function getSessionViewAsync(session) {
  const service = await getServiceProductAsync(session.serviceProductId);
  const teacher = session.teacherUserId ? await getUserAsync(session.teacherUserId) : null;
  return {
    ...session,
    serviceProductName: service ? service.serviceName : '',
    teacherId: session.teacherUserId || 0,
    teacherName: teacher ? teacher.realName : ''
  };
}

function getSessionStudents(sessionId) {
  const roster = store.filter('session_students', (item) => Number(item.sessionId) === Number(sessionId));
  return roster.map((item) => {
    const student = getStudent(item.studentId);
    const attendance = store.filter('attendance_records', (record) => {
      return Number(record.sessionId) === Number(sessionId) && Number(record.studentId) === Number(item.studentId);
    })[0];
    return {
      studentId: item.studentId,
      studentName: student ? student.name : '',
      studentNo: student ? student.studentNo : '',
      attendanceStatus: attendance ? attendance.status : 'NOT_SIGNED',
      signInTime: attendance ? attendance.signInTime : '',
      signOutTime: attendance ? attendance.signOutTime : ''
    };
  });
}

async function getSessionStudentsAsync(sessionId) {
  const roster = await store.filterAsync('session_students', (item) => Number(item.sessionId) === Number(sessionId));
  const students = [];
  for (let i = 0; i < roster.length; i++) {
    const rosterItem = roster[i];
    const student = await getStudentAsync(rosterItem.studentId);
    const attendanceList = await store.filterAsync('attendance_records', (record) => {
      return Number(record.sessionId) === Number(sessionId) && Number(record.studentId) === Number(rosterItem.studentId);
    });
    const attendance = attendanceList.length > 0 ? attendanceList[0] : null;
    students.push({
      studentId: rosterItem.studentId,
      studentName: student ? student.name : '',
      studentNo: student ? student.studentNo : '',
      attendanceStatus: attendance ? attendance.status : 'NOT_SIGNED',
      signInTime: attendance ? attendance.signInTime : '',
      signOutTime: attendance ? attendance.signOutTime : ''
    });
  }
  return students;
}

function getAttendanceView(record) {
  const student = getStudent(record.studentId);
  const session = getSession(record.sessionId);
  const operator = record.operatorUserId ? getUser(record.operatorUserId) : null;
  return {
    ...record,
    operatorName: operator ? operator.realName : '',
    studentName: student ? student.name : '',
    studentNo: student ? student.studentNo : '',
    orderId: 0,
    sessionNo: session ? session.sessionNo : '',
    attendanceDate: record.attendanceDate || (session ? session.sessionDate : '')
  };
}

async function getAttendanceViewAsync(record) {
  const student = await getStudentAsync(record.studentId);
  const session = await getSessionAsync(record.sessionId);
  const operator = record.operatorUserId ? await getUserAsync(record.operatorUserId) : null;
  return {
    ...record,
    operatorName: operator ? operator.realName : '',
    studentName: student ? student.name : '',
    studentNo: student ? student.studentNo : '',
    orderId: 0,
    sessionNo: session ? session.sessionNo : '',
    attendanceDate: record.attendanceDate || (session ? session.sessionDate : '')
  };
}

function getHomeworkTaskView(task) {
  const student = getStudent(task.studentId);
  const session = task.sessionId ? getSession(task.sessionId) : null;
  const teacher = task.teacherId ? getUser(task.teacherId) : null;
  return {
    ...task,
    studentName: student ? student.name : '',
    sessionNo: session ? session.sessionNo : '',
    teacherName: teacher ? teacher.realName : ''
  };
}

async function getHomeworkTaskViewAsync(task) {
  const student = await getStudentAsync(task.studentId);
  const session = task.sessionId ? await getSessionAsync(task.sessionId) : null;
  const teacher = task.teacherId ? await getUserAsync(task.teacherId) : null;
  return {
    ...task,
    studentName: student ? student.name : '',
    sessionNo: session ? session.sessionNo : '',
    teacherName: teacher ? teacher.realName : ''
  };
}

function getHomeworkFeedbackView(feedback) {
  const task = store.findById('homework_tasks', feedback.taskId);
  const teacher = feedback.teacherId ? getUser(feedback.teacherId) : null;
  return {
    ...feedback,
    teacherName: teacher ? teacher.realName : feedback.teacherName,
    studentId: task ? task.studentId : feedback.studentId
  };
}

async function getHomeworkFeedbackViewAsync(feedback) {
  const task = await store.findByIdAsync('homework_tasks', feedback.taskId);
  const teacher = feedback.teacherId ? await getUserAsync(feedback.teacherId) : null;
  return {
    ...feedback,
    teacherName: teacher ? teacher.realName : feedback.teacherName,
    studentId: task ? task.studentId : feedback.studentId
  };
}

function getMessageDetailView(message) {
  const detail = {
    ...message
  };

  if (message.bizType === 'ATTENDANCE') {
    const attendance = store.findById('attendance_records', message.bizId);
    const student = attendance ? getStudent(attendance.studentId) : null;
    detail.relatedInfo = {
      studentName: student ? student.name : '',
      actionText: 'View attendance',
      actionUrl: '/parent/alerts'
    };
  } else if (message.bizType === 'HOMEWORK') {
    const task = store.findById('homework_tasks', message.bizId);
    const student = task ? getStudent(task.studentId) : null;
    detail.relatedInfo = {
      studentName: student ? student.name : '',
      actionText: 'View homework',
      actionUrl: '/parent/homework'
    };
  } else if (message.bizType === 'ORDER') {
    detail.relatedInfo = {
      studentName: '',
      actionText: 'View order',
      actionUrl: '/parent/orders'
    };
  }

  return detail;
}

async function getMessageDetailViewAsync(message) {
  const detail = {
    ...message
  };

  if (message.bizType === 'ATTENDANCE') {
    const attendance = await store.findByIdAsync('attendance_records', message.bizId);
    const student = attendance ? await getStudentAsync(attendance.studentId) : null;
    detail.relatedInfo = {
      studentName: student ? student.name : '',
      actionText: 'View attendance',
      actionUrl: '/parent/alerts'
    };
  } else if (message.bizType === 'HOMEWORK') {
    const task = await store.findByIdAsync('homework_tasks', message.bizId);
    const student = task ? await getStudentAsync(task.studentId) : null;
    detail.relatedInfo = {
      studentName: student ? student.name : '',
      actionText: 'View homework',
      actionUrl: '/parent/homework'
    };
  } else if (message.bizType === 'ORDER') {
    detail.relatedInfo = {
      studentName: '',
      actionText: 'View order',
      actionUrl: '/parent/orders'
    };
  }

  return detail;
}

function getRefundView(refund) {
  return {
    ...refund
  };
}

async function getRefundViewAsync(refund) {
  return {
    ...refund
  };
}

function buildMessageStatistics(userId) {
  const messages = store.filter('messages', (item) => Number(item.userId) === Number(userId));
  const byType = {};
  for (let i = 0; i < messages.length; i++) {
    const key = messages[i].msgType;
    byType[key] = (byType[key] || 0) + 1;
  }
  return {
    total: messages.length,
    unread: messages.filter((item) => !item.readStatus).length,
    byType
  };
}

async function buildMessageStatisticsAsync(userId) {
  const messages = await store.filterAsync('messages', (item) => Number(item.userId) === Number(userId));
  const byType = {};
  for (let i = 0; i < messages.length; i++) {
    const key = messages[i].msgType;
    byType[key] = (byType[key] || 0) + 1;
  }
  return {
    total: messages.length,
    unread: messages.filter((item) => !item.readStatus).length,
    byType
  };
}

function buildAlertStatistics() {
  const alerts = store.list('alerts');
  const byType = {};
  const bySeverity = {};
  for (let i = 0; i < alerts.length; i++) {
    const alert = alerts[i];
    byType[alert.alertType] = (byType[alert.alertType] || 0) + 1;
    bySeverity[alert.severity] = (bySeverity[alert.severity] || 0) + 1;
  }
  return {
    total: alerts.length,
    active: alerts.filter((item) => item.status === 'ACTIVE').length,
    acknowledged: alerts.filter((item) => item.status === 'ACKNOWLEDGED').length,
    resolved: alerts.filter((item) => item.status === 'RESOLVED').length,
    byType,
    bySeverity
  };
}

async function buildAlertStatisticsAsync() {
  const alerts = await store.listAsync('alerts');
  const byType = {};
  const bySeverity = {};
  for (let i = 0; i < alerts.length; i++) {
    const alert = alerts[i];
    byType[alert.alertType] = (byType[alert.alertType] || 0) + 1;
    bySeverity[alert.severity] = (bySeverity[alert.severity] || 0) + 1;
  }
  return {
    total: alerts.length,
    active: alerts.filter((item) => item.status === 'ACTIVE').length,
    acknowledged: alerts.filter((item) => item.status === 'ACKNOWLEDGED').length,
    resolved: alerts.filter((item) => item.status === 'RESOLVED').length,
    byType,
    bySeverity
  };
}

function buildRefundStatistics() {
  const refunds = store.list('refunds');
  return {
    total: refunds.length,
    pending: refunds.filter((item) => item.status === 'PENDING').length,
    processing: refunds.filter((item) => item.status === 'PROCESSING').length,
    completed: refunds.filter((item) => item.status === 'COMPLETED').length,
    totalAmount: refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0)
  };
}

async function buildRefundStatisticsAsync() {
  const refunds = await store.listAsync('refunds');
  return {
    total: refunds.length,
    pending: refunds.filter((item) => item.status === 'PENDING').length,
    processing: refunds.filter((item) => item.status === 'PROCESSING').length,
    completed: refunds.filter((item) => item.status === 'COMPLETED').length,
    totalAmount: refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0)
  };
}

function buildTodayStatusCard(studentId) {
  const targetStudent = getStudent(studentId);
  if (!targetStudent) {
    return null;
  }
  const date = todayDate();
  const sessions = store.filter('sessions', (session) => session.sessionDate === date);
  const sessionRoster = store.filter('session_students', (item) => Number(item.studentId) === Number(studentId));
  let matchedSession = null;
  for (let i = 0; i < sessionRoster.length; i++) {
    const session = sessions.find((candidate) => Number(candidate.id) === Number(sessionRoster[i].sessionId));
    if (session) {
      matchedSession = session;
      break;
    }
  }
  const attendance = store.filter('attendance_records', (record) => Number(record.studentId) === Number(studentId) && record.attendanceDate === date)[0];
  const homeworkList = store.filter('homework_tasks', (item) => Number(item.studentId) === Number(studentId) && item.taskDate === date);
  const messageCount = store.filter('messages', (item) => Number(item.userId) === Number(targetStudent.guardianUserId) && !item.readStatus).length;
  const feedback = store.filter('homework_feedback', (item) => Number(item.studentId) === Number(studentId))[0];
  const sessionView = matchedSession ? getSessionView(matchedSession) : null;

  return {
    date,
    studentId: targetStudent.id,
    studentName: targetStudent.name,
    sessionInfo: matchedSession ? {
      sessionId: matchedSession.id,
      sessionNo: matchedSession.sessionNo,
      sessionDate: matchedSession.sessionDate,
      startTime: matchedSession.startTime,
      endTime: matchedSession.endTime,
      teacherName: sessionView ? sessionView.teacherName : '',
      location: matchedSession.location
    } : undefined,
    attendanceStatus: attendance ? attendance.status : 'NOT_SIGNED',
    signInTime: attendance ? attendance.signInTime : '',
    signOutTime: attendance ? attendance.signOutTime : '',
    homeworkStatus: homeworkList.length > 0 ? homeworkList[0].status : 'PENDING',
    homeworkCount: homeworkList.length,
    completedHomework: homeworkList.filter((item) => item.status === 'COMPLETED' || item.status === 'CONFIRMED').length,
    messages: messageCount,
    sessionName: sessionView ? sessionView.serviceProductName : 'Today session',
    sessionTime: matchedSession ? `${matchedSession.startTime} - ${matchedSession.endTime}` : '',
    status: attendance ? attendance.status : 'NOT_SIGNED',
    latestDynamic: feedback ? feedback.feedbackContent : '',
    homeworkProgress: homeworkList.length > 0 ? Math.round((homeworkList.filter((item) => item.status !== 'PENDING').length / homeworkList.length) * 100) : 0,
    teacherFeedback: feedback ? feedback.feedbackContent : ''
  };
}

async function buildTodayStatusCardAsync(studentId) {
  const targetStudent = await getStudentAsync(studentId);
  if (!targetStudent) {
    return null;
  }
  const date = todayDate();
  const sessions = await store.filterAsync('sessions', (session) => session.sessionDate === date);
  const sessionRoster = await store.filterAsync('session_students', (item) => Number(item.studentId) === Number(studentId));
  let matchedSession = null;
  for (let i = 0; i < sessionRoster.length; i++) {
    const rosterItem = sessionRoster[i];
    const session = sessions.find((candidate) => Number(candidate.id) === Number(rosterItem.sessionId));
    if (session) {
      matchedSession = session;
      break;
    }
  }
  const attendanceList = await store.filterAsync('attendance_records', (record) => Number(record.studentId) === Number(studentId) && record.attendanceDate === date);
  const homeworkList = await store.filterAsync('homework_tasks', (item) => Number(item.studentId) === Number(studentId) && item.taskDate === date);
  const messages = await store.filterAsync('messages', (item) => Number(item.userId) === Number(targetStudent.guardianUserId) && !item.readStatus);
  const feedbackList = await store.filterAsync('homework_feedback', (item) => Number(item.studentId) === Number(studentId));
  const attendance = attendanceList.length > 0 ? attendanceList[0] : null;
  const feedback = feedbackList.length > 0 ? feedbackList[0] : null;
  const sessionView = matchedSession ? await getSessionViewAsync(matchedSession) : null;

  return {
    date,
    studentId: targetStudent.id,
    studentName: targetStudent.name,
    sessionInfo: matchedSession ? {
      sessionId: matchedSession.id,
      sessionNo: matchedSession.sessionNo,
      sessionDate: matchedSession.sessionDate,
      startTime: matchedSession.startTime,
      endTime: matchedSession.endTime,
      teacherName: sessionView ? sessionView.teacherName : '',
      location: matchedSession.location
    } : undefined,
    attendanceStatus: attendance ? attendance.status : 'NOT_SIGNED',
    signInTime: attendance ? attendance.signInTime : '',
    signOutTime: attendance ? attendance.signOutTime : '',
    homeworkStatus: homeworkList.length > 0 ? homeworkList[0].status : 'PENDING',
    homeworkCount: homeworkList.length,
    completedHomework: homeworkList.filter((item) => item.status === 'COMPLETED' || item.status === 'CONFIRMED').length,
    messages: messages.length,
    sessionName: sessionView ? sessionView.serviceProductName : 'Today session',
    sessionTime: matchedSession ? `${matchedSession.startTime} - ${matchedSession.endTime}` : '',
    status: attendance ? attendance.status : 'NOT_SIGNED',
    latestDynamic: feedback ? feedback.feedbackContent : '',
    homeworkProgress: homeworkList.length > 0 ? Math.round((homeworkList.filter((item) => item.status !== 'PENDING').length / homeworkList.length) * 100) : 0,
    teacherFeedback: feedback ? feedback.feedbackContent : ''
  };
}

function buildAbnormalAlertCard(studentId) {
  const alerts = store.filter('alerts', (item) => Number(item.studentId) === Number(studentId) && item.status === 'ACTIVE');
  if (alerts.length === 0) {
    return null;
  }
  const latest = alerts.sort((left, right) => right.createdAt.localeCompare(left.createdAt))[0];
  return {
    alertId: latest.id,
    studentId: latest.studentId,
    studentName: latest.studentName,
    alertType: latest.alertType === 'ATTENDANCE_ANOMALY' ? 'ATTENDANCE' : 'OTHER',
    alertLevel: latest.severity === 'HIGH' || latest.severity === 'CRITICAL' ? 'ERROR' : 'WARNING',
    alertTitle: latest.title,
    alertContent: latest.description,
    alertTime: latest.createdAt,
    isRead: latest.status !== 'ACTIVE',
    relatedData: {
      suggestedAction: latest.suggestedAction
    }
  };
}

async function buildAbnormalAlertCardAsync(studentId) {
  const alerts = await store.filterAsync('alerts', (item) => Number(item.studentId) === Number(studentId) && item.status === 'ACTIVE');
  if (alerts.length === 0) {
    return null;
  }
  const latest = alerts.sort((left, right) => right.createdAt.localeCompare(left.createdAt))[0];
  return {
    alertId: latest.id,
    studentId: latest.studentId,
    studentName: latest.studentName,
    alertType: latest.alertType === 'ATTENDANCE_ANOMALY' ? 'ATTENDANCE' : 'OTHER',
    alertLevel: latest.severity === 'HIGH' || latest.severity === 'CRITICAL' ? 'ERROR' : 'WARNING',
    alertTitle: latest.title,
    alertContent: latest.description,
    alertTime: latest.createdAt,
    isRead: latest.status !== 'ACTIVE',
    relatedData: {
      suggestedAction: latest.suggestedAction
    }
  };
}

function buildAttendanceReport(startDate, endDate) {
  const records = store.filter('attendance_records', (item) => {
    return (!startDate || item.attendanceDate >= startDate) && (!endDate || item.attendanceDate <= endDate);
  });
  const totalStudents = store.list('students').length;
  const presentCount = records.filter((item) => item.status === 'SIGNED_IN' || item.status === 'SIGNED_OUT').length;
  const absentCount = records.filter((item) => item.status === 'NOT_SIGNED' || item.status === 'ABSENT').length;
  const lateCount = records.filter((item) => item.status === 'LATE').length;
  const leaveCount = records.filter((item) => item.status === 'LEAVE').length;
  const rate = totalStudents === 0 ? 0 : Math.round((presentCount / totalStudents) * 100);
  const dailyBuckets = {};
  for (let i = 0; i < records.length; i++) {
    const key = records[i].attendanceDate;
    if (!dailyBuckets[key]) {
      dailyBuckets[key] = {
        date: key,
        presentCount: 0,
        absentCount: 0,
        lateCount: 0
      };
    }
    if (records[i].status === 'SIGNED_IN' || records[i].status === 'SIGNED_OUT') {
      dailyBuckets[key].presentCount += 1;
    } else if (records[i].status === 'LATE') {
      dailyBuckets[key].lateCount += 1;
    } else {
      dailyBuckets[key].absentCount += 1;
    }
  }
  return {
    totalStudents,
    presentCount,
    absentCount,
    lateCount,
    leaveCount,
    attendanceRate: rate,
    dailyStats: Object.values(dailyBuckets).sort((left, right) => left.date.localeCompare(right.date))
  };
}

async function buildAttendanceReportAsync(startDate, endDate) {
  const records = await store.filterAsync('attendance_records', (item) => {
    return (!startDate || item.attendanceDate >= startDate) && (!endDate || item.attendanceDate <= endDate);
  });
  const students = await store.listAsync('students');
  const totalStudents = students.length;
  const presentCount = records.filter((item) => item.status === 'SIGNED_IN' || item.status === 'SIGNED_OUT').length;
  const absentCount = records.filter((item) => item.status === 'NOT_SIGNED' || item.status === 'ABSENT').length;
  const lateCount = records.filter((item) => item.status === 'LATE').length;
  const leaveCount = records.filter((item) => item.status === 'LEAVE').length;
  const rate = totalStudents === 0 ? 0 : Math.round((presentCount / totalStudents) * 100);
  const dailyBuckets = {};
  for (let i = 0; i < records.length; i++) {
    const key = records[i].attendanceDate;
    if (!dailyBuckets[key]) {
      dailyBuckets[key] = {
        date: key,
        presentCount: 0,
        absentCount: 0,
        lateCount: 0
      };
    }
    if (records[i].status === 'SIGNED_IN' || records[i].status === 'SIGNED_OUT') {
      dailyBuckets[key].presentCount += 1;
    } else if (records[i].status === 'LATE') {
      dailyBuckets[key].lateCount += 1;
    } else {
      dailyBuckets[key].absentCount += 1;
    }
  }
  return {
    totalStudents,
    presentCount,
    absentCount,
    lateCount,
    leaveCount,
    attendanceRate: rate,
    dailyStats: Object.values(dailyBuckets).sort((left, right) => left.date.localeCompare(right.date))
  };
}

function buildAttendanceDailyStats(startDate, endDate) {
  const report = buildAttendanceReport(startDate, endDate);
  return report.dailyStats.map((item) => {
    const totalStudents = store.list('students').length;
    return {
      date: item.date,
      totalStudents,
      presentStudents: item.presentCount,
      absentStudents: item.absentCount,
      lateStudents: item.lateCount,
      leaveStudents: 0,
      attendanceRate: totalStudents === 0 ? 0 : Math.round((item.presentCount / totalStudents) * 100)
    };
  });
}

async function buildAttendanceDailyStatsAsync(startDate, endDate) {
  const report = await buildAttendanceReportAsync(startDate, endDate);
  return report.dailyStats.map((item) => {
    const totalStudents = report.totalStudents;
    return {
      date: item.date,
      totalStudents,
      presentStudents: item.presentCount,
      absentStudents: item.absentCount,
      lateStudents: item.lateCount,
      leaveStudents: 0,
      attendanceRate: totalStudents === 0 ? 0 : Math.round((item.presentCount / totalStudents) * 100)
    };
  });
}

function buildStudentAttendanceSummary(startDate, endDate) {
  const students = store.list('students');
  return students.map((student) => {
    const records = store.filter('attendance_records', (item) => {
      return Number(item.studentId) === Number(student.id) && (!startDate || item.attendanceDate >= startDate) && (!endDate || item.attendanceDate <= endDate);
    });
    const totalDays = records.length;
    const presentDays = records.filter((item) => item.status === 'SIGNED_IN' || item.status === 'SIGNED_OUT').length;
    const absentDays = records.filter((item) => item.status === 'NOT_SIGNED' || item.status === 'ABSENT').length;
    const lateDays = records.filter((item) => item.status === 'LATE').length;
    const leaveDays = records.filter((item) => item.status === 'LEAVE').length;
    return {
      studentId: student.id,
      studentName: student.name,
      studentNo: student.studentNo,
      totalDays,
      presentDays,
      absentDays,
      lateDays,
      leaveDays,
      attendanceRate: totalDays === 0 ? 0 : Math.round((presentDays / totalDays) * 100)
    };
  });
}

async function buildStudentAttendanceSummaryAsync(startDate, endDate) {
  const students = await store.listAsync('students');
  const summaries = [];
  for (let i = 0; i < students.length; i++) {
    const student = students[i];
    const records = await store.filterAsync('attendance_records', (item) => {
      return Number(item.studentId) === Number(student.id) && (!startDate || item.attendanceDate >= startDate) && (!endDate || item.attendanceDate <= endDate);
    });
    const totalDays = records.length;
    const presentDays = records.filter((item) => item.status === 'SIGNED_IN' || item.status === 'SIGNED_OUT').length;
    const absentDays = records.filter((item) => item.status === 'NOT_SIGNED' || item.status === 'ABSENT').length;
    const lateDays = records.filter((item) => item.status === 'LATE').length;
    const leaveDays = records.filter((item) => item.status === 'LEAVE').length;
    summaries.push({
      studentId: student.id,
      studentName: student.name,
      studentNo: student.studentNo,
      totalDays,
      presentDays,
      absentDays,
      lateDays,
      leaveDays,
      attendanceRate: totalDays === 0 ? 0 : Math.round((presentDays / totalDays) * 100)
    });
  }
  return summaries;
}

function buildFinanceReport(startDate, endDate) {
  const orders = store.filter('orders', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const refunds = store.filter('refunds', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const totalIncome = orders.reduce((sum, item) => sum + Number(item.paidAmount || 0), 0);
  const totalRefund = refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0);
  const dailyMap = {};
  for (let i = 0; i < orders.length; i++) {
    const key = orders[i].createdAt.slice(0, 10);
    if (!dailyMap[key]) {
      dailyMap[key] = { date: key, income: 0, refund: 0 };
    }
    dailyMap[key].income += Number(orders[i].paidAmount || 0);
  }
  for (let i = 0; i < refunds.length; i++) {
    const key = refunds[i].createdAt.slice(0, 10);
    if (!dailyMap[key]) {
      dailyMap[key] = { date: key, income: 0, refund: 0 };
    }
    dailyMap[key].refund += Number(refunds[i].refundAmount || 0);
  }
  return {
    totalIncome,
    totalRefund,
    netIncome: totalIncome - totalRefund,
    orderCount: orders.length,
    refundedOrderCount: refunds.length,
    dailyStats: Object.values(dailyMap).sort((left, right) => left.date.localeCompare(right.date))
  };
}

async function buildFinanceReportAsync(startDate, endDate) {
  const orders = await store.filterAsync('orders', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const refunds = await store.filterAsync('refunds', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const totalIncome = orders.reduce((sum, item) => sum + Number(item.paidAmount || 0), 0);
  const totalRefund = refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0);
  const dailyMap = {};
  for (let i = 0; i < orders.length; i++) {
    const key = orders[i].createdAt.slice(0, 10);
    if (!dailyMap[key]) {
      dailyMap[key] = { date: key, income: 0, refund: 0 };
    }
    dailyMap[key].income += Number(orders[i].paidAmount || 0);
  }
  for (let i = 0; i < refunds.length; i++) {
    const key = refunds[i].createdAt.slice(0, 10);
    if (!dailyMap[key]) {
      dailyMap[key] = { date: key, income: 0, refund: 0 };
    }
    dailyMap[key].refund += Number(refunds[i].refundAmount || 0);
  }
  return {
    totalIncome,
    totalRefund,
    netIncome: totalIncome - totalRefund,
    orderCount: orders.length,
    refundedOrderCount: refunds.length,
    dailyStats: Object.values(dailyMap).sort((left, right) => left.date.localeCompare(right.date))
  };
}

function buildDailyRevenueStats(startDate, endDate) {
  const finance = buildFinanceReport(startDate, endDate);
  return finance.dailyStats.map((item) => {
    return {
      date: item.date,
      orderCount: store.filter('orders', (order) => order.createdAt.slice(0, 10) === item.date).length,
      totalAmount: item.income,
      paidAmount: item.income,
      refundedAmount: item.refund
    };
  });
}

async function buildDailyRevenueStatsAsync(startDate, endDate) {
  const finance = await buildFinanceReportAsync(startDate, endDate);
  const orders = await store.listAsync('orders');
  return finance.dailyStats.map((item) => {
    return {
      date: item.date,
      orderCount: orders.filter((order) => order.createdAt.slice(0, 10) === item.date).length,
      totalAmount: item.income,
      paidAmount: item.income,
      refundedAmount: item.refund
    };
  });
}

function buildServiceProductRevenue(startDate, endDate) {
  const orders = store.filter('orders', (item) => {
    const date = item.createdAt.slice(0, 10);
    return (!startDate || date >= startDate) && (!endDate || date <= endDate);
  });
  const totalAmount = orders.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0);
  const services = store.list('service_products');
  return services.map((service) => {
    const related = orders.filter((item) => Number(item.serviceProductId) === Number(service.id));
    const amount = related.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0);
    return {
      serviceProductId: service.id,
      serviceName: service.serviceName,
      orderCount: related.length,
      totalAmount: amount,
      percentage: totalAmount === 0 ? 0 : Math.round((amount / totalAmount) * 100)
    };
  }).filter((item) => item.orderCount > 0);
}

async function buildServiceProductRevenueAsync(startDate, endDate) {
  const orders = await store.filterAsync('orders', (item) => {
    const date = item.createdAt.slice(0, 10);
    return (!startDate || date >= startDate) && (!endDate || date <= endDate);
  });
  const totalAmount = orders.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0);
  const services = await store.listAsync('service_products');
  return services.map((service) => {
    const related = orders.filter((item) => Number(item.serviceProductId) === Number(service.id));
    const amount = related.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0);
    return {
      serviceProductId: service.id,
      serviceName: service.serviceName,
      orderCount: related.length,
      totalAmount: amount,
      percentage: totalAmount === 0 ? 0 : Math.round((amount / totalAmount) * 100)
    };
  }).filter((item) => item.orderCount > 0);
}

function buildTeacherPerformance(startDate, endDate) {
  const teachers = store.filter('users', (item) => item.roleType === 'TEACHER');
  return teachers.map((teacher) => {
    const sessions = store.filter('sessions', (item) => {
      return Number(item.teacherUserId) === Number(teacher.id) && (!startDate || item.sessionDate >= startDate) && (!endDate || item.sessionDate <= endDate);
    });
    let totalStudents = 0;
    let attendanceRate = 0;
    for (let i = 0; i < sessions.length; i++) {
      const roster = getSessionStudents(sessions[i].id);
      totalStudents += roster.length;
      const signedCount = roster.filter((item) => item.attendanceStatus === 'SIGNED_IN' || item.attendanceStatus === 'SIGNED_OUT').length;
      attendanceRate += roster.length === 0 ? 0 : Math.round((signedCount / roster.length) * 100);
    }
    const tasks = store.filter('homework_tasks', (item) => Number(item.teacherId) === Number(teacher.id));
    const homeworkCompletedCount = tasks.filter((item) => item.status === 'COMPLETED' || item.status === 'CONFIRMED').length;
    return {
      teacherId: teacher.id,
      teacherName: teacher.realName,
      totalSessions: sessions.length,
      totalStudents,
      avgAttendanceRate: sessions.length === 0 ? 0 : Math.round(attendanceRate / sessions.length),
      homeworkCompletedCount,
      avgRating: 4.7
    };
  });
}

async function buildTeacherPerformanceAsync(startDate, endDate) {
  const teachers = await store.filterAsync('users', (item) => item.roleType === 'TEACHER');
  const performance = [];
  for (let i = 0; i < teachers.length; i++) {
    const teacher = teachers[i];
    const sessions = await store.filterAsync('sessions', (item) => {
      return Number(item.teacherUserId) === Number(teacher.id) && (!startDate || item.sessionDate >= startDate) && (!endDate || item.sessionDate <= endDate);
    });
    let totalStudents = 0;
    let attendanceRate = 0;
    for (let j = 0; j < sessions.length; j++) {
      const roster = await getSessionStudentsAsync(sessions[j].id);
      totalStudents += roster.length;
      const signedCount = roster.filter((item) => item.attendanceStatus === 'SIGNED_IN' || item.attendanceStatus === 'SIGNED_OUT').length;
      attendanceRate += roster.length === 0 ? 0 : Math.round((signedCount / roster.length) * 100);
    }
    const tasks = await store.filterAsync('homework_tasks', (item) => Number(item.teacherId) === Number(teacher.id));
    const homeworkCompletedCount = tasks.filter((item) => item.status === 'COMPLETED' || item.status === 'CONFIRMED').length;
    performance.push({
      teacherId: teacher.id,
      teacherName: teacher.realName,
      totalSessions: sessions.length,
      totalStudents,
      avgAttendanceRate: sessions.length === 0 ? 0 : Math.round(attendanceRate / sessions.length),
      homeworkCompletedCount,
      avgRating: 4.7
    });
  }
  return performance;
}

function buildWorkbench(roleType) {
  const manifests = store.filter('workbench_manifests', (item) => item.roleType === roleType && item.status === 'ACTIVE');
  return manifests.length > 0 ? manifests[0].payload : null;
}

async function buildWorkbenchAsync(roleType) {
  const manifests = await store.filterAsync('workbench_manifests', (item) => item.roleType === roleType && item.status === 'ACTIVE');
  return manifests.length > 0 ? manifests[0].payload : null;
}

function buildFinanceSummaryModel(startDate, endDate) {
  const orders = store.filter('orders', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const refunds = store.filter('refunds', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  return {
    reportMonth: formatMonth(endDate ? `${endDate}T00:00:00.000Z` : new Date().toISOString()),
    totalOrders: orders.length,
    totalAmount: orders.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0),
    paidAmount: orders.reduce((sum, item) => sum + Number(item.paidAmount || 0), 0),
    pendingAmount: orders.filter((item) => item.payStatus === 'UNPAID').reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0),
    refundedAmount: refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0),
    orderCount: orders.length,
    refundCount: refunds.length
  };
}

async function buildFinanceSummaryModelAsync(startDate, endDate) {
  const orders = await store.filterAsync('orders', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const refunds = await store.filterAsync('refunds', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  return {
    reportMonth: formatMonth(endDate ? `${endDate}T00:00:00.000Z` : new Date().toISOString()),
    totalOrders: orders.length,
    totalAmount: orders.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0),
    paidAmount: orders.reduce((sum, item) => sum + Number(item.paidAmount || 0), 0),
    pendingAmount: orders.filter((item) => item.payStatus === 'UNPAID').reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0),
    refundedAmount: refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0),
    orderCount: orders.length,
    refundCount: refunds.length
  };
}

module.exports = {
  getUser,
  getUserAsync,
  getStudent,
  getStudentAsync,
  getServiceProduct,
  getServiceProductAsync,
  getSession,
  getSessionAsync,
  getStudentView,
  getStudentViewAsync,
  getServiceProductView,
  getServiceProductViewAsync,
  getOrderView,
  getOrderViewAsync,
  getSessionView,
  getSessionViewAsync,
  getSessionStudents,
  getSessionStudentsAsync,
  getAttendanceView,
  getAttendanceViewAsync,
  getHomeworkTaskView,
  getHomeworkTaskViewAsync,
  getHomeworkFeedbackView,
  getHomeworkFeedbackViewAsync,
  getMessageDetailView,
  getMessageDetailViewAsync,
  getRefundView,
  getRefundViewAsync,
  buildMessageStatistics,
  buildMessageStatisticsAsync,
  buildAlertStatistics,
  buildAlertStatisticsAsync,
  buildRefundStatistics,
  buildRefundStatisticsAsync,
  buildTodayStatusCard,
  buildTodayStatusCardAsync,
  buildAbnormalAlertCard,
  buildAbnormalAlertCardAsync,
  buildAttendanceReport,
  buildAttendanceReportAsync,
  buildAttendanceDailyStats,
  buildAttendanceDailyStatsAsync,
  buildStudentAttendanceSummary,
  buildStudentAttendanceSummaryAsync,
  buildFinanceReport,
  buildFinanceReportAsync,
  buildFinanceSummaryModel,
  buildFinanceSummaryModelAsync,
  buildDailyRevenueStats,
  buildDailyRevenueStatsAsync,
  buildServiceProductRevenue,
  buildServiceProductRevenueAsync,
  buildTeacherPerformance,
  buildTeacherPerformanceAsync,
  buildWorkbench,
  buildWorkbenchAsync
};
