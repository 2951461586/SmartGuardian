const store = require('../store');

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
  getOrderViewAsync
};
