/**
 * SmartGuardian - Mock Service
 * Mock service wrapper for API calls
 */

import { ApiResponse, PageResponse } from '../../models/common';
import { LoginResponse, UserInfo, Student } from '../../models/user';
import { ServiceProduct, Order, SessionSchedule } from '../../models/service';
import { AttendanceRecord, HomeworkTask, MessageRecord, StudentTimeline } from '../../models/attendance';
import { TodayStatusCard, AbnormalAlertCard } from '../../models/card';
import { AlertRecord, AlertStatistics } from '../../models/alert';
import { PaymentOrder } from '../../models/payment';
import { ApiConfig } from '../../config/api.config';
import * as mockData from './mockData';
import { RequestOptions, HttpMethod, HttpResponse } from '../../utils/request';

function delay(ms: number): Promise<void> {
  return new Promise((resolve: Function): void => {
    setTimeout((): void => resolve(), ms);
  });
}

async function mockResponse<T>(data: T): Promise<HttpResponse<T>> {
  if (ApiConfig.ENABLE_LOGGING) {
    console.info('[Mock] Returning mock data');
  }
  await delay(ApiConfig.MOCK_DELAY);
  return {
    code: 0,
    message: 'success',
    data: data
  };
}

function getQueryParam(url: string, key: string): string {
  const queryIndex = url.indexOf('?');
  if (queryIndex < 0) {
    return '';
  }
  const queryString = url.substring(queryIndex + 1);
  const pairs = queryString.split('&');
  for (let i = 0; i < pairs.length; i++) {
    const pair = pairs[i];
    const equalsIndex = pair.indexOf('=');
    if (equalsIndex < 0) {
      continue;
    }
    const paramKey = decodeURIComponent(pair.substring(0, equalsIndex));
    if (paramKey === key) {
      return decodeURIComponent(pair.substring(equalsIndex + 1));
    }
  }
  return '';
}

function getPath(url: string): string {
  const queryIndex = url.indexOf('?');
  if (queryIndex < 0) {
    return url;
  }
  return url.substring(0, queryIndex);
}

function createPageResponse<T>(list: T[], pageNum: number, pageSize: number): PageResponse<T> {
  return {
    list: list,
    total: list.length,
    pageNum: pageNum,
    pageSize: pageSize
  };
}

