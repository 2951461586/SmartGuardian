/**
 * SmartGuardian - Card API Service
 * Widget card data API
 */

import { get, post } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import { TodayStatusCard, AbnormalAlertCard, CardUpdateRequest, CardDataResponse } from '../../models/card';

/**
 * Card API Service
 */
export class CardService {
  /**
   * Get today status card data
   */
  static async getTodayStatus(studentId?: number): Promise<ApiResponse<TodayStatusCard>> {
    const params = studentId ? { studentId } : undefined;
    return get<TodayStatusCard>('/api/v1/cards/today-status', params);
  }

  /**
   * Get abnormal alert card data
   * Route corrected: /api/v1/cards/abnormal-alert (singular form)
   */
  static async getAbnormalAlert(studentId?: number): Promise<ApiResponse<AbnormalAlertCard | null>> {
    const params = studentId ? { studentId } : undefined;
    return get<AbnormalAlertCard | null>('/api/v1/cards/abnormal-alert', params);
  }

  /**
   * Update card data
   * 
   * ⚠️ P0优化说明：
   * - 此方法为扩展功能，未在 OpenAPI 文档中定义
   * - 当前无任何页面调用此方法（搜索确认）
   * - 路由设计：POST /api/v1/cards/update
   * - 保留原因：为未来卡片手动刷新功能预留
   * - 建议：如确定不需要，可在下个版本删除
   */
  static async updateCard(data: CardUpdateRequest): Promise<ApiResponse<CardDataResponse>> {
    return post<CardDataResponse>('/api/v1/cards/update', data);
  }

  /**
   * Get all cards data for current user
   * 
   * ⚠️ P0优化说明：
   * - 此方法为扩展功能，未在 OpenAPI 文档中定义
   * - 当前无任何页面调用此方法（搜索确认）
   * - 路由设计：GET /api/v1/cards/all
   * - 保留原因：为家长端多学生卡片展示预留
   * - 建议：如确定不需要，可在下个版本删除
   */
  static async getAllCards(): Promise<ApiResponse<TodayStatusCard[]>> {
    return get<TodayStatusCard[]>('/api/v1/cards/all');
  }
}
