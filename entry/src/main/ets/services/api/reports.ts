/**
 * SmartGuardian - Reports & Cards API Service
 * Statistics and reports APIs aligned with AGC contracts
 */

import { get } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import {
  AttendanceReport,
  FinanceReport,
  TeacherPerformance,
  DailyAttendanceStats,
  StudentAttendanceSummary,
  DailyRevenueStats,
  ServiceProductRevenue,
  ReportQueryParams
} from '../../models/report';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

export { AttendanceReport, FinanceReport, TeacherPerformance } from '../../models/report';

export class ReportsService {
  static readonly AGC_DOMAIN: string = 'report';
  static readonly AGC_FUNCTION: string = 'smartguardian-report';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.REPORTS;

  static async getAttendanceReport(params?: {
    startDate?: string;
    endDate?: string;
    orgId?: number;
    schoolId?: number;
  }): Promise<ApiResponse<AttendanceReport>> {
    return get<AttendanceReport>(ApiEndpoints.REPORTS_ATTENDANCE, params);
  }

  static async getFinanceReport(params?: {
    startDate?: string;
    endDate?: string;
    orgId?: number;
  }): Promise<ApiResponse<FinanceReport>> {
    return get<FinanceReport>(ApiEndpoints.REPORTS_FINANCE, params);
  }

  static async getTeacherPerformance(params?: {
    startDate?: string;
    endDate?: string;
    teacherId?: number;
    orgId?: number;
  }): Promise<ApiResponse<TeacherPerformance[]>> {
    return get<TeacherPerformance[]>(ApiEndpoints.REPORTS_PERFORMANCE, params);
  }

  static async getDailyAttendanceStats(params?: ReportQueryParams): Promise<ApiResponse<DailyAttendanceStats[]>> {
    return get<DailyAttendanceStats[]>(ApiEndpoints.REPORTS_ATTENDANCE_DAILY, params);
  }

  static async getStudentAttendanceSummary(params?: ReportQueryParams): Promise<ApiResponse<StudentAttendanceSummary[]>> {
    return get<StudentAttendanceSummary[]>(ApiEndpoints.REPORTS_ATTENDANCE_STUDENTS, params);
  }

  static async getDailyRevenueStats(params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<DailyRevenueStats[]>> {
    return get<DailyRevenueStats[]>(ApiEndpoints.REPORTS_FINANCE_DAILY, params);
  }

  static async getServiceProductRevenue(params?: {
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<ServiceProductRevenue[]>> {
    return get<ServiceProductRevenue[]>(ApiEndpoints.REPORTS_FINANCE_PRODUCTS, params);
  }
}
