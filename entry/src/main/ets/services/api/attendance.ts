/**
 * SmartGuardian - Attendance & Homework API Service
 * Attendance, homework, feedback API
 */

import { get, post } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';
import { AttendanceRecord, SignInRequest, SignOutRequest, LeaveRequest, HomeworkTask, HomeworkTaskCreateRequest, HomeworkFeedback, HomeworkFeedbackCreateRequest, HomeworkConfirmRequest, MessageRecord, SendMessageRequest, StudentTimeline } from '../../models/attendance';

/**
 * Attendance API Service
 */
export class AttendanceService {
  /**
   * Get attendance records
   */
  static async getAttendanceList(params?: {
    pageNum?: number;
    pageSize?: number;
    studentId?: number;
    sessionId?: number;
    attendanceDate?: string;
    status?: string;
  }): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    return get<PageResponse<AttendanceRecord>>('/api/v1/attendance', params);
  }

  /**
   * Sign in
   */
  static async signIn(data: SignInRequest): Promise<ApiResponse<AttendanceRecord>> {
    return post<AttendanceRecord>('/api/v1/attendance/sign-in', data);
  }

  /**
   * Sign out
   */
  static async signOut(data: SignOutRequest): Promise<ApiResponse<AttendanceRecord>> {
    return post<AttendanceRecord>('/api/v1/attendance/sign-out', data);
  }

  /**
   * Get abnormal attendance records
   */
  static async getAbnormalAttendance(params?: {
    pageNum?: number;
    pageSize?: number;
    startDate?: string;
    endDate?: string;
  }): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    return get<PageResponse<AttendanceRecord>>('/api/v1/attendance/abnormal', params);
  }

  /**
   * Submit leave request
   */
  static async submitLeave(data: LeaveRequest): Promise<ApiResponse<AttendanceRecord>> {
    return post<AttendanceRecord>('/api/v1/attendance/leave', data);
  }
}

/**
 * Homework API Service
 */
export class HomeworkService {
  /**
   * Get homework tasks
   */
  static async getTasks(params?: {
    pageNum?: number;
    pageSize?: number;
    studentId?: number;
    status?: string;
    taskDate?: string;
  }): Promise<ApiResponse<PageResponse<HomeworkTask>>> {
    return get<PageResponse<HomeworkTask>>('/api/v1/homework/tasks', params);
  }

  /**
   * Create homework task
   */
  static async createTask(data: HomeworkTaskCreateRequest): Promise<ApiResponse<HomeworkTask>> {
    return post<HomeworkTask>('/api/v1/homework/tasks', data);
  }

  /**
   * Submit homework feedback
   */
  static async submitFeedback(data: HomeworkFeedbackCreateRequest): Promise<ApiResponse<HomeworkFeedback>> {
    return post<HomeworkFeedback>('/api/v1/homework/feedback', data);
  }

  /**
   * Confirm homework feedback
   */
  static async confirmFeedback(feedbackId: number, data: HomeworkConfirmRequest): Promise<ApiResponse<HomeworkFeedback>> {
    return post<HomeworkFeedback>(`/api/v1/homework/feedback/${feedbackId}/confirm`, data);
  }
}

/**
 * Message API Service
 */
export class MessageService {
  /**
   * Get message list
   */
  static async getMessages(params?: {
    pageNum?: number;
    pageSize?: number;
    msgType?: string;
    readStatus?: boolean;
  }): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    return get<PageResponse<MessageRecord>>('/api/v1/messages', params);
  }

  /**
   * Send message
   */
  static async sendMessage(data: SendMessageRequest): Promise<ApiResponse<MessageRecord>> {
    return post<MessageRecord>('/api/v1/messages', data);
  }

  /**
   * Mark message as read
   */
  static async markAsRead(messageId: number): Promise<ApiResponse<null>> {
    return post<null>(`/api/v1/messages/${messageId}/read`);
  }

  /**
   * Get student timeline
   */
  static async getTimeline(studentId: number, params?: {
    pageNum?: number;
    pageSize?: number;
    timelineType?: string;
  }): Promise<ApiResponse<PageResponse<StudentTimeline>>> {
    return get<PageResponse<StudentTimeline>>(`/api/v1/timeline/${studentId}`, params);
  }
}

export { HomeworkTask };
