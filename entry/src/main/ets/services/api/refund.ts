/**
 * SmartGuardian - Refund Service API
 * Refund process related API calls
 * 
 * @description 退款服务 API，提供退款申请、查询和管理功能
 * @features
 * - 退款申请创建
 * - 退款记录查询
 * - 退款金额计算
 * - 退款统计数据
 * - 退款申请取消
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
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Refund Service
 * 
 * @description 退款服务类，提供退款申请和管理功能
 * @class
 */
export class RefundService {
  /**
   * Create refund application
   * 
   * @description 创建退款申请
   * @param params 退款申请参数（订单ID、退款金额、退款原因等）
   * @returns 退款记录响应
   */
  static async createRefund(params: CreateRefundParams): Promise<ApiResponse<RefundRecord>> {
    return post<RefundRecord>(ApiEndpoints.REFUNDS, params);
  }

  /**
   * Get refund list
   * 
   * @description 分页获取退款记录列表
   * @param params 查询参数
   * @returns 分页退款记录响应
   */
  static async getRefunds(params: RefundQueryParams): Promise<ApiResponse<PageResponse<RefundRecord>>> {
    return get<PageResponse<RefundRecord>>(ApiEndpoints.REFUNDS, params);
  }

  /**
   * Get refund detail
   * 
   * @description 获取退款详情
   * @param refundId 退款ID
   * @returns 退款记录响应
   */
  static async getRefundDetail(refundId: number): Promise<ApiResponse<RefundRecord>> {
    return get<RefundRecord>(ApiEndpoints.refundDetail(refundId));
  }

  /**
   * Cancel refund application
   * 
   * @description 取消退款申请
   * @param params 取消参数（退款ID、取消原因等）
   * @returns 操作响应
   */
  static async cancelRefund(params: CancelRefundParams): Promise<ApiResponse<void>> {
    return post<void>(ApiEndpoints.refundCancel(params.refundId), params);
  }

  /**
   * Get refund statistics
   * 
   * @description 获取退款统计数据
   * @returns 退款统计数据响应
   */
  static async getStatistics(): Promise<ApiResponse<RefundStatistics>> {
    return get<RefundStatistics>(ApiEndpoints.REFUNDS_STATISTICS);
  }

  /**
   * Calculate refund amount
   * 
   * @description 计算退款金额（预计算可退款金额）
   * @param orderId 订单ID
   * @returns 退款金额计算结果（是否可退款、退款金额、扣款金额、原因）
   */
  static async calculateRefundAmount(orderId: number): Promise<ApiResponse<{
    refundable: boolean;
    refundAmount: number;
    deduction: number;
    reason?: string;
  }>> {
    return get(ApiEndpoints.REFUNDS_CALCULATE, { orderId });
  }

  /**
   * Get refunds by order
   * 
   * @description 根据订单ID获取所有退款记录
   * @param orderId 订单ID
   * @returns 退款记录数组响应
   */
  static async getRefundsByOrder(orderId: number): Promise<ApiResponse<RefundRecord[]>> {
    return get<RefundRecord[]>(ApiEndpoints.refundsByOrder(orderId));
  }

  /**
   * Get pending refunds
   * 
   * @description 获取待处理的退款列表（封装方法）
   * @param pageNum 页码，默认 1
   * @param pageSize 每页数量，默认 20
   * @returns 分页退款记录响应
   */
  static async getPendingRefunds(
    pageNum: number = 1,
    pageSize: number = 20
  ): Promise<ApiResponse<PageResponse<RefundRecord>>> {
    return this.getRefunds({ status: 'PENDING', pageNum, pageSize });
  }
}