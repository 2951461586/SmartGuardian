/**
 * SmartGuardian - Homework Models
 * Homework task and feedback related types
 */

/**
 * Homework task status
 */
export enum HomeworkTaskStatus {
  PENDING = 'PENDING',           // 待辅导
  IN_PROGRESS = 'IN_PROGRESS',   // 辅导中
  COMPLETED = 'COMPLETED',       // 已完成
  CONFIRMED = 'CONFIRMED'        // 家长已确认
}

/**
 * Homework task
 */
export interface HomeworkTask {
  id: number;
  studentId: number;
  taskDate: string;
  subject?: string;
  title?: string;
  content?: string;
  sourceType?: string;
  status: HomeworkTaskStatus;
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
 * Homework feedback performance level
 */
export enum PerformanceLevel {
  EXCELLENT = 'EXCELLENT',   // 优秀
  GOOD = 'GOOD',             // 良好
  AVERAGE = 'AVERAGE',       // 一般
  NEEDS_IMPROVEMENT = 'NEEDS_IMPROVEMENT'  // 需改进
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
  performance?: PerformanceLevel;
  attachments?: string[];
  status?: HomeworkTaskStatus;
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
  performance?: PerformanceLevel;
  attachments?: string[];
}

/**
 * Homework confirm request
 */
export interface HomeworkConfirmRequest {
  confirmStatus: 'CONFIRMED' | 'DISPUTED';
  guardianRemark?: string;
}
