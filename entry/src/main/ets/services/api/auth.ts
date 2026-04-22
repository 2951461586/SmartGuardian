/**
 * SmartGuardian - Auth API Service
 * Authentication and user management API
 * 
 * @description 认证与用户管理 API 服务，包含登录、登出、用户信息获取以及学生管理功能
 * @features
 * - 用户登录/登出
 * - 用户信息获取
 * - 学生档案管理
 * - 监护人关系绑定
 */

import { get, post, put } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';
import { LoginRequest, LoginResponse, UserInfo, Student, StudentCreateRequest, GuardianRelation, CreateGuardianRequest } from '../../models/user';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Auth API Service
 * 
 * @description 认证服务类，提供用户登录、登出和获取当前用户信息等功能
 * @class
 * @example
 * ```typescript
 * // 用户登录
 * const loginResp = await AuthService.login({ phone: '13800138000', password: '123456' });
 * 
 * // 获取当前用户信息
 * const userResp = await AuthService.getCurrentUser();
 * 
 * // 用户登出
 * await AuthService.logout();
 * ```
 */
export class AuthService {
  /**
   * User login
   * 
   * @description 用户登录接口，验证手机号和密码
   * @param {LoginRequest} data - 登录请求数据（包含 phone 和 password）
   * @returns {Promise<ApiResponse<LoginResponse>>} 登录响应（包含 token 和用户信息）
   * @throws {Error} 当网络请求失败或服务器返回错误时抛出异常
   * @example
   * ```typescript
   * const loginResp = await AuthService.login({
   *   phone: '13800138000',
   *   password: '123456'
   * });
   * 
   * if (loginResp.code === 0) {
   *   // 登录成功，保存 token 和用户信息
   *   UserStore.setUserInfo(loginResp.data.userInfo);
   * }
   * ```
   */
  static async login(data: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    return post<LoginResponse>(ApiEndpoints.AUTH_LOGIN, data, { needAuth: false });
  }

  /**
   * User logout
   * 
   * @description 用户登出接口，清除服务端的登录状态
   * @returns {Promise<ApiResponse<null>>} 登出响应
   * @example
   * ```typescript
   * // 用户登出
   * await AuthService.logout();
   * UserStore.clearUserInfo();
   * router.replaceUrl({ url: '/pages/LoginPage' });
   * ```
   */
  static async logout(): Promise<ApiResponse<null>> {
    return post<null>(ApiEndpoints.AUTH_LOGOUT);
  }

  /**
   * Get current user info
   * 
   * @description 获取当前登录用户的详细信息
   * @returns {Promise<ApiResponse<UserInfo>>} 用户信息响应
   * @throws {Error} 当用户未登录或 token 失效时抛出异常
   * @example
   * ```typescript
   * const userResp = await AuthService.getCurrentUser();
   * if (userResp.code === 0) {
   *   console.log('当前用户:', userResp.data.realName);
   *   console.log('用户角色:', userResp.data.roleType);
   * }
   * ```
   */
  static async getCurrentUser(): Promise<ApiResponse<UserInfo>> {
    return get<UserInfo>(ApiEndpoints.AUTH_ME);
  }
}

/**
 * Student API Service
 * 
 * @description 学生服务类，提供学生档案管理和监护人关系绑定功能
 * @class
 * @example
 * ```typescript
 * // 获取学生列表
 * const studentsResp = await StudentService.getStudents({ pageNum: 1, pageSize: 20 });
 * 
 * // 创建学生档案
 * const newStudent = await StudentService.createStudent({ name: '张三', ... });
 * 
 * // 绑定监护人
 * await StudentService.bindGuardian(studentId, { guardianId: 100, relation: 'FATHER' });
 * ```
 */
export class StudentService {
  /**
   * Get student list
   * 
   * @description 分页获取学生列表，支持按关键词、年级、班级筛选
   * @param {Object} params - 查询参数
   * @param {number} [params.pageNum] - 页码，默认为 1
   * @param {number} [params.pageSize] - 每页数量，默认为 20
   * @param {string} [params.keyword] - 搜索关键词（姓名或学号）
   * @param {number} [params.grade] - 年级筛选
   * @param {number} [params.classId] - 班级ID筛选
   * @returns {Promise<ApiResponse<PageResponse<Student>>>} 分页学生列表响应
   * @example
   * ```typescript
   * // 获取第一页学生列表
   * const resp = await StudentService.getStudents({ pageNum: 1, pageSize: 20 });
   * 
   * // 按关键词搜索
   * const searchResp = await StudentService.getStudents({ keyword: '张三' });
   * 
   * // 按班级筛选
   * const classResp = await StudentService.getStudents({ classId: 5 });
   * ```
   */
  static async getStudents(params?: {
    pageNum?: number;
    pageSize?: number;
    keyword?: string;
    classId?: number;
  }): Promise<ApiResponse<PageResponse<Student>>> {
    return get<PageResponse<Student>>(ApiEndpoints.STUDENTS, params);
  }

