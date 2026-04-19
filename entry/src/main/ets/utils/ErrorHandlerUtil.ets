/**
 * SmartGuardian - Error Handler Utility
 * Centralized error handling for the application
 */

import { promptAction } from '@kit.ArkUI';
import { LogUtil } from './LogUtil';

export interface AppError {
  code: number;
  message: string;
  type: ErrorType;
}

export enum ErrorType {
  NETWORK_ERROR = 'NETWORK_ERROR',
  AUTH_ERROR = 'AUTH_ERROR',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  BUSINESS_ERROR = 'BUSINESS_ERROR',
  UNKNOWN_ERROR = 'UNKNOWN_ERROR'
}

export class ErrorHandlerUtil {
  private static readonly TAG = 'ErrorHandler';

  /**
   * Handle API response error
   */
  static handleApiError(response: ESObject): AppError {
    const errorCode = response.code || -1;
    const errorMessage = response.message || '请求失败';

    let errorType: ErrorType;
    
    // Categorize error
    if (errorCode === 401 || errorCode === 403) {
      errorType = ErrorType.AUTH_ERROR;
    } else if (errorCode >= 400 && errorCode < 500) {
      errorType = ErrorType.VALIDATION_ERROR;
    } else if (errorCode >= 500) {
      errorType = ErrorType.NETWORK_ERROR;
    } else {
      errorType = ErrorType.BUSINESS_ERROR;
    }

    const error: AppError = {
      code: errorCode,
      message: this.getLocalizedErrorMessage(errorCode, errorMessage),
      type: errorType
    };

    LogUtil.error(this.TAG, `API Error: ${JSON.stringify(error)}`);
    
    return error;
  }

  /**
   * Handle network error
   */
  static handleNetworkError(error: ESObject): AppError {
    LogUtil.error(this.TAG, `Network Error: ${JSON.stringify(error)}`);
    
    return {
      code: -1,
      message: '网络连接失败，请检查网络设置后重试',
      type: ErrorType.NETWORK_ERROR
    };
  }

  /**
   * Handle unknown error
   */
  static handleUnknownError(error: ESObject): AppError {
    LogUtil.error(this.TAG, `Unknown Error: ${JSON.stringify(error)}`);
    
    return {
      code: -999,
      message: '发生未知错误，请稍后重试',
      type: ErrorType.UNKNOWN_ERROR
    };
  }

  /**
   * Show error toast
   */
  static showErrorToast(message: string, duration: number = 2000): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration
      });
    } catch (error) {
      LogUtil.error(this.TAG, `Show toast failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Show success toast
   */
  static showSuccessToast(message: string): void {
    try {
      promptAction.showToast({
        message: message,
        duration: 1500
      });
    } catch (error) {
      LogUtil.error(this.TAG, `Show toast failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Get localized error message
   */
  private static getLocalizedErrorMessage(code: number, defaultMessage: string): string {
    const errorMessages: Record<number, string> = {
      400: '请求参数错误',
      401: '登录已过期，请重新登录',
      403: '没有权限执行此操作',
      404: '请求的资源不存在',
      408: '请求超时，请重试',
      409: '资源冲突',
      500: '服务器错误，请稍后重试',
      502: '网关错误',
      503: '服务暂时不可用',
      504: '网关超时'
    };

    return errorMessages[code] || defaultMessage;
  }

  /**
   * Validate required fields
   */
  static validateRequired(value: string | undefined | null, fieldName: string): boolean {
    if (!value || value.trim().length === 0) {
      this.showErrorToast(`${fieldName}不能为空`);
      return false;
    }
    return true;
  }

  /**
   * Validate phone number
   */
  static validatePhone(phone: string): boolean {
    if (!phone || phone.trim().length === 0) {
      this.showErrorToast('手机号不能为空');
      return false;
    }
    
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(phone)) {
      this.showErrorToast('请输入正确的手机号');
      return false;
    }
    
    return true;
  }

  /**
   * Validate password strength
   */
  static validatePassword(password: string): boolean {
    if (!password || password.length < 6) {
      this.showErrorToast('密码长度至少为6位');
      return false;
    }
    
    if (password.length > 20) {
      this.showErrorToast('密码长度不能超过20位');
      return false;
    }
    
    return true;
  }

  /**
   * Validate verification code
   */
  static validateCode(code: string): boolean {
    if (!code || code.length !== 6) {
      this.showErrorToast('请输入6位验证码');
      return false;
    }
    
    return true;
  }
}
