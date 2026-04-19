/**
 * SmartGuardian - Mock Data
 * Mock data for development and testing
 */

import { UserInfo, Student, LoginResponse } from '../../models/user';
import { UserRole } from '../../models/common';
import { ServiceProduct, Order, SessionSchedule } from '../../models/service';
import { AttendanceRecord, HomeworkTask, MessageRecord, StudentTimeline } from '../../models/attendance';
import { TodayStatusCard, AbnormalAlertCard } from '../../models/card';

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
    status: 'IN_PROGRESS',
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
    status: 'PENDING',
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
    senderUserId: 2,
    senderName: '王老师',
    receiverUserId: 1,
    msgType: 'ATTENDANCE',
    content: '王小明同学已安全到达托管教室，请家长放心。',
    readStatus: false,
    createdAt: '2026-04-16T16:36:00Z'
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
