/**
 * SmartGuardian - Attendance API Service
 * Attendance and leave related API
 * 
 * @description 考勤管理 API 服务，包含签到签退、异常考勤和请假功能
 * @features
 * - 学生签到/签退
 * - 异常考勤查询
 * - 请假申请
 */

import { get, post } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';
import { AttendanceRecord, SignInRequest, SignOutRequest, LeaveRequest } from '../../models/attendance';

/**
 * Attendance API Service
 * 
 * @description 考勤服务类，提供学生签到签退、请假和异常考勤查询功能
 * @class
 */
export class AttendanceService {
  /**
   * Get attendance records
   * 
   * @description 分页获取考勤记录，支持按学生、班次、日期和状态筛选
   * @param params 查询参数
   * @returns 分页考勤记录响应
   */
  static async getAttendanceList(params?: {
    pageNum?: number;
    pageSize?: number;
    studentId?: number;
    sessionId?: number;
    attendanceDate?: string;
    status?: string;
  }): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    return get<PageResponse<AttendanceRecord>>('/api/v1/attendance', params);
  }

  /**
   * Sign in
   * 
   * @description 学生签到接口，记录签到时间、方式和位置信息
   * @param data 签到请求数据
   * @returns 签到成功后的考勤记录
   */
  static async signIn(data: SignInRequest): Promise<ApiResponse<AttendanceRecord>> {
    const payload: SignInRequest = {
      studentId: data.studentId,
      sessionId: data.sessionId,
      signInType: data.signInType,
      signMethod: data.signMethod,
      location: data.location
    };
    return post<AttendanceRecord>('/api/v1/attendance/sign-in', payload);
  }

  /**
   * Sign out
   * 
   * @description 学生签退接口，记录签退时间、方式和接送人信息
   * @param data 签退请求数据
   * @returns 签退成功后的考勤记录
   */
  static async signOut(data: SignOutRequest): Promise<ApiResponse<AttendanceRecord>> {
    const payload: SignOutRequest = {
      studentId: data.studentId,
      sessionId: data.sessionId,
      signOutType: data.signOutType,
      signMethod: data.signMethod,
      guardianId: data.guardianId ? data.guardianId : data.pickupUserId,
      pickupUserId: data.pickupUserId,
      location: data.location
    };
    return post<AttendanceRecord>('/api/v1/attendance/sign-out', payload);
  }

  /**
   * Get abnormal attendance records
   * 
   * @description 获取异常考勤记录（如迟到、早退、缺勤等）
   * @param params 查询参数
   * @returns 异常考勤记录分页响应
   */
  static async getAbnormalAttendance(params?: {
    pageNum?: number;
    pageSize?: number;
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    return get<PageResponse<AttendanceRecord>>('/api/v1/attendance/abnormal-events', params);
  }

  /**
   * Submit leave request
   * 
   * @description 提交学生请假申请
   * @param data 请假请求数据
   * @returns 请假记录响应
   */
  static async submitLeave(data: LeaveRequest): Promise<ApiResponse<AttendanceRecord>> {
    return post<AttendanceRecord>('/api/v1/attendance/leave', data);
  }
}
