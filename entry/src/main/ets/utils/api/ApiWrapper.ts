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
import { http } from '@kit.NetworkKit';
import { router } from '@kit.ArkUI';
import { ApiConfig } from '../../config/api.config';
import { MockService } from '../../services/mock/mockService';
import {
  AppError,
  ErrorCode,
  ErrorCategory,
  ErrorFactory,
  ErrorHandler
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
  private static readonly TOKEN_KEY = 'smart_guardian_token';
  private static cache: Map<string, CacheEntry<unknown>> = new Map();
  private static pendingRequests: Map<string, Promise<ApiResponse<unknown>>> = new Map();
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
      const queryString = Object.entries(params)
        .filter(([, value]) => value !== undefined && value !== null)
        .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`)
        .join('&');
      if (queryString) {
        fullUrl += (url.includes('?') ? '&' : '?') + queryString;
      }
    }
    
    return this.request<T>({
      url: fullUrl,
      method: HttpMethod.GET,
      ...options
    });
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
    return this.request<T>({
      url,
      method: HttpMethod.POST,
      data,
      ...options
    });
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
    return this.request<T>({
      url,
      method: HttpMethod.PUT,
      data,
      ...options
    });
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
    return this.request<T>({
      url,
      method: HttpMethod.DELETE,
      ...options
    });
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
    const {
      url,
      method,
      data,
      headers = {},
      needAuth = true,
      timeout = ApiConfig.TIMEOUT,
      retryCount = 0,
      retryDelay = 1000,
      enableCache = false,
      cacheTime = 5 * 60 * 1000,
      source = 'ApiWrapper'
    } = options;
    
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
        const response = await this.pendingRequests.get(requestKey) as ApiResponse<T>;
        return ApiResult.success(response.data);
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
          return this.request<T>({
            ...options,
            retryCount: retryCount - 1
          });
        }
        
        return ApiResult.failure(appError);
      }
    };
    
    // 设置pending请求
    const requestPromise = executeRequest();
    if (method !== HttpMethod.GET) {
      this.pendingRequests.set(requestKey, requestPromise.then(r => {
        if (r.isSuccess) {
          return { code: 0, message: 'success', data: r.data! };
        }
        throw r.error;
      }) as Promise<ApiResponse<unknown>>);
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
    const { url, method, data, headers, needAuth, timeout, source } = options;
    
    // Mock模式
    if (ApiConfig.USE_MOCK_DATA) {
      return MockService.handleMockRequest<T>({
        url,
        method: method as unknown as import('../../utils/request').HttpMethod,
        data,
        headers,
        needAuth
      });
    }
    
    const fullUrl = url.startsWith('http') ? url : `${ApiConfig.BASE_URL}${url}`;
    
    // 构建请求头
    const requestHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      ...headers
    };
    
    if (needAuth) {
      const token = this.getToken();
      if (token) {
        requestHeaders['Authorization'] = `Bearer ${token}`;
      }
    }
    
    // 创建HTTP客户端
    const httpClient = http.createHttp();
    
    // 转换HTTP方法
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
      default:
        requestMethod = http.RequestMethod.GET;
    }
    
    const httpOptions: http.HttpRequestOptions = {
      method: requestMethod,
      header: requestHeaders,
      connectTimeout: timeout,
      readTimeout: timeout,
      extraData: method !== HttpMethod.GET && data ? JSON.stringify(data) : undefined
    };
    
    if (ApiConfig.ENABLE_LOGGING) {
      hilog.info(DOMAIN, TAG, `[${method}] ${fullUrl}`);
    }
    
    try {
      const response = await httpClient.request(fullUrl, httpOptions);
      
      // 检查HTTP状态码
      if (!response.responseCode || response.responseCode >= 400) {
        if (response.responseCode === 401) {
          this.handleUnauthorized();
          throw ErrorFactory.tokenExpired({ source, operation: url });
        }
        if (response.responseCode === 403) {
          throw ErrorFactory.permissionDenied({ source, operation: url });
        }
        throw ErrorFactory.network(`HTTP Error: ${response.responseCode}`, { source });
      }
      
      // 解析响应
      const result = JSON.parse(response.result as string) as ApiResponse<T>;
      
      if (ApiConfig.ENABLE_LOGGING) {
        hilog.info(DOMAIN, TAG, `Response: ${JSON.stringify(result).substring(0, 200)}`);
      }
      
      // 检查业务状态码
      if (result.code === 401 || result.code === 40100) {
        this.handleUnauthorized();
        throw ErrorFactory.tokenExpired({ source, operation: url });
      }
      
      if (result.code !== 0 && result.code !== 200) {
        throw new AppError(
          result.message || '业务处理失败',
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
    } finally {
      httpClient.destroy();
    }
  }
  
  /**
   * Get token
   */
  private static getToken(): string | null {
    return AppStorage.get<string>(this.TOKEN_KEY) ?? null;
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
    AppStorage.delete('user_info');
    AppStorage.delete('is_logged_in');
    
    try {
      router.replaceUrl({ url: 'pages/LoginPage' });
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
  get: ApiWrapper.get.bind(ApiWrapper),
  post: ApiWrapper.post.bind(ApiWrapper),
  put: ApiWrapper.put.bind(ApiWrapper),
  delete: ApiWrapper.delete.bind(ApiWrapper),
  request: ApiWrapper.request.bind(ApiWrapper),
  clearCache: ApiWrapper.clearCache.bind(ApiWrapper)
};
