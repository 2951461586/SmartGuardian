/**
 * SmartGuardian - Network Request Utility
 * HTTP request wrapper with authentication and error handling
 */

import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
import { ApiConfig } from '../config/api.config';
import { MockService } from '../services/mock/mockService';
import { ApiResponseHelper, ApiCode } from '../models/common';

const TAG = 'SmartGuardian/Request';
const DOMAIN = 0x0001;

export enum HttpMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE',
  PATCH = 'PATCH'
}

export interface RequestOptions {
  url: string;
  method: HttpMethod;
  data?: object;
  headers?: Record<string, string>;
  needAuth?: boolean;
}

export interface HttpResponse<T = object> {
  code: number;
  message: string;
  data: T;
}

const TOKEN_KEY = 'smart_guardian_token';
const USER_INFO_KEY = 'user_info';
const IS_LOGGED_IN_KEY = 'is_logged_in';

let isRedirectingToLogin: boolean = false;

export function getToken(): string | null {
  return AppStorage.get<string>(TOKEN_KEY) ?? null;
}

export function setToken(token: string): void {
  AppStorage.setOrCreate(TOKEN_KEY, token);
}

export function removeToken(): void {
  AppStorage.delete(TOKEN_KEY);
}

function clearAuthState(): void {
  removeToken();
  AppStorage.delete(USER_INFO_KEY);
  AppStorage.delete(IS_LOGGED_IN_KEY);
}

function handleUnauthorized(): void {
  clearAuthState();

  if (isRedirectingToLogin) {
    return;
  }

  isRedirectingToLogin = true;
  try {
    router.replaceUrl({ url: 'pages/LoginPage' });
  } catch (error) {
    hilog.error(DOMAIN, TAG, `Redirect to login failed: ${error}`);
  }

  setTimeout((): void => {
    isRedirectingToLogin = false;
  }, 300);
}

export async function httpRequest<T = object>(
  options: RequestOptions
): Promise<HttpResponse<T>> {
  if (ApiConfig.isMockEnabled()) {
    return MockService.handleMockRequest<T>(options);
  }

  const url = options.url;
  const method = options.method;
  const data = options.data;
  const headers = options.headers ?? {};
  const needAuth = options.needAuth ?? true;
  const baseUrl = ApiConfig.getBaseUrl();
  if (!url.startsWith('http') && baseUrl.length === 0) {
    throw new Error('ApiConfig.TEST_BASE_URL is not configured');
  }
  const fullUrl = url.startsWith('http') ? url : `${baseUrl}${url}`;

  const requestHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
    ...headers
  };

  if (needAuth) {
    const token = getToken();
    if (token) {
      requestHeaders['Authorization'] = `Bearer ${token}`;
    }
  }

  const httpClient = http.createHttp();
  let requestMethod: http.RequestMethod = http.RequestMethod.GET;
  switch (method) {
    case HttpMethod.POST:
      requestMethod = http.RequestMethod.POST;
      break;
    case HttpMethod.PUT:
      requestMethod = http.RequestMethod.PUT;
      break;
    case HttpMethod.DELETE:
      requestMethod = http.RequestMethod.DELETE;
      break;
    case HttpMethod.PATCH:
      requestMethod = http.RequestMethod.PUT;
      break;
    default:
      requestMethod = http.RequestMethod.GET;
  }

  const httpOptions: http.HttpRequestOptions = {
    method: requestMethod,
    header: requestHeaders,
    connectTimeout: ApiConfig.TIMEOUT,
    readTimeout: ApiConfig.TIMEOUT,
    extraData: method !== HttpMethod.GET && data ? JSON.stringify(data) : undefined
  };

  if (ApiConfig.ENABLE_LOGGING) {
    hilog.info(DOMAIN, TAG, `[${method}] ${fullUrl}`);
  }

  try {
    const response = await httpClient.request(fullUrl, httpOptions);

    if (!response.responseCode || response.responseCode >= 400) {
      hilog.error(DOMAIN, TAG, `HTTP Error: ${response.responseCode}`);
      if (response.responseCode === 401) {
        handleUnauthorized();
      }
      throw new Error(`HTTP Error: ${response.responseCode}`);
    }

    const result = JSON.parse(response.result as string) as HttpResponse<T>;

    if (ApiConfig.ENABLE_LOGGING) {
      hilog.info(DOMAIN, TAG, `Response: ${JSON.stringify(result).substring(0, 200)}`);
    }

    // 使用统一的响应码判断
    if (ApiResponseHelper.isAuthError(result.code)) {
      hilog.error(DOMAIN, TAG, `Auth Error: ${result.code} - ${result.message}`);
      handleUnauthorized();
      throw new Error(result.message || '登录已失效');
    }

    if (!ApiResponseHelper.isSuccess(result.code)) {
      hilog.error(DOMAIN, TAG, `Business Error: ${result.code} - ${result.message}`);
      throw new Error(result.message || '业务处理失败');
    }

    return result;
  } catch (error) {
    hilog.error(DOMAIN, TAG, `Request failed: ${error}`);
    throw error;
  } finally {
    httpClient.destroy();
  }
}

export async function get<T = object>(
  url: string,
  params?: object,
  options?: Partial<RequestOptions>
): Promise<HttpResponse<T>> {
  let fullUrl = url;
  if (params) {
    const queryString = Object.entries(params)
      .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`)
      .join('&');
    fullUrl += (url.includes('?') ? '&' : '?') + queryString;
  }
  return httpRequest<T>({
    url: fullUrl,
    method: HttpMethod.GET,
    ...options
  });
}

export async function post<T = object>(
  url: string,
  data?: object,
  options?: Partial<RequestOptions>
): Promise<HttpResponse<T>> {
  return httpRequest<T>({
    url,
    method: HttpMethod.POST,
    data,
    ...options
  });
}

export async function put<T = object>(
  url: string,
  data?: object,
  options?: Partial<RequestOptions>
): Promise<HttpResponse<T>> {
  return httpRequest<T>({
    url,
    method: HttpMethod.PUT,
    data,
    ...options
  });
}

export async function del<T = object>(
  url: string,
  options?: Partial<RequestOptions>
): Promise<HttpResponse<T>> {
  return httpRequest<T>({
    url,
    method: HttpMethod.DELETE,
    ...options
  });
}
