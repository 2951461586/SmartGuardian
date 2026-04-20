/**
 * SmartGuardian - Error Messages
 * Unified error message constants with i18n support
 * 
 * @description 统一错误消息常量，支持国际化
 * @features
 * - 网络错误消息
 * - 业务错误消息
 * - 验证错误消息
 * - 系统错误消息
 */

/**
 * Error Message Category
 */
export enum ErrorCategory {
  /** 网络错误 */
  NETWORK = 'NETWORK',
  /** 认证错误 */
  AUTH = 'AUTH',
  /** 业务错误 */
  BUSINESS = 'BUSINESS',
  /** 验证错误 */
  VALIDATION = 'VALIDATION',
  /** 系统错误 */
  SYSTEM = 'SYSTEM'
}

/**
 * Error Messages Class
 * @description 错误消息常量类
 */
export class ErrorMessages {
  // ============================================
  // Network Errors (网络错误)
  // ============================================
  
  /** 网络连接失败 */
  static readonly NETWORK_ERROR = '网络连接失败，请检查网络设置后重试';
  /** 网络超时 */
  static readonly NETWORK_TIMEOUT = '网络请求超时，请稍后重试';
  /** 服务器错误 */
  static readonly SERVER_ERROR = '服务器错误，请稍后重试';
  /** 服务不可用 */
  static readonly SERVICE_UNAVAILABLE = '服务暂时不可用，请稍后重试';
  /** 请求失败 */
  static readonly REQUEST_FAILED = '请求失败，请重试';

  // ============================================
  // Auth Errors (认证错误)
  // ============================================
  
  /** 登录过期 */
  static readonly AUTH_EXPIRED = '登录已过期，请重新登录';
  /** 未授权 */
  static readonly UNAUTHORIZED = '未授权，请先登录';
  /** 无权限 */
  static readonly FORBIDDEN = '没有权限执行此操作';
  /** 登录失败 */
  static readonly LOGIN_FAILED = '登录失败，请检查账号密码';
  /** 账号或密码错误 */
  static readonly INVALID_CREDENTIALS = '账号或密码错误';
  /** Token无效 */
  static readonly INVALID_TOKEN = '登录状态无效，请重新登录';

  // ============================================
  // Business Errors (业务错误)
  // ============================================
  
  /** 数据加载失败 */
  static readonly DATA_LOAD_FAILED = '数据加载失败，请重试';
  /** 数据保存失败 */
  static readonly DATA_SAVE_FAILED = '数据保存失败，请重试';
  /** 操作失败 */
  static readonly OPERATION_FAILED = '操作失败，请重试';
  /** 操作成功 */
  static readonly OPERATION_SUCCESS = '操作成功';
  
  /** 订单相关 */
  static readonly ORDER_LOAD_FAILED = '加载订单失败';
  static readonly ORDER_CREATE_FAILED = '创建订单失败';
  static readonly ORDER_AUDIT_FAILED = '审核订单失败';
  static readonly ORDER_CANCEL_FAILED = '取消订单失败';
  
  /** 考勤相关 */
  static readonly ATTENDANCE_LOAD_FAILED = '加载考勤记录失败';
  static readonly SIGN_IN_FAILED = '签到失败';
  static readonly SIGN_OUT_FAILED = '签退失败';
  static readonly LEAVE_SUBMIT_FAILED = '请假申请失败';
  
  /** 作业相关 */
  static readonly HOMEWORK_LOAD_FAILED = '加载作业失败';
  static readonly HOMEWORK_SUBMIT_FAILED = '提交作业失败';
  static readonly HOMEWORK_FEEDBACK_FAILED = '提交反馈失败';
  
  /** 学生相关 */
  static readonly STUDENT_LOAD_FAILED = '加载学生信息失败';
  static readonly STUDENT_NOT_FOUND = '未找到学生信息';
  
  /** 支付相关 */
  static readonly PAYMENT_FAILED = '支付失败';
  static readonly PAYMENT_CANCELLED = '支付已取消';
  static readonly REFUND_FAILED = '退款申请失败';

  // ============================================
  // Validation Errors (验证错误)
  // ============================================
  
  /** 必填项为空 */
  static readonly REQUIRED_FIELD = '此项为必填项';
  /** 请输入账号和密码 */
  static readonly INPUT_ACCOUNT_PASSWORD = '请输入账号和密码';
  /** 手机号格式错误 */
  static readonly INVALID_PHONE = '请输入正确的手机号';
  /** 密码长度错误 */
  static readonly INVALID_PASSWORD_LENGTH = '密码长度应为6-20位';
  /** 验证码错误 */
  static readonly INVALID_CODE = '验证码错误';
  /** 请输入6位验证码 */
  static readonly INVALID_CODE_LENGTH = '请输入6位验证码';
  /** 请同意隐私协议 */
  static readonly AGREE_PRIVACY = '请同意隐私协议';

  // ============================================
  // System Errors (系统错误)
  // ============================================
  
  /** 未知错误 */
  static readonly UNKNOWN_ERROR = '发生未知错误，请稍后重试';
  /** 功能开发中 */
  static readonly FEATURE_IN_DEVELOPMENT = '功能开发中，敬请期待';
  /** 暂不支持 */
  static readonly NOT_SUPPORTED = '当前版本暂不支持此功能';

  // ============================================
  // Success Messages (成功消息)
  // ============================================
  
  /** 保存成功 */
  static readonly SAVE_SUCCESS = '保存成功';
  /** 提交成功 */
  static readonly SUBMIT_SUCCESS = '提交成功';
  /** 删除成功 */
  static readonly DELETE_SUCCESS = '删除成功';
  /** 更新成功 */
  static readonly UPDATE_SUCCESS = '更新成功';
  /** 登出成功 */
  static readonly LOGOUT_SUCCESS = '已安全退出';
}

/**
 * Error Message Helper
 * @description 错误消息工具类
 */
export class ErrorMessageHelper {
  /**
   * Get error message by code
   * @param code 错误码
   * @param defaultMessage 默认消息
   * @returns 错误消息
   */
  static getErrorMessage(code: number, defaultMessage?: string): string {
    const messageMap: Record<number, string> = {
      400: '请求参数错误',
      401: ErrorMessages.AUTH_EXPIRED,
      403: ErrorMessages.FORBIDDEN,
      404: '请求的资源不存在',
      408: ErrorMessages.NETWORK_TIMEOUT,
      409: '资源冲突',
      500: ErrorMessages.SERVER_ERROR,
      502: '网关错误',
      503: ErrorMessages.SERVICE_UNAVAILABLE,
      504: '网关超时'
    };

    return messageMap[code] || defaultMessage || ErrorMessages.UNKNOWN_ERROR;
  }

  /**
   * Get error category by code
   * @param code 错误码
   * @returns 错误类别
   */
  static getErrorCategory(code: number): ErrorCategory {
    if (code === 401 || code === 403) {
      return ErrorCategory.AUTH;
    }
    if (code >= 400 && code < 500) {
      return ErrorCategory.VALIDATION;
    }
    if (code >= 500) {
      return ErrorCategory.NETWORK;
    }
    return ErrorCategory.BUSINESS;
  }

  /**
   * Format error message with params
   * @param message 消息模板
   * @param params 参数
   * @returns 格式化后的消息
   */
  static format(message: string, ...params: string[]): string {
    let result = message;
    params.forEach((param: string, index: number) => {
      result = result.replace(`{${index}}`, param);
    });
    return result;
  }
}
