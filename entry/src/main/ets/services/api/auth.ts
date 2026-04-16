/**
 * SmartGuardian - Auth API Service
 * Authentication and user management API
 */

import { get, post } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';
import { LoginRequest, LoginResponse, UserInfo, Student, StudentCreateRequest, GuardianRelation, CreateGuardianRequest } from '../../models/user';

/**
 * Auth API Service
 */
export class AuthService {
  /**
   * User login
   */
  static async login(data: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    return post<LoginResponse>('/api/v1/auth/login', data, { needAuth: false });
  }

  /**
   * User logout
   */
  static async logout(): Promise<ApiResponse<null>> {
    return post<null>('/api/v1/auth/logout');
  }

  /**
   * Get current user info
   */
  static async getCurrentUser(): Promise<ApiResponse<UserInfo>> {
    return get<UserInfo>('/api/v1/auth/me');
  }
}

/**
 * Student API Service
 */
export class StudentService {
  /**
   * Get student list
   */
  static async getStudents(params?: {
    pageNum?: number;
    pageSize?: number;
    keyword?: string;
  }): Promise<ApiResponse<PageResponse<Student>>> {
    return get<PageResponse<Student>>('/api/v1/students', params);
  }

  /**
   * Get student details
   */
  static async getStudentDetail(studentId: number): Promise<ApiResponse<Student>> {
    return get<Student>(`/api/v1/students/${studentId}`);
  }

  /**
   * Create student profile
   */
  static async createStudent(data: StudentCreateRequest): Promise<ApiResponse<Student>> {
    return post<Student>('/api/v1/students', data);
  }

  /**
   * Update student profile
   */
  static async updateStudent(studentId: number, data: Partial<StudentCreateRequest>): Promise<ApiResponse<Student>> {
    return post<Student>(`/api/v1/students/${studentId}`, data);
  }

  /**
   * Bind guardian relation
   */
  static async bindGuardian(studentId: number, data: CreateGuardianRequest): Promise<ApiResponse<GuardianRelation>> {
    return post<GuardianRelation>(`/api/v1/students/${studentId}/guardians`, data);
  }

  /**
   * Get guardian relations
   */
  static async getGuardians(studentId: number): Promise<ApiResponse<GuardianRelation[]>> {
    return get<GuardianRelation[]>(`/api/v1/students/${studentId}/guardians`);
  }
}