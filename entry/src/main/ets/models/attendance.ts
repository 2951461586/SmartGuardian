/**
 * SmartGuardian - Attendance & Homework Models
 * Attendance, homework, feedback related types
 */

/**
 * Attendance record
 */
export interface AttendanceRecord {
  id: number;
  studentId: number;
  studentName?: string;
  studentNo?: string;
  orderId: number;
  sessionId: number;
  sessionNo?: string;
  attendanceDate: string;
  signInTime?: string;
  signOutTime?: string;
  signInMethod?: 'QR_CODE' | 'NFC' | 'FACE' | 'MANUAL';
  signOutMethod?: 'QR_CODE' | 'NFC' | 'FACE' | 'MANUAL';
  signInLocation?: string;
  signOutLocation?: string;
  operatorUserId?: number;
  operatorName?: string;
  status: 'NOT_SIGNED' | 'SIGNED_IN' | 'SIGNED_OUT' | 'ABSENT' | 'LATE' | 'LEAVE';
  abnormalFlag: boolean;
  abnormalType?: string;
  abnormalDesc?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * Sign in request
 */
export interface SignInRequest {
  studentId: number;
  sessionId: number;
  signMethod: 'QR_CODE' | 'NFC' | 'FACE' | 'MANUAL';
  location?: string;
}

/**
 * Sign out request
 */
export interface SignOutRequest {
  studentId: number;
  sessionId: number;
  signMethod: 'QR_CODE' | 'NFC' | 'FACE' | 'MANUAL';
  pickupUserId?: number;
  location?: string;
}

/**
 * Homework task
 */
export interface HomeworkTask {
  id: number;
  taskNo: string;
  studentId: number;
  studentName?: string;
  sessionId: number;
  sessionNo?: string;
  teacherId: number;
  teacherName?: string;
  taskDate: string;
  subject?: string;
  content: string;
  attachments?: string[];
  status: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'CONFIRMED';
  completedTime?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * Create homework task request
 */
export interface HomeworkTaskCreateRequest {
  studentId: number;
  sessionId: number;
  taskDate: string;
  subject?: string;
  content: string;
  attachments?: string[];
}

/**
 * Homework feedback
 */
export interface HomeworkFeedback {
  id: number;
  taskId: number;
  teacherId: number;
  teacherName?: string;
  studentId: number;
  feedbackContent: string;
  performance?: string;
  attachments?: string[];
  status: 'DRAFT' | 'SUBMITTED' | 'CONFIRMED' | 'DISPUTED';
  guardianConfirmTime?: string;
  guardianRemark?: string;
  createdAt: string;
  updatedAt: string;
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
  senderUserId: number;
  senderName?: string;
  senderAvatar?: string;
  receiverUserId: number;
  receiverName?: string;
  conversationId: number;
  msgType: 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER' | 'CHAT';
  content: string;
  attachments?: string[];
  readStatus: boolean;
  createdAt: string;
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
  bizId: number;
  title: string;
  content: string;
  timestamp: string;
  operatorUserId?: number;
  operatorName?: string;
}