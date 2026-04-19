/**
 * SmartGuardian - Global User Store
 * Using AppStorage for global state management
 */

import { UserRole } from '../models/common';
import { UserInfo } from '../models/user';
import { removeToken } from '../utils/request';

/**
 * User store keys
 */
const USER_INFO_KEY = 'user_info';
const IS_LOGGED_IN_KEY = 'is_logged_in';

/**
 * Global user store using AppStorage
 */
export class UserStore {
  /**
   * Set user info
   */
  static setUserInfo(userInfo: UserInfo): void {
    AppStorage.setOrCreate(USER_INFO_KEY, userInfo);
    AppStorage.setOrCreate(IS_LOGGED_IN_KEY, true);
  }

  /**
   * Get user info
   */
  static getUserInfo(): UserInfo | null {
    return AppStorage.get<UserInfo>(USER_INFO_KEY) ?? null;
  }

  /**
   * Check if user is logged in
   */
  static isLoggedIn(): boolean {
    return AppStorage.get<boolean>(IS_LOGGED_IN_KEY) ?? false;
  }

  /**
   * Get current user role
   */
  static getUserRole(): UserRole | null {
    const userInfo = this.getUserInfo();
    return userInfo?.roleType ?? null;
  }

  /**
   * Check if current user is parent
   */
  static isParent(): boolean {
    return this.getUserRole() === UserRole.PARENT;
  }

  /**
   * Check if current user is teacher
   */
  static isTeacher(): boolean {
    return this.getUserRole() === UserRole.TEACHER;
  }

  /**
   * Check if current user is admin (org or school)
   */
  static isAdmin(): boolean {
    const role = this.getUserRole();
    return role === UserRole.ORG_ADMIN || role === UserRole.SCHOOL_ADMIN || role === UserRole.PLATFORM_ADMIN;
  }

  /**
   * Clear user info (logout)
   */
  static clearUserInfo(): void {
    removeToken();
    AppStorage.delete(USER_INFO_KEY);
    AppStorage.delete(IS_LOGGED_IN_KEY);
  }
}