  /**
   * Get student details
   * 
   * @description 获取指定学生的详细信息
   * @param {number} studentId - 学生ID
   * @returns {Promise<ApiResponse<Student>>} 学生详情响应
   * @throws {Error} 当学生不存在时抛出异常
   * @example
   * ```typescript
   * const resp = await StudentService.getStudentDetail(123);
   * if (resp.code === 0) {
   *   console.log('学生姓名:', resp.data.name);
   *   console.log('学生班级:', resp.data.className);
   * }
   * ```
   */
  static async getStudentDetail(studentId: number): Promise<ApiResponse<Student>> {
    return get<Student>(ApiEndpoints.studentDetail(studentId));
  }

  /**
   * Create student profile
   * 
   * @description 创建新的学生档案
   * @param {StudentCreateRequest} data - 学生创建请求数据
   * @returns {Promise<ApiResponse<Student>>} 创建成功的学生信息响应
   * @example
   * ```typescript
   * const newStudent = await StudentService.createStudent({
   *   name: '张三',
   *   studentNo: '2024001',
   *   gender: 'MALE',
   *   grade: '一年级',
   *   classId: 1
   * });
   * 
   * if (newStudent.code === 0) {
   *   console.log('创建成功，学生ID:', newStudent.data.id);
   * }
   * ```
   */
  static async createStudent(data: StudentCreateRequest): Promise<ApiResponse<Student>> {
    return post<Student>(ApiEndpoints.STUDENTS, data);
  }

  /**
   * Update student profile
   * 
   * @description 更新学生档案信息
   * @param {number} studentId - 学生ID
   * @param {Partial<StudentCreateRequest>} data - 需要更新的学生数据
   * @returns {Promise<ApiResponse<Student>>} 更新成功的学生信息响应
   * @example
   * ```typescript
   * // 更新学生班级
   * const updated = await StudentService.updateStudent(123, {
   *   classId: 2
   * });
   * ```
   */
  static async updateStudent(studentId: number, data: Partial<StudentCreateRequest>): Promise<ApiResponse<Student>> {
    return put<Student>(ApiEndpoints.studentDetail(studentId), data);
  }

  /**
   * Bind guardian relation
   * 
   * @description 为学生绑定监护人关系
   * @param {number} studentId - 学生ID
   * @param {CreateGuardianRequest} data - 监护人绑定请求数据
   * @returns {Promise<ApiResponse<GuardianRelation>>} 监护人关系响应
   * @example
   * ```typescript
   * // 绑定父亲
   * const fatherRelation = await StudentService.bindGuardian(123, {
   *   guardianId: 100,
   *   relation: 'FATHER'
   * });
   * 
   * // 绑定母亲
   * const motherRelation = await StudentService.bindGuardian(123, {
   *   guardianId: 101,
   *   relation: 'MOTHER'
   * });
   * ```
   */
  static async bindGuardian(studentId: number, data: CreateGuardianRequest): Promise<ApiResponse<GuardianRelation>> {
    return post<GuardianRelation>(ApiEndpoints.bindGuardian(studentId), data);
  }

  /**
   * Get guardian relations
   * 
   * @description 获取学生的所有监护人关系列表
   * @param {number} studentId - 学生ID
   * @returns {Promise<ApiResponse<GuardianRelation[]>>} 监护人关系列表响应
   * @example
   * ```typescript
   * const guardians = await StudentService.getGuardians(123);
   * if (guardians.code === 0) {
   *   guardians.data.forEach(g => {
   *     console.log(`${g.relation}: ${g.guardianName}`);
   *   });
   * }
   * ```
   */
  static async getGuardians(studentId: number): Promise<ApiResponse<GuardianRelation[]>> {
    return get<GuardianRelation[]>(ApiEndpoints.bindGuardian(studentId));
  }
}
