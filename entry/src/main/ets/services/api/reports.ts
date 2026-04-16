/**
 * SmartGuardian - Reports & Cards API Service
 * Statistics, reports, and widget card APIs
 */

import { get, post } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';

/**
 * Attendance Report
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
 */
export interface TodaySummaryCard {
  studentId: number;
  studentName: string;
  sessionName: string;
  sessionTime: string;
  status: 'NOT_SIGNED' | 'SIGNED_IN' | 'IN_PROGRESS' | 'SIGNED_OUT';
  latestDynamic: string;
  homeworkProgress?: number;
  teacherFeedback?: string;
}

/**
 * Abnormal Alert Card
 */
export interface AbnormalAlertCard {
  studentId: number;
  studentName: string;
  abnormalType: string;
  occurTime: string;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
  suggestedAction: string;
}

/**
 * Reports API Service
 */
export class ReportsService {
  /**
   * Get attendance report
   */
  static async getAttendanceReport(params?: {
    startDate?: string;
    endDate?: string;
    orgId?: number;
    schoolId?: number;
  }): Promise<ApiResponse<AttendanceReport>> {
    return get<AttendanceReport>('/api/v1/reports/attendance', params);
  }

  /**
   * Get finance report
   */
  static async getFinanceReport(params?: {
    startDate?: string;
    endDate?: string;
    orgId?: number;
  }): Promise<ApiResponse<FinanceReport>> {
    return get<FinanceReport>('/api/v1/reports/finance', params);
  }

  /**
   * Get teacher performance report
   */
  static async getTeacherPerformance(params?: {
    startDate?: string;
    endDate?: string;
    teacherId?: number;
    orgId?: number;
  }): Promise<ApiResponse<TeacherPerformance[]>> {
    return get<TeacherPerformance[]>('/api/v1/reports/performance', params);
  }
}

/**
 * Cards API Service (for Widget/Meta Service)
 */
export class CardsService {
  /**
   * Get today summary card
   */
  static async getTodaySummary(studentId: number): Promise<ApiResponse<TodaySummaryCard>> {
    return get<TodaySummaryCard>('/api/v1/cards/today-summary', { studentId });
  }

  /**
   * Get abnormal alert card
   */
  static async getAbnormalAlert(studentId: number): Promise<ApiResponse<AbnormalAlertCard | null>> {
    return get<AbnormalAlertCard | null>('/api/v1/cards/abnormal-alert', { studentId });
  }
}