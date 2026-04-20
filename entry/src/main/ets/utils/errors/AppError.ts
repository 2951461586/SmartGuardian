/**
 * SmartGuardian - Application Error Types
 * Unified error handling system
 * 
 * @description 应用错误类型定义，提供统一的错误处理机制
 * @features
 * - 类型安全的错误分类
 * - 错误代码标准化
 * - 错误信息国际化支持
 * - 错误上下文信息
 */

/**
 * Error code enumeration
 * 
 * @description 错误代码枚举
 */
export enum ErrorCode {
  // 网络错误 (1000-1999)
  NETWORK_ERROR = 1000,
  NETWORK_TIMEOUT = 1001,
  NETWORK_UNAVAILABLE = 1002,
  
  // 认证错误 (2000-2999)
  AUTH_UNAUTHORIZED = 2000,
  AUTH_TOKEN_EXPIRED = 2001,
  AUTH_TOKEN_INVALID = 2002,
  AUTH_PERMISSION_DENIED = 2003,
  AUTH_LOGIN_FAILED = 2004,
  
  // 业务错误 (3000-3999)
  BIZ_NOT_FOUND = 3000,
  BIZ_ALREADY_EXISTS = 3001,
  BIZ_INVALID_PARAM = 3002,
  BIZ_OPERATION_FAILED = 3003,
  BIZ_STATE_INVALID = 3004,
  
  // 数据错误 (4000-4999)
  DATA_PARSE_ERROR = 4000,
  DATA_VALIDATION_ERROR = 4001,
  DATA_EMPTY_ERROR = 4002,
  
  // 未知错误
  UNKNOWN = 9999
}

/**
 * Error category
 * 
 * @description 错误分类
 */
export enum ErrorCategory {
  NETWORK = 'NETWORK',
  AUTH = 'AUTH',
  BUSINESS = 'BUSINESS',
  DATA = 'DATA',
  UNKNOWN = 'UNKNOWN'
}

/**
 * Error context
 * 
 * @description 错误上下文信息
 */
export interface ErrorContext {
  /** 错误来源（模块或组件名） */
  source?: string;
  
  /** 操作名称 */
  operation?: string;
  
  /** 请求ID */
  requestId?: string;
  
  /** 时间戳 */
  timestamp?: number;
  
  /** 原始错误 */
  originalError?: Error;
  
  /** 附加数据 */
  [key: string]: unknown;
}

/**
 * Application Error
 * 
 * @description 应用错误基类
 * @class
 * @extends Error
 */
export class AppError extends Error {
  /** 错误代码 */
  readonly code: ErrorCode;
  
  /** 错误分类 */
  readonly category: ErrorCategory;
  
  /** HTTP状态码 */
  readonly httpStatus?: number;
  
  /** 错误上下文 */
  readonly context?: ErrorContext;
  
  /** 是否可重试 */
  readonly retryable: boolean;
  
  /**
   * Constructor
   * 
   * @param {string} message - 错误消息
   * @param {ErrorCode} code - 错误代码
   * @param {ErrorCategory} category - 错误分类
   * @param {Object} options - 附加选项
   */
  constructor(
    message: string,
    code: ErrorCode,
    category: ErrorCategory,
    options?: {
      httpStatus?: number;
      context?: ErrorContext;
      retryable?: boolean;
      cause?: Error;
    }
  ) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.category = category;
    this.httpStatus = options?.httpStatus;
    this.context = options?.context;
    this.retryable = options?.retryable ?? false;
    
    // 设置原型链
    Object.setPrototypeOf(this, AppError.prototype);
  }
  
  /**
   * To JSON
   * 
   * @description 序列化错误信息
   * @returns {object} JSON对象
   */
  toJSON(): object {
    return {
      name: this.name,
      message: this.message,
      code: this.code,
      category: this.category,
      httpStatus: this.httpStatus,
      context: this.context,
      retryable: this.retryable
    };
  }
  
  /**
   * Create from error
   * 
   * @description 从普通错误创建 AppError
   * @param {Error} error - 原始错误
   * @param {ErrorContext} context - 错误上下文
   * @returns {AppError} 应用错误
   */
  static fromError(error: Error, context?: ErrorContext): AppError {
    if (error instanceof AppError) {
      return error;
    }
    return new AppError(
      error.message || '未知错误',
      ErrorCode.UNKNOWN,
      ErrorCategory.UNKNOWN,
      { context: { ...context, originalError: error } }
    );
  }
}

