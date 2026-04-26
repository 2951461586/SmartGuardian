import { ApiResponse, PageResponse } from '../../../models/common';
import { RefundRecord, RefundStatistics } from '../../../models/refund';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockRefundStatistics, mockRefunds } from '../mockData';
import { createPageResponse, extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class RefundMockHandler {
  static async getRefundList(params?: {
    orderId?: number;
    studentId?: number;
    status?: string;
    pageNum?: number;
    pageSize?: number;
  }): Promise<ApiResponse<PageResponse<RefundRecord>>> {
    let records = mockRefunds;
    if (params?.orderId) {
      records = records.filter((item: RefundRecord) => item.orderId === params.orderId);
    }
    if (params?.studentId) {
      records = records.filter((item: RefundRecord) => item.studentId === params.studentId);
    }
    if (params?.status) {
      records = records.filter((item: RefundRecord) => item.status === params.status);
    }
    return mockResponse(createPageResponse(records, params?.pageNum ?? 1, params?.pageSize ?? 20));
  }

  static async getRefundDetail(refundId: number): Promise<ApiResponse<RefundRecord>> {
    const detail = mockRefunds.find((item: RefundRecord) => item.id === refundId);
    if (!detail) {
      return mockNotFound<RefundRecord>('Refund not found');
    }
    return mockResponse(detail);
  }

  static async createRefund(data: object): Promise<ApiResponse<RefundRecord>> {
    const body = data as Record<string, string | number>;
    return mockResponse({
      id: mockRefunds.length + 1,
      orderNo: 'ORD' + String(body.orderId ?? Date.now()),
      orderId: Number(body.orderId) || 0,
      studentId: 1,
      studentName: '王小明',
      serviceProductId: 1,
      serviceName: '午间托管',
      refundAmount: Number(body.refundAmount) || 0,
      reason: String(body.reason ?? ''),
      reasonType: String(body.reasonType ?? 'OTHER'),
      description: body.description ? String(body.description) : undefined,
      status: 'PENDING',
      appliedAt: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  }

  static async cancelRefund(refundId: number): Promise<ApiResponse<void>> {
    const detail = await this.getRefundDetail(refundId);
    if (detail.code !== 0) {
      return detail as unknown as ApiResponse<void>;
    }
    return mockResponse<void>(undefined);
  }

  static async getRefundStatistics(): Promise<ApiResponse<RefundStatistics>> {
    return mockResponse(mockRefundStatistics);
  }

  static async calculateRefund(orderId: number): Promise<ApiResponse<{ refundable: boolean; refundAmount: number; deduction: number; reason?: string }>> {
    return mockResponse({
      refundable: true,
      refundAmount: 200,
      deduction: 0,
      reason: `订单 ${orderId} 可退款`
    });
  }

  static async getRefundsByOrder(orderId: number): Promise<ApiResponse<RefundRecord[]>> {
    return mockResponse(mockRefunds.filter((item: RefundRecord) => item.orderId === orderId));
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.REFUNDS && method === HttpMethod.GET) {
      return this.getRefundList({
        orderId: Number(getQueryParam(url, 'orderId')) || undefined,
        studentId: Number(getQueryParam(url, 'studentId')) || undefined,
        status: getQueryParam(url, 'status') || undefined,
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REFUNDS && method === HttpMethod.POST) {
      return this.createRefund(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REFUNDS_STATISTICS && method === HttpMethod.GET) {
      return this.getRefundStatistics() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.REFUNDS_CALCULATE) === 0 && method === HttpMethod.GET) {
      return this.calculateRefund(Number(getQueryParam(url, 'orderId')) || 0) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(`${ApiEndpoints.REFUNDS}/order/`) === 0 && method === HttpMethod.GET) {
      return this.getRefundsByOrder(extractId(path, `${ApiEndpoints.REFUNDS}/order/`)) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/cancel') > -1 && method === HttpMethod.POST) {
      return this.cancelRefund(extractId(path, ApiEndpoints.REFUNDS + '/')) as Promise<HttpResponse<T>>;
    }
    const refundId = extractId(path, ApiEndpoints.REFUNDS + '/');
    if (refundId > 0 && method === HttpMethod.GET) {
      return this.getRefundDetail(refundId) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
