/**
 * SmartGuardian - API Wrapper
 * Unified API call wrapper with error handling and retry
 * 
 * @description 统一的 API 调用封装，提供错误处理、重试和缓存功能
 * @features
 * - 统一的 API 调用方式
 * - 自动错误处理
 * - 请求重试机制
 * - 请求取消支持
 * - 请求缓存支持
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';
import { ApiConfig } from '../../config/api.config';
import { RouteUrls, StorageKeys } from '../../constants/app.constants';
import { ApiResponseHelper } from '../../models/common';
import { AgcRequestAdapter } from '../../services/agc/AgcRequestAdapter';
import {
  AppError,
  ErrorCode,
  ErrorCategory,
  ErrorFactory
} from '../errors';
import { ApiResult } from './ApiResult';

const TAG = 'ApiWrapper';
const DOMAIN = 0x0001;

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
interface CacheEntry<T> {
  data: T;
  timestamp: number;
  cacheTime: number;
}

/**
 * API Wrapper
 * 
 * @description 统一的 API 调用封装
 * @class
 */
export class ApiWrapper {
  private static readonly TOKEN_KEY = StorageKeys.TOKEN;
  private static cache: Map<string, CacheEntry<Object>> = new Map();
  private static pendingRequests: Map<string, Promise<ApiResult<Object>>> = new Map();
  private static isRedirectingToLogin: boolean = false;
  
  /**
   * GET request
   * 
   * @description 发送 GET 请求
   * @template T - 响应数据类型
   * @param {string} url - 请求URL
   * @param {object} params - 查询参数
   * @param {Partial<RequestOptions>} options - 请求选项
   * @returns {Promise<ApiResult<T>>} API结果
   */
  static async get<T>(
    url: string,
    params?: object,
    options?: Partial<RequestOptions>
  ): Promise<ApiResult<T>> {
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
    return this.request<T>(this.applyPartialOptions(requestOptions, options));
  }
  
  /**
   * POST request
   * 
   * @description 发送 POST 请求
   * @template T - 响应数据类型
   * @param {string} url - 请求URL
   * @param {object} data - 请求数据
   * @param {Partial<RequestOptions>} options - 请求选项
   * @returns {Promise<ApiResult<T>>} API结果
   */
  static async post<T>(
    url: string,
    data?: object,
    options?: Partial<RequestOptions>
  ): Promise<ApiResult<T>> {
    const requestOptions: RequestOptions = {
      url,
      method: HttpMethod.POST,
      data
    };
    return this.request<T>(this.applyPartialOptions(requestOptions, options));
  }
  
  /**
   * PUT request
   * 
   * @description 发送 PUT 请求
   * @template T - 响应数据类型
   * @param {string} url - 请求URL
   * @param {object} data - 请求数据
   * @param {Partial<RequestOptions>} options - 请求选项
   * @returns {Promise<ApiResult<T>>} API结果
   */
  static async put<T>(
    url: string,
    data?: object,
    options?: Partial<RequestOptions>
  ): Promise<ApiResult<T>> {
    const requestOptions: RequestOptions = {
      url,
      method: HttpMethod.PUT,
      data
    };
    return this.request<T>(this.applyPartialOptions(requestOptions, options));
  }
  
  /**
   * DELETE request
   * 
   * @description 发送 DELETE 请求
   * @template T - 响应数据类型
   * @param {string} url - 请求URL
   * @param {Partial<RequestOptions>} options - 请求选项
   * @returns {Promise<ApiResult<T>>} API结果
   */
  static async delete<T>(
    url: string,
    options?: Partial<RequestOptions>
  ): Promise<ApiResult<T>> {
    const requestOptions: RequestOptions = {
      url,
      method: HttpMethod.DELETE
    };
    return this.request<T>(this.applyPartialOptions(requestOptions, options));
  }
  
