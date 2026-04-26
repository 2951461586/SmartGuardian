import { ApiResponse } from '../../../models/common';
import { Order } from '../../../models/service';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockOrders, mockServiceProducts, mockStudents } from '../mockData';
import { extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class OrderMockHandler {
  private static buildOrders(): Order[] {
    const orderList: Order[] = [];
    for (let i = 0; i < mockOrders.length; i++) {
      orderList.push(mockOrders[i]);
    }

    if (orderList.length >= 3) {
      return orderList;
    }

    const firstStudent = mockStudents[0];
    const secondStudent = mockStudents[1] ?? mockStudents[0];
    const firstService = mockServiceProducts[0];
    const secondService = mockServiceProducts[1] ?? mockServiceProducts[0];

    orderList.push({
      id: 2,
      orderNo: 'ORD202604150002',
      studentId: firstStudent.id,
      serviceProductId: secondService.id,
      orderStatus: 'PENDING',
      amount: 500,
      totalAmount: 500,
      discountAmount: 0,
      actualAmount: 500,
      paidAmount: 0,
      payStatus: 'UNPAID',
      studentName: firstStudent.name,
      guardianUserId: firstStudent.guardianUserId,
      guardianName: firstStudent.guardianName,
      serviceProductName: secondService.serviceName,
      startDate: '2026-04-18',
      endDate: '2026-04-30',
      createdAt: '2026-04-15 14:20:00',
      updatedAt: '2026-04-15 14:20:00'
    });
    orderList.push({
      id: 3,
      orderNo: 'ORD202604100003',
      studentId: secondStudent.id,
      serviceProductId: firstService.id,
      orderStatus: 'COMPLETED',
      amount: 960,
      totalAmount: 960,
      discountAmount: 60,
      actualAmount: 900,
      paidAmount: 900,
      payStatus: 'PAID',
      studentName: secondStudent.name,
      guardianUserId: secondStudent.guardianUserId,
      guardianName: secondStudent.guardianName,
      serviceProductName: firstService.serviceName,
      startDate: '2026-03-01',
      endDate: '2026-03-31',
      createdAt: '2026-03-01 08:00:00',
      updatedAt: '2026-03-31 18:00:00'
    });
    return orderList;
  }

  private static getOrderPayableAmount(order: Order): number {
    if (order.actualAmount !== undefined) {
      return order.actualAmount;
    }
    if (order.totalAmount !== undefined) {
      return order.totalAmount - (order.discountAmount || 0);
    }
    return order.amount || 0;
  }

  static async getOrders(params?: {
    orderStatus?: string;
    studentId?: number;
  }): Promise<ApiResponse<Order[]>> {
    let orders = this.buildOrders();
    if (params?.orderStatus) {
      orders = orders.filter((item: Order) => item.orderStatus === params.orderStatus);
    }
    if (params?.studentId) {
      orders = orders.filter((item: Order) => item.studentId === params.studentId);
    }
    return mockResponse(orders);
  }

  static async getOrderDetail(orderId: number): Promise<ApiResponse<Order>> {
    const detail = this.buildOrders().find((item: Order) => item.id === orderId);
    if (!detail) {
      return mockNotFound<Order>('Order not found');
    }
    return mockResponse(detail);
  }

  static async createOrder(data: object): Promise<ApiResponse<Order>> {
    const body = data as Record<string, string | number>;
    const student = mockStudents.find((item) => item.id === Number(body.studentId)) ?? mockStudents[0];
    const service = mockServiceProducts.find((item) => item.id === Number(body.serviceProductId)) ?? mockServiceProducts[0];
    const totalAmountValue = Number(body.totalAmount) || Number(service.price) || 800;
    const discountAmountValue = Number(body.discountAmount) || 0;
    return mockResponse({
      id: this.buildOrders().length + 1,
      orderNo: 'ORD' + Date.now(),
      studentId: student.id,
      serviceProductId: service.id,
      orderStatus: 'PENDING',
      amount: totalAmountValue,
      totalAmount: totalAmountValue,
      discountAmount: discountAmountValue,
      actualAmount: totalAmountValue - discountAmountValue,
      paidAmount: 0,
      payStatus: 'UNPAID',
      studentName: student.name,
      guardianUserId: student.guardianUserId,
      guardianName: student.guardianName,
      serviceProductName: service.serviceName,
      startDate: String(body.startDate ?? '2026-04-20'),
      endDate: String(body.endDate ?? '2026-05-20'),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  }

  static async auditOrder(orderId: number, data: object): Promise<ApiResponse<Order>> {
    const detail = await this.getOrderDetail(orderId);
    if (detail.code !== 0 || !detail.data) {
      return detail;
    }
    const body = data as Record<string, string>;
    return mockResponse({
      ...detail.data,
      orderStatus: body.auditStatus === 'APPROVED' ? 'APPROVED' : 'REJECTED',
      auditStatus: body.auditStatus,
      auditRemark: body.auditRemark,
      auditTime: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  }

  static async refundOrder(orderId: number, data: object): Promise<ApiResponse<Order>> {
    const detail = await this.getOrderDetail(orderId);
    if (detail.code !== 0 || !detail.data) {
      return detail;
    }
    const body = data as Record<string, string | number>;
    const refundAmount = Number(body.refundAmount) || detail.data.paidAmount || this.getOrderPayableAmount(detail.data);
    return mockResponse({
      ...detail.data,
      orderStatus: 'REFUNDED',
      payStatus: 'PAID',
      paidAmount: Math.max(detail.data.paidAmount || 0, refundAmount),
      updatedAt: new Date().toISOString()
    });
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.ORDERS && method === HttpMethod.GET) {
      return this.getOrders({
        orderStatus: getQueryParam(url, 'orderStatus') || undefined,
        studentId: Number(getQueryParam(url, 'studentId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ORDERS && method === HttpMethod.POST) {
      return this.createOrder(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/audit') > -1 && method === HttpMethod.POST) {
      return this.auditOrder(extractId(path, ApiEndpoints.ORDERS + '/'), data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/refund') > -1 && method === HttpMethod.POST) {
      return this.refundOrder(extractId(path, ApiEndpoints.ORDERS + '/'), data ?? {}) as Promise<HttpResponse<T>>;
    }
    const orderId = extractId(path, ApiEndpoints.ORDERS + '/');
    if (orderId > 0 && method === HttpMethod.GET) {
      return this.getOrderDetail(orderId) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
