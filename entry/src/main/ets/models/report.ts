/**
 * SmartGuardian - Report Models
 * Statistics report related types
 */

/**
 * Attendance report summary
 */
export interface AttendanceReport {
  reportDate: string;
  totalCount: number;
  signedInCount: number;
  signedOutCount: number;
  absentCount: number;
  lateCount: number;
  leaveCount: number;
  abnormalCount: number;
  attendanceRate: number;
}

/**
 * Daily attendance statistics
 */
export interface DailyAttendanceStats {
  date: string;
  totalStudents: number;
  presentStudents: number;
  absentStudents: number;
  lateStudents: number;
  leaveStudents: number;
  attendanceRate: number;
}

/**
 * Student attendance summary
 */
export interface StudentAttendanceSummary {
  studentId: number;
  studentName: string;
  studentNo: string;
  totalDays: number;
  presentDays: number;
  absentDays: number;
  lateDays: number;
  leaveDays: number;
  attendanceRate: number;
}

/**
 * Finance report summary
 */
export interface FinanceReport {
  reportMonth: string;
  totalOrders: number;
  totalAmount: number;
  paidAmount: number;
  pendingAmount: number;
  refundedAmount: number;
  orderCount: number;
  refundCount: number;
}

/**
 * Teacher performance
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
 * Daily revenue statistics
 */
export interface DailyRevenueStats {
  date: string;
  orderCount: number;
  totalAmount: number;
  paidAmount: number;
  refundedAmount: number;
}

/**
 * Service product revenue
 */
export interface ServiceProductRevenue {
  serviceProductId: number;
  serviceName: string;
  orderCount: number;
  totalAmount: number;
  percentage: number;
}

/**
 * Report query parameters
 */
export interface ReportQueryParams {
  startDate: string;
  endDate: string;
  serviceProductId?: number;
  studentId?: number;
}
