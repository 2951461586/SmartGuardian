/**
 * SmartGuardian - Mock Data
 * Mock data for development and testing
 */

import { UserInfo, Student, LoginResponse, GuardianRelation } from '../../models/user';
import { UserRole } from '../../models/common';
import { ServiceProduct, Order, SessionSchedule, SessionStudent } from '../../models/service';
import { AttendanceRecord, LeaveRecord } from '../../models/attendance';
import { HomeworkTask, HomeworkTaskStatus } from '../../models/homework';
import { MessageRecord, MessageStatistics, MessageDetail } from '../../models/message';
import { StudentTimeline } from '../../models/timeline';
import { TodayStatusCard, AbnormalAlertCard } from '../../models/card';
import { RefundRecord, RefundStatistics } from '../../models/refund';
import { PaymentOrder } from '../../models/payment';
import { DailyAttendanceStats, StudentAttendanceSummary, DailyRevenueStats, ServiceProductRevenue, AttendanceReport, FinanceReport, TeacherPerformance } from '../../models/report';

/**
 * Mock Users
 */
export const mockUsers: UserInfo[] = [
  {
    id: 1,
    username: 'parent_zhang',
    realName: '张丽',
    mobile: '13800000001',
    roleType: UserRole.PARENT,
    avatar: 'https://example.com/avatar/parent_zhang.jpg'
  },
  {
    id: 2,
    username: 'teacher_wang',
    realName: '王老师',
    mobile: '13800000002',
    roleType: UserRole.TEACHER,
    avatar: 'https://example.com/avatar/teacher_wang.jpg'
  },
  {
    id: 3,
    username: 'admin_li',
    realName: '李管理员',
    mobile: '13800000003',
    roleType: UserRole.ORG_ADMIN,
    avatar: 'https://example.com/avatar/admin_li.jpg'
  }
];

/**
 * Mock Students
 */
export const mockStudents: Student[] = [
  {
    id: 1,
    studentNo: 'S20260001',
    name: '王小明',
    schoolId: 1,
    schoolName: '实验小学',
    classId: 1,
    className: '三年级1班',
    grade: '三年级',
    gender: 'MALE',
    birthDate: '2016-05-15',
    guardianUserId: 1,
    guardianName: '张丽',
    guardianMobile: '13800000001',
    healthNotes: '无特殊病史',
    status: 'ACTIVE',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z'
  },
  {
    id: 2,
    studentNo: 'S20260002',
    name: '李小红',
    schoolId: 1,
    schoolName: '实验小学',
    classId: 1,
    className: '三年级1班',
    grade: '三年级',
    gender: 'FEMALE',
    birthDate: '2016-08-20',
    guardianUserId: 1,
    guardianName: '张丽',
    guardianMobile: '13800000001',
    healthNotes: '对花生过敏',
    status: 'ACTIVE',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z'
  }
];

export const mockGuardians: GuardianRelation[] = [
  {
    id: 1,
    studentId: 1,
    userId: 1,
    relation: 'MOTHER',
    isPrimary: true,
    authorizedPickup: true,
    pickupCode: 'PICKUP-1001'
  },
  {
    id: 2,
    studentId: 1,
    userId: 2,
    relation: 'FATHER',
    isPrimary: false,
    authorizedPickup: true,
    pickupCode: 'PICKUP-1002'
  }
];

/**
 * Mock Service Products
 */
export const mockServiceProducts: ServiceProduct[] = [
  {
    id: 1,
    serviceName: '午间托管',
    serviceType: 'NOON_CARE',
    price: 800,
    capacity: 30,
    status: 'ACTIVE',
    description: '中午12:00-14:00提供午餐和午休',
    unit: '月',
    gradeRange: '1-6年级',
    maxStudents: 30,
    currentStudents: 25,
    serviceStartDate: '2026-03-01',
    serviceEndDate: '2026-07-31',
    orgId: 1,
    orgName: '智慧托管中心'
  },
  {
    id: 2,
    serviceName: '课后托管',
    serviceType: 'AFTER_SCHOOL_CARE',
    price: 1200,
    capacity: 40,
    status: 'ACTIVE',
    description: '下午放学后到18:30，提供作业辅导和晚餐',
    unit: '月',
    gradeRange: '1-6年级',
    maxStudents: 40,
    currentStudents: 35,
    serviceStartDate: '2026-03-01',
    serviceEndDate: '2026-07-31',
    orgId: 1,
    orgName: '智慧托管中心'
  }
];