  /**
   * Generic request
   * 
   * @description 通用请求方法
   * @template T - 响应数据类型
   * @param {RequestOptions} options - 请求选项
   * @returns {Promise<ApiResult<T>>} API结果
   */
  static async request<T>(options: RequestOptions): Promise<ApiResult<T>> {
    const url = options.url;
    const method = options.method;
    const data = options.data;
    const headers = options.headers ?? {};
    const needAuth = options.needAuth ?? true;
    const timeout = options.timeout ?? ApiConfig.TIMEOUT;
    const retryCount = options.retryCount ?? 0;
    const retryDelay = options.retryDelay ?? 1000;
    const enableCache = options.enableCache ?? false;
    const cacheTime = options.cacheTime ?? 5 * 60 * 1000;
    const source = options.source ?? 'ApiWrapper';
    
    // 检查缓存（仅GET请求）
    if (method === HttpMethod.GET && enableCache) {
      const cached = this.getFromCache<T>(url, cacheTime);
      if (cached) {
        return ApiResult.success(cached);
      }
    }
    
    // 检查重复请求（防止重复提交）
    const requestKey = `${method}:${url}:${JSON.stringify(data)}`;
    if (method !== HttpMethod.GET && this.pendingRequests.has(requestKey)) {
      try {
        const pendingRequest = this.pendingRequests.get(requestKey);
        if (pendingRequest) {
          return await pendingRequest as ApiResult<T>;
        }
      } catch (error) {
        return ApiResult.failure(error as AppError);
      }
    }
    
    // 执行请求
    const executeRequest = async (): Promise<ApiResult<T>> => {
      try {
        const response = await this.executeHttpRequest<T>({
          url,
          method,
          data,
          headers,
          needAuth,
          timeout,
          source
        });
        
        // 缓存结果（仅GET请求）
        if (method === HttpMethod.GET && enableCache) {
          this.setCache(url, response.data, cacheTime);
        }
        
        return ApiResult.success(response.data);
      } catch (error) {
        const appError = error instanceof AppError
          ? error
          : ErrorFactory.fromError(error as Error, { source, operation: `${method} ${url}` });
        
        // 判断是否需要重试
        if (retryCount > 0 && appError.retryable) {
          hilog.warn(DOMAIN, TAG, `Retrying request: ${url}, remaining: ${retryCount}`);
          await this.delay(retryDelay);
          return this.request<T>(this.copyRequestOptionsWithRetry(options, retryCount - 1));
        }
        
        return ApiResult.failure(appError);
      }
    };
    
    // 设置pending请求
    const requestPromise = executeRequest();
    if (method !== HttpMethod.GET) {
      this.pendingRequests.set(requestKey, requestPromise as Promise<ApiResult<Object>>);
    }
    
    try {
      return await requestPromise;
    } finally {
      this.pendingRequests.delete(requestKey);
    }
  }
  
  /**
   * Execute HTTP request
   */
  private static async executeHttpRequest<T>(options: {
    url: string;
    method: HttpMethod;
    data?: object;
    headers: Record<string, string>;
    needAuth: boolean;
    timeout: number;
    source: string;
  }): Promise<ApiResponse<T>> {
    const url = options.url;
    const method = options.method;
    const data = options.data;
    const headers = options.headers;
    const needAuth = options.needAuth;
    const timeout = options.timeout;
    const source = options.source;
    
    try {
      const result = await AgcRequestAdapter.request<T>({
        url,
        method,
        data,
        headers,
        needAuth,
        timeout,
        source
      });

      if (ApiResponseHelper.isAuthError(result.code)) {
        this.handleUnauthorized();
        throw ErrorFactory.tokenExpired({ source, operation: url });
      }

      if (!ApiResponseHelper.isSuccess(result.code)) {
        throw new AppError(
          result.message || 'Business request failed',
          ErrorCode.BIZ_OPERATION_FAILED,
          ErrorCategory.BUSINESS,
          { context: { source, operation: url } }
        );
      }

      return result;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw ErrorFactory.fromError(error as Error, { source, operation: url });
    }
  }

  

