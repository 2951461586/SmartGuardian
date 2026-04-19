/**
 * SmartGuardian - Attendance Store
 * Attendance state management
 * 
 * @description 考勤状态管理 Store，负责考勤数据和学生签到签退状态的全局管理
 * @features
 * - 今日考勤记录缓存
 * - 当前班次信息追踪
 * - 学生签到签退状态实时更新
 * - 考勤统计数据维护
 */

import { AttendanceRecord } from '../models/attendance';
import { SessionWithStudents } from '../models/service';

/**
 * Attendance store keys
 * 
 * @description AppStorage 存储键名常量
 */
const TODAY_ATTENDANCE_KEY = 'today_attendance';
const CURRENT_SESSION_KEY = 'current_session';
const ATTENDANCE_STATS_KEY = 'attendance_stats';

/**
 * Attendance status constants
 * 
 * @description 考勤状态常量定义
 */
export const ATTENDANCE_STATUS = {
  /** 未签到 */
  NOT_SIGNED: 'NOT_SIGNED',
  /** 已签到 */
  SIGNED_IN: 'SIGNED_IN',
  /** 已签退 */
  SIGNED_OUT: 'SIGNED_OUT',
  /** 请假 */
  ON_LEAVE: 'ON_LEAVE',
  /** 缺席 */
  ABSENT: 'ABSENT'
} as const;

/**
 * Attendance statistics
 * 
 * @description 考勤统计信息接口
 */
export interface AttendanceStats {
  /** 总学生数 */
  totalStudents: number;
  
  /** 已签到数 */
  signedInCount: number;
  
  /** 已签退数 */
  signedOutCount: number;
  
  /** 未签到数 */
  notSignedCount: number;
  
  /** 请假数 */
  onLeaveCount: number;
  
  /** 签到率 */
  signInRate: number;
}

/**
 * Attendance state management
 * 
 * @description 考勤状态管理类，提供考勤数据的增删改查操作
 * @class
 * @example
 * ```typescript
 * // 设置今日考勤记录
 * AttendanceStore.setTodayAttendance(records);
 * 
 * // 更新学生签到状态
 * AttendanceStore.updateTodayAttendance(record);
 * 
 * // 获取统计数据
 * const stats = AttendanceStore.getAttendanceStats();
 * ```
 */
export class AttendanceStore {
  /**
   * Set today attendance records
   * 
   * @description 设置今日考勤记录列表到全局状态
   * @param {AttendanceRecord[]} records - 考勤记录列表数组
   * @returns {void}
   * @example
   * ```typescript
   * const records = await AttendanceService.getTodayAttendances();
   * AttendanceStore.setTodayAttendance(records.data);
   * ```
   */
  static setTodayAttendance(records: AttendanceRecord[]): void {
    AppStorage.setOrCreate(TODAY_ATTENDANCE_KEY, records);
  }

  /**
   * Get today attendance records
   * 
   * @description 从全局状态获取今日考勤记录列表
   * @returns {AttendanceRecord[]} 考勤记录列表数组，如果为空则返回空数组
   * @example
   * ```typescript
   * const records = AttendanceStore.getTodayAttendance();
   * console.log('考勤记录数量:', records.length);
   * ```
   */
  static getTodayAttendance(): AttendanceRecord[] {
    return AppStorage.get<AttendanceRecord[]>(TODAY_ATTENDANCE_KEY) ?? [];
  }

  /**
   * Update today attendance
   * 
   * @description 更新今日考勤记录中的指定记录（用于签到签退操作）
   * @param {AttendanceRecord} updatedRecord - 更新后的考勤记录
   * @returns {void}
   * @example
   * ```typescript
   * const record = AttendanceStore.findAttendanceByStudentId(123);
   * record.status = 'SIGNED_IN';
   * record.signInTime = new Date().toISOString();
   * AttendanceStore.updateTodayAttendance(record);
   * ```
   */
  static updateTodayAttendance(updatedRecord: AttendanceRecord): void {
    const records = this.getTodayAttendance();
    const index = records.findIndex(r => r.studentId === updatedRecord.studentId);
    if (index > -1) {
      records[index] = updatedRecord;
      this.setTodayAttendance(records);
    }
  }

