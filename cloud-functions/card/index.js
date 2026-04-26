const contract = require('./contract.json');
const { createDomainHandler, ok } = require('../shared/router');
const { buildTodayStatusCardAsync, buildAbnormalAlertCardAsync } = require('../shared/read-models');
const { getScopedStudentIds, assertStudentAccess } = require('../shared/auth');

async function getStudentId(query, auth) {
  if (query.studentId) {
    const studentId = Number(query.studentId);
    await assertStudentAccess(auth.user, studentId);
    return studentId;
  }
  const scopedStudentIds = await getScopedStudentIds(auth.user);
  if (scopedStudentIds.length > 0) {
    return scopedStudentIds[0];
  }
  return 0;
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/cards/today-status',
    handler: async ({ query, auth }) => {
      const card = await buildTodayStatusCardAsync(await getStudentId(query, auth));
      return ok(card);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/cards/abnormal-alert',
    handler: async ({ query, auth }) => {
      const card = await buildAbnormalAlertCardAsync(await getStudentId(query, auth));
      return ok(card);
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
