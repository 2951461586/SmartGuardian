/**
 * SmartGuardian - AGC Request Adapter
 * Route ArkTS requests to AGC API Gateway / Cloud Functions contracts.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
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
}

export class AgcRequestAdapter {
  static async request<T>(options: AgcRequestOptions): Promise<ApiResponse<T>> {
    const url = options.url;
    const method = options.method;
    const data = options.data;
    const headers = options.headers ?? {};
    const needAuth = options.needAuth ?? true;
    const timeout = options.timeout ?? ApiConfig.TIMEOUT;
    const source = options.source ?? TAG;
    const gatewayBaseUrl = ApiConfig.getBaseUrl();
    const route = AgcRouteRegistry.resolve(url);

    if (!url.startsWith('http') && gatewayBaseUrl.length === 0) {
      throw new Error('AGC API gateway base URL is not configured');
    }

    const fullUrl = url.startsWith('http') ? url : `${gatewayBaseUrl}${url}`;
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

    let requestMethod: http.RequestMethod = http.RequestMethod.GET;
    switch (method) {
      case 'POST':
        requestMethod = http.RequestMethod.POST;
        break;
      case 'PUT':
        requestMethod = http.RequestMethod.PUT;
        break;
      case 'DELETE':
        requestMethod = http.RequestMethod.DELETE;
        break;
      case 'PATCH':
        throw new Error('PATCH method is not supported by current NetworkKit RequestMethod');
      default:
        requestMethod = http.RequestMethod.GET;
    }

    const httpOptions: http.HttpRequestOptions = {
      method: requestMethod,
      header: requestHeaders,
      connectTimeout: timeout,
      readTimeout: timeout,
      extraData: method !== 'GET' && data ? JSON.stringify(data) : undefined
    };

    if (ApiConfig.ENABLE_LOGGING) {
      hilog.info(DOMAIN, TAG, `[${source}] [${route.functionName}] [${method}] ${fullUrl}`);
    }

    const httpClient = http.createHttp();
    try {
      let response: http.HttpResponse;
      try {
        response = await httpClient.request(fullUrl, httpOptions);
      } catch (error) {
        hilog.error(DOMAIN, TAG, `[${source}] AGC gateway request failed: ${String(error)}`);
        throw new Error('AGC gateway request failed');
      }

      if (!response.responseCode || response.responseCode >= 400) {
        hilog.error(DOMAIN, TAG, `[${source}] AGC gateway error: ${response.responseCode}`);
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }

      let result: ApiResponse<T>;
      try {
        result = JSON.parse(response.result as string) as ApiResponse<T>;
      } catch (error) {
        hilog.error(DOMAIN, TAG, `[${source}] AGC response parse failed: ${String(error)}`);
        throw new Error('AGC response parse failed');
      }

      if (ApiConfig.ENABLE_LOGGING) {
        hilog.info(DOMAIN, TAG, `[${source}] AGC response: ${JSON.stringify(result).substring(0, 200)}`);
      }
      return result;
    } finally {
      httpClient.destroy();
    }
  }
}
