/**
 * SmartGuardian - Refund Service API
 * Refund process related API calls
 */

import { ApiResponse, PageResponse } from '../../models/common';
import {
  RefundRecord,
  CreateRefundParams,
  RefundQueryParams,
  RefundStatistics,
  CancelRefundParams
} from '../../models/refund';
import { get, post } from '../../utils/request';

/**
 * Refund Service
 */
export class RefundService {
  private static BASE_URL = '/api/v1/refunds';  // ✅ P0优化：修正为符合OpenAPI规范的 /api/v1 前缀

  /**
   * Create refund application
   */
  static async createRefund(params: CreateRefundParams): Promise<ApiResponse<RefundRecord>> {
    return post<RefundRecord>(this.BASE_URL, params);
  }

  /**
   * Get refund list
   */
  static async getRefunds(params: RefundQueryParams): Promise<ApiResponse<PageResponse<RefundRecord>>> {
    return get<PageResponse<RefundRecord>>(this.BASE_URL, params);
  }

  /**
   * Get refund detail
   */
  static async getRefundDetail(refundId: number): Promise<ApiResponse<RefundRecord>> {
    return get<RefundRecord>(`${this.BASE_URL}/${refundId}`);
  }

  /**
   * Cancel refund application
   */
  static async cancelRefund(params: CancelRefundParams): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${params.refundId}/cancel`, params);
  }

  /**
   * Get refund statistics
   */
  static async getStatistics(): Promise<ApiResponse<RefundStatistics>> {
    return get<RefundStatistics>(`${this.BASE_URL}/statistics`);
  }

  /**
   * Calculate refund amount
   */
  static async calculateRefundAmount(orderId: number): Promise<ApiResponse<{
    refundable: boolean;
    refundAmount: number;
    deduction: number;
    reason?: string;
  }>> {
    return get(`${this.BASE_URL}/calculate`, { orderId });
  }

  /**
   * Get refunds by order
   */
  static async getRefundsByOrder(orderId: number): Promise<ApiResponse<RefundRecord[]>> {
    return get<RefundRecord[]>(`${this.BASE_URL}/order/${orderId}`);
  }

  /**
   * Get pending refunds
   */
  static async getPendingRefunds(
    pageNum: number = 1,
    pageSize: number = 20
  ): Promise<ApiResponse<PageResponse<RefundRecord>>> {
    return this.getRefunds({ status: 'PENDING', pageNum, pageSize });
  }
}