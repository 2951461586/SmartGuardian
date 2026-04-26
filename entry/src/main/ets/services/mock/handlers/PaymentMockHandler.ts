import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { PaymentOrder } from '../../../models/payment';
import { ApiResponse } from '../../../models/common';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockPaymentOrders } from '../mockData';
import { mockNotFound, mockResponse } from '../shared/mockUtils';

export class PaymentMockHandler {
  static async getPaymentDetail(paymentNo: string): Promise<ApiResponse<PaymentOrder>> {
    const payment = mockPaymentOrders.find((item: PaymentOrder) => item.paymentNo === paymentNo);
    if (!payment) {
      return mockNotFound<PaymentOrder>('Payment not found');
    }
    return mockResponse(payment);
  }

  static async refundPayment(paymentNo: string): Promise<ApiResponse<PaymentOrder>> {
    const paymentDetail = await this.getPaymentDetail(paymentNo);
    if (paymentDetail.code !== 0 || !paymentDetail.data) {
      return paymentDetail;
    }
    return mockResponse({
      ...paymentDetail.data,
      payStatus: 'REFUNDED'
    });
  }

  static async createPayment(data: object): Promise<ApiResponse<PaymentOrder>> {
    const body = data as Record<string, string | number>;
    const identity = String(Date.now());
    return mockResponse({
      id: Number(identity),
      orderId: Number(body.orderId) || 0,
      paymentNo: 'PAY' + identity,
      payChannel: String(body.payChannel ?? 'ALIPAY'),
      payAmount: Number(body.payAmount) || 0,
      payStatus: 'CREATED',
      expireTime: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
      payUrl: 'https://mock.smartguardian/pay/' + identity,
      qrCode: 'MOCK_QR_' + identity
    });
  }

  static async callbackPayment(): Promise<ApiResponse<null>> {
    return mockResponse(null);
  }

  static async handleRequest<T>(path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.PAYMENTS && method === HttpMethod.POST) {
      return this.createPayment(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.PAYMENTS_CALLBACK && method === HttpMethod.POST) {
      return this.callbackPayment() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/refund') > -1 && method === HttpMethod.POST) {
      const paymentNo = path.substring((ApiEndpoints.PAYMENTS + '/').length, path.lastIndexOf('/refund'));
      return this.refundPayment(paymentNo) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.PAYMENTS + '/') === 0 && method === HttpMethod.GET) {
      const paymentNo = path.substring((ApiEndpoints.PAYMENTS + '/').length);
      return this.getPaymentDetail(paymentNo) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