export class MockService {
  static async handleMockRequest<T>(options: RequestOptions): Promise<HttpResponse<T>> {
    const url = options.url;
    const path = getPath(url);
    const method = options.method;

    if (path.indexOf('/api/v1/alerts') === 0) {
      return this.handleAlertRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf('/api/v1/orders') === 0) {
      return this.handleOrderRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf('/api/v1/payments') === 0) {
      return this.handlePaymentRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf('/api/v1/service-products') === 0) {
      return this.handleServiceProductRequest<T>(url, path, method);
    }
    if (path.indexOf('/api/v1/sessions') === 0) {
      return this.handleSessionRequest<T>(url, path, method);
    }
    if (path.indexOf('/api/v1/auth') === 0) {
      return this.handleAuthRequest<T>(path, method, options.data);
    }
    if (path.indexOf('/api/v1/students') === 0) {
      return this.handleStudentRequest<T>(url, path, method);
    }
    if (path.indexOf('/api/v1/homework') === 0) {
      return this.handleHomeworkRequest<T>(url, path, method);
    }
    if (path.indexOf('/api/v1/messages') === 0) {
      return this.handleMessageRequest<T>(url, path, method);
    }
    if (path.indexOf('/api/v1/cards') === 0) {
      return this.handleCardRequest<T>(path, method);
    }
    if (path.indexOf('/api/v1/timeline') === 0) {
      return this.handleTimelineRequest<T>(path, method);
    }

    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  static async login(username: string, password: string): Promise<ApiResponse<LoginResponse>> {
    const response = mockData.getMockLoginResponse(username);
    return mockResponse(response);
  }

  static async getCurrentUser(): Promise<ApiResponse<UserInfo>> {
    return mockResponse(mockData.mockUsers[0]);
  }

  static async getStudents(params?: {
    pageNum?: number;
    pageSize?: number;
    keyword?: string;
  }): Promise<ApiResponse<PageResponse<Student>>> {
    const pageNum = params?.pageNum ?? 1;
    const pageSize = params?.pageSize ?? 10;
    return mockResponse(createPageResponse(mockData.mockStudents, pageNum, pageSize));
  }

  static async getStudentDetail(studentId: number): Promise<ApiResponse<Student>> {
    let student: Student | null = null;
    for (let i = 0; i < mockData.mockStudents.length; i++) {
      if (mockData.mockStudents[i].id === studentId) {
        student = mockData.mockStudents[i];
        break;
      }
    }
    if (!student) {
      return {
        code: 404,
        message: 'Student not found',
        data: null as Student
      };
    }
    return mockResponse(student);
  }

  static async getServiceProducts(params?: {
    pageNum?: number;
    pageSize?: number;
    status?: string;
    serviceType?: string;
  }): Promise<ApiResponse<ServiceProduct[]>> {
    let products = mockData.mockServiceProducts;
    if (params?.status) {
      products = products.filter((p: ServiceProduct) => p.status === params.status);
    }
    if (params?.serviceType) {
      products = products.filter((p: ServiceProduct) => p.serviceType === params.serviceType);
    }
    return mockResponse(products);
  }

  static async getOrders(params?: {
    pageNum?: number;
    pageSize?: number;
    orderStatus?: string;
    studentId?: number;
  }): Promise<ApiResponse<Order[]>> {
    let orders = this.buildOrders();
    if (params?.orderStatus) {
      orders = orders.filter((o: Order) => o.orderStatus === params.orderStatus);
    }
    if (params?.studentId) {
      orders = orders.filter((o: Order) => o.studentId === params.studentId);
    }
    return mockResponse(orders);
  }

  static async getOrderDetail(orderId: number): Promise<ApiResponse<Order>> {
    const orders = this.buildOrders();
    for (let i = 0; i < orders.length; i++) {
      if (orders[i].id === orderId) {
        return mockResponse(orders[i]);
      }
    }
    return {
      code: 404,
      message: 'Order not found',
      data: null as Order
    };
  }

  static async createOrder(data: object): Promise<ApiResponse<Order>> {
    const totalAmountValue = Number((data as Record<string, string | number>).totalAmount) || 800;
    const discountAmountValue = Number((data as Record<string, string | number>).discountAmount) || 0;
    const newOrder: Order = {
      id: this.buildOrders().length + 1,
      orderNo: 'ORD' + Date.now(),
      studentId: Number((data as Record<string, string | number>).studentId),
      serviceProductId: Number((data as Record<string, string | number>).serviceProductId),
      orderStatus: 'PENDING',
      amount: totalAmountValue,
      totalAmount: totalAmountValue,
      discountAmount: discountAmountValue,
      actualAmount: totalAmountValue - discountAmountValue,
      paidAmount: 0,
      payStatus: 'UNPAID',
      studentName: '张小明',
      guardianUserId: 1,
      guardianName: '张家长',
      serviceProductName: '课后托管服务',
      startDate: String((data as Record<string, string>).startDate),
      endDate: String((data as Record<string, string>).endDate),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    return mockResponse(newOrder);
  }

  static async auditOrder(orderId: number, data: object): Promise<ApiResponse<Order>> {
    const detail = await this.getOrderDetail(orderId);
    if (detail.code !== 0 || !detail.data) {
      return detail;
    }
    const body = data as Record<string, string>;
    const updatedOrder: Order = {
      ...detail.data,
      orderStatus: body.auditStatus === 'APPROVED' ? 'APPROVED' : 'REJECTED',
      auditStatus: body.auditStatus,
      auditRemark: body.auditRemark,
      auditTime: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    return mockResponse(updatedOrder);
  }

  static async refundOrder(orderId: number, data: object): Promise<ApiResponse<Order>> {
    const detail = await this.getOrderDetail(orderId);
    if (detail.code !== 0 || !detail.data) {
      return detail;
    }
    const body = data as Record<string, string | number>;
    const refundAmount = Number(body.refundAmount) || detail.data.paidAmount || this.getOrderPayableAmount(detail.data);
    const updatedOrder: Order = {
      ...detail.data,
      orderStatus: 'REFUNDED',
      payStatus: 'PAID',
      paidAmount: Math.max(detail.data.paidAmount || 0, refundAmount),
      updatedAt: new Date().toISOString()
    };
    return mockResponse(updatedOrder);
  }

  static async createPayment(data: object): Promise<ApiResponse<PaymentOrder>> {
    const body = data as Record<string, string | number>;
    const paymentOrder: PaymentOrder = {
      id: Date.now(),
      orderId: Number(body.orderId) || 0,
      paymentNo: 'PAY' + Date.now(),
      payChannel: String(body.payChannel || 'ALIPAY'),
      payAmount: Number(body.payAmount) || 0,
      payStatus: 'CREATED',
      expireTime: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
      payUrl: 'https://mock.smartguardian/pay/' + Date.now(),
      qrCode: 'MOCK_QR_' + Date.now()
    };
    return mockResponse(paymentOrder);
  }

  static async callbackPayment(data: object): Promise<ApiResponse<null>> {
    return mockResponse(null);
  }

  static async getSessions(params?: {
    sessionDate?: string;
    teacherUserId?: number;
  }): Promise<ApiResponse<SessionSchedule[]>> {
    let sessions = mockData.mockSessions;
    if (params?.sessionDate) {
      sessions = sessions.filter((s: SessionSchedule) => s.sessionDate === params.sessionDate);
    }
    if (params?.teacherUserId) {
      sessions = sessions.filter((s: SessionSchedule) => s.teacherUserId === params.teacherUserId);
    }
    return mockResponse(sessions);
  }

  static async getAttendanceList(params?: {
    studentId?: number;
    sessionId?: number;
  }): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    let records = mockData.mockAttendanceRecords;
    if (params?.studentId) {
      records = records.filter((r: AttendanceRecord) => r.studentId === params.studentId);
    }
    if (params?.sessionId) {
      records = records.filter((r: AttendanceRecord) => r.sessionId === params.sessionId);
    }
    return mockResponse(createPageResponse(records, 1, 10));
  }

  static async getHomeworkTasks(params?: {
    studentId?: number;
    status?: string;
  }): Promise<ApiResponse<PageResponse<HomeworkTask>>> {
    let tasks = mockData.mockHomeworkTasks;
    if (params?.studentId) {
      tasks = tasks.filter((t: HomeworkTask) => t.studentId === params.studentId);
    }
    if (params?.status) {
      tasks = tasks.filter((t: HomeworkTask) => t.status === params.status);
    }
    return mockResponse(createPageResponse(tasks, 1, 10));
  }

  static async getMessages(params?: {
    pageNum?: number;
    pageSize?: number;
  }): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    const pageNum = params?.pageNum ?? 1;
    const pageSize = params?.pageSize ?? 20;
    return mockResponse(createPageResponse(mockData.mockMessages, pageNum, pageSize));
  }

  static async getTimeline(studentId: number): Promise<ApiResponse<StudentTimeline[]>> {
    let timeline: StudentTimeline[] = [];
    for (let i = 0; i < mockData.mockTimeline.length; i++) {
      if (mockData.mockTimeline[i].studentId === studentId) {
        timeline.push(mockData.mockTimeline[i]);
      }
    }
    return mockResponse(timeline);
  }

  static async getTodayStatus(studentId?: number): Promise<ApiResponse<TodayStatusCard>> {
    return mockResponse(mockData.mockTodayStatusCard);
  }

  static async getAbnormalAlerts(studentId?: number): Promise<ApiResponse<AbnormalAlertCard[]>> {
    return mockResponse(mockData.mockAbnormalAlerts);
  }

  static async getAlerts(params?: {
    studentId?: number;
    alertType?: string;
    severity?: string;
    status?: string;
    startDate?: string;
    endDate?: string;
    pageNum?: number;
    pageSize?: number;
  }): Promise<ApiResponse<PageResponse<AlertRecord>>> {
    let alerts = this.buildAlertRecords();
    if (params?.status) {
      alerts = alerts.filter((item: AlertRecord) => item.status === params.status);
    }
    if (params?.severity) {
      alerts = alerts.filter((item: AlertRecord) => item.severity === params.severity);
    }
    if (params?.alertType) {
      alerts = alerts.filter((item: AlertRecord) => item.alertType === params.alertType);
    }
    if (params?.studentId) {
      alerts = alerts.filter((item: AlertRecord) => item.studentId === params.studentId);
    }
    const pageNum = params?.pageNum ?? 1;
    const pageSize = params?.pageSize ?? 20;
    return mockResponse(createPageResponse(alerts, pageNum, pageSize));
  }

  static async getAlertStatistics(): Promise<ApiResponse<AlertStatistics>> {
    const statistics: AlertStatistics = {
      total: 3,
      active: 2,
      acknowledged: 1,
      resolved: 0,
      byType: {
        ATTENDANCE_ANOMALY: 2,
        SAFETY_CONCERN: 1
      },
      bySeverity: {
        HIGH: 1,
        MEDIUM: 1,
        LOW: 1
      }
    };
    return mockResponse(statistics);
  }

  static async acknowledgeAlert(params: { alertId: number; note?: string }): Promise<ApiResponse<void>> {
    return mockResponse<void>(undefined);
  }

  static async resolveAlert(params: { alertId: number; resolution: string }): Promise<ApiResponse<void>> {
    return mockResponse<void>(undefined);
  }

  static async dismissAlert(alertId: number): Promise<ApiResponse<void>> {
    return mockResponse<void>(undefined);
  }

  static async getActiveCount(): Promise<ApiResponse<{ count: number }>> {
    return mockResponse({ count: 2 });
  }

  static async getActiveAlerts(pageNum: number = 1, pageSize: number = 20): Promise<ApiResponse<PageResponse<AlertRecord>>> {
    return this.getAlerts({ status: 'ACTIVE', pageNum: pageNum, pageSize: pageSize });
  }

  private static buildOrders(): Order[] {
    return [
      {
        id: 1,
        orderNo: 'ORD202604160001',
        studentId: 1,
        serviceProductId: 1,
        orderStatus: 'APPROVED',
        amount: 800,
        totalAmount: 800,
        discountAmount: 80,
        actualAmount: 720,
        paidAmount: 0,
        payStatus: 'UNPAID',
        studentName: '张小明',
        guardianUserId: 1,
        guardianName: '张家长',
        serviceProductName: '课后托管服务',
        startDate: '2026-04-20',
        endDate: '2026-05-20',
        createdAt: '2026-04-16 09:30:00',
        updatedAt: '2026-04-16 09:30:00'
      },
      {
        id: 2,
        orderNo: 'ORD202604150002',
        studentId: 1,
        serviceProductId: 2,
        orderStatus: 'PENDING',
        amount: 500,
        totalAmount: 500,
        discountAmount: 0,
        actualAmount: 500,
        paidAmount: 0,
        payStatus: 'UNPAID',
        studentName: '张小明',
        guardianUserId: 1,
        guardianName: '张家长',
        serviceProductName: '周末托管服务',
        startDate: '2026-04-18',
        endDate: '2026-04-30',
        createdAt: '2026-04-15 14:20:00',
        updatedAt: '2026-04-15 14:20:00'
      },
      {
        id: 3,
        orderNo: 'ORD202604100003',
        studentId: 2,
        serviceProductId: 1,
        orderStatus: 'COMPLETED',
        amount: 960,
        totalAmount: 960,
        discountAmount: 60,
        actualAmount: 900,
        paidAmount: 900,
        payStatus: 'PAID',
        studentName: '李小红',
        guardianUserId: 2,
        guardianName: '李家长',
        serviceProductName: '课后托管服务',
        startDate: '2026-03-01',
        endDate: '2026-03-31',
        createdAt: '2026-03-01 08:00:00',
        updatedAt: '2026-03-31 18:00:00'
      }
    ];
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

  private static buildAlertRecords(): AlertRecord[] {
    return [
      {
        id: 1,
        studentId: 1,
        studentName: '王小明',
        alertType: 'ATTENDANCE_ANOMALY',
        severity: 'HIGH',
        title: '未按时签到',
        description: '学生今日未在规定时间内完成签到，请及时关注',
        suggestedAction: '请联系班主任确认学生情况',
        status: 'ACTIVE',
        createdAt: '2026-04-16 09:00:00',
        updatedAt: '2026-04-16 09:00:00'
      },
      {
        id: 2,
        studentId: 1,
        studentName: '王小明',
        alertType: 'SAFETY_CONCERN',
        severity: 'MEDIUM',
        title: '位置异常',
        description: '学生签到位置与活动地点不符',
        suggestedAction: '请核实学生实际位置',
        status: 'ACTIVE',
        createdAt: '2026-04-16 10:30:00',
        updatedAt: '2026-04-16 10:30:00'
      },
      {
        id: 3,
        studentId: 2,
        studentName: '李小红',
        alertType: 'SYSTEM',
        severity: 'LOW',
        title: '系统提醒',
        description: '托管服务即将在3天后到期',
        suggestedAction: '建议尽快办理续费',
        status: 'ACKNOWLEDGED',
        createdAt: '2026-04-15 15:00:00',
        updatedAt: '2026-04-15 15:10:00'
      }
    ];
  }

  private static async handleAlertRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === '/api/v1/alerts' && method === HttpMethod.GET) {
      return this.getAlerts({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20,
        status: getQueryParam(url, 'status') || undefined,
        severity: getQueryParam(url, 'severity') || undefined,
        alertType: getQueryParam(url, 'alertType') || undefined,
        studentId: Number(getQueryParam(url, 'studentId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === '/api/v1/alerts/active-count' && method === HttpMethod.GET) {
      return this.getActiveCount() as Promise<HttpResponse<T>>;
    }
    if (path === '/api/v1/alerts/statistics' && method === HttpMethod.GET) {
      return this.getAlertStatistics() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/acknowledge') > -1 && method === HttpMethod.POST) {
      const alertId = this.extractId(path, '/api/v1/alerts/');
      return this.acknowledgeAlert({ alertId: alertId }) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/resolve') > -1 && method === HttpMethod.POST) {
      const alertId = this.extractId(path, '/api/v1/alerts/');
      const body = data as Record<string, string | number>;
      return this.resolveAlert({ alertId: alertId, resolution: String(body.resolution ?? '') }) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/dismiss') > -1 && method === HttpMethod.POST) {
      const alertId = this.extractId(path, '/api/v1/alerts/');
      return this.dismissAlert(alertId) as Promise<HttpResponse<T>>;
    }
    const detailId = this.extractId(path, '/api/v1/alerts/');
    if (detailId > 0 && method === HttpMethod.GET) {
      const alerts = this.buildAlertRecords();
      for (let i = 0; i < alerts.length; i++) {
        if (alerts[i].id === detailId) {
          return mockResponse(alerts[i]) as Promise<HttpResponse<T>>;
        }
      }
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleOrderRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === '/api/v1/orders' && method === HttpMethod.GET) {
      return this.getOrders({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20,
        orderStatus: getQueryParam(url, 'orderStatus') || undefined,
        studentId: Number(getQueryParam(url, 'studentId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === '/api/v1/orders' && method === HttpMethod.POST) {
      return this.createOrder(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/audit') > -1 && method === HttpMethod.POST) {
      const orderId = this.extractId(path, '/api/v1/orders/');
      return this.auditOrder(orderId, data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/refund') > -1 && method === HttpMethod.POST) {
      const orderId = this.extractId(path, '/api/v1/orders/');
      return this.refundOrder(orderId, data ?? {}) as Promise<HttpResponse<T>>;
    }
    const orderId = this.extractId(path, '/api/v1/orders/');
    if (orderId > 0 && method === HttpMethod.GET) {
      return this.getOrderDetail(orderId) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handlePaymentRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === '/api/v1/payments' && method === HttpMethod.POST) {
      return this.createPayment(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === '/api/v1/payments/callback' && method === HttpMethod.POST) {
      return this.callbackPayment(data ?? {}) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleServiceProductRequest<T>(url: string, path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === '/api/v1/service-products' && method === HttpMethod.GET) {
      return this.getServiceProducts({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20,
        status: getQueryParam(url, 'status') || undefined,
        serviceType: getQueryParam(url, 'serviceType') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleSessionRequest<T>(url: string, path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === '/api/v1/sessions' && method === HttpMethod.GET) {
      return this.getSessions({
        sessionDate: getQueryParam(url, 'sessionDate') || undefined,
        teacherUserId: Number(getQueryParam(url, 'teacherUserId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === '/api/v1/sessions/today' && method === HttpMethod.GET) {
      return this.getSessions() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/api/v1/sessions/') === 0 && method === HttpMethod.GET) {
      const sessionId = this.extractId(path, '/api/v1/sessions/');
      if (sessionId > 0) {
        for (let i = 0; i < mockData.mockSessions.length; i++) {
          if (mockData.mockSessions[i].id === sessionId) {
            return mockResponse(mockData.mockSessions[i]) as Promise<HttpResponse<T>>;
          }
        }
      }
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleAuthRequest<T>(path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === '/api/v1/auth/login' && method === HttpMethod.POST) {
      const body = data as Record<string, string>;
      return this.login(body.username ?? 'parent_zhang', body.password ?? '') as Promise<HttpResponse<T>>;
    }
    if (path === '/api/v1/auth/me' && method === HttpMethod.GET) {
      return this.getCurrentUser() as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleStudentRequest<T>(url: string, path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === '/api/v1/students' && method === HttpMethod.GET) {
      return this.getStudents({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 10,
        keyword: getQueryParam(url, 'keyword') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleHomeworkRequest<T>(url: string, path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === '/api/v1/homework' && method === HttpMethod.GET) {
      return this.getHomeworkTasks({
        studentId: Number(getQueryParam(url, 'studentId')) || undefined,
        status: getQueryParam(url, 'status') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleMessageRequest<T>(url: string, path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === '/api/v1/messages' && method === HttpMethod.GET) {
      return this.getMessages({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20
      }) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleCardRequest<T>(path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === '/api/v1/cards/today-status' && method === HttpMethod.GET) {
      return this.getTodayStatus() as Promise<HttpResponse<T>>;
    }
    if (path === '/api/v1/cards/abnormal-alerts' && method === HttpMethod.GET) {
      return this.getAbnormalAlerts() as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleTimelineRequest<T>(path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path.indexOf('/api/v1/timeline/') === 0 && method === HttpMethod.GET) {
      const studentId = this.extractId(path, '/api/v1/timeline/');
      return this.getTimeline(studentId) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static extractId(path: string, prefix: string): number {
    const idString = path.substring(prefix.length);
    const endIndex = idString.indexOf('/');
    const rawId = endIndex > -1 ? idString.substring(0, endIndex) : idString;
    return Number(rawId) || 0;
  }
}
