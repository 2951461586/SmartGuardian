process.env.SMARTGUARDIAN_CLOUD_DB_PROVIDER = 'local';

const manifest = require('../cloud-functions/function-manifest.json');

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
  workbench: require('../cloud-functions/workbench').handler
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
  const headers = {};
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

  const logout = await invoke('auth', 'POST', '/api/v1/auth/logout', { token: parentToken });
  assert(logout.code === 0, 'logout should succeed');

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
