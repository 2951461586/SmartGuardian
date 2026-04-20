/**
 * SmartGuardian - Error Handler
 * Unified error handling system
 * 
 * @description 统一错误处理器，提供错误捕获、转换和通知功能
 * @features
 * - 错误捕获和转换
 * - 错误日志记录
 * - 错误通知机制
 * - 错误恢复策略
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  AppError,
  ErrorCode,
  ErrorCategory,
  ErrorContext,
  NetworkError,
  AuthError,
  BusinessError,
  DataError,
  ErrorFactory
} from './AppError';

const TAG = 'ErrorHandler';
const DOMAIN = 0x0001;

/**
 * Error handler options
 * 
 * @description 错误处理器选项
 */
export interface ErrorHandlerOptions {
  /** 是否显示错误提示 */
  showToast?: boolean;
  
  /** 是否记录日志 */
  logError?: boolean;
  
  /** 错误来源 */
  source?: string;
  
  /** 操作名称 */
  operation?: string;
  
  /** 自定义错误消息映射 */
  messageMap?: Record<number, string>;
}

/**
 * Error handler callback
 * 
 * @description 错误处理回调类型
 */
export type ErrorHandlerCallback = (error: AppError) => void;

/**
 * Error Handler
 * 
 * @description 统一错误处理器
 * @class
 */
export class ErrorHandler {
  private static callbacks: ErrorHandlerCallback[] = [];
  private static messageMap: Record<number, string> = {
    [ErrorCode.NETWORK_ERROR]: '网络连接失败，请检查网络设置',
    [ErrorCode.NETWORK_TIMEOUT]: '请求超时，请稍后重试',
    [ErrorCode.NETWORK_UNAVAILABLE]: '网络不可用，请检查网络连接',
    [ErrorCode.AUTH_UNAUTHORIZED]: '请先登录',
    [ErrorCode.AUTH_TOKEN_EXPIRED]: '登录已过期，请重新登录',
    [ErrorCode.AUTH_TOKEN_INVALID]: '登录状态无效，请重新登录',
    [ErrorCode.AUTH_PERMISSION_DENIED]: '权限不足',
    [ErrorCode.BIZ_NOT_FOUND]: '请求的资源不存在',
    [ErrorCode.BIZ_INVALID_PARAM]: '参数错误',
    [ErrorCode.BIZ_OPERATION_FAILED]: '操作失败，请稍后重试',
    [ErrorCode.DATA_PARSE_ERROR]: '数据解析失败',
    [ErrorCode.UNKNOWN]: '发生未知错误'
  };
  
  /**
   * Register error callback
   * 
   * @description 注册错误处理回调
   * @param {ErrorHandlerCallback} callback - 回调函数
   * @returns {() => void} 取消注册函数
   */
  static onerror(callback: ErrorHandlerCallback): () => void {
    this.callbacks.push(callback);
    return () => {
      const index = this.callbacks.indexOf(callback);
      if (index > -1) {
        this.callbacks.splice(index, 1);
      }
    };
  }
  
  /**
   * Set message map
   * 
   * @description 设置错误消息映射
   * @param {Record<number, string>} map - 消息映射
   */
  static setMessageMap(map: Record<number, string>): void {
    this.messageMap = { ...this.messageMap, ...map };
  }
  
  /**
   * Get error message
   * 
   * @description 获取用户友好的错误消息
   * @param {AppError} error - 错误对象
   * @returns {string} 错误消息
   */
  static getErrorMessage(error: AppError): string {
    return this.messageMap[error.code] ?? error.message;
  }
  
  /**
   * Handle error
   * 
   * @description 处理错误
   * @param {Error | AppError} error - 错误对象
   * @param {ErrorHandlerOptions} options - 处理选项
   * @returns {AppError} 应用错误对象
   */
  static handle(error: Error | AppError, options?: ErrorHandlerOptions): AppError {
    const appError = this.convertToAppError(error, options);
    
    // 记录日志
    if (options?.logError !== false) {
      this.logError(appError);
    }
    
    // 触发回调
    this.callbacks.forEach(callback => {
      try {
        callback(appError);
      } catch (e) {
        hilog.error(DOMAIN, TAG, `Error callback failed: ${e}`);
      }
    });
    
    return appError;
  }
  
