/**
 * SmartGuardian - API Wrapper
 * Unified API call wrapper with error handling and logging
 * 
 * @description 统一API调用包装器，提供错误处理、日志记录和重试机制
 * @features
 * - 统一错误处理
 * - 自动日志记录
 * - 请求重试
 * - 响应数据转换
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { ApiResponseHelper, ApiCode, ApiResponse } from '../models/common';
import { ErrorHandlerUtil, ErrorType, AppError } from './ErrorHandlerUtil';
import { LogUtil } from './LogUtil';

const TAG = 'ApiWrapper';
const DOMAIN = 0x0001;

/**
 * API Call Options
 */
export interface ApiCallOptions {
  /** 是否显示错误Toast */
  showErrorToast?: boolean;
  /** 是否记录日志 */
  enableLog?: boolean;
  /** 重试次数 */
  retryCount?: number;
  /** 重试延迟(ms) */
  retryDelay?: number;
  /** 自定义错误消息映射 */
  customErrorMsg?: Record<number, string>;
  /** 请求名称（用于日志） */
  requestName?: string;
}

/**
 * API Call Result
 */
export interface ApiCallResult<T> {
  /** 是否成功 */
  success: boolean;
  /** 响应数据 */
  data: T | null;
  /** 错误信息 */
  error: AppError | null;
  /** 原始响应 */
  rawResponse: ApiResponse<T> | null;
}

/**
 * API Wrapper Class
 * @description 统一API调用包装器
 */
export class ApiWrapper {
  /** 默认配置 */
  private static defaultOptions: ApiCallOptions = {
    showErrorToast: true,
    enableLog: true,
    retryCount: 0,
    retryDelay: 1000
  };

  /**
   * Wrap API call with unified error handling
   * @description 包装API调用，统一处理错误和日志
   * @param apiCall API调用函数
   * @param options 调用选项
   * @returns API调用结果
   */
  static async wrap<T>(
    apiCall: () => Promise<ApiResponse<T>>,
    options?: Partial<ApiCallOptions>
  ): Promise<ApiCallResult<T>> {
    const opts: ApiCallOptions = { ...ApiWrapper.defaultOptions, ...options };
    const requestName = opts.requestName || 'API';

    let lastError: AppError | null = null;
    let attemptCount = 0;
    const maxAttempts = (opts.retryCount || 0) + 1;

    while (attemptCount < maxAttempts) {
      attemptCount++;

      try {
        if (opts.enableLog) {
          LogUtil.info(TAG, `[${requestName}] Attempt ${attemptCount}/${maxAttempts}`);
        }

        const response = await apiCall();

        // 检查响应是否成功
        if (ApiResponseHelper.isSuccess(response.code)) {
          if (opts.enableLog) {
            LogUtil.info(TAG, `[${requestName}] Success`);
          }

          return {
            success: true,
            data: response.data,
            error: null,
            rawResponse: response
          };
        }

        // 处理业务错误
        const error = ApiWrapper.handleBusinessError(response, opts);
        lastError = error;

        // 认证错误不重试
        if (ApiResponseHelper.isAuthError(response.code)) {
          if (opts.showErrorToast) {
            ErrorHandlerUtil.showErrorToast(error.message);
          }
          break;
        }

        // 其他错误，判断是否需要重试
        if (attemptCount < maxAttempts) {
          if (opts.enableLog) {
            LogUtil.warn(TAG, `[${requestName}] Will retry after ${opts.retryDelay}ms`);
          }
          await ApiWrapper.delay(opts.retryDelay || 1000);
        }

      } catch (error) {
        // 网络或未知错误
        lastError = ApiWrapper.handleException(error, opts);

        if (attemptCount < maxAttempts) {
          await ApiWrapper.delay(opts.retryDelay || 1000);
        }
      }
    }

    // 所有尝试都失败
    if (lastError && opts.showErrorToast) {
      ErrorHandlerUtil.showErrorToast(lastError.message);
    }

    return {
      success: false,
      data: null,
      error: lastError,
      rawResponse: null
    };
  }

  /**
   * Wrap API call and throw on error
   * @description 包装API调用，失败时抛出异常
   * @param apiCall API调用函数
   * @param options 调用选项
   * @returns 响应数据
   * @throws AppError 当请求失败时抛出
   */
  static async wrapOrThrow<T>(
    apiCall: () => Promise<ApiResponse<T>>,
    options?: Partial<ApiCallOptions>
  ): Promise<T> {
    const result = await ApiWrapper.wrap(apiCall, { ...options, showErrorToast: false });

    if (!result.success || result.error) {
      throw result.error;
    }

    return result.data as T;
  }

  /**
   * Wrap API call with default value on error
   * @description 包装API调用，失败时返回默认值
   * @param apiCall API调用函数
   * @param defaultValue 默认值
   * @param options 调用选项
   * @returns 响应数据或默认值
   */
  static async wrapOrDefault<T>(
    apiCall: () => Promise<ApiResponse<T>>,
    defaultValue: T,
    options?: Partial<ApiCallOptions>
  ): Promise<T> {
    const result = await ApiWrapper.wrap(apiCall, options);
    return result.success ? (result.data as T) : defaultValue;
  }

  /**
   * Handle business error
   */
  private static handleBusinessError<T>(
    response: ApiResponse<T>,
    options: ApiCallOptions
  ): AppError {
    const errorCode = response.code;
    let errorMessage = response.message;

    // 应用自定义错误消息
    if (options.customErrorMsg && options.customErrorMsg[errorCode]) {
      errorMessage = options.customErrorMsg[errorCode];
    }

    const errorType = ApiWrapper.getErrorType(errorCode);

    return {
      code: errorCode,
      message: errorMessage || '请求失败',
      type: errorType
    };
  }

  /**
   * Handle exception error
   */
  private static handleException(error: Object, options: ApiCallOptions): AppError {
    LogUtil.error(TAG, `Exception: ${JSON.stringify(error)}`);

    // 判断是否为网络错误
    const errorStr = String(error);
    if (errorStr.includes('network') || errorStr.includes('timeout')) {
      return {
        code: ApiCode.REQUEST_TIMEOUT,
        message: '网络连接失败，请检查网络设置',
        type: ErrorType.NETWORK_ERROR
      };
    }

    return {
      code: ApiCode.INTERNAL_ERROR,
      message: '请求处理失败，请稍后重试',
      type: ErrorType.UNKNOWN_ERROR
    };
  }

  /**
   * Get error type from code
   */
  private static getErrorType(code: number): ErrorType {
    if (ApiResponseHelper.isAuthError(code)) {
      return ErrorType.AUTH_ERROR;
    }
    if (ApiResponseHelper.isClientError(code)) {
      return ErrorType.VALIDATION_ERROR;
    }
    if (ApiResponseHelper.isServerError(code)) {
      return ErrorType.NETWORK_ERROR;
    }
    return ErrorType.BUSINESS_ERROR;
  }

  /**
   * Delay helper
   */
  private static delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * Convenience function for wrapping API calls
 * @description 便捷的API调用包装函数
 */
export async function wrapApiCall<T>(
  requestName: string,
  apiCall: () => Promise<ApiResponse<T>>,
  options?: Partial<ApiCallOptions>
): Promise<ApiCallResult<T>> {
  return ApiWrapper.wrap(apiCall, { ...options, requestName });
}
