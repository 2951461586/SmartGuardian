const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { nowIso } = require('../shared/time');
const { getPushDeliveryConfig, processPendingNotificationJobsAsync } = require('../shared/push');

function asNumber(value) {
  const numberValue = Number(value || 0);
  return Number.isNaN(numberValue) ? 0 : numberValue;
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/notifications/delivery-config',
    roles: ['ADMIN'],
    handler: async () => {
      return ok(getPushDeliveryConfig());
    }
  },
  {
    method: 'GET',
    path: '/api/v1/notifications/jobs',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      const rows = await store.filterAsync('notification_jobs', (item) => {
        if (query.status && item.status !== query.status) {
          return false;
        }
        if (query.userId && asNumber(item.userId) !== asNumber(query.userId)) {
          return false;
        }
        return true;
      });
      rows.sort((left, right) => String(right.createdAt || '').localeCompare(String(left.createdAt || '')));
      const pageResult = store.paginate(rows, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/notifications/receipts',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      const rows = await store.filterAsync('notification_delivery_receipts', (item) => {
        if (query.jobId && asNumber(item.jobId) !== asNumber(query.jobId)) {
          return false;
        }
        if (query.status && item.status !== query.status) {
          return false;
        }
        return true;
      });
      const pageResult = store.paginate(rows, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/notifications/preferences',
    handler: async ({ auth }) => {
      const rows = await store.filterAsync('user_notification_preferences', (item) => asNumber(item.userId) === asNumber(auth.user.id));
      if (rows.length > 0) {
        return ok(rows[0]);
      }
      return ok({
        userId: auth.user.id,
        enabled: true,
        quietStartTime: '',
        quietEndTime: '',
        channels: ['PUSH', 'IN_APP']
      });
    }
  },
  {
    method: 'PUT',
    path: '/api/v1/notifications/preferences',
    handler: async ({ body, auth }) => {
      const now = nowIso();
      const rows = await store.filterAsync('user_notification_preferences', (item) => asNumber(item.userId) === asNumber(auth.user.id));
      const patch = {
        userId: auth.user.id,
        enabled: body.enabled !== false,
        quietStartTime: body.quietStartTime || '',
        quietEndTime: body.quietEndTime || '',
        channels: body.channels || ['PUSH', 'IN_APP'],
        createdAt: now,
        updatedAt: now
      };
      if (rows.length > 0) {
        return ok(await store.updateAsync('user_notification_preferences', rows[0].id, {
          enabled: patch.enabled,
          quietStartTime: patch.quietStartTime,
          quietEndTime: patch.quietEndTime,
          channels: patch.channels,
          updatedAt: now
        }), 'notification preferences updated');
      }
      return ok(await store.insertAsync('user_notification_preferences', patch), 'notification preferences created');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/notifications/jobs/process',
    roles: ['ADMIN'],
    handler: async ({ body }) => {
      const limit = Number(body.limit || 20);
      const results = await processPendingNotificationJobsAsync(limit);
      return ok({
        processed: results.length,
        jobs: results
      }, 'notification jobs processed');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/notifications/jobs/:jobId/retry',
    roles: ['ADMIN'],
    handler: async ({ params }) => {
      const now = nowIso();
      const job = await store.updateAsync('notification_jobs', Number(params.jobId), {
        status: 'PENDING',
        nextRetryAt: '',
        lastError: '',
        updatedAt: now
      });
      return ok(job, 'notification retry scheduled');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