/**
 * Mock Orders
 */
export const mockOrders: Order[] = [
  {
    id: 1,
    orderNo: 'ORD20260401001',
    studentId: 1,
    serviceProductId: 1,
    orderStatus: 'APPROVED',
    amount: 800,
    paidAmount: 800,
    payStatus: 'PAID',
    auditStatus: 'APPROVED',
    studentName: '王小明',
    guardianUserId: 1,
    guardianName: '张丽',
    serviceProductName: '午间托管',
    startDate: '2026-04-01',
    endDate: '2026-04-30',
    createdAt: '2026-03-28T10:30:00Z',
    updatedAt: '2026-03-28T11:00:00Z'
  }
];

/**
 * Mock Sessions
 */
export const mockSessions: SessionSchedule[] = [
  {
    id: 1,
    sessionDate: '2026-04-16',
    startTime: '16:30:00',
    endTime: '18:30:00',
    teacherUserId: 2,
    capacity: 40,
    currentCount: 35,
    sessionNo: 'SES20260416001',
    serviceProductId: 2,
    serviceProductName: '课后托管',
    teacherId: 2,
    teacherName: '王老师',
    maxCapacity: 40,
    location: '实验小学托管教室A',
    status: 'ACTIVE'
  }
];

/**
 * Mock Attendance Records
 */
export const mockAttendanceRecords: AttendanceRecord[] = [
  {
    id: 1,
    studentId: 1,
    sessionId: 1,
    signInTime: '2026-04-16T16:35:00Z',
    status: 'SIGNED_IN',
    studentName: '王小明',
    studentNo: 'S20260001',
    sessionNo: 'SES20260416001',
    attendanceDate: '2026-04-16',
    signInMethod: 'QRCODE',
    signInLocation: '实验小学托管教室A'
  },
  {
    id: 2,
    studentId: 2,
    sessionId: 1,
    status: 'ABSENT',
    abnormalFlag: true,
    abnormalType: 'ABSENT',
    abnormalDesc: '学生未到班次',
    studentName: '李小红',
    studentNo: 'S20260002',
    sessionNo: 'SES20260416001',
    attendanceDate: '2026-04-16'
  }
];

export const mockLeaveRecords: LeaveRecord[] = [
  {
    id: 1,
    studentId: 2,
    leaveDate: '2026-04-17',
    leaveType: 'SICK',
    reason: '感冒发烧请假',
    attachments: [],
    status: 'PENDING',
    reviewerId: 2,
    reviewerName: '王老师',
    createdAt: '2026-04-16T20:00:00Z',
    updatedAt: '2026-04-16T20:00:00Z'
  }
];

/**
 * Mock Homework Tasks
 */
export const mockHomeworkTasks: HomeworkTask[] = [
  {
    id: 1,
    studentId: 1,
    taskDate: '2026-04-16',
    subject: '语文',
    title: '完成课后练习第5课',
    content: '完成练习册第12-13页',
    status: HomeworkTaskStatus.IN_PROGRESS,
    studentName: '王小明',
    teacherId: 2,
    teacherName: '王老师'
  },
  {
    id: 2,
    studentId: 1,
    taskDate: '2026-04-16',
    subject: '数学',
    title: '完成练习题',
    content: '完成口算练习第20页',
    status: HomeworkTaskStatus.PENDING,
    studentName: '王小明',
    teacherId: 2,
    teacherName: '王老师'
  }
];

/**
 * Mock Messages
 */
