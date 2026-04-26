function normalizeEvent(event) {
  const source = event || {};
  const headers = source.headers || {};
  const requestContext = source.requestContext || {};
  const path = source.path || headers['X-SmartGuardian-Function-Route'] || '/';
  const method = source.httpMethod || requestContext.httpMethod || 'GET';
  const domain = headers['X-SmartGuardian-Function-Domain'] || 'gateway';
  const functionName = headers['X-SmartGuardian-Function-Name'] || 'smartguardian-gateway';
  const requestId = requestContext.requestId || headers['x-request-id'] || '';

  let parsedBody = source.body || null;
  if (typeof parsedBody === 'string' && parsedBody.length > 0) {
    try {
      parsedBody = JSON.parse(parsedBody);
    } catch (error) {
      parsedBody = null;
    }
  }

  return {
    path,
    method,
    headers,
    domain,
    functionName,
    requestId,
    body: parsedBody,
    queryStringParameters: source.queryStringParameters || {}
  };
}

module.exports = {
  normalizeEvent
};
