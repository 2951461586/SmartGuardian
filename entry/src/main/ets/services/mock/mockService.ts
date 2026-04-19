/**
 * SmartGuardian - Mock Service
 * Mock service wrapper for API calls
 */

import { ApiResponse, PageResponse } from '../../models/common';
import { LoginResponse, UserInfo, Student } from '../../models/user';
import { ServiceProduct, Order, SessionSchedule } from '../../models/service';
import { AttendanceRecord, HomeworkTask, MessageRecord, StudentTimeline } from '../../models/attendance';
import { TodayStatusCard, AbnormalAlertCard } from '../../models/card';
import { ApiConfig } from '../../config/api.config';
import * as mockData from './mockData';

/**
 * Delay simulation
 */
function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Mock response wrapper
 */
async function mockResponse<T>(data: T): Promise<ApiResponse<T>> {
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

/**
 * Mock Service Handler
 */
export class MockService {
  // Auth Service
  static async login(username: string, password: string): Promise<ApiResponse<LoginResponse>> {
    const response = mockData.getMockLoginResponse(username);
    return mockResponse(response);
  }

  static async getCurrentUser(): Promise<ApiResponse<UserInfo>> {
    return mockResponse(mockData.mockUsers[0]);
  }

  // Student Service
  static async getStudents(params?: {
    pageNum?: number;
    pageSize?: number;
    keyword?: string;
  }): Promise<ApiResponse<PageResponse<Student>>> {
    const pageNum = params?.pageNum ?? 1;
    const pageSize = params?.pageSize ?? 10;
    
    return mockResponse({
      list: mockData.mockStudents,
      total: mockData.mockStudents.length,
      pageNum: pageNum,
      pageSize: pageSize
    });
  }

  static async getStudentDetail(studentId: number): Promise<ApiResponse<Student>> {
    const student = mockData.mockStudents.find(s => s.id === studentId);
    if (!student) {
      return {
        code: 404,
        message: 'Student not found',
        data: null as unknown as Student
      };
    }
    return mockResponse(student);
  }

  // Service Product Service
  static async getServiceProducts(params?: {
    pageNum?: number;
    pageSize?: number;
    status?: string;
    serviceType?: string;
  }): Promise<ApiResponse<ServiceProduct[]>> {
    let products = [...mockData.mockServiceProducts];
    
    if (params?.status) {
      products = products.filter(p => p.status === params.status);
    }
    if (params?.serviceType) {
      products = products.filter(p => p.serviceType === params.serviceType);
    }
    
    return mockResponse(products);
  }

  // Order Service
  static async getOrders(params?: {
    pageNum?: number;
    pageSize?: number;
    orderStatus?: string;
    studentId?: number;
  }): Promise<ApiResponse<Order[]>> {
    let orders = [...mockData.mockOrders];
    
    if (params?.orderStatus) {
      orders = orders.filter(o => o.orderStatus === params.orderStatus);
    }
    if (params?.studentId) {
      orders = orders.filter(o => o.studentId === params.studentId);
    }
    
    return mockResponse(orders);
  }

  static async createOrder(data: object): Promise<ApiResponse<Order>> {
    const newOrder: Order = {
      id: mockData.mockOrders.length + 1,
      orderNo: 'ORD' + Date.now(),
      studentId: (data as Record<string, number>).studentId,
      serviceProductId: (data as Record<string, number>).serviceProductId,
      orderStatus: 'PENDING',
      amount: 800,
      paidAmount: 0,
      payStatus: 'UNPAID',
      studentName: 'Mock Student',
      guardianUserId: 1,
      guardianName: 'Mock Guardian',
      serviceProductName: 'Mock Service',
      startDate: (data as Record<string, string>).startDate,
      endDate: (data as Record<string, string>).endDate,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    return mockResponse(newOrder);
  }

  // Session Service
  static async getSessions(params?: {
    sessionDate?: string;
    teacherUserId?: number;
  }): Promise<ApiResponse<SessionSchedule[]>> {
    let sessions = [...mockData.mockSessions];
    
    if (params?.sessionDate) {
      sessions = sessions.filter(s => s.sessionDate === params.sessionDate);
    }
    if (params?.teacherUserId) {
      sessions = sessions.filter(s => s.teacherUserId === params.teacherUserId);
    }
    
    return mockResponse(sessions);
  }

  // Attendance Service
  static async getAttendanceList(params?: {
    studentId?: number;
    sessionId?: number;
  }): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    let records = [...mockData.mockAttendanceRecords];
    
    if (params?.studentId) {
      records = records.filter(r => r.studentId === params.studentId);
    }
    if (params?.sessionId) {
      records = records.filter(r => r.sessionId === params.sessionId);
    }
    
    return mockResponse({
      list: records,
      total: records.length,
      pageNum: 1,
      pageSize: 10
    });
  }

  // Homework Service
  static async getHomeworkTasks(params?: {
    studentId?: number;
    status?: string;
  }): Promise<ApiResponse<PageResponse<HomeworkTask>>> {
    let tasks = [...mockData.mockHomeworkTasks];
    
    if (params?.studentId) {
      tasks = tasks.filter(t => t.studentId === params.studentId);
    }
    if (params?.status) {
      tasks = tasks.filter(t => t.status === params.status);
    }
    
    return mockResponse({
      list: tasks,
      total: tasks.length,
      pageNum: 1,
      pageSize: 10
    });
  }

  // Message Service
  static async getMessages(params?: {
    pageNum?: number;
    pageSize?: number;
  }): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    return mockResponse({
      list: mockData.mockMessages,
      total: mockData.mockMessages.length,
      pageNum: params?.pageNum ?? 1,
      pageSize: params?.pageSize ?? 20
    });
  }

  // Timeline Service
  static async getTimeline(studentId: number): Promise<ApiResponse<StudentTimeline[]>> {
    const timeline = mockData.mockTimeline.filter(t => t.studentId === studentId);
    return mockResponse(timeline);
  }

  // Card Service
  static async getTodayStatus(studentId?: number): Promise<ApiResponse<TodayStatusCard>> {
    return mockResponse(mockData.mockTodayStatusCard);
  }

  static async getAbnormalAlerts(studentId?: number): Promise<ApiResponse<AbnormalAlertCard[]>> {
    return mockResponse(mockData.mockAbnormalAlerts);
  }
}