export const mockMessages: MessageRecord[] = [
  {
    id: 1,
    userId: 2,
    msgType: 'ATTENDANCE',
    title: '签到通知',
    content: '王小明同学已安全到达托管教室，请家长放心。',
    readStatus: false,
    createdAt: '2026-04-16T16:36:00Z',
    updatedAt: '2026-04-16T16:36:00Z'
  },
  {
    id: 2,
    userId: 1,
    msgType: 'HOMEWORK',
    title: '作业提醒',
    content: '请完成今日语文作业。',
    readStatus: true,
    readAt: '2026-04-16T21:00:00Z',
    createdAt: '2026-04-16T18:00:00Z',
    updatedAt: '2026-04-16T21:00:00Z'
  }
];

export const mockMessageStatistics: MessageStatistics = {
  total: 2,
  unread: 1,
  byType: {
    ATTENDANCE: 1,
    HOMEWORK: 1
  }
};

export const mockMessageDetails: MessageDetail[] = [
  {
    id: 1,
    userId: 2,
    msgType: 'ATTENDANCE',
    title: '签到通知',
    content: '王小明同学已安全到达托管教室，请家长放心。',
    readStatus: false,
    createdAt: '2026-04-16T16:36:00Z',
    updatedAt: '2026-04-16T16:36:00Z',
    relatedInfo: {
      studentName: '王小明',
      actionText: '查看考勤',
      actionUrl: '/attendance/1'
    }
  }
];

/**
 * Mock Timeline
 */
export const mockTimeline: StudentTimeline[] = [
  {
    id: 1,
    studentId: 1,
    timelineType: 'ATTENDANCE',
    bizId: 1,
    title: '签到成功',
    content: '王小明同学已签到到达',
    bizDate: '2026-04-16',
    timestamp: '2026-04-16T16:35:00Z',
    operatorUserId: 2,
    operatorName: '王老师'
  }
];

export const mockSessionStudents: SessionStudent[] = [
  {
    studentId: 1,
    studentName: '王小明',
    studentNo: 'S20260001',
    attendanceStatus: 'SIGNED_IN',
    signInTime: '2026-04-16T16:35:00Z'
  },
  {
    studentId: 2,
    studentName: '李小红',
    studentNo: 'S20260002',
    attendanceStatus: 'NOT_SIGNED'
  }
];

/**
 * Mock Today Status Card
 */
export const mockTodayStatusCard: TodayStatusCard = {
  date: '2026-04-16',
  studentId: 1,
  studentName: '王小明',
  sessionInfo: {
    sessionId: 1,
    sessionNo: 'SES20260416001',
    sessionDate: '2026-04-16',
    startTime: '16:30:00',
    endTime: '18:30:00',
    teacherName: '王老师',
    location: '实验小学托管教室A'
  },
  attendanceStatus: 'SIGNED_IN',
  signInTime: '16:35',
  homeworkStatus: 'IN_PROGRESS',
  homeworkCount: 2,
  completedHomework: 0,
  messages: 1
};

/**
 * Mock Abnormal Alerts
 */
export const mockAbnormalAlerts: AbnormalAlertCard[] = [
  {
    alertId: 1,
    studentId: 1,
    studentName: '王小明',
    alertType: 'ATTENDANCE',
    alertLevel: 'WARNING',
    alertTitle: '迟到提醒',
    alertContent: '王小明同学今日迟到15分钟',
    alertTime: '2026-04-16T16:45:00Z',
    isRead: false
  }
];

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
  reportDate: '2026-04-16',
  totalCount: 2,
  signedInCount: 1,
  signedOutCount: 0,
  absentCount: 1,
  lateCount: 0,
  leaveCount: 1,
  abnormalCount: 1,
  attendanceRate: 50
};

export const mockFinanceReport: FinanceReport = {
  reportMonth: '2026-04',
  totalOrders: 3,
  totalAmount: 2260,
  paidAmount: 1700,
  pendingAmount: 560,
  refundedAmount: 200,
  orderCount: 3,
  refundCount: 1
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

/**
 * Mock Login Response
 */
export function getMockLoginResponse(username: string): LoginResponse {
  const user = mockUsers.find(u => u.username === username) ?? mockUsers[0];
  return {
    token: 'mock_token_' + Date.now(),
    expiresIn: 7200,
    userInfo: user
  };
}
