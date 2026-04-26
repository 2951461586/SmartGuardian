/**
 * SmartGuardian - Mock Data
 * Barrel exports for domain-based mock datasets.
 */

export { mockV2Examples, getMockLoginResponse } from './data/authData';
export { mockUsers, mockStudents, mockGuardians } from './data/userData';
export { mockServiceProducts, mockOrders, mockSessions, mockSessionStudents } from './data/serviceData';
export {
  mockAttendanceRecords,
  mockLeaveRecords,
  mockHomeworkTasks,
  mockMessages,
  mockMessageStatistics,
  mockMessageDetails,
  mockTimeline,
  mockTodayStatusCard,
  mockAbnormalAlerts,
  mockAlerts,
  mockAlertStatistics
} from './data/activityData';
export {
  mockRefunds,
  mockRefundStatistics,
  mockPaymentOrders,
  mockAttendanceReport,
  mockFinanceReport,
  mockTeacherPerformance,
  mockDailyAttendanceStats,
  mockStudentAttendanceSummary,
  mockDailyRevenueStats,
  mockServiceProductRevenue
} from './data/financeData';
