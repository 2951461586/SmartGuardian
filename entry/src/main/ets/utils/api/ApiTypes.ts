/**
 * SmartGuardian - API type definitions
 * Extracted from ApiWrapper for clean separation of types and implementation.
 */

/**
 * HTTP Method
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
  /** 请求URL */
  url: string;

  /** 请求方法 */
  method: HttpMethod;

  /** 请求数据 */
  data?: object;

  /** 请求头 */
  headers?: Record<string, string>;

  /** 是否需要认证 */
  needAuth?: boolean;

  /** 超时时间（毫秒） */
  timeout?: number;

  /** 重试次数 */
  retryCount?: number;

  /** 重试延迟（毫秒） */
  retryDelay?: number;

  /** 是否启用缓存（仅GET） */
  enableCache?: boolean;

  /** 缓存时间（毫秒） */
  cacheTime?: number;

  /** 请求来源（用于错误追踪） */
  source?: string;
}

/**
 * API Response
 */
export interface ApiResponse<T = object> {
  code: number;
  message: string;
  data: T;
}

/**
 * Cache entry
 */
export interface CacheEntry<T> {
  data: T;
  timestamp: number;
  cacheTime: number;
}
