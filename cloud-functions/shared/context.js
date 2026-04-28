function normalizeEvent(event) {
  const source = event || {};
  let parsedBody = source.body || null;
  if (typeof parsedBody === 'string' && parsedBody.length > 0) {
    try {
      parsedBody = JSON.parse(parsedBody);
    } catch (error) {
      parsedBody = null;
    }
  }

  const forwarded = parsedBody && typeof parsedBody === 'object' && (parsedBody.path || parsedBody.httpMethod) ? parsedBody : null;
  const headers = forwarded ? (forwarded.headers || source.headers || {}) : (source.headers || {});
  const requestContext = forwarded ? (forwarded.requestContext || source.requestContext || {}) : (source.requestContext || {});
  const path = headers['X-SmartGuardian-Function-Route'] || (forwarded ? forwarded.path : source.path) || '/';
  const method = (forwarded ? forwarded.httpMethod : source.httpMethod) || requestContext.httpMethod || 'GET';
  const domain = headers['X-SmartGuardian-Function-Domain'] || 'gateway';
  const functionName = headers['X-SmartGuardian-Function-Name'] || 'smartguardian-gateway';
  const requestId = requestContext.requestId || headers['x-request-id'] || '';

  let requestBody = parsedBody;
  if (forwarded) {
    requestBody = forwarded.body || null;
    if (typeof requestBody === 'string' && requestBody.length > 0) {
      try {
        requestBody = JSON.parse(requestBody);
      } catch (error) {
        requestBody = null;
      }
    }
  }

  return {
    path,
    method,
    headers,
    domain,
    functionName,
    requestId,
    body: requestBody,
    queryStringParameters: forwarded ? (forwarded.queryStringParameters || {}) : (source.queryStringParameters || {})
  };
}

module.exports = {
  normalizeEvent
};