  private static applyPartialOptions(
    requestOptions: RequestOptions,
    options?: Partial<RequestOptions>
  ): RequestOptions {
    if (!options) {
      return requestOptions;
    }
    if (options.headers !== undefined) {
      requestOptions.headers = options.headers;
    }
    if (options.needAuth !== undefined) {
      requestOptions.needAuth = options.needAuth;
    }
    if (options.timeout !== undefined) {
      requestOptions.timeout = options.timeout;
    }
    if (options.retryCount !== undefined) {
      requestOptions.retryCount = options.retryCount;
    }
    if (options.retryDelay !== undefined) {
      requestOptions.retryDelay = options.retryDelay;
    }
    if (options.enableCache !== undefined) {
      requestOptions.enableCache = options.enableCache;
    }
    if (options.cacheTime !== undefined) {
      requestOptions.cacheTime = options.cacheTime;
    }
    if (options.source !== undefined) {
      requestOptions.source = options.source;
    }
    return requestOptions;
  }

  private static copyRequestOptionsWithRetry(options: RequestOptions, retryCount: number): RequestOptions {
    const retryOptions: RequestOptions = {
      url: options.url,
      method: options.method
    };
    if (options.data !== undefined) {
      retryOptions.data = options.data;
    }
    if (options.headers !== undefined) {
      retryOptions.headers = options.headers;
    }
    if (options.needAuth !== undefined) {
      retryOptions.needAuth = options.needAuth;
    }
    if (options.timeout !== undefined) {
      retryOptions.timeout = options.timeout;
    }
    retryOptions.retryCount = retryCount;
    if (options.retryDelay !== undefined) {
      retryOptions.retryDelay = options.retryDelay;
    }
    if (options.enableCache !== undefined) {
      retryOptions.enableCache = options.enableCache;
    }
    if (options.cacheTime !== undefined) {
      retryOptions.cacheTime = options.cacheTime;
    }
    if (options.source !== undefined) {
      retryOptions.source = options.source;
    }
    return retryOptions;
  }
  
  /**
   * Handle unauthorized
   */
  private static handleUnauthorized(): void {
    if (this.isRedirectingToLogin) {
      return;
    }
    
    this.isRedirectingToLogin = true;
    AppStorage.delete(this.TOKEN_KEY);
    AppStorage.delete(StorageKeys.USER_INFO);
    AppStorage.delete(StorageKeys.IS_LOGGED_IN);
    AppStorage.delete(StorageKeys.WORKBENCH_MANIFEST);
    AppStorage.delete(StorageKeys.MAIN_NAVIGATION_SCOPE);
    AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 0);
    
    try {
      router.replaceUrl({ url: RouteUrls.LOGIN });
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Redirect to login failed: ${error}`);
    }
    
    setTimeout(() => {
      this.isRedirectingToLogin = false;
    }, 300);
  }
  
  /**
   * Get from cache
   */
  private static getFromCache<T>(url: string, cacheTime: number): T | null {
    const entry = this.cache.get(url) as CacheEntry<T> | undefined;
    if (!entry) {
      return null;
    }
    
    const now = Date.now();
    if (now - entry.timestamp > entry.cacheTime) {
      this.cache.delete(url);
      return null;
    }
    
    return entry.data;
  }
  
  /**
   * Set cache
   */
  private static setCache<T>(url: string, data: T, cacheTime: number): void {
    this.cache.set(url, {
      data,
      timestamp: Date.now(),
      cacheTime
    });
  }
  
  /**
   * Clear cache
   */
  static clearCache(url?: string): void {
    if (url) {
      this.cache.delete(url);
    } else {
      this.cache.clear();
    }
  }
  
  /**
   * Delay
   */
  private static delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * Convenience functions
 */
export const api = {
  get: <T>(
    url: string,
    params?: object,
    options?: Partial<RequestOptions>
  ): Promise<ApiResult<T>> => ApiWrapper.get<T>(url, params, options),
  post: <T>(
    url: string,
    data?: object,
    options?: Partial<RequestOptions>
  ): Promise<ApiResult<T>> => ApiWrapper.post<T>(url, data, options),
  put: <T>(
    url: string,
    data?: object,
    options?: Partial<RequestOptions>
  ): Promise<ApiResult<T>> => ApiWrapper.put<T>(url, data, options),
  delete: <T>(
    url: string,
    options?: Partial<RequestOptions>
  ): Promise<ApiResult<T>> => ApiWrapper.delete<T>(url, options),
  request: <T>(options: RequestOptions): Promise<ApiResult<T>> => ApiWrapper.request<T>(options),
  clearCache: (url?: string): void => ApiWrapper.clearCache(url)
};
