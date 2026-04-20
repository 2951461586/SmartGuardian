/**
 * SmartGuardian - Attendance Store
 * Attendance state management with reactive support
 * 
 * @description 考勤状态管理 Store，负责考勤数据和学生签到签退状态的全局管理
 * @features
 * - 今日考勤记录缓存
 * - 当前班次信息追踪
 * - 学生签到签退状态实时更新
 * - 考勤统计数据维护
 * - 响应式状态变更通知
 * - 持久化支持
 */

import { AttendanceRecord } from '../models/attendance';
import { SessionWithStudents } from '../models/service';
import { ReactiveStore, StateChangeListener } from './core';

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
 * Attendance state management with reactive support
 * 
 * @description 考勤状态管理类，提供考勤数据的增删改查操作
 * @class
 * @example
 * ```typescript
 * // 设置今日考勤记录
 * AttendanceStore.setTodayAttendance(records);
 * 
 * // 监听考勤记录变更
 * AttendanceStore.onAttendanceChange((event) => {
 *   console.log('考勤记录已更新');
 * });
 * 
 * // 更新学生签到状态
 * AttendanceStore.updateTodayAttendance(record);
 * ```
 */
export class AttendanceStore extends ReactiveStore {
  // 初始化 Store 配置
  static {
    this.initOptions({
      name: 'AttendanceStore',
      persistent: false
    });
  }
  
  /**
   * Set today attendance records
   * 
   * @description 设置今日考勤记录列表到全局状态
   * @param {AttendanceRecord[]} records - 考勤记录列表数组
   */
  static setTodayAttendance(records: AttendanceRecord[]): void {
    this.setValue(TODAY_ATTENDANCE_KEY, records);
    // 自动更新统计数据
    this.updateStats(records);
  }
  
  /**
   * Get today attendance records
   * 
   * @description 从全局状态获取今日考勤记录列表
   * @returns {AttendanceRecord[]} 考勤记录列表数组，如果为空则返回空数组
   */
  static getTodayAttendance(): AttendanceRecord[] {
    return this.getValue<AttendanceRecord[]>(TODAY_ATTENDANCE_KEY) ?? [];
  }
  
  /**
   * Update today attendance
   * 
   * @description 更新今日考勤记录中的指定记录（用于签到签退操作）
   * @param {AttendanceRecord} updatedRecord - 更新后的考勤记录
   */
  static updateTodayAttendance(updatedRecord: AttendanceRecord): void {
    const records = this.getTodayAttendance();
    const index = records.findIndex(r => r.studentId === updatedRecord.studentId);
    if (index > -1) {
      records[index] = updatedRecord;
      this.setTodayAttendance([...records]);
    }
  }
  
  /**
   * Find attendance by student ID
   * 
   * @description 在今日考勤记录中查找指定学生的考勤记录
   * @param {number} studentId - 学生 ID
   * @returns {AttendanceRecord | null} 找到的考勤记录，未找到则返回 null
   */
  static findAttendanceByStudentId(studentId: number): AttendanceRecord | null {
    return this.getTodayAttendance().find(r => r.studentId === studentId) ?? null;
  }
  
  /**
   * Set current session
   * 
   * @description 设置当前班次信息
   * @param {SessionWithStudents} session - 班次对象
   */
  static setCurrentSession(session: SessionWithStudents): void {
    this.setValue(CURRENT_SESSION_KEY, session);
  }
  
  /**
   * Get current session
   * 
   * @description 获取当前班次信息
   * @returns {SessionWithStudents | null} 当前班次对象，如果未设置则返回 null
   */
  static getCurrentSession(): SessionWithStudents | null {
    return this.getValue<SessionWithStudents>(CURRENT_SESSION_KEY) ?? null;
  }
  
  /**
   * Get current session ID
   * 
   * @description 获取当前班次的 ID
   * @returns {number | null} 当前班次 ID，如果未设置则返回 null
   */
  static getCurrentSessionId(): number | null {
    const session = this.getCurrentSession();
    return session?.id ?? null;
  }
  
  /**
   * Set attendance stats
   * 
   * @description 设置考勤统计数据
   * @param {AttendanceStats} stats - 统计数据对象
   */
  static setAttendanceStats(stats: AttendanceStats): void {
    this.setValue(ATTENDANCE_STATS_KEY, stats, { persist: true });
  }
  