  /**
   * Find attendance by student ID
   * 
   * @description 在今日考勤记录中查找指定学生的考勤记录
   * @param {number} studentId - 学生 ID
   * @returns {AttendanceRecord | null} 找到的考勤记录，未找到则返回 null
   * @example
   * ```typescript
   * const record = AttendanceStore.findAttendanceByStudentId(123);
   * if (record) {
   *   console.log('签到状态:', record.status);
   * }
   * ```
   */
  static findAttendanceByStudentId(studentId: number): AttendanceRecord | null {
    const records = this.getTodayAttendance();
    return records.find(r => r.studentId === studentId) ?? null;
  }

  /**
   * Set current session info
   * 
   * @description 设置当前班次信息（用于教师端考勤管理）
   * @param {SessionWithStudents} session - 班次详情对象（包含学生列表）
   * @returns {void}
   * @example
   * ```typescript
   * const session = sessions[0];
   * AttendanceStore.setCurrentSession(session);
   * ```
   */
  static setCurrentSession(session: SessionWithStudents): void {
    AppStorage.setOrCreate(CURRENT_SESSION_KEY, session);
  }

  /**
   * Get current session info
   * 
   * @description 获取当前班次信息
   * @returns {SessionWithStudents | null} 班次详情对象，如果未设置则返回 null
   * @example
   * ```typescript
   * const session = AttendanceStore.getCurrentSession();
   * if (session) {
   *   console.log('当前班次:', session.sessionNo);
   *   console.log('学生数量:', session.students.length);
   * }
   * ```
   */
  static getCurrentSession(): SessionWithStudents | null {
    return AppStorage.get<SessionWithStudents>(CURRENT_SESSION_KEY) ?? null;
  }

  /**
   * Set attendance statistics
   * 
   * @description 设置考勤统计数据
   * @param {AttendanceStats} stats - 统计数据对象
   * @returns {void}
   * @example
   * ```typescript
   * AttendanceStore.setAttendanceStats({
   *   totalStudents: 30,
   *   signedInCount: 25,
   *   signedOutCount: 20,
   *   notSignedCount: 5,
   *   onLeaveCount: 0,
   *   signInRate: 0.83
   * });
   * ```
   */
  static setAttendanceStats(stats: AttendanceStats): void {
    AppStorage.setOrCreate(ATTENDANCE_STATS_KEY, stats);
  }

  /**
   * Get attendance statistics
   * 
   * @description 获取考勤统计数据
   * @returns {AttendanceStats | null} 统计数据对象，如果未设置则返回 null
   * @example
   * ```typescript
   * const stats = AttendanceStore.getAttendanceStats();
   * if (stats) {
   *   console.log('签到率:', stats.signInRate);
   * }
   * ```
   */
  static getAttendanceStats(): AttendanceStats | null {
    return AppStorage.get<AttendanceStats>(ATTENDANCE_STATS_KEY) ?? null;
  }

  /**
   * Calculate and update statistics
   * 
   * @description 计算并更新考勤统计数据（基于当前考勤记录）
   * @returns {AttendanceStats} 计算后的统计数据
   * @example
   * ```typescript
   * const stats = AttendanceStore.calculateAndSetStats();
   * console.log('签到率:', stats.signInRate);
   * ```
   */
  static calculateAndSetStats(): AttendanceStats {
    const records = this.getTodayAttendance();
    
    const totalStudents = records.length;
    const signedInCount = records.filter(r => r.status === ATTENDANCE_STATUS.SIGNED_IN).length;
    const signedOutCount = records.filter(r => r.status === ATTENDANCE_STATUS.SIGNED_OUT).length;
    const notSignedCount = records.filter(r => r.status === ATTENDANCE_STATUS.NOT_SIGNED).length;
    const onLeaveCount = records.filter(r => r.status === ATTENDANCE_STATUS.ON_LEAVE).length;
    const signInRate = totalStudents > 0 ? signedInCount / totalStudents : 0;
    
    const stats: AttendanceStats = {
      totalStudents,
      signedInCount,
      signedOutCount,
      notSignedCount,
      onLeaveCount,
      signInRate
    };
    
    this.setAttendanceStats(stats);
    return stats;
  }

  /**
   * Clear all attendance data
   * 
   * @description 清除所有考勤相关数据（用于退出登录或切换日期）
   * @returns {void}
   * @example
   * ```typescript
   * // 用户退出登录时调用
   * AttendanceStore.clearAll();
   * ```
   */
  static clearAll(): void {
    AppStorage.delete(TODAY_ATTENDANCE_KEY);
    AppStorage.delete(CURRENT_SESSION_KEY);
    AppStorage.delete(ATTENDANCE_STATS_KEY);
  }
}
