import { Order, ServiceProduct, SessionSchedule, SessionStudent } from '../../../models/service';

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
