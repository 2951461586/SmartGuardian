/**
 * SmartGuardian - Network Request Utility
 * HTTP request wrapper with authentication and error handling
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { ApiConfig } from '../config/api.config';
import { RouteUrls, StorageKeys } from '../constants/app.constants';
import { ApiResponseHelper } from '../models/common';
import { AgcRequestAdapter } from '../services/agc/AgcRequestAdapter';

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

interface RouterLike {
  replaceUrl(options: { url: string }): void;
}

interface RequestUIContext {
  getRouter(): RouterLike;
}

let isRedirectingToLogin: boolean = false;
let requestUIContext: RequestUIContext | null = null;

function applyPartialRequestOptions(
  requestOptions: RequestOptions,
  options?: Partial<RequestOptions>
): RequestOptions {
  if (!options) {
    return requestOptions;
  }
  if (options.data !== undefined) {
    requestOptions.data = options.data;
  }
  if (options.headers !== undefined) {
    requestOptions.headers = options.headers;
  }
  if (options.needAuth !== undefined) {
    requestOptions.needAuth = options.needAuth;
  }
  return requestOptions;
}

export function setRequestUIContext(uiContext: RequestUIContext): void {
  requestUIContext = uiContext;
}

export function getToken(): string | null {
  return AppStorage.get<string>(StorageKeys.TOKEN) ?? null;
}

export function setToken(token: string): void {
  AppStorage.setOrCreate(StorageKeys.TOKEN, token);
}

export function removeToken(): void {
  AppStorage.delete(StorageKeys.TOKEN);
}

function clearAuthState(): void {
  removeToken();
  AppStorage.delete(StorageKeys.USER_INFO);
  AppStorage.delete(StorageKeys.IS_LOGGED_IN);
  AppStorage.delete(StorageKeys.WORKBENCH_MANIFEST);
  AppStorage.delete(StorageKeys.MAIN_NAVIGATION_SCOPE);
  AppStorage.delete(StorageKeys.AGC_AUTH_USER_UID);
  AppStorage.delete(StorageKeys.AGC_AUTH_USER_PHONE);
  AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 0);
}

function handleUnauthorized(): void {
  clearAuthState();

  if (isRedirectingToLogin) {
    return;
  }

  isRedirectingToLogin = true;
  try {
    if (requestUIContext) {
      requestUIContext.getRouter().replaceUrl({ url: RouteUrls.LOGIN });
    } else {
      hilog.error(DOMAIN, TAG, 'Redirect to login skipped: UIContext not ready');
    }
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
  try {
    const result = await AgcRequestAdapter.request<T>({
      url: options.url,
      method: options.method,
      data: options.data,
      headers: options.headers,
      needAuth: options.needAuth,
      timeout: ApiConfig.TIMEOUT,
      source: TAG
    });

    if (ApiResponseHelper.isAuthError(result.code)) {
      hilog.error(DOMAIN, TAG, `AGC auth error: ${result.code} - ${result.message}`);
      handleUnauthorized();
      throw new Error(result.message || 'Session expired');
    }

    if (!ApiResponseHelper.isSuccess(result.code)) {
      hilog.error(DOMAIN, TAG, `AGC business error: ${result.code} - ${result.message}`);
      throw new Error(result.message || 'Business request failed');
    }

    return result;
  } catch (error) {
    hilog.error(DOMAIN, TAG, `AGC request failed: ${error}`);
    throw error;
  }
}

export async function get<T = object>(
  url: string,
  params?: object,
  options?: Partial<RequestOptions>
): Promise<HttpResponse<T>> {
  let fullUrl = url;
  if (params) {
    const queryStringParts: string[] = [];
    const paramsRecord = params as Record<string, string | number | boolean | null | undefined>;
    const paramKeys = Object.keys(paramsRecord);
    for (let i = 0; i < paramKeys.length; i++) {
      const key = paramKeys[i];
      const value = paramsRecord[key];
      if (value !== undefined && value !== null) {
        queryStringParts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
      }
    }
    if (queryStringParts.length > 0) {
      fullUrl += (url.includes('?') ? '&' : '?') + queryStringParts.join('&');
    }
  }
  const requestOptions: RequestOptions = {
    url: fullUrl,
    method: HttpMethod.GET
  };
  return httpRequest<T>(applyPartialRequestOptions(requestOptions, options));
}

export async function post<T = object>(
  url: string,
  data?: object,
  options?: Partial<RequestOptions>
): Promise<HttpResponse<T>> {
  const requestOptions: RequestOptions = {
    url,
    method: HttpMethod.POST,
    data
  };
  return httpRequest<T>(applyPartialRequestOptions(requestOptions, options));
}

export async function put<T = object>(
  url: string,
  data?: object,
  options?: Partial<RequestOptions>
): Promise<HttpResponse<T>> {
  const requestOptions: RequestOptions = {
    url,
    method: HttpMethod.PUT,
    data
  };
  return httpRequest<T>(applyPartialRequestOptions(requestOptions, options));
}

export async function del<T = object>(
  url: string,
  options?: Partial<RequestOptions>
): Promise<HttpResponse<T>> {
  const requestOptions: RequestOptions = {
    url,
    method: HttpMethod.DELETE
  };
  return httpRequest<T>(applyPartialRequestOptions(requestOptions, options));
}
