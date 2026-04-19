/**
 * SmartGuardian - Global User Store
 * User authentication and role management
 * 
 * @description 用户状态管理 Store，负责用户登录状态和角色权限的全局管理
 * @features
 * - 用户登录状态追踪
 * - 用户信息缓存管理
 * - 角色权限判断方法
 * - 登出清理功能
 */

import { UserRole } from '../models/common';
import { UserInfo } from '../models/user';
import { removeToken } from '../utils/request';

/**
 * User store keys
 * 
 * @description AppStorage 存储键名常量
 */
const USER_INFO_KEY = 'user_info';
const IS_LOGGED_IN_KEY = 'is_logged_in';

/**
 * Global user store using AppStorage
 * 
 * @description 用户状态管理类，提供用户认证和权限判断功能
 * @class
 * @example
 * ```typescript
 * // 登录成功后设置用户信息
 * UserStore.setUserInfo(userInfo);
 * 
 * // 判断用户角色
 * if (UserStore.isParent()) {
 *   // 跳转到家长端
 * }
 * 
 * // 登出
 * UserStore.clearUserInfo();
 * ```
 */
export class UserStore {
  /**
   * Set user info
   * 
   * @description 设置用户信息并标记为已登录
   * @param {UserInfo} userInfo - 用户信息对象
   * @returns {void}
   * @example
   * ```typescript
   * const loginResponse = await AuthService.login({ phone: '13800138000', password: '123456' });
   * UserStore.setUserInfo(loginResponse.data);
   * ```
   */
  static setUserInfo(userInfo: UserInfo): void {
    AppStorage.setOrCreate(USER_INFO_KEY, userInfo);
    AppStorage.setOrCreate(IS_LOGGED_IN_KEY, true);
  }

  /**
   * Get user info
   * 
   * @description 获取当前登录用户信息
   * @returns {UserInfo | null} 用户信息对象，未登录则返回 null
   * @example
   * ```typescript
   * const userInfo = UserStore.getUserInfo();
   * if (userInfo) {
   *   console.log('当前用户:', userInfo.realName);
   * }
   * ```
   */
  static getUserInfo(): UserInfo | null {
    return AppStorage.get<UserInfo>(USER_INFO_KEY) ?? null;
  }

  /**
   * Check if user is logged in
   * 
   * @description 检查用户是否已登录
   * @returns {boolean} 是否已登录
   * @example
   * ```typescript
   * if (UserStore.isLoggedIn()) {
   *   // 已登录，允许访问
   * } else {
   *   // 未登录，跳转到登录页
   * }
   * ```
   */
  static isLoggedIn(): boolean {
    return AppStorage.get<boolean>(IS_LOGGED_IN_KEY) ?? false;
  }

  /**
   * Get current user role
   * 
   * @description 获取当前用户的角色类型
   * @returns {UserRole | null} 用户角色，未登录则返回 null
   * @example
   * ```typescript
   * const role = UserStore.getUserRole();
   * if (role === UserRole.PARENT) {
   *   console.log('家长用户');
   * }
   * ```
   */
  static getUserRole(): UserRole | null {
    const userInfo = this.getUserInfo();
    return userInfo?.roleType ?? null;
  }

  /**
   * Check if current user is parent
   * 
   * @description 检查当前用户是否为家长角色
   * @returns {boolean} 是否为家长
   * @example
   * ```typescript
   * if (UserStore.isParent()) {
   *   // 显示家长端入口
   * }
   * ```
   */
  static isParent(): boolean {
    return this.getUserRole() === UserRole.PARENT;
  }

  /**
   * Check if current user is teacher
   * 
   * @description 检查当前用户是否为教师角色
   * @returns {boolean} 是否为教师
   * @example
   * ```typescript
   * if (UserStore.isTeacher()) {
   *   // 显示教师端入口
   * }
   * ```
   */
  static isTeacher(): boolean {
    return this.getUserRole() === UserRole.TEACHER;
  }

  /**
   * Check if current user is admin (org or school)
   * 
   * @description 检查当前用户是否为管理员（机构管理员、学校管理员或平台管理员）
   * @returns {boolean} 是否为管理员
   * @example
   * ```typescript
   * if (UserStore.isAdmin()) {
   *   // 显示管理端入口
   * }
   * ```
   */
  static isAdmin(): boolean {
    const role = this.getUserRole();
    return role === UserRole.ORG_ADMIN || role === UserRole.SCHOOL_ADMIN || role === UserRole.PLATFORM_ADMIN;
  }

  /**
   * Clear user info (logout)
   * 
   * @description 清除用户信息并登出（删除 token 和用户数据）
   * @returns {void}
   * @example
   * ```typescript
   * // 用户点击登出按钮
   * UserStore.clearUserInfo();
   * router.replaceUrl({ url: '/pages/LoginPage' });
   * ```
   */
  static clearUserInfo(): void {
    removeToken();
    AppStorage.delete(USER_INFO_KEY);
    AppStorage.delete(IS_LOGGED_IN_KEY);
  }
}
