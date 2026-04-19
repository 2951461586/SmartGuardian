/**
 * SmartGuardian - Homework API Service
 * Homework task and feedback API
 */

import { get, post } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';
import { 
  HomeworkTask, 
  HomeworkTaskCreateRequest, 
  HomeworkTaskStatus,
  HomeworkFeedback, 
  HomeworkFeedbackCreateRequest, 
  HomeworkConfirmRequest 
} from '../../models/homework';

/**
 * Homework API Service
 */
export class HomeworkService {
  /**
   * Get homework tasks list
   */
  static async getTasks(params?: {
    pageNum?: number;
    pageSize?: number;
    studentId?: number;
    status?: HomeworkTaskStatus;
    taskDate?: string;
    sessionId?: number;
  }): Promise<ApiResponse<PageResponse<HomeworkTask>>> {
    return get<PageResponse<HomeworkTask>>('/api/v1/homework/tasks', params);
  }

  /**
   * Get homework task detail
   */
  static async getTaskDetail(taskId: number): Promise<ApiResponse<HomeworkTask>> {
    return get<HomeworkTask>(`/api/v1/homework/tasks/${taskId}`);
  }

  /**
   * Create homework task
   */
  static async createTask(data: HomeworkTaskCreateRequest): Promise<ApiResponse<HomeworkTask>> {
    return post<HomeworkTask>('/api/v1/homework/tasks', data);
  }

  /**
   * Update homework task status
   */
  static async updateTaskStatus(taskId: number, status: HomeworkTaskStatus): Promise<ApiResponse<HomeworkTask>> {
    return post<HomeworkTask>(`/api/v1/homework/tasks/${taskId}/status`, { status });
  }

  /**
   * Submit homework feedback
   */
  static async submitFeedback(data: HomeworkFeedbackCreateRequest): Promise<ApiResponse<HomeworkFeedback>> {
    return post<HomeworkFeedback>('/api/v1/homework/feedback', data);
  }

  /**
   * Get feedback list by task
   */
  static async getFeedbacks(taskId: number): Promise<ApiResponse<HomeworkFeedback[]>> {
    return get<HomeworkFeedback[]>(`/api/v1/homework/tasks/${taskId}/feedbacks`);
  }

  /**
   * Confirm homework feedback
   */
  static async confirmFeedback(feedbackId: number, data: HomeworkConfirmRequest): Promise<ApiResponse<HomeworkFeedback>> {
    return post<HomeworkFeedback>(`/api/v1/homework/feedback/${feedbackId}/confirm`, data);
  }
}
