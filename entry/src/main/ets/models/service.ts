/**
 * SmartGuardian - Service & Order Models
 * Service product, order, session scheduling related types
 */

/**
 * Service product (托管服务)
 */
export interface ServiceProduct {
  id: number;
  serviceName: string;
  serviceType: 'AFTER_SCHOOL' | 'HOLIDAY' | 'FULL_DAY' | 'WEEKEND';
  description: string;
  price: number;
  unit: 'DAY' | 'WEEK' | 'MONTH' | 'SESSION';
  gradeRange?: string;
  maxStudents: number;
  currentStudents: number;
  serviceStartDate: string;
  serviceEndDate: string;
  signInStartTime: string;
  signInEndTime: string;
  signOutStartTime: string;
  signOutEndTime: string;
  orgId: number;
  orgName?: string;
  status: 'DRAFT' | 'PUBLISHED' | 'PAUSED' | 'CLOSED';
  createdAt: string;
  updatedAt: string;
}

/**
 * Create service product request
 */
export interface ServiceProductCreateRequest {
  serviceName: string;
  serviceType: 'AFTER_SCHOOL' | 'HOLIDAY' | 'FULL_DAY' | 'WEEKEND';
  description: string;
  price: number;
  unit: 'DAY' | 'WEEK' | 'MONTH' | 'SESSION';
  gradeRange?: string;
  maxStudents: number;
  serviceStartDate: string;
  serviceEndDate: string;
  signInStartTime: string;
  signInEndTime: string;
  signOutStartTime: string;
  signOutEndTime: string;
}

/**
 * Order (托管订单)
 */
export interface Order {
  id: number;
  orderNo: string;
  studentId: number;
  studentName?: string;
  guardianUserId: number;
  guardianName?: string;
  serviceProductId: number;
  serviceProductName?: string;
  startDate: string;
  endDate: string;
  totalAmount: number;
  discountAmount: number;
  actualAmount: number;
  orderStatus: 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED' | 'COMPLETED' | 'REFUNDED';
  payStatus: 'UNPAID' | 'PAID' | 'REFUNDING' | 'REFUNDED';
  payTime?: string;
  auditTime?: string;
  auditUserId?: number;
  auditRemark?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * Create order request
 */
export interface OrderCreateRequest {
  studentId: number;
  serviceProductId: number;
  startDate: string;
  endDate: string;
  totalAmount: number;
  discountAmount?: number;
}

/**
 * Order audit request
 */
export interface OrderAuditRequest {
  auditStatus: 'APPROVED' | 'REJECTED';
  auditRemark?: string;
}

/**
 * Order refund request
 */
export interface OrderRefundRequest {
  refundAmount: number;
  refundReason: string;
}

/**
 * Session schedule (班次排课)
 */
export interface SessionSchedule {
  id: number;
  sessionNo: string;
  serviceProductId: number;
  serviceProductName?: string;
  sessionDate: string;
  startTime: string;
  endTime: string;
  teacherId: number;
  teacherName?: string;
  maxCapacity: number;
  currentCount: number;
  location?: string;
  status: 'SCHEDULED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
  createdAt: string;
  updatedAt: string;
}

/**
 * Auto-schedule request
 */
export interface AutoScheduleRequest {
  serviceProductId: number;
  startDate: string;
  endDate: string;
  weekdays: number[]; // 1-7, 1=Monday
  startTime: string;
  endTime: string;
  teacherIds: number[];
  maxCapacity: number;
  location?: string;
}

/**
 * Session with student list
 */
export interface SessionWithStudents extends SessionSchedule {
  students: SessionStudent[];
}

/**
 * Student in session
 */
export interface SessionStudent {
  studentId: number;
  studentName: string;
  studentNo: string;
  attendanceStatus: string;
  signInTime?: string;
  signOutTime?: string;
}