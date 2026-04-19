/**
 * SmartGuardian - User Models
 * User-related types and interfaces
 */

import { UserRole } from './common';

/**
 * Login request
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * Login response
 */
export interface LoginResponse {
  token: string;
  expiresIn: number;
  userInfo: UserInfo;
}

/**
 * User information
 */
export interface UserInfo {
  id: number;
  username: string;
  realName: string;
  mobile: string;
  roleType: UserRole;
  avatar?: string;
  orgId?: number;
  schoolId?: number;
}

/**
 * Student profile
 */
export interface Student {
  id: number;
  studentNo: string;
  name: string;
  schoolId: number;
  schoolName?: string;
  classId?: number;
  className?: string;
  grade?: string;
  gender?: 'MALE' | 'FEMALE';
  birthDate?: string;
  guardianUserId: number;
  guardianName?: string;
  guardianMobile?: string;
  healthNotes?: string;
  status: 'ACTIVE' | 'INACTIVE' | 'GRADUATED';
  createdAt: string;
  updatedAt: string;
}

/**
 * Student create request
 */
export interface StudentCreateRequest {
  studentNo: string;
  name: string;
  schoolId: number;
  classId?: number;
  grade?: string;
  gender?: 'MALE' | 'FEMALE';
  birthDate?: string;
  guardianUserId: number;
  healthNotes?: string;
}

/**
 * Guardian relation
 */
export interface GuardianRelation {
  id: number;
  studentId: number;
  userId: number;
  relation: 'FATHER' | 'MOTHER' | 'GRANDPA' | 'GRANDMA' | 'OTHER';
  isPrimary: boolean;
  authorizedPickup: boolean;
  pickupCode?: string;
}

/**
 * Create guardian relation request
 */
export interface CreateGuardianRequest {
  studentId: number;
  userId: number;
  relation: 'FATHER' | 'MOTHER' | 'GRANDPA' | 'GRANDMA' | 'OTHER';
  isPrimary: boolean;
  authorizedPickup: boolean;
}