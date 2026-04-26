import { ApiResponse } from '../../../models/common';
import {
  AttendanceReport,
  DailyAttendanceStats,
  DailyRevenueStats,
  FinanceReport,
  ServiceProductRevenue,
  StudentAttendanceSummary,
  TeacherPerformance
} from '../../../models/report';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import {
  mockAttendanceReport,
  mockDailyAttendanceStats,
  mockDailyRevenueStats,
  mockFinanceReport,
  mockServiceProductRevenue,
  mockStudentAttendanceSummary,
  mockTeacherPerformance
} from '../mockData';
import { mockNotFound, mockResponse } from '../shared/mockUtils';

export class ReportMockHandler {
  static async getAttendanceReport(): Promise<ApiResponse<AttendanceReport>> {
    return mockResponse(mockAttendanceReport);
  }

  static async getFinanceReport(): Promise<ApiResponse<FinanceReport>> {
    return mockResponse(mockFinanceReport);
  }

  static async getTeacherPerformance(): Promise<ApiResponse<TeacherPerformance[]>> {
    return mockResponse(mockTeacherPerformance);
  }

  static async getDailyAttendanceStats(): Promise<ApiResponse<DailyAttendanceStats[]>> {
    return mockResponse(mockDailyAttendanceStats);
  }

  static async getStudentAttendanceSummary(): Promise<ApiResponse<StudentAttendanceSummary[]>> {
    return mockResponse(mockStudentAttendanceSummary);
  }

  static async getDailyRevenueStats(): Promise<ApiResponse<DailyRevenueStats[]>> {
    return mockResponse(mockDailyRevenueStats);
  }

  static async getServiceProductRevenue(): Promise<ApiResponse<ServiceProductRevenue[]>> {
    return mockResponse(mockServiceProductRevenue);
  }

  static async handleRequest<T>(path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (method !== HttpMethod.GET) {
      return mockNotFound<T>();
    }
    if (path === ApiEndpoints.REPORTS_ATTENDANCE) {
      return this.getAttendanceReport() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_FINANCE) {
      return this.getFinanceReport() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_PERFORMANCE) {
      return this.getTeacherPerformance() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_ATTENDANCE_DAILY) {
      return this.getDailyAttendanceStats() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_ATTENDANCE_STUDENTS) {
      return this.getStudentAttendanceSummary() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_FINANCE_DAILY) {
      return this.getDailyRevenueStats() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_FINANCE_PRODUCTS || path === ApiEndpoints.REPORTS) {
      return this.getServiceProductRevenue() as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
