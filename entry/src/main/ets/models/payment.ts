/**
 * SmartGuardian - Payment Models
 * Payment related request and response types
 */

/**
 * Create payment request
 * Aligned with OpenAPI Payments section.
 */
export interface PaymentCreateRequest {
  orderId: number;
  payChannel: 'ALIPAY' | 'WECHAT' | 'UNIONPAY' | 'CASH' | 'OTHER';
  payAmount: number;
  clientType?: 'APP' | 'H5' | 'MINI_PROGRAM' | 'WEB';
  subject?: string;
}

/**
 * Payment order / result info
 */
export interface PaymentOrder {
  id?: number;
  orderId: number;
  paymentNo?: string;
  payChannel: string;
  payAmount: number;
  payStatus?: 'CREATED' | 'PROCESSING' | 'SUCCESS' | 'FAILED' | 'CLOSED' | 'REFUNDED';
  payTime?: string;
  expireTime?: string;
  payUrl?: string;
  qrCode?: string;
  thirdTradeNo?: string;
}

/**
 * Payment callback request
 */
export interface PaymentCallbackRequest {
  paymentNo: string;
  tradeStatus: 'SUCCESS' | 'FAILED' | 'CLOSED' | 'REFUNDED';
  thirdTradeNo?: string;
  payTime?: string;
  rawPayload?: string;
}
