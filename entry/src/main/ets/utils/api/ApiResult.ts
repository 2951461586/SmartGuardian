/**
 * SmartGuardian - API Result
 * Type-safe API response wrapper
 * 
 * @description 类型安全的 API 响应封装，提供统一的结果处理方式
 * @features
 * - 类型安全的结果封装
 * - 成功/失败状态判断
 * - 链式调用支持
 * - 错误信息封装
 */

import { AppError } from '../errors';

/**
 * API Result
 * 
 * @description API 调用结果封装
 * @template T - 成功时的数据类型
 */
export class ApiResult<T> {
  private readonly _success: boolean;
  private readonly _data: T | null;
  private readonly _error: AppError | null;
  
  /**
   * Constructor
   * 
   * @param {boolean} success - 是否成功
   * @param {T | null} data - 数据
   * @param {AppError | null} error - 错误
   */
  private constructor(success: boolean, data: T | null, error: AppError | null) {
    this._success = success;
    this._data = data;
    this._error = error;
  }
  
  /**
   * Is success
   * 
   * @description 判断是否成功
   * @returns {boolean} 是否成功
   */
  get isSuccess(): boolean {
    return this._success;
  }
  
  /**
   * Is failure
   * 
   * @description 判断是否失败
   * @returns {boolean} 是否失败
   */
  get isFailure(): boolean {
    return !this._success;
  }
  
  /**
   * Get data
   * 
   * @description 获取数据（成功时有效）
   * @returns {T | null} 数据
   */
  get data(): T | null {
    return this._data;
  }
  
  /**
   * Get error
   * 
   * @description 获取错误（失败时有效）
   * @returns {AppError | null} 错误
   */
  get error(): AppError | null {
    return this._error;
  }
  
  /**
   * Get data or default
   * 
   * @description 获取数据，失败时返回默认值
   * @param {T} defaultValue - 默认值
   * @returns {T} 数据或默认值
   */
  getOrElse(defaultValue: T): T {
    return this._success ? this._data! : defaultValue;
  }
  
  /**
   * Get data or throw
   * 
   * @description 获取数据，失败时抛出错误
   * @returns {T} 数据
   * @throws {AppError} 失败时抛出错误
   */
  getOrThrow(): T {
    if (this._success) {
      return this._data!;
    }
    throw this._error!;
  }
  
  /**
   * Map
   * 
   * @description 转换成功时的数据
   * @template U - 转换后的数据类型
   * @param {(data: T) => U} fn - 转换函数
   * @returns {ApiResult<U>} 转换后的结果
   */
  map<U>(fn: (data: T) => U): ApiResult<U> {
    if (this._success) {
      return ApiResult.success(fn(this._data!));
    }
    return ApiResult.failure<U>(this._error!);
  }
  
  /**
   * Flat map
   * 
   * @description 扁平映射
   * @template U - 转换后的数据类型
   * @param {(data: T) => ApiResult<U>} fn - 转换函数
   * @returns {ApiResult<U>} 转换后的结果
   */
  flatMap<U>(fn: (data: T) => ApiResult<U>): ApiResult<U> {
    if (this._success) {
      return fn(this._data!);
    }
    return ApiResult.failure<U>(this._error!);
  }
  
  /**
   * On success
   * 
   * @description 成功时执行回调
   * @param {(data: T) => void} fn - 回调函数
   * @returns {ApiResult<T>} 当前结果
   */
  onSuccess(fn: (data: T) => void): ApiResult<T> {
    if (this._success) {
      fn(this._data!);
    }
    return this;
  }
  
  /**
   * On failure
   * 
   * @description 失败时执行回调
   * @param {(error: AppError) => void} fn - 回调函数
   * @returns {ApiResult<T>} 当前结果
   */
  onFailure(fn: (error: AppError) => void): ApiResult<T> {
    if (!this._success) {
      fn(this._error!);
    }
    return this;
  }
  
  /**
   * Recover
   * 
   * @description 失败时恢复
   * @param {(error: AppError) => T} fn - 恢复函数
   * @returns {ApiResult<T>} 恢复后的结果
   */
  recover(fn: (error: AppError) => T): ApiResult<T> {
    if (this._success) {
      return this;
    }
    return ApiResult.success(fn(this._error!));
  }
  
  /**
   * Create success result
   * 
   * @description 创建成功结果
   * @template T - 数据类型
   * @param {T} data - 数据
   * @returns {ApiResult<T>} 成功结果
   */
  static success<T>(data: T): ApiResult<T> {
    return new ApiResult<T>(true, data, null);
  }
  
  /**
   * Create failure result
   * 
   * @description 创建失败结果
   * @template T - 数据类型
   * @param {AppError} error - 错误
   * @returns {ApiResult<T>} 失败结果
   */
  static failure<T>(error: AppError): ApiResult<T> {
    return new ApiResult<T>(false, null, error);
  }
  
  /**
   * From promise
   * 
   * @description 从 Promise 创建结果
   * @template T - 数据类型
   * @param {Promise<T>} promise - Promise 对象
   * @returns {Promise<ApiResult<T>>} API 结果
   */
  static async fromPromise<T>(promise: Promise<T>): Promise<ApiResult<T>> {
    try {
      const data = await promise;
      return ApiResult.success(data);
    } catch (error) {
      const { ErrorHandler } = require('../errors/ErrorHandler');
      const appError = ErrorHandler.handle(error as Error);
      return ApiResult.failure<T>(appError);
    }
  }
}

/**
 * Paginated result
 * 
 * @description 分页结果封装
 * @template T - 数据项类型
 */
export interface PaginatedResult<T> {
  /** 数据列表 */
  list: T[];
  
  /** 总数 */
  total: number;
  
  /** 当前页码 */
  pageNum: number;
  
  /** 每页数量 */
  pageSize: number;
  
  /** 总页数 */
  totalPages: number;
  
  /** 是否有下一页 */
  hasNext: boolean;
  
  /** 是否有上一页 */
  hasPrev: boolean;
}

/**
 * Create paginated result
 * 
 * @description 创建分页结果
 * @template T - 数据项类型
 * @param {T[]} list - 数据列表
 * @param {number} total - 总数
 * @param {number} pageNum - 当前页码
 * @param {number} pageSize - 每页数量
 * @returns {PaginatedResult<T>} 分页结果
 */
export function createPaginatedResult<T>(
  list: T[],
  total: number,
  pageNum: number,
  pageSize: number
): PaginatedResult<T> {
  const totalPages = Math.ceil(total / pageSize);
  return {
    list,
    total,
    pageNum,
    pageSize,
    totalPages,
    hasNext: pageNum < totalPages,
    hasPrev: pageNum > 1
  };
}