/**
 * Network Error
 * 
 * @description 网络错误
 */
export class NetworkError extends AppError {
  constructor(
    message: string = '网络请求失败',
    code: ErrorCode = ErrorCode.NETWORK_ERROR,
    options?: {
      context?: ErrorContext;
      retryable?: boolean;
    }
  ) {
    super(message, code, ErrorCategory.NETWORK, {
      ...options,
      retryable: options?.retryable ?? true
    });
    this.name = 'NetworkError';
    Object.setPrototypeOf(this, NetworkError.prototype);
  }
}

/**
 * Auth Error
 * 
 * @description 认证错误
 */
export class AuthError extends AppError {
  constructor(
    message: string = '认证失败',
    code: ErrorCode = ErrorCode.AUTH_UNAUTHORIZED,
    options?: {
      httpStatus?: number;
      context?: ErrorContext;
    }
  ) {
    super(message, code, ErrorCategory.AUTH, {
      ...options,
      retryable: false
    });
    this.name = 'AuthError';
    Object.setPrototypeOf(this, AuthError.prototype);
  }
}

/**
 * Business Error
 * 
 * @description 业务错误
 */
export class BusinessError extends AppError {
  constructor(
    message: string,
    code: ErrorCode = ErrorCode.BIZ_OPERATION_FAILED,
    options?: {
      context?: ErrorContext;
      retryable?: boolean;
    }
  ) {
    super(message, code, ErrorCategory.BUSINESS, options);
    this.name = 'BusinessError';
    Object.setPrototypeOf(this, BusinessError.prototype);
  }
}

/**
 * Data Error
 * 
 * @description 数据错误
 */
export class DataError extends AppError {
  constructor(
    message: string,
    code: ErrorCode = ErrorCode.DATA_PARSE_ERROR,
    options?: {
      context?: ErrorContext;
    }
  ) {
    super(message, code, ErrorCategory.DATA, {
      ...options,
      retryable: false
    });
    this.name = 'DataError';
    Object.setPrototypeOf(this, DataError.prototype);
  }
}

/**
 * Error factory
 * 
 * @description 错误工厂方法
 */
export const ErrorFactory = {
  /**
   * Create network error
   */
  network(message?: string, context?: ErrorContext): NetworkError {
    return new NetworkError(message, ErrorCode.NETWORK_ERROR, { context });
  },
  
  /**
   * Create timeout error
   */
  timeout(context?: ErrorContext): NetworkError {
    return new NetworkError('请求超时', ErrorCode.NETWORK_TIMEOUT, {
      context,
      retryable: true
    });
  },
  
  /**
   * Create unauthorized error
   */
  unauthorized(context?: ErrorContext): AuthError {
    return new AuthError('未授权，请先登录', ErrorCode.AUTH_UNAUTHORIZED, {
      httpStatus: 401,
      context
    });
  },
  
  /**
   * Create token expired error
   */
  tokenExpired(context?: ErrorContext): AuthError {
    return new AuthError('登录已过期，请重新登录', ErrorCode.AUTH_TOKEN_EXPIRED, {
      httpStatus: 401,
      context
    });
  },
  
  /**
   * Create permission denied error
   */
  permissionDenied(context?: ErrorContext): AuthError {
    return new AuthError('权限不足', ErrorCode.AUTH_PERMISSION_DENIED, {
      httpStatus: 403,
      context
    });
  },
  
  /**
   * Create not found error
   */
  notFound(message: string = '资源不存在', context?: ErrorContext): BusinessError {
    return new BusinessError(message, ErrorCode.BIZ_NOT_FOUND, {
      context,
      httpStatus: 404
    });
  },
  
  /**
   * Create invalid param error
   */
  invalidParam(message: string, context?: ErrorContext): BusinessError {
    return new BusinessError(message, ErrorCode.BIZ_INVALID_PARAM, { context });
  },
  
  /**
   * Create data parse error
   */
  dataParse(message: string = '数据解析失败', context?: ErrorContext): DataError {
    return new DataError(message, ErrorCode.DATA_PARSE_ERROR, { context });
  }
};
