/**
 * SmartGuardian - Card API Service
 * Widget card data API
 * 
 * @description 卡片数据 API，提供首页卡片数据展示功能
 * @features
 * - 今日状态卡片
 * - 异常告警卡片
 * - 卡片数据刷新
 */

import { get, post } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import { TodayStatusCard, AbnormalAlertCard, CardUpdateRequest, CardDataResponse } from '../../models/card';

/**
 * Card API Service
 * 
 * @description 卡片服务类，提供首页卡片数据展示功能
 * @class
 */
export class CardService {
  /**
   * Get today status card data
   * 
   * @description 获取今日状态卡片数据（用于首页展示）
   * @param studentId 学生ID（可选，家长端查询指定学生）
   * @returns 今日状态卡片响应
   */
  static async getTodayStatus(studentId?: number): Promise<ApiResponse<TodayStatusCard>> {
    const params = studentId ? { studentId } : undefined;
    return get<TodayStatusCard>('/api/v1/cards/today-status', params);
  }

  /**
   * Get abnormal alert card data
   * 
   * @description 获取异常告警卡片数据（用于首页展示）
   * @param studentId 学生ID（可选，家长端查询指定学生）
   * @returns 异常告警卡片响应，无异常时返回 null
   */
  static async getAbnormalAlert(studentId?: number): Promise<ApiResponse<AbnormalAlertCard | null>> {
    const params = studentId ? { studentId } : undefined;
    return get<AbnormalAlertCard | null>('/api/v1/cards/abnormal-alert', params);
  }

  /**
   * Update card data
   * 
   * @description 更新卡片数据（手动刷新）
   * @param data 卡片更新请求数据
   * @returns 更新后的卡片数据响应
   * @note 扩展功能，为未来卡片手动刷新功能预留
   */
  static async updateCard(data: CardUpdateRequest): Promise<ApiResponse<CardDataResponse>> {
    return post<CardDataResponse>('/api/v1/cards/update', data);
  }

  /**
   * Get all cards data for current user
   * 
   * @description 获取当前用户所有卡片数据（家长端多学生场景）
   * @returns 卡片数组响应
   * @note 扩展功能，为家长端多学生卡片展示预留
   */
  static async getAllCards(): Promise<ApiResponse<TodayStatusCard[]>> {
    return get<TodayStatusCard[]>('/api/v1/cards/all');
  }
}
