import { AlertStatistics } from '../../../models/alert';
import {
  AttendanceReport,
  DailyAttendanceStats,
  DailyRevenueStats,
  FinanceReport,
  ServiceProductRevenue,
  StudentAttendanceSummary,
  TeacherPerformance
} from '../../../models/report';
import { PaymentOrder } from '../../../models/payment';
import { RefundRecord, RefundStatistics } from '../../../models/refund';

export const mockRefunds: RefundRecord[] = [
  {
    id: 1,
    orderNo: 'ORD20260401001',
    orderId: 1,
    studentId: 1,
    studentName: '王小明',
    serviceProductId: 1,
    serviceName: '午间托管',
    refundAmount: 200,
    reason: '临时请假退费',
    reasonType: 'PERSONAL_REASON',
    status: 'PENDING',
    appliedAt: '2026-04-16T09:00:00Z',
    createdAt: '2026-04-16T09:00:00Z',
    updatedAt: '2026-04-16T09:00:00Z'
  }
];

export const mockRefundStatistics: RefundStatistics = {
  total: 1,
  pending: 1,
  processing: 0,
  completed: 0,
  totalAmount: 200
};

export const mockPaymentOrders: PaymentOrder[] = [
  {
    id: 1,
    orderId: 1,
    paymentNo: 'PAY20260416001',
    payChannel: 'ALIPAY',
    payAmount: 800,
    payStatus: 'SUCCESS',
    payTime: '2026-04-16T10:00:00Z',
    expireTime: '2026-04-16T10:30:00Z',
    payUrl: 'https://mock.smartguardian/pay/PAY20260416001',
    qrCode: 'MOCK_QR_PAY20260416001',
    thirdTradeNo: 'TRADE20260416001'
  }
];

export const mockAttendanceReport: AttendanceReport = {
  totalStudents: 2,
  presentCount: 1,
  absentCount: 1,
  lateCount: 0,
  leaveCount: 1,
  attendanceRate: 50,
  dailyStats: [
    {
      date: '2026-04-16',
      presentCount: 1,
      absentCount: 1,
      lateCount: 0
    }
  ]
};

export const mockFinanceReport: FinanceReport = {
  totalIncome: 1700,
  totalRefund: 200,
  netIncome: 1500,
  orderCount: 3,
  refundedOrderCount: 1,
  dailyStats: [
    {
      date: '2026-04-16',
      income: 1700,
      refund: 200
    }
  ]
};

export const mockTeacherPerformance: TeacherPerformance[] = [
  {
    teacherId: 2,
    teacherName: '王老师',
    totalSessions: 12,
    totalStudents: 36,
    avgAttendanceRate: 96,
    homeworkCompletedCount: 48,
    avgRating: 4.8
  }
];

export const mockDailyAttendanceStats: DailyAttendanceStats[] = [
  {
    date: '2026-04-16',
    totalStudents: 2,
    presentStudents: 1,
    absentStudents: 1,
    lateStudents: 0,
    leaveStudents: 1,
    attendanceRate: 50
  }
];

export const mockStudentAttendanceSummary: StudentAttendanceSummary[] = [
  {
    studentId: 1,
    studentName: '王小明',
    studentNo: 'S20260001',
    totalDays: 20,
    presentDays: 18,
    absentDays: 1,
    lateDays: 1,
    leaveDays: 0,
    attendanceRate: 90
  }
];

export const mockDailyRevenueStats: DailyRevenueStats[] = [
  {
    date: '2026-04-16',
    orderCount: 2,
    totalAmount: 1300,
    paidAmount: 800,
    refundedAmount: 200
  }
];

export const mockServiceProductRevenue: ServiceProductRevenue[] = [
  {
    serviceProductId: 1,
    serviceName: '午间托管',
    orderCount: 2,
    totalAmount: 1600,
    percentage: 70
  },
  {
    serviceProductId: 2,
    serviceName: '课后托管',
    orderCount: 1,
    totalAmount: 660,
    percentage: 30
  }
];
