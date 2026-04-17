/**
 * SmartGuardian - Network Request Utility
 * HTTP request wrapper with authentication and error handling
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';

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

  // Build HTTP request
  const httpRequest = http.createHttp();
  // Convert custom HttpMethod to http.RequestMethod
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
    connectTimeout: TIMEOUT,
    readTimeout: TIMEOUT,
    extraData: method !== HttpMethod.GET && data ? JSON.stringify(data) : undefined
  };

  hilog.info(DOMAIN, TAG, `[${method}] ${fullUrl}`);

  try {
    const response = await httpRequest.request(fullUrl, httpOptions);

    // response.responseCode is the HTTP status code
    if (!response.responseCode || response.responseCode >= 400) {
      hilog.error(DOMAIN, TAG, `HTTP Error: ${response.responseCode}`);
      throw new Error(`HTTP Error: ${response.responseCode}`);
    }

    const result = JSON.parse(response.result as string) as HttpResponse<T>;

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
  } finally {
    // Destroy http instance to release resources
    httpRequest.destroy();
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