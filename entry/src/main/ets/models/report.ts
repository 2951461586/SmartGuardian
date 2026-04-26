/**
 * SmartGuardian - Report Models
 * Statistics report related types
 */

/**
 * Attendance report summary
 */
export interface AttendanceReport {
  totalStudents: number;
  presentCount: number;
  absentCount: number;
  lateCount: number;
  leaveCount: number;
  attendanceRate: number;
  dailyStats: AttendanceDailyBucket[];
}

export interface AttendanceDailyBucket {
  date: string;
  presentCount: number;
  absentCount: number;
  lateCount: number;
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
  totalIncome: number;
  totalRefund: number;
  netIncome: number;
  orderCount: number;
  refundedOrderCount: number;
  dailyStats: FinanceDailyBucket[];
}

export interface FinanceDailyBucket {
  date: string;
  income: number;
  refund: number;
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
