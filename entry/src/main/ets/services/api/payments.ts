/**
 * SmartGuardian - Payments API Service
 * Payment creation and callback APIs
 */

import { post } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import { PaymentCreateRequest, PaymentOrder, PaymentCallbackRequest } from '../../models/payment';

/**
 * Payments API Service
 */
export class PaymentService {
  /**
   * Create payment order
   */
  static async createPayment(data: PaymentCreateRequest): Promise<ApiResponse<PaymentOrder>> {
    return post<PaymentOrder>('/api/v1/payments', data);
  }

  /**
   * Handle payment callback
   */
  static async callback(data: PaymentCallbackRequest): Promise<ApiResponse<null>> {
    return post<null>('/api/v1/payments/callback', data, { needAuth: false });
  }
}
