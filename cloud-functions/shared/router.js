const { normalizeEvent } = require('./context');
const { requireUser, assertRole } = require('./auth');
const { badRequest } = require('./errors');

function ok(data, message) {
  return {
    code: 0,
    message: message || 'ok',
    data
  };
}

function detail(data, message) {
  return ok(data, message || 'detail success');
}

function command(data, message) {
  return ok(data === undefined ? null : data, message || 'command success');
}

function fail(code, message) {
  return {
    code,
    message,
    data: null
  };
}

function resolveHttpStatus(result) {
  if (!result || typeof result.code !== 'number' || result.code === 0) {
    return '200';
  }
  if (result.code === 401 || result.code === 403 || result.code === 404) {
    return String(result.code);
  }
  if (result.code >= 400 && result.code < 600) {
    return String(result.code);
  }
  return '500';
}

function emitAgcResult(context, callback, result) {
  if (context && typeof context.HTTPResponse === 'function' && typeof context.callback === 'function') {
    const response = new context.HTTPResponse(context.env, {
      'faas-content-type': 'json'
    }, 'application/json', resolveHttpStatus(result));
    response.body = result;
    context.callback(response);
    return;
  }

  if (context && typeof context.callback === 'function') {
    context.callback(result);
    return;
  }

  if (typeof callback === 'function') {
    callback(result);
  }
}

function page(list, total, pageNum, pageSize) {
  return ok({
    list,
    total,
    pageNum,
    pageSize
  });
}

function splitPath(path) {
  return path.split('/').filter(Boolean);
}

function matchRoute(pattern, actualPath) {
  const patternParts = splitPath(pattern);
  const actualParts = splitPath(actualPath);
  if (patternParts.length !== actualParts.length) {
    return null;
  }

  const params = {};
  for (let i = 0; i < patternParts.length; i++) {
    const patternPart = patternParts[i];
    const actualPart = actualParts[i];
    if (patternPart.indexOf(':') === 0) {
      params[patternPart.slice(1)] = actualPart;
      continue;
    }
    if (patternPart !== actualPart) {
      return null;
    }
  }
  return params;
}

function isMissingValue(value) {
  return value === undefined || value === null || value === '';
}

function getRuleName(rule) {
  if (typeof rule === 'string') {
    return rule;
  }
  return rule.name || '';
}

function getRuleType(rule) {
  if (typeof rule === 'string') {
    return '';
  }
  return rule.type || '';
}

function isRuleRequired(rule) {
  if (typeof rule === 'string') {
    return true;
  }
  return rule.required === true;
}

function validateFieldType(value, expectedType, fieldName, containerName) {
  if (!expectedType || isMissingValue(value)) {
    return;
  }

  if (expectedType === 'number') {
    const numberValue = Number(value);
    if (Number.isNaN(numberValue)) {
      throw badRequest(`${containerName}.${fieldName} must be a number`);
    }
    return;
  }

  if (expectedType === 'integer') {
    const numberValue = Number(value);
    if (Number.isNaN(numberValue) || Math.floor(numberValue) !== numberValue) {
      throw badRequest(`${containerName}.${fieldName} must be an integer`);
    }
    return;
  }

  if (expectedType === 'string' && typeof value !== 'string') {
    throw badRequest(`${containerName}.${fieldName} must be a string`);
  }

  if (expectedType === 'boolean' && typeof value !== 'boolean') {
    throw badRequest(`${containerName}.${fieldName} must be a boolean`);
  }
}

function validateRequiredFields(container, fields, containerName) {
  if (!fields || fields.length === 0) {
    return;
  }

  const source = container || {};
  const missing = [];
  for (let i = 0; i < fields.length; i++) {
    const field = fields[i];
    if (isMissingValue(source[field])) {
      missing.push(field);
    }
  }

  if (missing.length > 0) {
    throw badRequest(`${containerName} fields are required: ${missing.join(', ')}`);
  }
}

function validateFieldRules(container, rules, containerName) {
  if (!rules || rules.length === 0) {
    return;
  }

  const source = container || {};
  const missing = [];
  for (let i = 0; i < rules.length; i++) {
    const rule = rules[i];
    const fieldName = getRuleName(rule);
    if (!fieldName) {
      continue;
    }

    const value = source[fieldName];
    if (isRuleRequired(rule) && isMissingValue(value)) {
      missing.push(fieldName);
      continue;
    }

    validateFieldType(value, getRuleType(rule), fieldName, containerName);
  }

  if (missing.length > 0) {
    throw badRequest(`${containerName} fields are required: ${missing.join(', ')}`);
  }
}

function createDomainHandler(contract, routes) {
  return async function handler(event, context, callback) {
    const request = normalizeEvent(event);
    let response = null;

    for (let i = 0; i < routes.length; i++) {
      const route = routes[i];
      if (route.method !== request.method) {
        continue;
      }

      const params = matchRoute(route.path, request.path);
      if (!params) {
        continue;
      }

      try {
        validateRequiredFields(request.queryStringParameters, route.requiredQueryFields, 'query');
        validateRequiredFields(request.body || {}, route.requiredBodyFields, 'body');
        validateFieldRules(request.queryStringParameters, route.queryRules, 'query');
        validateFieldRules(request.body || {}, route.bodyRules, 'body');

        let authContext = null;
        if (route.auth !== false) {
          authContext = await requireUser(request);
          if (route.roles && route.roles.length > 0) {
            assertRole(authContext.user, route.roles);
          }
        }

        const result = await route.handler({
          request,
          params,
          query: request.queryStringParameters || {},
          body: request.body || {},
          auth: authContext,
          contract
        });

        if (result && typeof result.code === 'number' && Object.prototype.hasOwnProperty.call(result, 'message')) {
          response = result;
          emitAgcResult(context, callback, response);
          return response;
        }
        response = ok(result);
        emitAgcResult(context, callback, response);
        return response;
      } catch (error) {
        response = fail(error.code || 500, error.message || 'Internal error');
        emitAgcResult(context, callback, response);
        return response;
      }
    }

    response = fail(404, `${contract.domain} route not found`);
    emitAgcResult(context, callback, response);
    return response;
  };
}

module.exports = {
  ok,
  detail,
  command,
  fail,
  page,
  createDomainHandler
};
