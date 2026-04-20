/**
 * SmartGuardian - Global User Store
 * User authentication and role management with reactive support
 * 
 * @description 用户状态管理 Store，负责用户登录状态和角色权限的全局管理
 * @features
 * - 用户登录状态追踪
 * - 用户信息缓存管理
 * - 角色权限判断方法
 * - 登出清理功能
 * - 响应式状态变更通知
 * - 持久化支持
 */

import { UserRole } from '../models/common';
import { UserInfo } from '../models/user';
import { removeToken } from '../utils/request';
import { ReactiveStore, StateChangeListener, StateChangeEvent } from './core';

/**
 * User store keys
 * 
 * @description AppStorage 存储键名常量
 */
const USER_INFO_KEY = 'user_info';
const IS_LOGGED_IN_KEY = 'is_logged_in';
const USER_PREFERENCES_KEY = 'user_preferences';

/**
 * User preferences
 * 
 * @description 用户偏好设置接口
 */
export interface UserPreferences {
  /** 是否接收消息通知 */
  enableNotifications?: boolean;
  
  /** 是否接收考勤提醒 */
  enableAttendanceReminder?: boolean;
  
  /** 主题模式 */
  themeMode?: 'light' | 'dark' | 'auto';
  
  /** 语言设置 */
  language?: string;
}

/**
 * Global user store using AppStorage with reactive support
 * 
 * @description 用户状态管理类，提供用户认证和权限判断功能
 * @class
 * @example
 * ```typescript
 * // 登录成功后设置用户信息
 * UserStore.setUserInfo(userInfo);
 * 
 * // 监听用户信息变更
 * UserStore.onUserInfoChange((event) => {
 *   console.log('用户信息已更新:', event.newValue);
 * });
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
export class UserStore extends ReactiveStore {
  // 初始化 Store 配置
  static {
    this.initOptions({
      name: 'UserStore',
      persistent: true,
      defaultExpiresIn: 7 * 24 * 60 * 60 * 1000 // 7天
    });
  }
  
  /**
   * Set user info
   * 
   * @description 设置用户信息并标记为已登录
   * @param {UserInfo} userInfo - 用户信息对象
   * @returns {void}
   */
  static setUserInfo(userInfo: UserInfo): void {
    this.setValue(USER_INFO_KEY, userInfo, { persist: true });
    this.setValue(IS_LOGGED_IN_KEY, true, { persist: true });
  }
  
  /**
   * Get user info
   * 
   * @description 获取当前登录用户信息
   * @returns {UserInfo | null} 用户信息对象，未登录则返回 null
   */
  static getUserInfo(): UserInfo | null {
    return this.getValue<UserInfo>(USER_INFO_KEY) ?? null;
  }
  
  /**
   * Check if user is logged in
   * 
   * @description 检查用户是否已登录
   * @returns {boolean} 是否已登录
   */
  static isLoggedIn(): boolean {
    return this.getValue<boolean>(IS_LOGGED_IN_KEY) ?? false;
  }
  
  /**
   * Get current user role
   * 
   * @description 获取当前用户的角色类型
   * @returns {UserRole | null} 用户角色，未登录则返回 null
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
   */
  static isParent(): boolean {
    return this.getUserRole() === UserRole.PARENT;
  }
  
  /**
   * Check if current user is teacher
   * 
   * @description 检查当前用户是否为教师角色
   * @returns {boolean} 是否为教师
   */
  static isTeacher(): boolean {
    return this.getUserRole() === UserRole.TEACHER;
  }
  
  /**
   * Check if current user is admin (org or school)
   * 
   * @description 检查当前用户是否为管理员（机构管理员、学校管理员或平台管理员）
   * @returns {boolean} 是否为管理员
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
   */
  static clearUserInfo(): void {
    removeToken();
    this.deleteValue(USER_INFO_KEY);
    this.deleteValue(IS_LOGGED_IN_KEY);
  }
  
  /**
   * Set user preferences
   * 
   * @description 设置用户偏好设置
   * @param {UserPreferences} preferences - 偏好设置对象
   */
  static setUserPreferences(preferences: UserPreferences): void {
    this.setValue(USER_PREFERENCES_KEY, preferences, { persist: true });
  }
  
  /**
   * Get user preferences
   * 
   * @description 获取用户偏好设置
   * @returns {UserPreferences} 偏好设置对象
   */
  static getUserPreferences(): UserPreferences {
    return this.getValue<UserPreferences>(USER_PREFERENCES_KEY) ?? {
      enableNotifications: true,
      enableAttendanceReminder: true,
      themeMode: 'light',
      language: 'zh_CN'
    };
  }
  
  /**
   * Update user preferences
   * 
   * @description 更新用户偏好设置（部分更新）
   * @param {Partial<UserPreferences>} updates - 要更新的偏好设置
   */
  static updateUserPreferences(updates: Partial<UserPreferences>): void {
    const current = this.getUserPreferences();
    this.setUserPreferences({ ...current, ...updates });
  }
  
  // ============ 响应式订阅方法 ============
  
  /**
   * Subscribe to user info changes
   * 
   * @description 订阅用户信息变更
   * @param {StateChangeListener<UserInfo>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onUserInfoChange(listener: StateChangeListener<UserInfo>): () => void {
    return this.subscribe<UserInfo>(USER_INFO_KEY, listener);
  }
  
  /**
   * Subscribe to login state changes
   * 
   * @description 订阅登录状态变更
   * @param {StateChangeListener<boolean>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onLoginStateChange(listener: StateChangeListener<boolean>): () => void {
    return this.subscribe<boolean>(IS_LOGGED_IN_KEY, listener);
  }
  
  /**
   * Subscribe to user preferences changes
   * 
   * @description 订阅用户偏好设置变更
   * @param {StateChangeListener<UserPreferences>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onPreferencesChange(listener: StateChangeListener<UserPreferences>): () => void {
    return this.subscribe<UserPreferences>(USER_PREFERENCES_KEY, listener);
  }
  
  /**
   * Subscribe once to user info changes
   * 
   * @description 订阅一次用户信息变更
   * @param {StateChangeListener<UserInfo>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onceUserInfoChange(listener: StateChangeListener<UserInfo>): () => void {
    return this.subscribeOnce<UserInfo>(USER_INFO_KEY, listener);
  }
}
