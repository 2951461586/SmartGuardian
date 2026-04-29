const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');

function includesFilter(value, expected) {
  if (!expected) {
    return true;
  }
  return String(value || '') === String(expected);
}

function isInTimeRange(value, startTime, endTime) {
  const current = String(value || '');
  if (startTime && current < startTime) {
    return false;
  }
  if (endTime && current > endTime) {
    return false;
  }
  return true;
}

function incrementCounter(map, key) {
  const resolvedKey = key || 'UNKNOWN';
  map[resolvedKey] = Number(map[resolvedKey] || 0) + 1;
}

function buildBucketList(map) {
  const keys = Object.keys(map).sort();
  const list = [];
  for (let i = 0; i < keys.length; i++) {
    list.push({
      key: keys[i],
      count: map[keys[i]]
    });
  }
  return list;
}

async function queryAuditEventsAsync(query) {
  const events = await store.filterAsync('security_audit_events', (event) => {
    if (!includesFilter(event.domain, query.domain)) {
      return false;
    }
    if (!includesFilter(event.eventType, query.eventType)) {
      return false;
    }
    if (!includesFilter(event.roleType, query.roleType)) {
      return false;
    }
    if (query.userId && Number(event.userId || 0) !== Number(query.userId)) {
      return false;
    }
    if (query.success !== undefined && query.success !== null && query.success !== '') {
      const expectedSuccess = String(query.success) === 'true';
      if (event.success !== expectedSuccess) {
        return false;
      }
    }
    return isInTimeRange(event.createdAt, query.startTime || '', query.endTime || '');
  });
  events.sort((left, right) => String(right.createdAt || '').localeCompare(String(left.createdAt || '')));
  return events;
}

function sanitizeAuditEvent(event) {
  return {
    id: event.id,
    eventType: event.eventType || '',
    domain: event.domain || '',
    functionName: event.functionName || '',
    routePath: event.routePath || '',
    requestPath: event.requestPath || '',
    method: event.method || '',
    userId: Number(event.userId || 0),
    roleType: event.roleType || '',
    resourceId: event.resourceId || '',
    statusCode: Number(event.statusCode || 0),
    success: event.success === true,
    requestId: event.requestId || '',
    message: event.message || '',
    createdAt: event.createdAt || ''
  };
}

function buildStatistics(events) {
  const byDomain = {};
  const byEventType = {};
  const byRoleType = {};
  let successCount = 0;
  let failureCount = 0;

  for (let i = 0; i < events.length; i++) {
    const event = events[i];
    incrementCounter(byDomain, event.domain);
    incrementCounter(byEventType, event.eventType);
    incrementCounter(byRoleType, event.roleType);
    if (event.success === true) {
      successCount += 1;
    } else {
      failureCount += 1;
    }
  }

  return {
    total: events.length,
    successCount,
    failureCount,
    byDomain: buildBucketList(byDomain),
    byEventType: buildBucketList(byEventType),
    byRoleType: buildBucketList(byRoleType)
  };
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/security/audit-events',
    roles: ['ADMIN'],
    audit: false,
    handler: async ({ query }) => {
      const events = await queryAuditEventsAsync(query);
      const pageResult = store.paginate(events.map(sanitizeAuditEvent), query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/security/audit-events/statistics',
    roles: ['ADMIN'],
    audit: false,
    handler: async ({ query }) => {
      const events = await queryAuditEventsAsync(query);
      return ok(buildStatistics(events));
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
