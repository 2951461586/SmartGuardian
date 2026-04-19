/**
 * SmartGuardian - Homework API Service
 * Homework task and feedback API
 * 
 * @description 作业管理 API，提供作业任务管理和反馈功能
 * @features
 * - 作业任务创建与查询
 * - 作业状态更新
 * - 作业反馈提交
 * - 反馈确认机制
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
 * 
 * @description 作业服务类，提供作业任务管理和反馈功能
 * @class
 */
export class HomeworkService {
  /**
   * Get homework tasks list
   * 
   * @description 分页获取作业任务列表
   * @param params 查询参数
   * @returns 分页作业任务响应
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
   * 
   * @description 获取作业任务详情
   * @param taskId 任务ID
   * @returns 作业任务响应
   */
  static async getTaskDetail(taskId: number): Promise<ApiResponse<HomeworkTask>> {
    return get<HomeworkTask>(`/api/v1/homework/tasks/${taskId}`);
  }

  /**
   * Create homework task
   * 
   * @description 创建新的作业任务
   * @param data 任务创建数据
   * @returns 创建成功的任务响应
   */
  static async createTask(data: HomeworkTaskCreateRequest): Promise<ApiResponse<HomeworkTask>> {
    return post<HomeworkTask>('/api/v1/homework/tasks', data);
  }

  /**
   * Update homework task status
   * 
   * @description 更新作业任务状态（如：待完成、进行中、已完成）
   * @param taskId 任务ID
   * @param status 新状态
   * @returns 更新后的任务响应
   */
  static async updateTaskStatus(taskId: number, status: HomeworkTaskStatus): Promise<ApiResponse<HomeworkTask>> {
    return post<HomeworkTask>(`/api/v1/homework/tasks/${taskId}/status`, { status });
  }

  /**
   * Submit homework feedback
   * 
   * @description 提交作业反馈（教师或家长）
   * @param data 反馈数据
   * @returns 反馈响应
   */
  static async submitFeedback(data: HomeworkFeedbackCreateRequest): Promise<ApiResponse<HomeworkFeedback>> {
    return post<HomeworkFeedback>('/api/v1/homework/feedback', data);
  }

  /**
   * Get feedback list by task
   * 
   * @description 获取指定任务的所有反馈列表
   * @param taskId 任务ID
   * @returns 反馈数组响应
   */
  static async getFeedbacks(taskId: number): Promise<ApiResponse<HomeworkFeedback[]>> {
    return get<HomeworkFeedback[]>(`/api/v1/homework/tasks/${taskId}/feedbacks`);
  }

  /**
   * Confirm homework feedback
   * 
   * @description 确认作业反馈（家长确认已查看）
   * @param feedbackId 反馈ID
   * @param data 确认数据
   * @returns 确认后的反馈响应
   */
  static async confirmFeedback(feedbackId: number, data: HomeworkConfirmRequest): Promise<ApiResponse<HomeworkFeedback>> {
    return post<HomeworkFeedback>(`/api/v1/homework/feedback/${feedbackId}/confirm`, data);
  }
}
