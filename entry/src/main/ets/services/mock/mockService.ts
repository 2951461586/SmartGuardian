/**
 * SmartGuardian - Mock Service
 * Mock service wrapper for API calls
 */

import { ApiResponse, PageResponse } from '../../models/common';
import { LoginResponse, UserInfo, Student, GuardianRelation } from '../../models/user';
import { ServiceProduct, Order, SessionSchedule, SessionWithStudents } from '../../models/service';
import { AttendanceRecord, LeaveRecord } from '../../models/attendance';
import { HomeworkTask, HomeworkTaskStatus, HomeworkFeedback } from '../../models/homework';
import { MessageRecord, MessageStatistics, MessageDetail } from '../../models/message';
import { StudentTimeline } from '../../models/timeline';
import { TodayStatusCard, AbnormalAlertCard } from '../../models/card';
import { AlertRecord, AlertStatistics } from '../../models/alert';
import { PaymentOrder } from '../../models/payment';
import { RefundRecord, RefundStatistics } from '../../models/refund';
import { AttendanceReport, FinanceReport, TeacherPerformance, DailyAttendanceStats, StudentAttendanceSummary, DailyRevenueStats, ServiceProductRevenue } from '../../models/report';
import { ApiConfig } from '../../config/api.config';
import * as mockData from './mockData';
import { RequestOptions, HttpMethod, HttpResponse } from '../../utils/request';
import { ApiEndpoints, API_BASE } from '../../constants/ApiEndpoints';

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

    if (path.indexOf(ApiEndpoints.ALERTS) === 0) {
      return this.handleAlertRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.ORDERS) === 0) {
      return this.handleOrderRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.PAYMENTS) === 0) {
      return this.handlePaymentRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.SERVICE_PRODUCTS) === 0) {
      return this.handleServiceProductRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.SESSIONS) === 0) {
      return this.handleSessionRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.AUTH) === 0) {
      return this.handleAuthRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.STUDENTS) === 0) {
      return this.handleStudentRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.ATTENDANCE) === 0) {
      return this.handleAttendanceRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.HOMEWORK_TASKS) === 0 || path.indexOf(ApiEndpoints.HOMEWORK_FEEDBACK) === 0) {
      return this.handleHomeworkRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.MESSAGES) === 0) {
      return this.handleMessageRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.TIMELINE) === 0) {
      return this.handleTimelineRequest<T>(path, method);
    }
    if (path === ApiEndpoints.CARDS_TODAY_STATUS || path === ApiEndpoints.CARDS_ABNORMAL_ALERT || path === `${API_BASE}/cards/alerts`) {
      return this.handleCardRequest<T>(path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.REFUNDS) === 0) {
      return this.handleRefundRequest<T>(url, path, method, options.data);
    }
    if (path.indexOf(ApiEndpoints.REPORTS) === 0) {
      return this.handleReportRequest<T>(url, path, method, options.data);
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
  }): Promise<ApiResponse<PageResponse<ServiceProduct>>> {
    let products = mockData.mockServiceProducts;
    if (params?.status) {
      products = products.filter((p: ServiceProduct) => p.status === params.status);
    }
    if (params?.serviceType) {
      products = products.filter((p: ServiceProduct) => p.serviceType === params.serviceType);
    }
    const pageNum = params?.pageNum ?? 1;
    const pageSize = params?.pageSize ?? 20;
    return mockResponse(createPageResponse(products, pageNum, pageSize));
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

  static async createSession(data: object): Promise<ApiResponse<SessionSchedule>> {
    const body = data as Record<string, string | number>;
    return mockResponse({
      id: Date.now(),
      sessionDate: String(body.sessionDate || new Date().toISOString().split('T')[0]),
      startTime: String(body.startTime || '16:30:00'),
      endTime: String(body.endTime || '18:30:00'),
      teacherUserId: Number(body.teacherUserId) || 2,
      capacity: Number(body.capacity) || 40,
      currentCount: 0,
      sessionNo: 'SES' + Date.now(),
      serviceProductId: Number(body.serviceProductId) || 1,
      maxCapacity: Number(body.maxCapacity) || 40,
      location: String(body.location || '实验小学托管教室A'),
      status: 'SCHEDULED',
      teacherId: Number(body.teacherUserId) || 2,
      teacherName: '王老师'
    });
  }

  static async updateSession(sessionId: number, data: object): Promise<ApiResponse<SessionSchedule>> {
    const detail = mockData.mockSessions.find((item: SessionSchedule) => item.id === sessionId);
    if (!detail) {
      return {
        code: 404,
        message: 'Session not found',
        data: null as SessionSchedule
      };
    }
    const body = data as Record<string, string | number>;
    return mockResponse({
      ...detail,
      sessionDate: String(body.sessionDate || detail.sessionDate),
      startTime: String(body.startTime || detail.startTime),
      endTime: String(body.endTime || detail.endTime),
      teacherUserId: Number(body.teacherUserId) || detail.teacherUserId,
      capacity: Number(body.capacity) || detail.capacity,
      maxCapacity: Number(body.maxCapacity) || detail.maxCapacity,
      location: String(body.location || detail.location),
      status: String(body.status || detail.status),
      currentCount: detail.currentCount
    });
  }

  static async generateSessions(data: object): Promise<ApiResponse<SessionSchedule[]>> {
    return mockResponse(mockData.mockSessions);
  }

  static async getSessionStudents(sessionId: number): Promise<ApiResponse<SessionWithStudents>> {
    const session = mockData.mockSessions.find((item: SessionSchedule) => item.id === sessionId);
    if (!session) {
      return {
        code: 404,
        message: 'Session not found',
        data: null as SessionWithStudents
      };
    }
    return mockResponse({
      ...session,
      students: mockData.mockSessionStudents
    });
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

  static async getAbnormalAlerts(studentId?: number): Promise<ApiResponse<AbnormalAlertCard | null>> {
    return mockResponse(mockData.mockAbnormalAlerts[0] ?? null);
  }

  static async getPaymentDetail(paymentNo: string): Promise<ApiResponse<PaymentOrder>> {
    const payment = mockData.mockPaymentOrders.find((item: PaymentOrder) => item.paymentNo === paymentNo);
    if (!payment) {
      return {
        code: 404,
        message: 'Payment not found',
        data: null as PaymentOrder
      };
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

  static async getMessageDetail(messageId: number): Promise<ApiResponse<MessageDetail>> {
    const detail = mockData.mockMessageDetails.find((item: MessageDetail) => item.id === messageId);
    if (!detail) {
      return {
        code: 404,
        message: 'Message not found',
        data: null as MessageDetail
      };
    }
    return mockResponse(detail);
  }

  static async getUnreadCount(): Promise<ApiResponse<{ count: number }>> {
    return mockResponse({ count: mockData.mockMessageStatistics.unread });
  }

  static async getMessageStatistics(): Promise<ApiResponse<MessageStatistics>> {
    return mockResponse(mockData.mockMessageStatistics);
  }

  static async getRefundList(params?: {
    orderId?: number;
    studentId?: number;
    status?: string;
    pageNum?: number;
    pageSize?: number;
  }): Promise<ApiResponse<PageResponse<RefundRecord>>> {
    let records = mockData.mockRefunds;
    if (params?.orderId) {
      records = records.filter((item: RefundRecord) => item.orderId === params.orderId);
    }
    if (params?.studentId) {
      records = records.filter((item: RefundRecord) => item.studentId === params.studentId);
    }
    if (params?.status) {
      records = records.filter((item: RefundRecord) => item.status === params.status);
    }
    const pageNum = params?.pageNum ?? 1;
    const pageSize = params?.pageSize ?? 20;
    return mockResponse(createPageResponse(records, pageNum, pageSize));
  }

  static async getRefundDetail(refundId: number): Promise<ApiResponse<RefundRecord>> {
    const detail = mockData.mockRefunds.find((item: RefundRecord) => item.id === refundId);
    if (!detail) {
      return {
        code: 404,
        message: 'Refund not found',
        data: null as RefundRecord
      };
    }
    return mockResponse(detail);
  }

  static async createRefund(data: object): Promise<ApiResponse<RefundRecord>> {
    const body = data as Record<string, string | number>;
    const newRefund: RefundRecord = {
      id: mockData.mockRefunds.length + 1,
      orderNo: 'ORD' + String(body.orderId ?? Date.now()),
      orderId: Number(body.orderId) || 0,
      studentId: 1,
      studentName: '王小明',
      serviceProductId: 1,
      serviceName: '午间托管',
      refundAmount: Number(body.refundAmount) || 0,
      reason: String(body.reason || ''),
      reasonType: String(body.reasonType || 'OTHER'),
      description: body.description ? String(body.description) : undefined,
      status: 'PENDING',
      appliedAt: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    return mockResponse(newRefund);
  }

  static async cancelRefund(refundId: number): Promise<ApiResponse<void>> {
    return mockResponse<void>(undefined);
  }

  static async getRefundStatistics(): Promise<ApiResponse<RefundStatistics>> {
    return mockResponse(mockData.mockRefundStatistics);
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
    return mockResponse(mockData.mockRefunds.filter((item: RefundRecord) => item.orderId === orderId));
  }

  static async getAttendanceReport(): Promise<ApiResponse<AttendanceReport>> {
    return mockResponse(mockData.mockAttendanceReport);
  }

  static async getFinanceReport(): Promise<ApiResponse<FinanceReport>> {
    return mockResponse(mockData.mockFinanceReport);
  }

  static async getTeacherPerformance(): Promise<ApiResponse<TeacherPerformance[]>> {
    return mockResponse(mockData.mockTeacherPerformance);
  }

  static async getDailyAttendanceStats(): Promise<ApiResponse<DailyAttendanceStats[]>> {
    return mockResponse(mockData.mockDailyAttendanceStats);
  }

  static async getStudentAttendanceSummary(): Promise<ApiResponse<StudentAttendanceSummary[]>> {
    return mockResponse(mockData.mockStudentAttendanceSummary);
  }

  static async getDailyRevenueStats(): Promise<ApiResponse<DailyRevenueStats[]>> {
    return mockResponse(mockData.mockDailyRevenueStats);
  }

  static async getServiceProductRevenue(): Promise<ApiResponse<ServiceProductRevenue[]>> {
    return mockResponse(mockData.mockServiceProductRevenue);
  }

  static async signIn(data: object): Promise<ApiResponse<AttendanceRecord>> {
    const body = data as Record<string, string | number>;
    const session = mockData.mockSessions[0];
    const student = mockData.mockStudents.find((item: Student) => item.id === Number(body.studentId)) ?? mockData.mockStudents[0];
    return mockResponse({
      id: Date.now(),
      studentId: student.id,
      sessionId: Number(body.sessionId) || session.id,
      signInTime: new Date().toISOString(),
      signInMethod: body.signMethod ? String(body.signMethod) : 'MANUAL',
      signInLocation: body.location ? String(body.location) : session.location,
      status: 'SIGNED_IN',
      studentName: student.name,
      studentNo: student.studentNo,
      sessionNo: session.sessionNo,
      attendanceDate: session.sessionDate
    });
  }

  static async signOut(data: object): Promise<ApiResponse<AttendanceRecord>> {
    const body = data as Record<string, string | number>;
    const session = mockData.mockSessions[0];
    const student = mockData.mockStudents.find((item: Student) => item.id === Number(body.studentId)) ?? mockData.mockStudents[0];
    return mockResponse({
      id: Date.now(),
      studentId: student.id,
      sessionId: Number(body.sessionId) || session.id,
      signInTime: new Date().toISOString(),
      signOutTime: new Date().toISOString(),
      signOutMethod: body.signMethod ? String(body.signMethod) : 'MANUAL',
      signOutLocation: body.location ? String(body.location) : session.location,
      status: 'SIGNED_OUT',
      studentName: student.name,
      studentNo: student.studentNo,
      sessionNo: session.sessionNo,
      attendanceDate: session.sessionDate
    });
  }

  static async getAbnormalAttendance(): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    const abnormalRecords = mockData.mockAttendanceRecords.filter((item: AttendanceRecord) => item.abnormalFlag || item.status === 'ABSENT');
    return mockResponse(createPageResponse(abnormalRecords, 1, 20));
  }

  static async submitLeave(data: object): Promise<ApiResponse<LeaveRecord>> {
    const body = data as Record<string, string | number | string[]>;
    return mockResponse({
      id: mockData.mockLeaveRecords.length + 1,
      studentId: Number(body.studentId) || 0,
      leaveDate: String(body.leaveDate || new Date().toISOString().split('T')[0]),
      leaveType: String(body.leaveType || 'PERSONAL'),
      reason: String(body.reason || ''),
      attachments: Array.isArray(body.attachments) ? body.attachments as string[] : [],
      status: 'PENDING',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  }

  static async getLeaveList(): Promise<ApiResponse<PageResponse<LeaveRecord>>> {
    return mockResponse(createPageResponse(mockData.mockLeaveRecords, 1, 20));
  }

  static async cancelLeave(leaveId: number): Promise<ApiResponse<LeaveRecord>> {
    const leave = mockData.mockLeaveRecords.find((item: LeaveRecord) => item.id === leaveId) ?? mockData.mockLeaveRecords[0];
    return mockResponse({
      ...leave,
      status: 'CANCELLED',
      updatedAt: new Date().toISOString()
    });
  }

  static async getAttendanceStatistics(): Promise<ApiResponse<{ total: number; signedIn: number; signedOut: number; absent: number; leave: number }>> {
    return mockResponse({
      total: mockData.mockAttendanceRecords.length,
      signedIn: mockData.mockAttendanceRecords.filter((item: AttendanceRecord) => item.status === 'SIGNED_IN').length,
      signedOut: mockData.mockAttendanceRecords.filter((item: AttendanceRecord) => item.status === 'SIGNED_OUT').length,
      absent: mockData.mockAttendanceRecords.filter((item: AttendanceRecord) => item.status === 'ABSENT').length,
      leave: mockData.mockLeaveRecords.length
    });
  }

  static async getSessionWithStudents(sessionId: number): Promise<ApiResponse<SessionWithStudents>> {
    const session = mockData.mockSessions.find((item: SessionSchedule) => item.id === sessionId);
    if (!session) {
      return {
        code: 404,
        message: 'Session not found',
        data: null as SessionWithStudents
      };
    }
    return mockResponse({
      ...session,
      students: mockData.mockSessionStudents
    });
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
    if (path === ApiEndpoints.ALERTS && method === HttpMethod.GET) {
      return this.getAlerts({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20,
        status: getQueryParam(url, 'status') || undefined,
        severity: getQueryParam(url, 'severity') || undefined,
        alertType: getQueryParam(url, 'alertType') || undefined,
        studentId: Number(getQueryParam(url, 'studentId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ALERTS_ACTIVE_COUNT && method === HttpMethod.GET) {
      return this.getActiveCount() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ALERTS_STATISTICS && method === HttpMethod.GET) {
      return this.getAlertStatistics() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/acknowledge') > -1 && method === HttpMethod.POST) {
      const alertId = this.extractId(path, ApiEndpoints.ALERTS + '/');
      return this.acknowledgeAlert({ alertId: alertId }) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/resolve') > -1 && method === HttpMethod.POST) {
      const alertId = this.extractId(path, ApiEndpoints.ALERTS + '/');
      const body = data as Record<string, string | number>;
      return this.resolveAlert({ alertId: alertId, resolution: String(body.resolution ?? '') }) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/dismiss') > -1 && method === HttpMethod.POST) {
      const alertId = this.extractId(path, ApiEndpoints.ALERTS + '/');
      return this.dismissAlert(alertId) as Promise<HttpResponse<T>>;
    }
    const detailId = this.extractId(path, ApiEndpoints.ALERTS + '/');
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
    if (path === ApiEndpoints.ORDERS && method === HttpMethod.GET) {
      return this.getOrders({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20,
        orderStatus: getQueryParam(url, 'orderStatus') || undefined,
        studentId: Number(getQueryParam(url, 'studentId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ORDERS && method === HttpMethod.POST) {
      return this.createOrder(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/audit') > -1 && method === HttpMethod.POST) {
      const orderId = this.extractId(path, ApiEndpoints.ORDERS + '/');
      return this.auditOrder(orderId, data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/refund') > -1 && method === HttpMethod.POST) {
      const orderId = this.extractId(path, ApiEndpoints.ORDERS + '/');
      return this.refundOrder(orderId, data ?? {}) as Promise<HttpResponse<T>>;
    }
    const orderId = this.extractId(path, ApiEndpoints.ORDERS + '/');
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
    if (path === ApiEndpoints.PAYMENTS && method === HttpMethod.POST) {
      return this.createPayment(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.PAYMENTS_CALLBACK && method === HttpMethod.POST) {
      return this.callbackPayment(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.PAYMENTS + '/') === 0 && method === HttpMethod.GET) {
      const paymentNo = path.substring((ApiEndpoints.PAYMENTS + '/').length);
      return this.getPaymentDetail(paymentNo) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/refund') > -1 && method === HttpMethod.POST) {
      const paymentNo = path.substring((ApiEndpoints.PAYMENTS + '/').length, path.lastIndexOf('/refund'));
      return this.refundPayment(paymentNo) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleServiceProductRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.SERVICE_PRODUCTS && method === HttpMethod.GET) {
      return this.getServiceProducts({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20,
        status: getQueryParam(url, 'status') || undefined,
        serviceType: getQueryParam(url, 'serviceType') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.SERVICE_PRODUCTS && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        ...(data as Record<string, string | number>)
      } as ServiceProduct) as Promise<HttpResponse<T>>;
    }
    const serviceId = this.extractId(path, ApiEndpoints.SERVICE_PRODUCTS + '/');
    if (serviceId > 0 && method === HttpMethod.GET) {
      const detail = mockData.mockServiceProducts.find((item: ServiceProduct) => item.id === serviceId);
      if (detail) {
        return mockResponse(detail) as Promise<HttpResponse<T>>;
      }
    }
    if (serviceId > 0 && method === HttpMethod.PUT) {
      const detail = mockData.mockServiceProducts.find((item: ServiceProduct) => item.id === serviceId);
      if (detail) {
        return mockResponse({
          ...detail,
          ...(data as Record<string, string | number>)
        }) as Promise<HttpResponse<T>>;
      }
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleSessionRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.SESSIONS && method === HttpMethod.GET) {
      return this.getSessions({
        sessionDate: getQueryParam(url, 'sessionDate') || undefined,
        teacherUserId: Number(getQueryParam(url, 'teacherUserId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.SESSIONS && method === HttpMethod.POST) {
      return this.createSession(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.SESSIONS_TODAY && method === HttpMethod.GET) {
      return this.getSessions() as Promise<HttpResponse<T>>;
    }
    if (path === `${ApiEndpoints.SESSIONS}/generate` && method === HttpMethod.POST) {
      return this.generateSessions(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/students') > -1 && method === HttpMethod.GET) {
      const sessionId = this.extractId(path, ApiEndpoints.SESSIONS + '/');
      return this.getSessionStudents(sessionId) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.SESSIONS + '/') === 0 && method === HttpMethod.GET) {
      const sessionId = this.extractId(path, ApiEndpoints.SESSIONS + '/');
      return this.getSessionWithStudents(sessionId) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.SESSIONS + '/') === 0 && method === HttpMethod.POST) {
      const sessionId = this.extractId(path, ApiEndpoints.SESSIONS + '/');
      return this.updateSession(sessionId, data ?? {}) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleAuthRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.AUTH_LOGIN && method === HttpMethod.POST) {
      const body = data as Record<string, string>;
      return this.login(body.username ?? 'parent_zhang', body.password ?? '') as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.AUTH_ME && method === HttpMethod.GET) {
      return this.getCurrentUser() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.AUTH_LOGOUT && method === HttpMethod.POST) {
      return mockResponse(null) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.AUTH_REFRESH && method === HttpMethod.POST) {
      return mockResponse({ token: 'mock_refresh_token_' + Date.now() }) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleStudentRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.STUDENTS && method === HttpMethod.GET) {
      return this.getStudents({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 10,
        keyword: getQueryParam(url, 'keyword') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.STUDENTS && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        status: 'ACTIVE',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        ...(data as Record<string, string | number>)
      } as Student) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/guardians') > -1 && method === HttpMethod.GET) {
      const studentId = this.extractId(path, ApiEndpoints.STUDENTS + '/');
      return mockResponse(mockData.mockGuardians.filter((item: GuardianRelation) => item.studentId === studentId)) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/guardians') > -1 && method === HttpMethod.POST) {
      const studentId = this.extractId(path, ApiEndpoints.STUDENTS + '/');
      return mockResponse({
        id: Date.now(),
        studentId,
        ...(data as Record<string, string | number | boolean>)
      } as GuardianRelation) as Promise<HttpResponse<T>>;
    }
    const studentId = this.extractId(path, ApiEndpoints.STUDENTS + '/');
    if (studentId > 0 && method === HttpMethod.GET) {
      return this.getStudentDetail(studentId) as Promise<HttpResponse<T>>;
    }
    if (studentId > 0 && method === HttpMethod.PUT) {
      const detail = await this.getStudentDetail(studentId);
      if (detail.code === 0 && detail.data) {
        return mockResponse({
          ...detail.data,
          ...(data as Record<string, string | number>)
        }) as Promise<HttpResponse<T>>;
      }
    }
    if (studentId > 0 && method === HttpMethod.DELETE) {
      return mockResponse(null) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleAttendanceRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.ATTENDANCE && method === HttpMethod.GET) {
      return this.getAttendanceList({
        studentId: Number(getQueryParam(url, 'studentId')) || undefined,
        sessionId: Number(getQueryParam(url, 'sessionId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_SIGN_IN && method === HttpMethod.POST) {
      return this.signIn(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_SIGN_OUT && method === HttpMethod.POST) {
      return this.signOut(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_ABNORMAL && method === HttpMethod.GET) {
      return this.getAbnormalAttendance() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_LEAVE && method === HttpMethod.POST) {
      return this.submitLeave(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_LEAVE && method === HttpMethod.GET) {
      return this.getLeaveList() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/cancel') > -1 && method === HttpMethod.POST) {
      const leaveId = this.extractId(path, ApiEndpoints.ATTENDANCE_LEAVE + '/');
      return this.cancelLeave(leaveId) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_STATS && method === HttpMethod.GET) {
      return this.getAttendanceStatistics() as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleHomeworkRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.HOMEWORK_TASKS && method === HttpMethod.GET) {
      return this.getHomeworkTasks({
        studentId: Number(getQueryParam(url, 'studentId')) || undefined,
        status: getQueryParam(url, 'status') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.HOMEWORK_TASKS && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        status: HomeworkTaskStatus.PENDING,
        ...(data as Record<string, string | number>)
      } as HomeworkTask) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/status') > -1 && method === HttpMethod.POST) {
      const taskId = this.extractId(path, ApiEndpoints.HOMEWORK_TASKS + '/');
      const task = mockData.mockHomeworkTasks.find((item: HomeworkTask) => item.id === taskId) ?? mockData.mockHomeworkTasks[0];
      const body = data as Record<string, string>;
      return mockResponse({
        ...task,
        status: body.status ? body.status as HomeworkTaskStatus : task.status,
        updatedAt: new Date().toISOString()
      }) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/feedbacks') > -1 && method === HttpMethod.GET) {
      return mockResponse([
        {
          id: 1,
          taskId: this.extractId(path, ApiEndpoints.HOMEWORK_TASKS + '/'),
          teacherId: 2,
          teacherName: '王老师',
          studentId: 1,
          feedbackContent: '完成情况良好',
          status: HomeworkTaskStatus.CONFIRMED,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        }
      ] as HomeworkFeedback[]) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.HOMEWORK_FEEDBACK && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        ...(data as Record<string, string | number>)
      } as HomeworkFeedback) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.HOMEWORK_FEEDBACK + '/') === 0 && path.indexOf('/confirm') > -1 && method === HttpMethod.POST) {
      const feedbackId = this.extractId(path, ApiEndpoints.HOMEWORK_FEEDBACK + '/');
      return mockResponse({
        id: feedbackId,
        taskId: 1,
        teacherId: 2,
        teacherName: '王老师',
        studentId: 1,
        feedbackContent: '完成情况良好',
        status: HomeworkTaskStatus.CONFIRMED,
        guardianConfirmTime: new Date().toISOString(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as HomeworkFeedback) as Promise<HttpResponse<T>>;
    }
    const taskId = this.extractId(path, ApiEndpoints.HOMEWORK_TASKS + '/');
    if (taskId > 0 && method === HttpMethod.GET) {
      const task = mockData.mockHomeworkTasks.find((item: HomeworkTask) => item.id === taskId);
      if (task) {
        return mockResponse(task) as Promise<HttpResponse<T>>;
      }
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleMessageRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.MESSAGES && method === HttpMethod.GET) {
      return this.getMessages({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        readStatus: false,
        ...(data as Record<string, string | number | boolean>)
      } as MessageRecord) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES_UNREAD_COUNT && method === HttpMethod.GET) {
      return this.getUnreadCount() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES_STATISTICS && method === HttpMethod.GET) {
      return this.getMessageStatistics() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES_BATCH_READ && method === HttpMethod.POST) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES_READ_ALL && method === HttpMethod.POST) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/read') > -1 && method === HttpMethod.POST) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/delete') > -1 && method === HttpMethod.POST) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    const messageId = this.extractId(path, ApiEndpoints.MESSAGES + '/');
    if (messageId > 0 && method === HttpMethod.GET) {
      return this.getMessageDetail(messageId) as Promise<HttpResponse<T>>;
    }
    if (messageId > 0 && method === HttpMethod.DELETE) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleCardRequest<T>(path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.CARDS_TODAY_STATUS && method === HttpMethod.GET) {
      return this.getTodayStatus() as Promise<HttpResponse<T>>;
    }
    if ((path === ApiEndpoints.CARDS_ABNORMAL_ALERT || path === `${API_BASE}/cards/alerts`) && method === HttpMethod.GET) {
      return this.getAbnormalAlerts() as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleTimelineRequest<T>(path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path.indexOf(`${ApiEndpoints.TIMELINE}/students/`) === 0 && method === HttpMethod.GET) {
      const studentId = this.extractId(path, `${ApiEndpoints.TIMELINE}/students/`);
      return this.getTimeline(studentId) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleRefundRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
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
    if (path === ApiEndpoints.REFUNDS_CALCULATE && method === HttpMethod.GET) {
      return this.calculateRefund(Number(getQueryParam(url, 'orderId')) || 0) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(`${ApiEndpoints.REFUNDS}/order/`) === 0 && method === HttpMethod.GET) {
      const orderId = this.extractId(path, `${ApiEndpoints.REFUNDS}/order/`);
      return this.getRefundsByOrder(orderId) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/cancel') > -1 && method === HttpMethod.POST) {
      const refundId = this.extractId(path, ApiEndpoints.REFUNDS + '/');
      return this.cancelRefund(refundId) as Promise<HttpResponse<T>>;
    }
    const refundId = this.extractId(path, ApiEndpoints.REFUNDS + '/');
    if (refundId > 0 && method === HttpMethod.GET) {
      return this.getRefundDetail(refundId) as Promise<HttpResponse<T>>;
    }
    return {
      code: 404,
      message: 'Mock route not found',
      data: null as T
    };
  }

  private static async handleReportRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (method !== HttpMethod.GET) {
      return {
        code: 404,
        message: 'Mock route not found',
        data: null as T
      };
    }
    if (path === ApiEndpoints.REPORTS_ATTENDANCE) {
      return this.getAttendanceReport() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_FINANCE) {
      return this.getFinanceReport() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_PERFORMANCE) {
      return this.getTeacherPerformance() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_ATTENDANCE_DAILY) {
      return this.getDailyAttendanceStats() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_ATTENDANCE_STUDENTS) {
      return this.getStudentAttendanceSummary() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_FINANCE_DAILY) {
      return this.getDailyRevenueStats() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.REPORTS_FINANCE_PRODUCTS) {
      return this.getServiceProductRevenue() as Promise<HttpResponse<T>>;
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
