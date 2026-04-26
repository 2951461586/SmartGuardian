const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok } = require('../shared/router');
const { assertStudentAccess } = require('../shared/auth');

const routes = [
  {
    method: 'GET',
    path: '/api/v1/timeline/students/:studentId',
    handler: async ({ params, query, auth }) => {
      const studentId = Number(params.studentId);
      await assertStudentAccess(auth.user, studentId);
      const items = await store.filterAsync('student_timelines', (item) => {
        if (Number(item.studentId) !== studentId) {
          return false;
        }
        if (query.timelineType && item.timelineType !== query.timelineType) {
          return false;
        }
        if (query.bizDate && item.bizDate !== query.bizDate) {
          return false;
        }
        return true;
      });
      items.sort((left, right) => right.timestamp.localeCompare(left.timestamp));
      return ok(items);
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
