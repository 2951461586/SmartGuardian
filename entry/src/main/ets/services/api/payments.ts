/**
 * SmartGuardian - Payments API Service
 * Payment creation and callback APIs
 * 
 * @description 支付服务 API，提供支付订单创建和支付回调处理功能
 * @features
 * - 创建支付订单
 * - 支付回调处理
 * - 支持多种支付方式
 */

import { post } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import { PaymentCreateRequest, PaymentOrder, PaymentCallbackRequest } from '../../models/payment';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Payments API Service
 * 
 * @description 支付服务类，提供支付订单创建和回调处理功能
 * @class
 */
export class PaymentService {
  /**
   * Create payment order
   * 
   * @description 创建支付订单，发起支付请求
   * @param data 支付创建请求数据（金额、支付方式、关联业务等）
   * @returns 支付订单响应（订单号、支付参数等）
   */
  static async createPayment(data: PaymentCreateRequest): Promise<ApiResponse<PaymentOrder>> {
    return post<PaymentOrder>(ApiEndpoints.PAYMENTS, data);
  }

  /**
   * Handle payment callback
   * 
   * @description 处理支付回调（支付平台回调通知）
   * @param data 支付回调数据（订单号、支付状态、支付流水号等）
   * @returns 操作响应
   * @note 此接口不需要认证，由支付平台调用
   */
  static async callback(data: PaymentCallbackRequest): Promise<ApiResponse<null>> {
    return post<null>(ApiEndpoints.PAYMENTS_CALLBACK, data, { needAuth: false });
  }
}
