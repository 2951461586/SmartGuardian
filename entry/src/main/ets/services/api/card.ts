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

import { get } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import { TodayStatusCard, AbnormalAlertCard } from '../../models/card';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Card API Service
 * 
 * @description 卡片服务类，提供首页卡片数据展示功能
 * @class
 */
export class CardService {
  static readonly AGC_DOMAIN: string = 'card';
  static readonly AGC_FUNCTION: string = 'smartguardian-card';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.CARDS;

  /**
   * Get today status card data
   *
   * @description 获取今日状态卡片数据（用于首页展示）
   * @param studentId 学生ID（可选，家长端查询指定学生）
   * @returns 今日状态卡片响应
   */
  static async getTodayStatus(studentId?: number): Promise<ApiResponse<TodayStatusCard>> {
    const params = studentId ? { studentId } : undefined;
    return get<TodayStatusCard>(ApiEndpoints.CARDS_TODAY_STATUS, params);
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
    return get<AbnormalAlertCard | null>(ApiEndpoints.CARDS_ABNORMAL_ALERT, params);
  }
}
