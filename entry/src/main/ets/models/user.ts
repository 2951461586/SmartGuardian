/**
 * SmartGuardian - User Models
 * User-related types and interfaces
 * 
 * @description 用户相关数据模型，包括登录、用户信息、学生档案等
 * @note 包含 OpenAPI 标准字段和 UI 便利字段
 */

import { UserRole } from './common';

/**
 * Login request (登录请求)
 * 
 * @description 用户登录请求参数
 */
export interface LoginRequest {
  /** 用户名 */
  username: string;
  
  /** 密码 */
  password: string;
}

/**
 * Login response (登录响应)
 * 
 * @description 登录成功后的响应数据
 */
export interface LoginResponse {
  /** 认证令牌 (JWT Token) */
  token: string;
  
  /** 令牌有效期 (单位: 秒) */
  expiresIn: number;
  
  /** 用户信息 */
  userInfo: UserInfo;
}

/**
 * User information (用户信息)
 * 
 * @description 登录用户的基本信息
 */
export interface UserInfo {
  // ===== OpenAPI 标准字段 =====
  
  /** 用户ID */
  id: number;
  
  /** 用户名 */
  username: string;
  
  /** 真实姓名 */
  realName: string;
  
  /** 手机号 */
  mobile: string;
  
  /** 角色类型 (PARENT, TEACHER, ADMIN) */
  roleType: UserRole;
  
  /** 头像URL */
  avatar?: string;
  
  /** 所属机构ID */
  orgId?: number;
  
  /** 所属学校ID */
  schoolId?: number;
}

/**
 * Student profile (学生档案)
 * 
 * @description 学生的详细信息档案
 * @note 包含关联字段，由后端通过JOIN查询返回
 */
export interface Student {
  // ===== OpenAPI 标准字段 =====
  
  /** 学生ID */
  id: number;
  
  /** 学号 */
  studentNo: string;
  
  /** 学生姓名 */
  name: string;
  
  /** 所属学校ID */
  schoolId: number;
  
  /** 所属班级ID */
  classId?: number;
  
  /** 年级 */
  grade?: string;
  
  /** 性别 (MALE, FEMALE) */
  gender?: 'MALE' | 'FEMALE';
  
  /** 出生日期 */
  birthDate?: string;
  
  /** 家长用户ID */
  guardianUserId: number;
  
  /** 健康备注 (过敏、疾病等信息) */
  healthNotes?: string;
  
  /** 学生状态 (ACTIVE, INACTIVE, GRADUATED) */
  status: 'ACTIVE' | 'INACTIVE' | 'GRADUATED';
  
  /** 创建时间 */
  createdAt: string;
  
  /** 更新时间 */
  updatedAt: string;
  
  // ===== UI 便利字段 (后端关联返回) =====
  
  /** 学校名称 (关联 School.name) */
  schoolName?: string;
  
  /** 班级名称 (关联 Class.name) */
  className?: string;
  
  /** 家长姓名 (关联 User.name) */
  guardianName?: string;
  
  /** 家长手机号 (关联 User.mobile) */
  guardianMobile?: string;
}

/**
 * Student create request (创建学生请求)
 * 
 * @description 创建学生档案的请求参数
 */
export interface StudentCreateRequest {
  /** 学号 */
  studentNo: string;
  
  /** 学生姓名 */
  name: string;
  
  /** 所属学校ID */
  schoolId: number;
  
  /** 所属班级ID */
  classId?: number;
  
  /** 年级 */
  grade?: string;
  
  /** 性别 */
  gender?: 'MALE' | 'FEMALE';
  
  /** 出生日期 */
  birthDate?: string;
  
  /** 家长用户ID */
  guardianUserId: number;
  
  /** 健康备注 */
  healthNotes?: string;
}

/**
 * Guardian relation (监护关系)
 * 
 * @description 家长与学生的监护关系
 */
export interface GuardianRelation {
  /** 关系ID */
  id: number;
  
  /** 学生ID */
  studentId: number;
  
  /** 家长用户ID */
  userId: number;
  
  /** 关系类型 (FATHER, MOTHER, GRANDPA, GRANDMA, OTHER) */
  relation: 'FATHER' | 'MOTHER' | 'GRANDPA' | 'GRANDMA' | 'OTHER';
  
  /** 是否主要监护人 */
  isPrimary: boolean;
  
  /** 是否授权接送 */
  authorizedPickup: boolean;
  
  /** 接送码 (用于家长接送验证) */
  pickupCode?: string;
}

/**
 * Create guardian relation request (创建监护关系请求)
 * 
 * @description 创建监护关系的请求参数
 */
export interface CreateGuardianRequest {
  /** 学生ID */
  studentId: number;
  
  /** 家长用户ID */
  userId: number;
  
  /** 关系类型 */
  relation: 'FATHER' | 'MOTHER' | 'GRANDPA' | 'GRANDMA' | 'OTHER';
  
  /** 是否主要监护人 */
  isPrimary: boolean;
  
  /** 是否授权接送 */
  authorizedPickup: boolean;
}
