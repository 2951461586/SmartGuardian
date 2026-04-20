/**
 * SmartGuardian - Attendance API (V2)
 * Attendance API using ApiWrapper
 * 
 * @description 使用 ApiWrapper 的考勤 API 服务
 * @features
 * - 类型安全的 API 调用
 * - 统一的错误处理
 * - 自动重试机制
 * - 结果链式处理
 */

import { api, ApiResult, createPaginatedResult, PaginatedResult } from '../../utils/api';
import {
  AttendanceRecord,
  SignInRequest,
  SignOutRequest,
  LeaveRequest,
  LeaveRecord
} from '../../models/attendance';
import { PageResponse } from '../../models/common';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Attendance API (V2)
 * 
 * @description 考勤服务类
 * @class
 * @example
 * ```typescript
 * // 签到
 * const result = await AttendanceApi.signIn({
 *   studentId: 1,
 *   sessionId: 1,
 *   signInType: 'NORMAL',
 *   signMethod: 'FACE'
 * });
 * 
 * result
 *   .onSuccess(record => {
 *     console.log('签到成功:', record.signInTime);
 *   })
 *   .onFailure(error => {
 *     promptAction.showToast({ message: error.message });
 *   });
 * ```
 */
export class AttendanceApi {
  /**
   * Get attendance list
   * 
   * @description 获取考勤记录列表
   * @param {object} params - 查询参数
   * @returns {Promise<ApiResult<PageResponse<AttendanceRecord>>>} 考勤记录列表结果
   */
  static async getList(params?: {
    pageNum?: number;
    pageSize?: number;
    studentId?: number;
    sessionId?: number;
    attendanceDate?: string;
    status?: string;
  }): Promise<ApiResult<PageResponse<AttendanceRecord>>> {
    return api.get<PageResponse<AttendanceRecord>>(ApiEndpoints.ATTENDANCE, params, {
      source: 'AttendanceApi.getList'
    });
  }
  
  /**
   * Get today attendance
   * 
   * @description 获取今日考勤记录
   * @param {number} sessionId - 班次ID
   * @returns {Promise<ApiResult<AttendanceRecord[]>>} 今日考勤记录结果
   */
  static async getToday(sessionId?: number): Promise<ApiResult<AttendanceRecord[]>> {
    const today = new Date().toISOString().split('T')[0];
    const result = await api.get<PageResponse<AttendanceRecord>>(ApiEndpoints.ATTENDANCE, {
      attendanceDate: today,
      sessionId,
      pageNum: 1,
      pageSize: 1000
    }, {
      source: 'AttendanceApi.getToday',
      enableCache: true,
      cacheTime: 30 * 1000 // 30秒缓存
    });
    
    return result.map(response => response.list);
  }
  
  /**
   * Sign in
   * 
   * @description 学生签到
   * @param {SignInRequest} data - 签到数据
   * @returns {Promise<ApiResult<AttendanceRecord>>} 签到结果
   */
  static async signIn(data: SignInRequest): Promise<ApiResult<AttendanceRecord>> {
    return api.post<AttendanceRecord>(ApiEndpoints.ATTENDANCE_SIGN_IN, {
      studentId: data.studentId,
      sessionId: data.sessionId,
      signInType: data.signInType,
      signMethod: data.signMethod,
      location: data.location
    }, {
      source: 'AttendanceApi.signIn',
      retryCount: 2 // 签到支持重试
    });
  }
  
  /**
   * Sign out
   * 
   * @description 学生签退
   * @param {SignOutRequest} data - 签退数据
   * @returns {Promise<ApiResult<AttendanceRecord>>} 签退结果
   */
  static async signOut(data: SignOutRequest): Promise<ApiResult<AttendanceRecord>> {
    return api.post<AttendanceRecord>(ApiEndpoints.ATTENDANCE_SIGN_OUT, {
      studentId: data.studentId,
      sessionId: data.sessionId,
      signOutType: data.signOutType,
      signMethod: data.signMethod,
      guardianId: data.guardianId ?? data.pickupUserId,
      pickupUserId: data.pickupUserId,
      location: data.location
    }, {
      source: 'AttendanceApi.signOut',
      retryCount: 2 // 签退支持重试
    });
  }
  
  /**
   * Get abnormal attendance
   * 
   * @description 获取异常考勤记录
   * @param {object} params - 查询参数
   * @returns {Promise<ApiResult<PageResponse<AttendanceRecord>>>} 异常考勤记录结果
   */
  static async getAbnormal(params?: {
    pageNum?: number;
    pageSize?: number;
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResult<PageResponse<AttendanceRecord>>> {
    return api.get<PageResponse<AttendanceRecord>>(ApiEndpoints.ATTENDANCE_ABNORMAL, params, {
      source: 'AttendanceApi.getAbnormal'
    });
  }
  
  /**
   * Submit leave request
   * 
   * @description 提交请假申请
   * @param {LeaveRequest} data - 请假数据
   * @returns {Promise<ApiResult<LeaveRecord>>} 请假记录结果
   */
  static async submitLeave(data: LeaveRequest): Promise<ApiResult<LeaveRecord>> {
    return api.post<LeaveRecord>(ApiEndpoints.LEAVE, data, {
      source: 'AttendanceApi.submitLeave'
    });
  }
  
  /**
   * Get leave records
   * 
   * @description 获取请假记录列表
   * @param {object} params - 查询参数
   * @returns {Promise<ApiResult<PageResponse<LeaveRecord>>>} 请假记录列表结果
   */
  static async getLeaveList(params?: {
    pageNum?: number;
    pageSize?: number;
    studentId?: number;
    status?: string;
  }): Promise<ApiResult<PageResponse<LeaveRecord>>> {
    return api.get<PageResponse<LeaveRecord>>(ApiEndpoints.LEAVE, params, {
      source: 'AttendanceApi.getLeaveList'
    });
  }
  
  /**
   * Cancel leave request
   * 
   * @description 取消请假申请
   * @param {number} id - 请假记录ID
   * @returns {Promise<ApiResult<null>>} 取消结果
   */
  static async cancelLeave(id: number): Promise<ApiResult<null>> {
    return api.post<null>(`${ApiEndpoints.LEAVE}/${id}/cancel`, undefined, {
      source: 'AttendanceApi.cancelLeave'
    });
  }
  
  /**
   * Get attendance statistics
   * 
   * @description 获取考勤统计
   * @param {object} params - 查询参数
   * @returns {Promise<ApiResult<object>>} 统计结果
   */
  static async getStatistics(params?: {
    startDate?: string;
    endDate?: string;
    studentId?: number;
  }): Promise<ApiResult<{
    totalDays: number;
    presentDays: number;
    absentDays: number;
    lateDays: number;
    earlyLeaveDays: number;
    leaveDays: number;
    attendanceRate: number;
  }>> {
    return api.get(ApiEndpoints.ATTENDANCE_STATS, params, {
      source: 'AttendanceApi.getStatistics',
      enableCache: true,
      cacheTime: 5 * 60 * 1000 // 5分钟缓存
    });
  }
}
