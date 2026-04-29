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
import {
  AttendanceRecord,
  AttendanceStatistics,
  SignInRequest,
  SignOutRequest,
  LeaveRequest,
  LeaveRecord
} from '../../models/attendance';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Attendance API Service
 * 
 * @description 考勤服务类，提供学生签到签退、请假和异常考勤查询功能
 * @class
 */
export class AttendanceService {
  static readonly AGC_DOMAIN: string = 'attendance';
  static readonly AGC_FUNCTION: string = 'smartguardian-attendance';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.ATTENDANCE;

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
    return get<PageResponse<AttendanceRecord>>(ApiEndpoints.ATTENDANCE, params);
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
    return post<AttendanceRecord>(ApiEndpoints.ATTENDANCE_SIGN_IN, payload);
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
    return post<AttendanceRecord>(ApiEndpoints.ATTENDANCE_SIGN_OUT, payload);
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
    return get<PageResponse<AttendanceRecord>>(ApiEndpoints.ATTENDANCE_ABNORMAL, params);
  }

  /**
   * Submit leave request
   * 
   * @description 提交学生请假申请
   * @param data 请假请求数据
   * @returns 请假记录响应
   */
  static async submitLeave(data: LeaveRequest): Promise<ApiResponse<LeaveRecord>> {
    return post<LeaveRecord>(ApiEndpoints.ATTENDANCE_LEAVE, data);
  }

  /**
   * Get leave requests
   *
   * @description 分页获取请假申请，支持按学生、日期和状态筛选
   * @param params 查询参数
   * @returns 分页请假记录响应
   */
  static async getLeaveRequests(params?: {
    pageNum?: number;
    pageSize?: number;
    studentId?: number;
    leaveDate?: string;
    status?: string;
  }): Promise<ApiResponse<PageResponse<LeaveRecord>>> {
    return get<PageResponse<LeaveRecord>>(ApiEndpoints.ATTENDANCE_LEAVE, params);
  }

  /**
   * Cancel leave request
   *
   * @description 取消待审核请假申请
   * @param leaveId 请假记录ID
   * @returns 取消后的请假记录响应
   */
  static async cancelLeave(leaveId: number): Promise<ApiResponse<LeaveRecord>> {
    return post<LeaveRecord>(ApiEndpoints.attendanceLeaveCancel(leaveId));
  }

  /**
   * Get attendance statistics
   *
   * @description 获取考勤与请假汇总统计
   * @param params 查询参数
   * @returns 考勤统计响应
   */
  static async getStatistics(params?: {
    studentId?: number;
    sessionId?: number;
    attendanceDate?: string;
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<AttendanceStatistics>> {
    return get<AttendanceStatistics>(ApiEndpoints.ATTENDANCE_STATS, params);
  }
}
