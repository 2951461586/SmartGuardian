/**
 * SmartGuardian - Attendance & Homework Models
 * Attendance, homework, feedback, message related types
 */

/**
 * Attendance record
 * OpenAPI base fields + optional compatibility fields.
 */
export interface AttendanceRecord {
  id: number;
  studentId: number;
  sessionId: number;
  signInTime?: string;
  status: string;
  studentName?: string;
  studentNo?: string;
  orderId?: number;
  sessionNo?: string;
  attendanceDate?: string;
  signOutTime?: string;
  signInMethod?: string;
  signOutMethod?: string;
  signInLocation?: string;
  signOutLocation?: string;
  operatorUserId?: number;
  operatorName?: string;
  abnormalFlag?: boolean;
  abnormalType?: string;
  abnormalDesc?: string;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Sign in request
 * Keep both OpenAPI names and current page names for compatibility.
 */
export interface SignInRequest {
  studentId: number;
  sessionId: number;
  signInType?: string;
  signMethod?: string;
  location?: string;
}

/**
 * Sign out request
 */
export interface SignOutRequest {
  studentId: number;
  sessionId: number;
  signOutType?: string;
  signMethod?: string;
  guardianId?: number;
  pickupUserId?: number;
  location?: string;
}

/**
 * Leave request
 */
export interface LeaveRequest {
  studentId: number;
  leaveDate: string;
  leaveType: string;
  reason: string;
  attachments?: string[];
}

/**
 * Homework task
 * OpenAPI base fields + optional UI fields.
 */
export interface HomeworkTask {
  id: number;
  studentId: number;
  taskDate: string;
  subject?: string;
  title?: string;
  content?: string;
  sourceType?: string;
  status: string;
  taskNo?: string;
  studentName?: string;
  sessionId?: number;
  sessionNo?: string;
  teacherId?: number;
  teacherName?: string;
  attachments?: string[];
  completedTime?: string;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Create homework task request
 */
export interface HomeworkTaskCreateRequest {
  studentId: number;
  taskDate: string;
  subject: string;
  title: string;
  content?: string;
  sourceType?: string;
  sessionId?: number;
  attachments?: string[];
}

/**
 * Homework feedback
 */
export interface HomeworkFeedback {
  id: number;
  taskId: number;
  teacherId?: number;
  teacherName?: string;
  studentId?: number;
  feedbackContent: string;
  performance?: string;
  attachments?: string[];
  status?: string;
  guardianConfirmTime?: string;
  guardianRemark?: string;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Create homework feedback request
 */
export interface HomeworkFeedbackCreateRequest {
  taskId: number;
  feedbackContent: string;
  performance?: string;
  attachments?: string[];
}

/**
 * Homework confirm request
 */
export interface HomeworkConfirmRequest {
  confirmStatus: 'CONFIRMED' | 'DISPUTED';
  guardianRemark?: string;
}

/**
 * Message record
 */
export interface MessageRecord {
  id: number;
  senderUserId?: number;
  senderName?: string;
  senderAvatar?: string;
  receiverUserId?: number;
  receiverName?: string;
  conversationId?: number;
  msgType: 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER' | 'CHAT';
  content: string;
  attachments?: string[];
  readStatus?: boolean;
  createdAt?: string;
}

/**
 * Send message request
 */
export interface SendMessageRequest {
  receiverUserId: number;
  msgType: 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER' | 'CHAT';
  content: string;
  attachments?: string[];
}

/**
 * Student timeline entry
 */
export interface StudentTimeline {
  id: number;
  studentId: number;
  timelineType: 'ATTENDANCE' | 'HOMEWORK' | 'MESSAGE' | 'ORDER' | 'NOTE';
  bizId?: number;
  title: string;
  content: string;
  bizDate?: string;
  timestamp: string;
  operatorUserId?: number;
  operatorName?: string;
}
