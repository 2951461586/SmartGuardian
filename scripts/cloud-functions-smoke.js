process.env.SMARTGUARDIAN_CLOUD_DB_PROVIDER = 'local';
process.env.SMARTGUARDIAN_LLM_DISABLED = 'true';

const manifest = require('../cloud-functions/function-manifest.json');
const store = require('../cloud-functions/shared/store');

const handlers = {
  auth: require('../cloud-functions/auth').handler,
  user: require('../cloud-functions/user').handler,
  student: require('../cloud-functions/student').handler,
  service: require('../cloud-functions/service').handler,
  order: require('../cloud-functions/order').handler,
  session: require('../cloud-functions/session').handler,
  attendance: require('../cloud-functions/attendance').handler,
  homework: require('../cloud-functions/homework').handler,
  message: require('../cloud-functions/message').handler,
  alert: require('../cloud-functions/alert').handler,
  report: require('../cloud-functions/report').handler,
  refund: require('../cloud-functions/refund').handler,
  timeline: require('../cloud-functions/timeline').handler,
  card: require('../cloud-functions/card').handler,
  payment: require('../cloud-functions/payment').handler,
  workbench: require('../cloud-functions/workbench').handler,
  agent: require('../cloud-functions/agent').handler,
  security: require('../cloud-functions/security').handler,
  event: require('../cloud-functions/event').handler,
  notification: require('../cloud-functions/notification').handler,
  storage: require('../cloud-functions/storage').handler
};

const coveredDomains = {};

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function assertPageResponse(response, label) {
  assert(response && response.data, `${label} should contain data`);
  assert(Array.isArray(response.data.list), `${label} should contain data.list`);
  assert(typeof response.data.total === 'number', `${label} should contain data.total`);
  assert(typeof response.data.pageNum === 'number', `${label} should contain data.pageNum`);
  assert(typeof response.data.pageSize === 'number', `${label} should contain data.pageSize`);
}

function assertArrayResponse(response, label) {
  assert(Array.isArray(response.data), `${label} should contain an array`);
}

function assertObjectKeys(response, keys, label) {
  assert(response && response.data, `${label} should contain data`);
  for (let i = 0; i < keys.length; i++) {
    assert(Object.prototype.hasOwnProperty.call(response.data, keys[i]), `${label} missing key '${keys[i]}'`);
  }
}

async function invoke(domain, method, routePath, options) {
  const handler = handlers[domain];
  const requestOptions = options || {};
  const headers = requestOptions.headers || {};
  if (requestOptions.token) {
    headers.Authorization = `Bearer ${requestOptions.token}`;
  }

  coveredDomains[domain] = true;
  return handler({
    path: routePath,
    httpMethod: method,
    headers,
    body: requestOptions.body || null,
    queryStringParameters: requestOptions.query || {}
  });
}

async function login(username, roleType) {
  const response = await invoke('auth', 'POST', '/api/v1/auth/login', {
    body: {
      username,
      password: '123456',
      roleType
    }
  });
  assert(response.code === 0, `login failed for ${username}`);
  assertObjectKeys(response, ['token', 'userInfo'], `login ${username}`);
  return response.data.token;
}

