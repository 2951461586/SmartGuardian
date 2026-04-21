/**
 * SmartGuardian - Error Handler Utility
 * Centralized error handling for the application
 */

import { UIContext } from '@kit.ArkUI';
import { LogUtil } from './LogUtil';

export interface AppError {
  code: number;
  message: string;
  type: ErrorType;
}

export interface ApiErrorResponse {
  code?: number;
  message?: string;
}

interface ToastOptions {
  message: string;
  duration: number;
}

export enum ErrorType {
  NETWORK_ERROR = 'NETWORK_ERROR',
  AUTH_ERROR = 'AUTH_ERROR',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  BUSINESS_ERROR = 'BUSINESS_ERROR',
  UNKNOWN_ERROR = 'UNKNOWN_ERROR'
}

export class ErrorHandlerUtil {
  private static readonly TAG: string = 'ErrorHandler';
  private static uiContext: UIContext | null = null;

  /**
   * Handle API response error
   */
  static handleApiError(response: ApiErrorResponse): AppError {
    const errorCode: number = response.code ? response.code : -1;
    const errorMessage: string = response.message ? response.message : '请求失败';

    let errorType: ErrorType = ErrorType.BUSINESS_ERROR;

    if (errorCode === 401 || errorCode === 403) {
      errorType = ErrorType.AUTH_ERROR;
    } else if (errorCode >= 400 && errorCode < 500) {
      errorType = ErrorType.VALIDATION_ERROR;
    } else if (errorCode >= 500) {
      errorType = ErrorType.NETWORK_ERROR;
    }

    const error: AppError = {
      code: errorCode,
      message: ErrorHandlerUtil.getLocalizedErrorMessage(errorCode, errorMessage),
      type: errorType
    };

    LogUtil.error(ErrorHandlerUtil.TAG, `API Error: ${JSON.stringify(error)}`);
    return error;
  }

  /**
   * Handle network error
   */
  static handleNetworkError(error: Object): AppError {
    LogUtil.error(ErrorHandlerUtil.TAG, `Network Error: ${JSON.stringify(error)}`);

    return {
      code: -1,
      message: '网络连接失败，请检查网络设置后重试',
      type: ErrorType.NETWORK_ERROR
    };
  }

  /**
   * Handle unknown error
   */
  static handleUnknownError(error: Object): AppError {
    LogUtil.error(ErrorHandlerUtil.TAG, `Unknown Error: ${JSON.stringify(error)}`);

    return {
      code: -999,
      message: '发生未知错误，请稍后重试',
      type: ErrorType.UNKNOWN_ERROR
    };
  }

  static setUIContext(uiContext: UIContext): void {
    ErrorHandlerUtil.uiContext = uiContext;
  }

  static replaceUrl(url: string): void {
    try {
      const uiContext = ErrorHandlerUtil.uiContext;
      if (!uiContext) {
        LogUtil.error(ErrorHandlerUtil.TAG, `Replace url skipped: ${url}`);
        return;
      }

      uiContext.getRouter().replaceUrl({ url: url });
    } catch (error) {
      LogUtil.error(ErrorHandlerUtil.TAG, `Replace url failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Show error toast
   */
  static showErrorToast(message: string, duration: number = 2000): void {
    try {
      const uiContext = ErrorHandlerUtil.uiContext;
      const toastOptions: ToastOptions = {
        message: message,
        duration: duration
      };

      if (uiContext) {
        uiContext.getPromptAction().showToast(toastOptions);
        return;
      }

      LogUtil.error(ErrorHandlerUtil.TAG, `Show toast skipped: ${message}`);
    } catch (error) {
      LogUtil.error(ErrorHandlerUtil.TAG, `Show toast failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Show success toast
   */
  static showSuccessToast(message: string): void {
    try {
      const uiContext = ErrorHandlerUtil.uiContext;
      const toastOptions: ToastOptions = {
        message: message,
        duration: 1500
      };

      if (uiContext) {
        uiContext.getPromptAction().showToast(toastOptions);
        return;
      }

      LogUtil.error(ErrorHandlerUtil.TAG, `Show toast skipped: ${message}`);
    } catch (error) {
      LogUtil.error(ErrorHandlerUtil.TAG, `Show toast failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Get localized error message
   */
  private static getLocalizedErrorMessage(code: number, defaultMessage: string): string {
    if (code === 400) {
      return '请求参数错误';
    }
    if (code === 401) {
      return '登录已过期，请重新登录';
    }
    if (code === 403) {
      return '没有权限执行此操作';
    }
    if (code === 404) {
      return '请求的资源不存在';
    }
    if (code === 408) {
      return '请求超时，请重试';
    }
    if (code === 409) {
      return '资源冲突';
    }
    if (code === 500) {
      return '服务器错误，请稍后重试';
    }
    if (code === 502) {
      return '网关错误';
    }
    if (code === 503) {
      return '服务暂时不可用';
    }
    if (code === 504) {
      return '网关超时';
    }
    return defaultMessage;
  }

  /**
   * Validate required fields
   */
  static validateRequired(value: string | undefined | null, fieldName: string): boolean {
    if (!value || value.trim().length === 0) {
      ErrorHandlerUtil.showErrorToast(`${fieldName}不能为空`);
      return false;
    }
    return true;
  }

  /**
   * Validate phone number
   */
  static validatePhone(phone: string): boolean {
    if (phone.trim().length === 0) {
      ErrorHandlerUtil.showErrorToast('手机号不能为空');
      return false;
    }

    const phoneRegex: RegExp = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(phone)) {
      ErrorHandlerUtil.showErrorToast('请输入正确的手机号');
      return false;
    }

    return true;
  }

  /**
   * Validate password strength
   */
  static validatePassword(password: string): boolean {
    if (password.length < 6) {
      ErrorHandlerUtil.showErrorToast('密码长度至少为6位');
      return false;
    }

    if (password.length > 20) {
      ErrorHandlerUtil.showErrorToast('密码长度不能超过20位');
      return false;
    }

    return true;
  }

  /**
   * Validate verification code
   */
  static validateCode(code: string): boolean {
    if (code.length !== 6) {
      ErrorHandlerUtil.showErrorToast('请输入6位验证码');
      return false;
    }

    return true;
  }
}
