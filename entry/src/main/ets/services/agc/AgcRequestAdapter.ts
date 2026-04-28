/**
 * SmartGuardian - AGC Request Adapter
 * Route ArkTS requests to AGC Cloud Functions contracts.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import agconnect from '@hw-agconnect/api-ohos';
import '@hw-agconnect/function-ohos';
import { ApiConfig } from '../../config/api.config';
import { StorageKeys } from '../../constants/app.constants';
import { ApiResponse } from '../../models/common';
import { AgcFunctionContractRegistry } from './AgcFunctionContracts';

const TAG = 'SmartGuardian/AGC';
const DOMAIN = 0x0001;

export interface AgcRequestOptions {
  url: string;
  method: string;
  data?: object;
  headers?: Record<string, string>;
  needAuth?: boolean;
  timeout?: number;
  source?: string;
}

export interface AgcRouteDescriptor {
  domain: string;
  functionName: string;
  routePath: string;
}

interface AgcHttpResponseEnvelope<T> {
  code?: number;
  message?: string;
  data?: T;
  body?: ApiResponse<T> | string;
}

interface AgcFunctionTransportEvent {
  httpMethod: string;
  path: string;
  headers: Record<string, string>;
  body: string;
  queryStringParameters: Record<string, string>;
}

interface AgcFunctionProvider {
  function(name?: string): AgcFunctionClient;
}

interface AgcFunctionClient {
  wrap(httpTriggerURI: string): AgcFunctionCallable;
}

interface AgcFunctionCallable {
  setTimeout(timeout: number): void;
  call(reqBody: AgcFunctionTransportEvent): Promise<AgcFunctionResult>;
}

interface AgcFunctionResult {
  getValue(): Object | string | null;
}

interface AgcErrorLike {
  code?: number;
  responseCode?: number;
  message?: string;
  name?: string;
  stack?: string;
  result?: string;
  errMsg?: string;
}

export class AgcRouteRegistry {
  static resolve(url: string): AgcRouteDescriptor {
    const routePath = AgcRouteRegistry.extractPath(url);
    const contract = AgcFunctionContractRegistry.resolve(routePath);
    return {
      domain: contract.domain,
      functionName: contract.functionName,
      routePath
    };
  }

  static extractPath(url: string): string {
    const queryIndex = url.indexOf('?');
    if (queryIndex < 0) {
      return url;
    }
    return url.substring(0, queryIndex);
  }

  static extractQuery(url: string): Record<string, string> {
    const queryIndex = url.indexOf('?');
    const result: Record<string, string> = {};
    if (queryIndex < 0 || queryIndex >= url.length - 1) {
      return result;
    }

    const queryText = url.substring(queryIndex + 1);
    const pairs = queryText.split('&');
    for (let i = 0; i < pairs.length; i++) {
      const pair = pairs[i];
      if (pair.length === 0) {
        continue;
      }
      const separatorIndex = pair.indexOf('=');
      if (separatorIndex < 0) {
        result[decodeURIComponent(pair)] = '';
      } else {
        const key = decodeURIComponent(pair.substring(0, separatorIndex));
        const value = decodeURIComponent(pair.substring(separatorIndex + 1));
        result[key] = value;
      }
    }
    return result;
  }
}

export class AgcRequestAdapter {
  private static addTextPart(parts: string[], label: string, value?: string): void {
    if (value !== undefined && value !== null && value.length > 0) {
      parts.push(`${label}=${value}`);
    }
  }

  private static addNumberPart(parts: string[], label: string, value?: number): void {
    if (value !== undefined && value !== null) {
      parts.push(`${label}=${value}`);
    }
  }

  private static formatAgcError(error: Object): string {
    const detail = error as AgcErrorLike;
    const parts: string[] = [];

    AgcRequestAdapter.addTextPart(parts, 'name', detail.name);
    AgcRequestAdapter.addNumberPart(parts, 'code', detail.code);
    AgcRequestAdapter.addNumberPart(parts, 'responseCode', detail.responseCode);
    AgcRequestAdapter.addTextPart(parts, 'message', detail.message);
    AgcRequestAdapter.addTextPart(parts, 'result', detail.result);
    AgcRequestAdapter.addTextPart(parts, 'errMsg', detail.errMsg);

    const text = String(error);
    if (text.length > 0 && text !== '[object Object]' && text !== detail.message) {
      AgcRequestAdapter.addTextPart(parts, 'text', text);
    }

    try {
      const serialized = JSON.stringify(error);
      if (serialized.length > 0 && serialized !== '{}') {
        AgcRequestAdapter.addTextPart(parts, 'raw', serialized);
      }
    } catch (serializeError) {
      AgcRequestAdapter.addTextPart(parts, 'serializeError', String(serializeError));
    }

    if (parts.length === 0) {
      return text.length > 0 ? text : 'empty AGC SDK error';
    }
    return parts.join(', ');
  }

  private static parseApiResponse<T>(payload: string): ApiResponse<T> {
    const parsed = JSON.parse(payload) as ApiResponse<T>;
    return parsed;
  }

  private static unwrapAgcHttpResponse<T>(payload: string): ApiResponse<T> {
    const parsed = JSON.parse(payload) as AgcHttpResponseEnvelope<T>;
    if (parsed.code !== undefined && parsed.message !== undefined) {
      return {
        code: parsed.code,
        message: parsed.message,
        data: parsed.data as T
      };
    }

    const body = parsed.body;
    if (typeof body === 'string') {
      return AgcRequestAdapter.parseApiResponse<T>(body);
    }
    if (body !== undefined && body !== null && typeof body === 'object') {
      return body as ApiResponse<T>;
    }

    throw new Error('AGC response body is missing');
  }

  private static resolveTriggerIdentifier(route: AgcRouteDescriptor): string {
    const functionTriggerUrl = ApiConfig.getFunctionTriggerUrl(route.functionName);
    if (functionTriggerUrl.length > 0) {
      return functionTriggerUrl;
    }

    throw new Error(`AGC Function trigger identifier is not configured: ${route.functionName}`);
  }

  static async request<T>(options: AgcRequestOptions): Promise<ApiResponse<T>> {
    const url = options.url;
    const method = options.method;
    const data = options.data;
    const headers = options.headers ?? {};
    const needAuth = options.needAuth ?? true;
    const timeout = options.timeout ?? ApiConfig.TIMEOUT;
    const source = options.source ?? TAG;
    const route = AgcRouteRegistry.resolve(url);
    const triggerIdentifier = AgcRequestAdapter.resolveTriggerIdentifier(route);
    const requestHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      'X-SmartGuardian-Request-Mode': 'AGC_SERVERLESS',
      'X-SmartGuardian-Function-Domain': route.domain,
      'X-SmartGuardian-Function-Name': route.functionName,
      'X-SmartGuardian-Function-Route': route.routePath,
      ...headers
    };

    if (needAuth) {
      const token = AppStorage.get<string>(StorageKeys.TOKEN);
      if (token) {
        requestHeaders['Authorization'] = `Bearer ${token}`;
      }
    }

    const transportEvent: AgcFunctionTransportEvent = {
      httpMethod: method,
      path: route.routePath,
      headers: requestHeaders,
      body: data ? JSON.stringify(data) : '',
      queryStringParameters: AgcRouteRegistry.extractQuery(url)
    };

    if (ApiConfig.ENABLE_LOGGING) {
      hilog.info(DOMAIN, TAG, `[${source}] [${route.functionName}] [${method}] ${triggerIdentifier}`);
    }

    try {
      const functionProvider = agconnect as Object as AgcFunctionProvider;
      const callable = functionProvider.function().wrap(triggerIdentifier);
      callable.setTimeout(timeout);
      const functionResult = await callable.call(transportEvent);
      const value = functionResult.getValue();
      const payload = typeof value === 'string' ? value : JSON.stringify(value);

      let result: ApiResponse<T>;
      try {
        result = AgcRequestAdapter.unwrapAgcHttpResponse<T>(payload);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `[${source}] AGC response parse failed: ${AgcRequestAdapter.formatAgcError(error as Object)}, payload=${payload.substring(0, 500)}`);
        throw new Error('AGC response parse failed');
      }

      if (ApiConfig.ENABLE_LOGGING) {
        hilog.info(DOMAIN, TAG, `[${source}] AGC response: ${JSON.stringify(result).substring(0, 200)}`);
      }
      return result;
    } catch (error) {
      const detail = AgcRequestAdapter.formatAgcError(error as Object);
      hilog.error(
        DOMAIN,
        TAG,
        `[${source}] AGC function request failed: function=${route.functionName}, trigger=${triggerIdentifier}, route=${route.routePath}, detail=${detail}`
      );
      throw new Error(`AGC function request failed: ${detail}`);
    }
  }
}
