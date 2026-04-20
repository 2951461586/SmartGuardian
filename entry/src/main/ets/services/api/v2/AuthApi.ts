/**
 * SmartGuardian - Auth API (V2) [BETA]
 * Authentication API using ApiWrapper
 * 
 * @description 使用 ApiWrapper 的认证 API 服务（实验版本）
 * @beta 此模块为实验版本，尚未启用
 * @status RESERVED - 预留架构，暂未投入使用
 * 
 * @features
 * - 类型安全的 API 调用
 * - 统一的错误处理
 * - 自动重试机制
 * - 结果链式处理
 * 
 * @note 当前项目使用 v1 AuthService (../auth.ts)，此模块为未来 API 升级预留
 * @see ../auth.ts - 当前生产环境认证服务
 */

import { api, ApiResult } from '../../utils/api';
import { HttpMethod } from '../../utils/api/ApiWrapper';
import {
  LoginRequest,
  LoginResponse,
  UserInfo,
  Student,
  StudentCreateRequest,
  GuardianRelation
} from '../../models/user';
import { PageResponse } from '../../models/common';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Auth API (V2)
 * 
 * @description 认证服务类
 * @class
 * @example
 * ```typescript
 * // 登录
 * const result = await AuthApi.login({ phone: '13800138000', password: '123456' });
 * 
 * result
 *   .onSuccess(data => {
 *     UserStore.setUserInfo(data.userInfo);
 *     router.replaceUrl({ url: 'pages/MainPage' });
 *   })
 *   .onFailure(error => {
 *     promptAction.showToast({ message: error.message });
 *   });
 * ```
 */
export class AuthApi {
  /**
   * User login
   * 
   * @description 用户登录
   * @param {LoginRequest} data - 登录数据
   * @returns {Promise<ApiResult<LoginResponse>>} 登录结果
   */
  static async login(data: LoginRequest): Promise<ApiResult<LoginResponse>> {
    return api.post<LoginResponse>(ApiEndpoints.AUTH_LOGIN, data, {
      needAuth: false,
      source: 'AuthApi.login'
    });
  }
  
  /**
   * User logout
   * 
   * @description 用户登出
   * @returns {Promise<ApiResult<null>>} 登出结果
   */
  static async logout(): Promise<ApiResult<null>> {
    return api.post<null>(ApiEndpoints.AUTH_LOGOUT, undefined, {
      source: 'AuthApi.logout'
    });
  }
  
  /**
   * Get current user info
   * 
   * @description 获取当前用户信息
   * @returns {Promise<ApiResult<UserInfo>>} 用户信息结果
   */
  static async getCurrentUser(): Promise<ApiResult<UserInfo>> {
    return api.get<UserInfo>(ApiEndpoints.AUTH_ME, undefined, {
      source: 'AuthApi.getCurrentUser',
      enableCache: true,
      cacheTime: 5 * 60 * 1000 // 5分钟缓存
    });
  }
  
  /**
   * Refresh token
   * 
   * @description 刷新令牌
   * @returns {Promise<ApiResult<{ token: string }>>} 新令牌结果
   */
  static async refreshToken(): Promise<ApiResult<{ token: string }>> {
    return api.post<{ token: string }>(ApiEndpoints.AUTH_REFRESH, undefined, {
      needAuth: true,
      source: 'AuthApi.refreshToken'
    });
  }
}

/**
 * Student API (V2)
 * 
 * @description 学生服务类
 * @class
 */
export class StudentApi {
  /**
   * Get student list
   * 
   * @description 获取学生列表
   * @param {object} params - 查询参数
   * @returns {Promise<ApiResult<PageResponse<Student>>>} 学生列表结果
   */
  static async getList(params?: {
    pageNum?: number;
    pageSize?: number;
    keyword?: string;
    grade?: string;
    classId?: number;
  }): Promise<ApiResult<PageResponse<Student>>> {
    return api.get<PageResponse<Student>>(ApiEndpoints.STUDENTS, params, {
      source: 'StudentApi.getList',
      enableCache: true,
      cacheTime: 60 * 1000 // 1分钟缓存
    });
  }
  
  /**
   * Get student by ID
   * 
   * @description 根据ID获取学生详情
   * @param {number} id - 学生ID
   * @returns {Promise<ApiResult<Student>>} 学生详情结果
   */
  static async getById(id: number): Promise<ApiResult<Student>> {
    return api.get<Student>(ApiEndpoints.STUDENT_DETAIL.replace('{id}', String(id)), undefined, {
      source: 'StudentApi.getById'
    });
  }
  
  /**
   * Create student
   * 
   * @description 创建学生
   * @param {StudentCreateRequest} data - 学生数据
   * @returns {Promise<ApiResult<Student>>} 创建结果
   */
  static async create(data: StudentCreateRequest): Promise<ApiResult<Student>> {
    return api.post<Student>(ApiEndpoints.STUDENTS, data, {
      source: 'StudentApi.create'
    });
  }
  
  /**
   * Update student
   * 
   * @description 更新学生信息
   * @param {number} id - 学生ID
   * @param {Partial<Student>} data - 更新数据
   * @returns {Promise<ApiResult<Student>>} 更新结果
   */
  static async update(id: number, data: Partial<Student>): Promise<ApiResult<Student>> {
    return api.put<Student>(ApiEndpoints.STUDENT_DETAIL.replace('{id}', String(id)), data, {
      source: 'StudentApi.update'
    });
  }
  
  /**
   * Delete student
   * 
   * @description 删除学生
   * @param {number} id - 学生ID
   * @returns {Promise<ApiResult<null>>} 删除结果
   */
  static async delete(id: number): Promise<ApiResult<null>> {
    return api.delete<null>(ApiEndpoints.STUDENT_DETAIL.replace('{id}', String(id)), {
      source: 'StudentApi.delete'
    });
  }
  
  /**
   * Get guardian relations
   * 
   * @description 获取监护人关系列表
   * @param {number} studentId - 学生ID
   * @returns {Promise<ApiResult<GuardianRelation[]>>} 监护人关系列表结果
   */
  static async getGuardians(studentId: number): Promise<ApiResult<GuardianRelation[]>> {
    return api.get<GuardianRelation[]>(
      ApiEndpoints.STUDENT_GUARDIANS.replace('{studentId}', String(studentId)),
      undefined,
      { source: 'StudentApi.getGuardians' }
    );
  }
}