  /**
   * Convert to AppError
   * 
   * @description 将普通错误转换为 AppError
   * @param {Error | AppError} error - 错误对象
   * @param {ErrorHandlerOptions} options - 转换选项
   * @returns {AppError} 应用错误对象
   */
  static convertToAppError(error: Error | AppError, options?: ErrorHandlerOptions): AppError {
    if (error instanceof AppError) {
      return error;
    }
    
    const context: ErrorContext = {
      source: options?.source,
      operation: options?.operation,
      timestamp: Date.now(),
      originalError: error
    };
    
    // 根据错误消息判断错误类型
    const message = error.message.toLowerCase();
    
    if (message.includes('network') || message.includes('网络')) {
      return ErrorFactory.network(error.message, context);
    }
    
    if (message.includes('timeout') || message.includes('超时')) {
      return ErrorFactory.timeout(context);
    }
    
    if (message.includes('unauthorized') || message.includes('未授权') || message.includes('401')) {
      return ErrorFactory.unauthorized(context);
    }
    
    if (message.includes('forbidden') || message.includes('权限') || message.includes('403')) {
      return ErrorFactory.permissionDenied(context);
    }
    
    if (message.includes('not found') || message.includes('不存在') || message.includes('404')) {
      return ErrorFactory.notFound(error.message, context);
    }
    
    if (message.includes('parse') || message.includes('解析') || message.includes('json')) {
      return ErrorFactory.dataParse(error.message, context);
    }
    
    // 默认返回业务错误
    return new BusinessError(error.message, ErrorCode.BIZ_OPERATION_FAILED, { context });
  }
  
  /**
   * Log error
   * 
   * @description 记录错误日志
   * @param {AppError} error - 错误对象
   */
  static logError(error: AppError): void {
    const logMessage = `[${error.category}] ${error.code}: ${error.message}`;
    
    if (error.category === ErrorCategory.AUTH) {
      hilog.warn(DOMAIN, TAG, logMessage);
    } else if (error.category === ErrorCategory.NETWORK) {
      hilog.warn(DOMAIN, TAG, logMessage);
    } else {
      hilog.error(DOMAIN, TAG, logMessage);
    }
    
    // 记录上下文信息
    if (error.context) {
      hilog.debug(DOMAIN, TAG, `Context: ${JSON.stringify(error.context)}`);
    }
  }
  
  /**
   * Is retryable
   * 
   * @description 判断错误是否可重试
   * @param {AppError} error - 错误对象
   * @returns {boolean} 是否可重试
   */
  static isRetryable(error: AppError): boolean {
    return error.retryable;
  }
  
  /**
   * Is auth error
   * 
   * @description 判断是否为认证错误
   * @param {AppError} error - 错误对象
   * @returns {boolean} 是否为认证错误
   */
  static isAuthError(error: AppError): boolean {
    return error.category === ErrorCategory.AUTH;
  }
  
  /**
   * Is network error
   * 
   * @description 判断是否为网络错误
   * @param {AppError} error - 错误对象
   * @returns {boolean} 是否为网络错误
   */
  static isNetworkError(error: AppError): boolean {
    return error.category === ErrorCategory.NETWORK;
  }
  
  /**
   * Wrap async function
   * 
   * @description 包装异步函数，自动捕获错误
   * @param {Function} fn - 异步函数
   * @param {ErrorHandlerOptions} options - 处理选项
   * @returns {Function} 包装后的函数
   */
  static wrapAsync<T, Args extends unknown[]>(
    fn: (...args: Args) => Promise<T>,
    options?: ErrorHandlerOptions
  ): (...args: Args) => Promise<T | null> {
    return async (...args: Args): Promise<T | null> => {
      try {
        return await fn(...args);
      } catch (error) {
        this.handle(error as Error, options);
        return null;
      }
    };
  }
}

/**
 * Safe execute
 * 
 * @description 安全执行异步函数，捕获错误并返回结果
 * @param {Function} fn - 异步函数
 * @param {ErrorHandlerOptions} options - 处理选项
 * @returns {Promise<{data: T | null, error: AppError | null}>} 执行结果
 */
export async function safeExecute<T>(
  fn: () => Promise<T>,
  options?: ErrorHandlerOptions
): Promise<{ data: T | null; error: AppError | null }> {
  try {
    const data = await fn();
    return { data, error: null };
  } catch (error) {
    const appError = ErrorHandler.handle(error as Error, options);
    return { data: null, error: appError };
  }
}