  /**
   * Get attendance stats
   * 
   * @description 获取考勤统计数据
   * @returns {AttendanceStats | null} 统计数据对象，如果未设置则返回 null
   */
  static getAttendanceStats(): AttendanceStats | null {
    return this.getValue<AttendanceStats>(ATTENDANCE_STATS_KEY) ?? null;
  }
  
  /**
   * Update stats
   * 
   * @description 根据考勤记录更新统计数据
   * @param {AttendanceRecord[]} records - 考勤记录列表
   */
  private static updateStats(records: AttendanceRecord[]): void {
    const totalStudents = records.length;
    const signedInCount = records.filter(r => 
      r.status === ATTENDANCE_STATUS.SIGNED_IN || r.status === ATTENDANCE_STATUS.SIGNED_OUT
    ).length;
    const signedOutCount = records.filter(r => 
      r.status === ATTENDANCE_STATUS.SIGNED_OUT
    ).length;
    const notSignedCount = records.filter(r => 
      r.status === ATTENDANCE_STATUS.NOT_SIGNED
    ).length;
    const onLeaveCount = records.filter(r => 
      r.status === ATTENDANCE_STATUS.ON_LEAVE
    ).length;
    
    const stats: AttendanceStats = {
      totalStudents,
      signedInCount,
      signedOutCount,
      notSignedCount,
      onLeaveCount,
      signInRate: totalStudents > 0 ? signedInCount / totalStudents : 0
    };
    
    this.setAttendanceStats(stats);
  }
  
  /**
   * Sign in student
   * 
   * @description 学生签到
   * @param {number} studentId - 学生 ID
   * @param {string} signInTime - 签到时间
   */
  static signInStudent(studentId: number, signInTime: string): void {
    const record = this.findAttendanceByStudentId(studentId);
    if (record) {
      record.status = ATTENDANCE_STATUS.SIGNED_IN;
      record.signInTime = signInTime;
      this.updateTodayAttendance(record);
    }
  }
  
  /**
   * Sign out student
   * 
   * @description 学生签退
   * @param {number} studentId - 学生 ID
   * @param {string} signOutTime - 签退时间
   */
  static signOutStudent(studentId: number, signOutTime: string): void {
    const record = this.findAttendanceByStudentId(studentId);
    if (record) {
      record.status = ATTENDANCE_STATUS.SIGNED_OUT;
      record.signOutTime = signOutTime;
      this.updateTodayAttendance(record);
    }
  }
  
  /**
   * Get attendance by status
   * 
   * @description 按状态获取考勤记录
   * @param {string} status - 考勤状态
   * @returns {AttendanceRecord[]} 筛选后的考勤记录列表
   */
  static getAttendanceByStatus(status: string): AttendanceRecord[] {
    return this.getTodayAttendance().filter(r => r.status === status);
  }
  
  /**
   * Clear today attendance
   * 
   * @description 清空今日考勤记录
   */
  static clearTodayAttendance(): void {
    this.setTodayAttendance([]);
  }
  
  /**
   * Clear current session
   * 
   * @description 清除当前班次信息
   */
  static clearCurrentSession(): void {
    this.deleteValue(CURRENT_SESSION_KEY);
  }
  
  // ============ 响应式订阅方法 ============
  
  /**
   * Subscribe to attendance changes
   * 
   * @description 订阅考勤记录变更
   * @param {StateChangeListener<AttendanceRecord[]>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onAttendanceChange(listener: StateChangeListener<AttendanceRecord[]>): () => void {
    return this.subscribe<AttendanceRecord[]>(TODAY_ATTENDANCE_KEY, listener);
  }
  
  /**
   * Subscribe to current session changes
   * 
   * @description 订阅当前班次变更
   * @param {StateChangeListener<SessionWithStudents>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onCurrentSessionChange(listener: StateChangeListener<SessionWithStudents>): () => void {
    return this.subscribe<SessionWithStudents>(CURRENT_SESSION_KEY, listener);
  }
  
  /**
   * Subscribe to stats changes
   * 
   * @description 订阅统计数据变更
   * @param {StateChangeListener<AttendanceStats>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onStatsChange(listener: StateChangeListener<AttendanceStats>): () => void {
    return this.subscribe<AttendanceStats>(ATTENDANCE_STATS_KEY, listener);
  }
}
