/**
 * SmartGuardian - Alert Service API
 * Alert and warning related API calls
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
 */
export class AlertService {
  private static BASE_URL = '/api/alerts';

  /**
   * Get alert list
   */
  static async getAlerts(params: AlertQueryParams): Promise<ApiResponse<PageResponse<AlertRecord>>> {
    return get<PageResponse<AlertRecord>>(this.BASE_URL, params);
  }

  /**
   * Get alert detail
   */
  static async getAlertDetail(alertId: number): Promise<ApiResponse<AlertRecord>> {
    return get<AlertRecord>(`${this.BASE_URL}/${alertId}`);
  }

  /**
   * Acknowledge alert
   */
  static async acknowledgeAlert(params: AcknowledgeAlertParams): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${params.alertId}/acknowledge`, params);
  }

  /**
   * Resolve alert
   */
  static async resolveAlert(params: ResolveAlertParams): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${params.alertId}/resolve`, params);
  }

  /**
   * Dismiss alert
   */
  static async dismissAlert(alertId: number): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${alertId}/dismiss`);
  }

  /**
   * Get active alerts count
   */
  static async getActiveCount(): Promise<ApiResponse<{ count: number }>> {
    return get<{ count: number }>(`${this.BASE_URL}/active-count`);
  }

  /**
   * Get alert statistics
   */
  static async getStatistics(): Promise<ApiResponse<AlertStatistics>> {
    return get<AlertStatistics>(`${this.BASE_URL}/statistics`);
  }

  /**
   * Get active alerts (Used by ParentAlertsPage)
   */
  static async getActiveAlerts(
    pageNum: number = 1,
    pageSize: number = 20
  ): Promise<ApiResponse<PageResponse<AlertRecord>>> {
    return this.getAlerts({ status: 'ACTIVE', pageNum, pageSize });
  }
}