async function main() {
  const parentToken = await login('parent.demo', 'PARENT');
  const teacherToken = await login('teacher.demo', 'TEACHER');
  const adminToken = await login('admin.demo', 'ADMIN');

  const currentUser = await invoke('user', 'GET', '/api/v1/auth/me', { token: parentToken });
  assert(currentUser.code === 0, 'auth/me should succeed');
  assertObjectKeys(currentUser, ['id', 'roleType'], 'auth/me');

  const workbench = await invoke('workbench', 'GET', '/api/v1/workbench/manifest', { token: parentToken });
  assert(workbench.code === 0, 'workbench manifest should succeed');
  assertObjectKeys(workbench, ['roleType', 'modules'], 'workbench manifest');

  const users = await invoke('user', 'GET', '/api/v1/users', { token: adminToken });
  assert(users.code === 0, 'admin user list should succeed');
  assertArrayResponse(users, 'admin users');

  const students = await invoke('student', 'GET', '/api/v1/students', {
    token: parentToken,
    query: { pageNum: 1, pageSize: 10 }
  });
  assert(students.code === 0, 'student list should succeed');
  assertPageResponse(students, 'students');

  const serviceProducts = await invoke('service', 'GET', '/api/v1/service-products', { token: parentToken });
  assert(serviceProducts.code === 0, 'service list should succeed');
  assertArrayResponse(serviceProducts, 'service products');

  const orders = await invoke('order', 'GET', '/api/v1/orders', {
    token: parentToken,
    query: { pageNum: 1, pageSize: 10 }
  });
  assert(orders.code === 0, 'order list should succeed');
  assertPageResponse(orders, 'orders');

  const createdOrder = await invoke('order', 'POST', '/api/v1/orders', {
    token: parentToken,
    body: {
      studentId: 101,
      serviceProductId: 401,
      startDate: '2026-05-01',
      endDate: '2026-05-31'
    }
  });
  assert(createdOrder.code === 0, 'order create should succeed');
  assertObjectKeys(createdOrder, ['id', 'orderNo', 'studentName'], 'created order');

  const sessions = await invoke('session', 'GET', '/api/v1/sessions', { token: teacherToken });
  assert(sessions.code === 0, 'session list should succeed');
  assertArrayResponse(sessions, 'sessions');

  const todaySessions = await invoke('session', 'GET', '/api/v1/sessions/today', { token: teacherToken });
  assert(todaySessions.code === 0, 'today session list should succeed');
  assertArrayResponse(todaySessions, 'today sessions');

  const invalidSignIn = await invoke('attendance', 'POST', '/api/v1/attendance/sign-in', {
    token: teacherToken,
    body: {}
  });
  assert(invalidSignIn.code === 400, 'attendance validation should reject empty sign-in');

  const signIn = await invoke('attendance', 'POST', '/api/v1/attendance/sign-in', {
    token: teacherToken,
    body: {
      studentId: 102,
      sessionId: 801,
      signInType: 'NORMAL',
      signMethod: 'QR_CODE',
      location: 'North Gate'
    }
  });
  assert(signIn.code === 0, 'attendance sign-in should succeed');
  assertObjectKeys(signIn, ['studentId', 'sessionId', 'status'], 'attendance sign-in');

  const eventOutboxAfterSignIn = await invoke('event', 'GET', '/api/v1/events/outbox', {
    token: adminToken,
    query: { eventType: 'ATTENDANCE_SIGNED_IN', pageNum: 1, pageSize: 10 }
  });
  assert(eventOutboxAfterSignIn.code === 0, 'event outbox should succeed');
  assertPageResponse(eventOutboxAfterSignIn, 'event outbox');
  assert(eventOutboxAfterSignIn.data.total > 0, 'sign-in should create a domain event');

  const eventTriggerConfig = await invoke('event', 'GET', '/api/v1/events/trigger-config', {
    token: adminToken
  });
  assert(eventTriggerConfig.code === 0, 'event trigger config should succeed');
  assertObjectKeys(eventTriggerConfig, ['triggerEndpoint', 'consumerSecretConfigured', 'recommendedHeader'], 'event trigger config');

  const processEventsAfterSignIn = await invoke('event', 'POST', '/api/v1/events/process', {
    token: adminToken,
    body: { limit: 10 }
  });
  assert(processEventsAfterSignIn.code === 0, 'event process after sign-in should succeed');
  assertObjectKeys(processEventsAfterSignIn, ['processed', 'events'], 'event process after sign-in');
  assert(processEventsAfterSignIn.data.processed > 0, 'event consumer should process sign-in outbox');

  const notificationJobsAfterSignIn = await invoke('notification', 'GET', '/api/v1/notifications/jobs', {
    token: adminToken,
    query: { pageNum: 1, pageSize: 10 }
  });
  assert(notificationJobsAfterSignIn.code === 0, 'notification jobs should succeed');
  assertPageResponse(notificationJobsAfterSignIn, 'notification jobs');
  assert(notificationJobsAfterSignIn.data.total > 0, 'domain event should create notification jobs');

  const notificationDeliveryConfig = await invoke('notification', 'GET', '/api/v1/notifications/delivery-config', {
    token: adminToken
  });
  assert(notificationDeliveryConfig.code === 0, 'notification delivery config should succeed');
  assertObjectKeys(notificationDeliveryConfig, ['deliveryMode', 'huaweiPushConfigured', 'realDeliveryReady'], 'notification delivery config');

  const notificationProcessAfterSignIn = await invoke('notification', 'POST', '/api/v1/notifications/jobs/process', {
    token: adminToken,
    body: { limit: 10 }
  });
  assert(notificationProcessAfterSignIn.code === 0, 'notification job process should succeed');
  assertObjectKeys(notificationProcessAfterSignIn, ['processed', 'jobs'], 'notification job process');

  const attendanceStats = await invoke('attendance', 'GET', '/api/v1/attendance/statistics', {
    token: teacherToken,
    query: { attendanceDate: '2026-04-29' }
  });
  assert(attendanceStats.code === 0, 'attendance statistics should succeed');
  assertObjectKeys(attendanceStats, ['total', 'signedIn', 'signedOut', 'absent', 'late', 'abnormal', 'leavePending'], 'attendance statistics');

  const leave = await invoke('attendance', 'POST', '/api/v1/attendance/leave', {
    token: parentToken,
    body: {
      studentId: 101,
      leaveDate: '2026-05-06',
      leaveType: 'PERSONAL',
      reason: 'Cloud function smoke test'
    }
  });
  assert(leave.code === 0, 'leave submit should succeed');
  assertObjectKeys(leave, ['id', 'studentId', 'status'], 'leave submit');

  const leaveList = await invoke('attendance', 'GET', '/api/v1/attendance/leave', {
    token: parentToken,
    query: { studentId: 101, pageNum: 1, pageSize: 10 }
  });
  assert(leaveList.code === 0, 'leave list should succeed');
  assertPageResponse(leaveList, 'leave list');

  const leaveCancel = await invoke('attendance', 'POST', `/api/v1/attendance/leave/${leave.data.id}/cancel`, {
    token: parentToken
  });
  assert(leaveCancel.code === 0, 'leave cancel should succeed');
  assertObjectKeys(leaveCancel, ['id', 'status'], 'leave cancel');

  const homeworkTasks = await invoke('homework', 'GET', '/api/v1/homework/tasks', {
    token: parentToken,
    query: { pageNum: 1, pageSize: 10 }
  });
  assert(homeworkTasks.code === 0, 'homework list should succeed');
  assertPageResponse(homeworkTasks, 'homework tasks');

  const unreadCount = await invoke('message', 'GET', '/api/v1/messages/unread-count', { token: parentToken });
  assert(unreadCount.code === 0, 'message unread count should succeed');
  assertObjectKeys(unreadCount, ['count'], 'message unread count');

  const broadcast = await invoke('message', 'POST', '/api/v1/messages', {
    token: teacherToken,
    body: {
      userId: 0,
      msgType: 'SYSTEM',
      title: 'Smoke Broadcast',
      content: 'Cloud function smoke test'
    }
  });
  assert(broadcast.code === 0, 'message broadcast should succeed');
  assertObjectKeys(broadcast, ['id', 'userId', 'msgType'], 'message broadcast');

  const activeCount = await invoke('alert', 'GET', '/api/v1/alerts/active-count', { token: parentToken });
  assert(activeCount.code === 0, 'alert active count should succeed');
  assertObjectKeys(activeCount, ['count'], 'alert active count');

  const acknowledgedAlert = await invoke('alert', 'POST', '/api/v1/alerts/1601/acknowledge', {
    token: teacherToken,
    body: { note: 'Smoke acknowledged' }
  });
  assert(acknowledgedAlert.code === 0, 'alert acknowledge should succeed');
  assertObjectKeys(acknowledgedAlert, ['id', 'status'], 'alert acknowledge');

  const forbiddenReport = await invoke('report', 'GET', '/api/v1/reports/attendance', {
    token: parentToken,
    query: { startDate: '2026-04-01', endDate: '2026-04-30' }
  });
  assert(forbiddenReport.code === 403, 'parent should be forbidden from reports');

  const report = await invoke('report', 'GET', '/api/v1/reports/attendance', {
    token: adminToken,
    query: { startDate: '2026-04-01', endDate: '2026-04-30' }
  });
  assert(report.code === 0, 'admin attendance report should succeed');
  assertObjectKeys(report, ['totalStudents', 'attendanceRate', 'dailyStats'], 'attendance report');

  const refundCalc = await invoke('refund', 'GET', '/api/v1/refunds/calculate', {
    token: parentToken,
    query: { orderId: 501 }
  });
  assert(refundCalc.code === 0, 'refund calculation should succeed');
  assertObjectKeys(refundCalc, ['refundable', 'refundAmount', 'deduction'], 'refund calculation');

  const timeline = await invoke('timeline', 'GET', '/api/v1/timeline/students/101', { token: parentToken });
  assert(timeline.code === 0, 'timeline should succeed');
  assertArrayResponse(timeline, 'timeline');

  const todayStatus = await invoke('card', 'GET', '/api/v1/cards/today-status', { token: parentToken });
  assert(todayStatus.code === 0, 'today status card should succeed');
  assertObjectKeys(todayStatus, ['studentId', 'studentName', 'attendanceStatus'], 'today status card');

  const cardConsistency = await invoke('card', 'GET', '/api/v1/cards/consistency', {
    token: parentToken,
    query: { refresh: 'true' }
  });
  assert(cardConsistency.code === 0, 'card consistency should succeed');
  assertObjectKeys(cardConsistency, ['studentId', 'checkedAt', 'consistent', 'todayStatus', 'abnormalAlert'], 'card consistency');
  assert(cardConsistency.data.consistent === true, 'form card cache should match fresh cloud read model');

  const cardRefresh = await invoke('card', 'POST', '/api/v1/cards/refresh', {
    token: parentToken,
    body: {}
  });
  assert(cardRefresh.code === 0, 'card refresh should succeed');
  assert(cardRefresh.data.consistent === true, 'refreshed form card cache should stay consistent');

  const cardRows = store.filter('form_cards', (item) => item.cardType === 'TODAY_STATUS' && Number(item.studentId || 0) > 0);
  assert(cardRows.length > 0, 'today status form card cache should be refreshed');

  const payment = await invoke('payment', 'POST', '/api/v1/payments', {
    token: parentToken,
    body: {
      orderId: createdOrder.data.id,
      payChannel: 'WECHAT',
      payAmount: createdOrder.data.actualAmount || createdOrder.data.amount
    }
  });
  assert(payment.code === 0, 'payment creation should succeed');
  assertObjectKeys(payment, ['id', 'paymentNo', 'payStatus'], 'payment creation');

  const callback = await invoke('payment', 'POST', '/api/v1/payments/callback', {
    body: {
      paymentNo: payment.data.paymentNo,
      tradeStatus: 'SUCCESS',
      thirdTradeNo: 'SMOKE-TRADE-001',
      payTime: '2026-04-26T08:00:00.000Z',
      rawPayload: '{}'
    }
  });
  assert(callback.code === 0, 'payment callback should succeed');

  const agentChat = await invoke('agent', 'POST', '/api/v1/agent/chat', {
    token: parentToken,
    body: {
      message: '今天孩子托管情况怎么样？',
      studentId: 101,
      date: '2026-04-25'
    }
  });
  assert(agentChat.code === 0, 'agent chat should succeed');
  assertObjectKeys(agentChat, ['agentId', 'answer', 'summary', 'actions', 'suggestions', 'citations'], 'agent chat');
  assert(agentChat.data.source === 'LOCAL_RULES' || agentChat.data.source === 'LLM', 'agent source should be known');

  const agentSummary = await invoke('agent', 'POST', '/api/v1/agent/summary', {
    token: teacherToken,
    body: {
      date: '2026-04-25'
    }
  });
  assert(agentSummary.code === 0, 'agent summary should succeed');
  assertObjectKeys(agentSummary, ['agentId', 'answer', 'summary'], 'agent summary');

  const agentNavigation = await invoke('agent', 'POST', '/api/v1/agent/navigation', {
    token: adminToken,
    body: {
      message: '打开运营报表'
    }
  });
  assert(agentNavigation.code === 0, 'agent navigation should succeed');
  assertObjectKeys(agentNavigation, ['agentId', 'answer', 'actions'], 'agent navigation');
  assert(agentNavigation.data.actions.length > 0, 'agent navigation should include an action');

  const notificationPreferences = await invoke('notification', 'GET', '/api/v1/notifications/preferences', {
    token: parentToken
  });
  assert(notificationPreferences.code === 0, 'notification preferences should succeed');
  assertObjectKeys(notificationPreferences, ['userId', 'enabled', 'channels'], 'notification preferences');

  const notificationPreferencesUpdate = await invoke('notification', 'PUT', '/api/v1/notifications/preferences', {
    token: parentToken,
    body: {
      enabled: true,
      quietStartTime: '22:00',
      quietEndTime: '07:00',
      channels: ['PUSH', 'IN_APP']
    }
  });
  assert(notificationPreferencesUpdate.code === 0, 'notification preferences update should succeed');
  assertObjectKeys(notificationPreferencesUpdate, ['userId', 'enabled', 'quietStartTime'], 'notification preferences update');

  const attachmentRegistration = await invoke('storage', 'POST', '/api/v1/storage/attachments', {
    token: parentToken,
    body: {
      fileName: 'homework-feedback.jpg',
      contentType: 'image/jpeg',
      fileSize: 1024,
      bizType: 'HOMEWORK',
      bizId: 1201,
      studentId: 101
    }
  });
  assert(attachmentRegistration.code === 0, 'attachment registration should succeed');
  assertObjectKeys(attachmentRegistration, ['attachment', 'uploadPolicy'], 'attachment registration');

  const storageConfig = await invoke('storage', 'GET', '/api/v1/storage/config', {
    token: adminToken
  });
  assert(storageConfig.code === 0, 'storage config should succeed');
  assertObjectKeys(storageConfig, ['provider', 'defaultBucketConfigured', 'uploadMethod'], 'storage config');

  const attachmentComplete = await invoke('storage', 'POST', `/api/v1/storage/attachments/${attachmentRegistration.data.attachment.id}/complete`, {
    token: parentToken,
    body: {
      downloadUrl: 'agc://smartguardian/HOMEWORK/1201/homework-feedback.jpg',
      checksum: 'smoke-checksum'
    }
  });
  assert(attachmentComplete.code === 0, 'attachment completion should succeed');
  assertObjectKeys(attachmentComplete, ['id', 'status', 'storagePath'], 'attachment completion');

  const attachmentList = await invoke('storage', 'GET', '/api/v1/storage/attachments', {
    token: parentToken,
    query: { bizType: 'HOMEWORK', pageNum: 1, pageSize: 10 }
  });
  assert(attachmentList.code === 0, 'attachment list should succeed');
  assertPageResponse(attachmentList, 'attachment list');

  const processEvents = await invoke('event', 'POST', '/api/v1/events/process', {
    token: adminToken,
    body: { limit: 5 }
  });
  assert(processEvents.code === 0, 'event process should succeed');
  assertObjectKeys(processEvents, ['processed', 'events'], 'event process');

  const previousEventSecret = process.env.SMARTGUARDIAN_EVENT_CONSUMER_SECRET || '';
  process.env.SMARTGUARDIAN_EVENT_CONSUMER_SECRET = 'smoke-event-secret';
  const rejectedTriggerEvents = await invoke('event', 'POST', '/api/v1/events/trigger', {
    body: { limit: 5 }
  });
  assert(rejectedTriggerEvents.code === 403, 'event trigger should reject missing consumer secret');
  const triggerEvents = await invoke('event', 'POST', '/api/v1/events/trigger', {
    body: { limit: 5 },
    headers: {
      'x-smartguardian-event-secret': 'smoke-event-secret'
    }
  });
  if (previousEventSecret.length > 0) {
    process.env.SMARTGUARDIAN_EVENT_CONSUMER_SECRET = previousEventSecret;
  } else {
    delete process.env.SMARTGUARDIAN_EVENT_CONSUMER_SECRET;
  }
  assert(triggerEvents.code === 0, 'event trigger should succeed with consumer secret');
  assertObjectKeys(triggerEvents, ['processed', 'events'], 'event trigger');

  const logout = await invoke('auth', 'POST', '/api/v1/auth/logout', { token: parentToken });
  assert(logout.code === 0, 'logout should succeed');

  const auditEvents = store.list('security_audit_events');
  assert(auditEvents.length > 0, 'security audit events should be recorded');
  const agentAudit = auditEvents.find((event) => event.domain === 'agent' && event.requestPath === '/api/v1/agent/chat');
  assert(agentAudit && agentAudit.success === true, 'agent chat audit event should be recorded');
  const forbiddenAudit = auditEvents.find((event) => event.domain === 'report' && event.statusCode === 403);
  assert(forbiddenAudit && forbiddenAudit.success === false, 'forbidden report audit event should be recorded');

  const auditList = await invoke('security', 'GET', '/api/v1/security/audit-events', {
    token: adminToken,
    query: { pageNum: 1, pageSize: 10 }
  });
  assert(auditList.code === 0, 'security audit list should succeed');
  assertPageResponse(auditList, 'security audit list');

  const auditStatistics = await invoke('security', 'GET', '/api/v1/security/audit-events/statistics', {
    token: adminToken
  });
  assert(auditStatistics.code === 0, 'security audit statistics should succeed');
  assertObjectKeys(auditStatistics, ['total', 'successCount', 'failureCount', 'byDomain'], 'security audit statistics');

  const manifestDomains = manifest.functions.map((item) => item.domain).sort();
  const coveredNames = Object.keys(coveredDomains).sort();
  for (let i = 0; i < manifestDomains.length; i++) {
    assert(coveredDomains[manifestDomains[i]] === true, `smoke did not cover domain '${manifestDomains[i]}'`);
  }

  console.log('Cloud functions smoke passed.');
  console.log(`Covered domains: ${coveredNames.join(', ')}`);
}

main().catch((error) => {
  console.error(error && error.stack ? error.stack : String(error));
  process.exit(1);
}).then(() => {
  process.exit(0);
});
