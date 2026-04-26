function createError(code, message) {
  const error = new Error(message);
  error.code = code;
  return error;
}

function badRequest(message) {
  return createError(400, message);
}

function unauthorized(message) {
  return createError(401, message || 'Unauthorized');
}

function forbidden(message) {
  return createError(403, message || 'Forbidden');
}

function notFound(message) {
  return createError(404, message || 'Not found');
}

function conflict(message) {
  return createError(409, message || 'Conflict');
}

module.exports = {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict
};
