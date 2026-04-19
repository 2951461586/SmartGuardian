/**
 * SmartGuardian - Alert Service API
 * Alert and warning related API calls
 * 
 * @description 告警服务 API，提供告警记录查询、确认、解决等功能
 * @features
 * - 告警记录查询
 * - 告警确认与解决
 * - 告警统计信息
 * - 活跃告警监控
 */

import { ApiResponse, PageResponse } from '../../models/common';
import {
  AlertRecord,
  AlertQueryParams,
  AlertStatistics,
  AcknowledgeAlertParams,
  ResolveAlertParams
} from '../../models/alert';
import { get, post } from '../../utils/request';

/**
 * Alert Service
 * 
 * @description 告警服务类，提供告警记录管理和状态处理功能
 * @class
 */
export class AlertService {
  private static BASE_URL = '/api/v1/alerts';

  static async getAlerts(params: AlertQueryParams): Promise<ApiResponse<PageResponse<AlertRecord>>> {
    return get<PageResponse<AlertRecord>>(this.BASE_URL, params);
  }

  static async getAlertDetail(alertId: number): Promise<ApiResponse<AlertRecord>> {
    return get<AlertRecord>(`${this.BASE_URL}/${alertId}`);
  }

  /**
   * Acknowledge alert
   * 
   * @description 确认告警
   * @param params 确认参数（家长/教师操作）
   * @returns 确认结果响应
   */
  static async acknowledgeAlert(params: AcknowledgeAlertParams): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${params.alertId}/acknowledge`, params);
  }

  static async resolveAlert(params: ResolveAlertParams): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${params.alertId}/resolve`, params);
  }

  static async dismissAlert(alertId: number): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${alertId}/dismiss`);
  }

  static async getActiveCount(): Promise<ApiResponse<{ count: number }>> {
    return get<{ count: number }>(`${this.BASE_URL}/active-count`);
  }

  static async getStatistics(): Promise<ApiResponse<AlertStatistics>> {
    return get<AlertStatistics>(`${this.BASE_URL}/statistics`);
  }

  static async getActiveAlerts(
    pageNum: number = 1,
    pageSize: number = 20
  ): Promise<ApiResponse<PageResponse<AlertRecord>>> {
    return this.getAlerts({ status: 'ACTIVE', pageNum, pageSize });
  }
}
