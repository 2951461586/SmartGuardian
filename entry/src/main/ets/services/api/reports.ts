/**
 * SmartGuardian - Reports & Cards API Service
 * Statistics, reports, and widget card APIs
 * 
 * @description 报表与卡片 API，提供统计报表和首页卡片数据功能
 * @features
 * - 考勤报表统计
 * - 财务报表统计
 * - 教师绩效报表
 * - 今日状态卡片
 * - 异常告警卡片
 */

import { get, post } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';
import { 
  DailyAttendanceStats, 
  StudentAttendanceSummary,
  DailyRevenueStats,
  ServiceProductRevenue,
  ReportQueryParams 
} from '../../models/report';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Attendance Report
 * 
 * @description 考勤报表数据结构
 */
export interface AttendanceReport {
  totalStudents: number;
  presentCount: number;
  absentCount: number;
  lateCount: number;
  leaveCount: number;
  attendanceRate: number;
  dailyStats: {
    date: string;
    presentCount: number;
    absentCount: number;
    lateCount: number;
  }[];
}

/**
 * Finance Report
 * 
 * @description 财务报表数据结构
 */
export interface FinanceReport {
  totalIncome: number;
  totalRefund: number;
  netIncome: number;
  orderCount: number;
  refundedOrderCount: number;
  dailyStats: {
    date: string;
    income: number;
    refund: number;
  }[];
}

/**
 * Teacher Performance
 * 
 * @description 教师绩效数据结构
 */
export interface TeacherPerformance {
  teacherId: number;
  teacherName: string;
  totalSessions: number;
  totalStudents: number;
  avgAttendanceRate: number;
  homeworkCompletedCount: number;
  avgRating: number;
}

/**
 * Today Summary Card
 * 
 * @description 今日状态卡片数据结构
 */
/**
 * Reports API Service
 * 
 * @description 报表服务类，提供考勤、财务和教师绩效报表功能
 * @class
 */
export class ReportsService {
  /**
   * Get attendance report
   * 
   * @description 获取考勤报表统计数据
   * @param params 查询参数（日期范围、组织ID、学校ID）
   * @returns 考勤报表响应
   */
  static async getAttendanceReport(params?: {
    startDate?: string;
    endDate?: string;
    orgId?: number;
    schoolId?: number;
  }): Promise<ApiResponse<AttendanceReport>> {
    return get<AttendanceReport>(ApiEndpoints.REPORTS_ATTENDANCE, params);
  }

  /**
   * Get finance report
   * 
   * @description 获取财务报表统计数据
   * @param params 查询参数（日期范围、组织ID）
   * @returns 财务报表响应
   */
  static async getFinanceReport(params?: {
    startDate?: string;
    endDate?: string;
    orgId?: number;
  }): Promise<ApiResponse<FinanceReport>> {
    return get<FinanceReport>(ApiEndpoints.REPORTS_FINANCE, params);
  }

  /**
   * Get teacher performance report
   * 
   * @description 获取教师绩效报表
   * @param params 查询参数（日期范围、教师ID、组织ID）
   * @returns 教师绩效数组响应
   */
  static async getTeacherPerformance(params?: {
    startDate?: string;
    endDate?: string;
    teacherId?: number;
    orgId?: number;
  }): Promise<ApiResponse<TeacherPerformance[]>> {
    return get<TeacherPerformance[]>(ApiEndpoints.REPORTS_PERFORMANCE, params);
  }

  /**
   * Get daily attendance statistics
   * 
   * @description 获取每日考勤统计数据（从原 report.ts 迁移）
   * @param params 查询参数
   * @returns 每日考勤统计数组响应
   */
  static async getDailyAttendanceStats(params?: ReportQueryParams): Promise<ApiResponse<DailyAttendanceStats[]>> {
    return get<DailyAttendanceStats[]>(ApiEndpoints.REPORTS_ATTENDANCE_DAILY, params);
  }

  /**
   * Get student attendance summary
   * 
   * @description 获取学生考勤汇总数据（从原 report.ts 迁移）
   * @param params 查询参数
   * @returns 学生考勤汇总数组响应
   */
  static async getStudentAttendanceSummary(params?: ReportQueryParams): Promise<ApiResponse<StudentAttendanceSummary[]>> {
    return get<StudentAttendanceSummary[]>(ApiEndpoints.REPORTS_ATTENDANCE_STUDENTS, params);
  }

  /**
   * Get daily revenue statistics
   * 
   * @description 获取每日营收统计数据（从原 report.ts 迁移）
   * @param params 查询参数（日期范围）
   * @returns 每日营收统计数组响应
   */
  static async getDailyRevenueStats(params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<DailyRevenueStats[]>> {
    return get<DailyRevenueStats[]>(ApiEndpoints.REPORTS_FINANCE_DAILY, params);
  }

  /**
   * Get service product revenue
   * 
   * @description 获取服务产品营收数据（从原 report.ts 迁移）
   * @param params 查询参数（日期范围）
   * @returns 服务产品营收数组响应
   */
  static async getServiceProductRevenue(params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<ServiceProductRevenue[]>> {
    return get<ServiceProductRevenue[]>(ApiEndpoints.REPORTS_FINANCE_PRODUCTS, params);
  }
}