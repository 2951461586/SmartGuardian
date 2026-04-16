/**
 * SmartGuardian - Network Request Utility
 * HTTP request wrapper with authentication and error handling
 */

import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'SmartGuardian/Request';
const DOMAIN = 0x0001;

// Base URL - should be configured per environment
const BASE_URL = 'https://api.smartguardian.local';

// Request timeout in milliseconds
const TIMEOUT = 30000;

/**
 * HTTP Methods
 */
export enum HttpMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE',
  PATCH = 'PATCH'
}

/**
 * Request options
 */
export interface RequestOptions {
  url: string;
  method: HttpMethod;
  data?: object;
  headers?: Record<string, string>;
  needAuth?: boolean;
}

/**
 * Response wrapper
 */
export interface HttpResponse<T = object> {
  code: number;
  message: string;
  data: T;
}

/**
 * Token storage key
 */
const TOKEN_KEY = 'smart_guardian_token';

/**
 * Get stored token
 */
export function getToken(): string | null {
  // TODO: Use proper storage after implementing storage utility
  // For now, return placeholder
  return AppStorage.get<string>(TOKEN_KEY) ?? null;
}

/**
 * Set stored token
 */
export function setToken(token: string): void {
  AppStorage.setOrCreate(TOKEN_KEY, token);
}

/**
 * Remove stored token
 */
export function removeToken(): void {
  AppStorage.delete(TOKEN_KEY);
}

/**
 * HTTP Request helper
 */
export async function httpRequest<T = object>(
  options: RequestOptions
): Promise<HttpResponse<T>> {
  const { url, method, data, headers = {}, needAuth = true } = options;

  // Build full URL
  const fullUrl = url.startsWith('http') ? url : `${BASE_URL}${url}`;

  // Build headers
  const requestHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
    ...headers
  };

  // Add auth token if needed
  if (needAuth) {
    const token = getToken();
    if (token) {
      requestHeaders['Authorization'] = `Bearer ${token}`;
    }
  }

  // Build request options
  const requestOptions: Record<string, object> = {
    method: method,
    headers: requestHeaders,
    connectTimeout: TIMEOUT,
    readTimeout: TIMEOUT
  };

  // Add body for non-GET requests
  if (method !== HttpMethod.GET && data) {
    requestOptions['body'] = JSON.stringify(data);
  }

  hilog.info(DOMAIN, TAG, `[${method}] ${fullUrl}`);

  try {
    const response = await fetch(fullUrl, requestOptions);

    if (!response.ok) {
      hilog.error(DOMAIN, TAG, `HTTP Error: ${response.status} ${response.statusText}`);
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const result = await response.json() as HttpResponse<T>;

    hilog.info(DOMAIN, TAG, `Response: ${JSON.stringify(result).substring(0, 200)}`);

    // Handle business error
    if (result.code !== 0 && result.code !== 200) {
      hilog.error(DOMAIN, TAG, `Business Error: ${result.code} - ${result.message}`);
      throw new Error(result.message || 'Business error');
    }

    return result;
  } catch (error) {
    hilog.error(DOMAIN, TAG, `Request failed: ${error}`);
    throw error;
  }
}

/**
 * GET request helper
 */
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

/**
 * POST request helper
 */
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

/**
 * PUT request helper
 */
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

/**
 * DELETE request helper
 */
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