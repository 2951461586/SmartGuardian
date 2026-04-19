/**
 * SmartGuardian - Service & Order Models
 * Service product, order, session scheduling related types
 */

/**
 * Service product (托管服务)
 * OpenAPI core fields + compatibility aliases used by existing pages.
 */
export interface ServiceProduct {
  id: number;
  serviceName: string;
  serviceType: string;
  price: number;
  capacity?: number;
  status: string;
  description?: string;
  unit?: string;
  gradeRange?: string;
  maxStudents?: number;
  currentStudents?: number;
  serviceStartDate?: string;
  serviceEndDate?: string;
  signInStartTime?: string;
  signInEndTime?: string;
  signOutStartTime?: string;
  signOutEndTime?: string;
  orgId?: number;
  orgName?: string;
  createdAt?: string;
  updatedAt?: string;
  name?: string;
  category?: string;
  startTime?: string;
  endTime?: string;
}

/**
 * Create service product request
 */
export interface ServiceProductCreateRequest {
  serviceName: string;
  serviceType: string;
  description?: string;
  price: number;
  unit?: string;
  gradeRange?: string;
  maxStudents?: number;
  capacity?: number;
  serviceStartDate?: string;
  serviceEndDate?: string;
  signInStartTime?: string;
  signInEndTime?: string;
  signOutStartTime?: string;
  signOutEndTime?: string;
}

/**
 * Order (托管订单)
 * OpenAPI fields are required; extra UI-friendly fields are optional.
 */
export interface Order {
  id: number;
  orderNo: string;
  studentId: number;
  serviceProductId: number;
  orderStatus: string;
  amount: number;
  paidAmount: number;
  payStatus: string;
  auditStatus?: string;
  studentName?: string;
  guardianUserId?: number;
  guardianName?: string;
  serviceProductName?: string;
  startDate?: string;
  endDate?: string;
  totalAmount?: number;
  discountAmount?: number;
  actualAmount?: number;
  payTime?: string;
  auditTime?: string;
  auditUserId?: number;
  auditRemark?: string;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Create order request
 */
export interface OrderCreateRequest {
  studentId: number;
  serviceProductId: number;
  startDate: string;
  endDate: string;
  totalAmount?: number;
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
 * Includes OpenAPI SessionInfo fields and current page compatibility fields.
 */
export interface SessionSchedule {
  id: number;
  sessionDate: string;
  startTime: string;
  endTime: string;
  teacherUserId?: number;
  capacity?: number;
  currentCount: number;
  sessionNo?: string;
  serviceProductId?: number;
  serviceProductName?: string;
  teacherId?: number;
  teacherName?: string;
  maxCapacity?: number;
  location?: string;
  status?: string;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Auto-schedule request
 */
export interface AutoScheduleRequest {
  serviceProductId: number;
  startDate: string;
  endDate: string;
  weekdays: number[];
  startTime: string;
  endTime: string;
  teacherIds: number[];
  maxCapacity: number;
  location?: string;
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

/**
 * Session with student list
 */
export interface SessionWithStudents extends SessionSchedule {
  students: SessionStudent[];
}
