const store = require('./store');
const { nowIso } = require('./time');

function getHeader(headers, name) {
  const keys = Object.keys(headers || {});
  const expected = name.toLowerCase();
  for (let i = 0; i < keys.length; i++) {
    if (keys[i].toLowerCase() === expected) {
      return headers[keys[i]];
    }
  }
  return '';
}

function resolveResourceId(params) {
  const keys = Object.keys(params || {});
  for (let i = 0; i < keys.length; i++) {
    const value = params[keys[i]];
    if (value !== undefined && value !== null && value !== '') {
      return String(value);
    }
  }
  return '';
}

function shouldAuditRoute(route, request, result) {
  if (route && route.audit === false) {
    return false;
  }
  if (route && route.audit === true) {
    return true;
  }
  if (request.method !== 'GET') {
    return true;
  }
  return result && typeof result.code === 'number' && result.code !== 0;
}

async function recordAuditEventAsync(options) {
  const route = options.route || {};
  const request = options.request || {};
  const result = options.result || {};
  if (!shouldAuditRoute(route, request, result)) {
    return;
  }

  const auth = options.auth || null;
  const user = auth ? auth.user : null;
  const now = nowIso();
  try {
    await store.insertAsync('security_audit_events', {
      eventType: result.code === 0 ? 'ACCESS' : 'ERROR',
      domain: options.contract ? options.contract.domain : request.domain,
      functionName: request.functionName || '',
      routePath: route.path || '',
      requestPath: request.path || '',
      method: request.method || '',
      userId: user ? Number(user.id) : 0,
      roleType: user ? user.roleType : '',
      resourceId: resolveResourceId(options.params),
      statusCode: Number(result.code || 0),
      success: result.code === 0,
      requestId: request.requestId || getHeader(request.headers, 'x-request-id'),
      clientIp: getHeader(request.headers, 'x-forwarded-for'),
      userAgent: getHeader(request.headers, 'user-agent'),
      message: result.message || '',
      createdAt: now,
      updatedAt: now
    });
  } catch (error) {
    // Audit failure must not break the business response.
  }
}

module.exports = {
  recordAuditEventAsync
};
