const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { processPendingEventsAsync } = require('../shared/events');
const { forbidden } = require('../shared/errors');

function assertConsumerSecret(request, body) {
  const expected = process.env.SMARTGUARDIAN_EVENT_CONSUMER_SECRET || '';
  if (expected.length === 0) {
    return;
  }
  const headers = request.headers || {};
  const actual = headers['x-smartguardian-event-secret'] || headers['X-SmartGuardian-Event-Secret'] || body.secret || '';
  if (actual !== expected) {
    throw forbidden('Invalid event consumer secret');
  }
}

function getTriggerConfig() {
  const expected = process.env.SMARTGUARDIAN_EVENT_CONSUMER_SECRET || '';
  return {
    triggerEndpoint: '/api/v1/events/trigger',
    consumerSecretConfigured: expected.length > 0,
    recommendedHeader: 'x-smartguardian-event-secret'
  };
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/events/trigger-config',
    roles: ['ADMIN'],
    handler: async () => {
      return ok(getTriggerConfig());
    }
  },
  {
    method: 'GET',
    path: '/api/v1/events/outbox',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      const rows = await store.filterAsync('domain_events', (item) => {
        if (query.status && item.status !== query.status) {
          return false;
        }
        if (query.eventType && item.eventType !== query.eventType) {
          return false;
        }
        if (query.studentId && Number(item.studentId || 0) !== Number(query.studentId)) {
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
    method: 'POST',
    path: '/api/v1/events/process',
    roles: ['ADMIN'],
    handler: async ({ body }) => {
      const processed = await processPendingEventsAsync(Number(body.limit || 20));
      return ok({
        processed: processed.length,
        events: processed
      }, 'events processed');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/events/trigger',
    auth: false,
    handler: async ({ request, body }) => {
      assertConsumerSecret(request, body);
      const processed = await processPendingEventsAsync(Number(body.limit || 20));
      return ok({
        processed: processed.length,
        events: processed
      }, 'event trigger processed');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
