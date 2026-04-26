const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { buildAlertStatisticsAsync } = require('../shared/read-models');
const { nowIso } = require('../shared/time');
const { notFound } = require('../shared/errors');
const { filterAttendanceForUser } = require('../shared/auth');

async function addAlertAction(alertId, actionType, operatorId, note) {
  await store.insertAsync('alert_actions', {
    alertId,
    actionType,
    operatorId,
    note: note || '',
    createdAt: nowIso(),
    updatedAt: nowIso()
  });
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/alerts',
    handler: async ({ query, auth }) => {
      const items = await store.filterAsync('alerts', (item) => {
        if (query.studentId && Number(item.studentId) !== Number(query.studentId)) {
          return false;
        }
        if (query.alertType && item.alertType !== query.alertType) {
          return false;
        }
        if (query.severity && item.severity !== query.severity) {
          return false;
        }
        if (query.status && item.status !== query.status) {
          return false;
        }
        return true;
      });
      const scopedAlerts = await filterAttendanceForUser(auth.user, items);
      scopedAlerts.sort((left, right) => right.createdAt.localeCompare(left.createdAt));
      const pageResult = store.paginate(scopedAlerts, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/alerts/active-count',
    handler: async ({ auth }) => {
      const alerts = await store.filterAsync('alerts', (item) => item.status === 'ACTIVE');
      const scopedAlerts = await filterAttendanceForUser(auth.user, alerts);
      return ok({ count: scopedAlerts.length });
    }
  },
  {
    method: 'GET',
    path: '/api/v1/alerts/statistics',
    roles: ['TEACHER', 'ADMIN'],
    handler: async () => {
      return ok(await buildAlertStatisticsAsync());
    }
  },
  {
    method: 'GET',
    path: '/api/v1/alerts/:alertId',
    handler: async ({ params, auth }) => {
      const alert = await store.findByIdAsync('alerts', Number(params.alertId));
      if (!alert) {
        throw notFound('Alert not found');
      }
      const scopedAlerts = await filterAttendanceForUser(auth.user, [alert]);
      if (scopedAlerts.length === 0) {
        throw notFound('Alert not found');
      }
      return ok(alert);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/alerts/:alertId/acknowledge',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ params, body, auth }) => {
      const alertId = Number(params.alertId);
      const alert = await store.findByIdAsync('alerts', alertId);
      if (!alert) {
        throw notFound('Alert not found');
      }
      const updated = await store.updateAsync('alerts', alertId, {
        status: 'ACKNOWLEDGED',
        acknowledgedBy: auth.user.id,
        acknowledgedAt: nowIso(),
        updatedAt: nowIso()
      });
      await addAlertAction(alertId, 'ACKNOWLEDGE', auth.user.id, body.note || '');
      return ok(updated, 'alert acknowledged');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/alerts/:alertId/resolve',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ params, body, auth }) => {
      const alertId = Number(params.alertId);
      const alert = await store.findByIdAsync('alerts', alertId);
      if (!alert) {
        throw notFound('Alert not found');
      }
      const updated = await store.updateAsync('alerts', alertId, {
        status: 'RESOLVED',
        resolvedBy: auth.user.id,
        resolvedAt: nowIso(),
        resolution: body.resolution || '',
        updatedAt: nowIso()
      });
      await addAlertAction(alertId, 'RESOLVE', auth.user.id, body.resolution || '');
      return ok(updated, 'alert resolved');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/alerts/:alertId/dismiss',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ params, auth }) => {
      const alertId = Number(params.alertId);
      const alert = await store.findByIdAsync('alerts', alertId);
      if (!alert) {
        throw notFound('Alert not found');
      }
      const updated = await store.updateAsync('alerts', alertId, {
        status: 'DISMISSED',
        updatedAt: nowIso()
      });
      await addAlertAction(alertId, 'DISMISS', auth.user.id, 'dismissed');
      return ok(updated, 'alert dismissed');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
