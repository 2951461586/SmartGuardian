/**
 * SmartGuardian - Service & Order API Service
 * Service product, order, session scheduling API
 */

import { get, post, put } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import { ServiceProduct, ServiceProductCreateRequest, Order, OrderCreateRequest, OrderAuditRequest, OrderRefundRequest, SessionSchedule, AutoScheduleRequest, SessionWithStudents } from '../../models/service';

/**
 * Service Product API Service
 */
export class ServiceProductService {
  /**
   * Get service product list
   * OpenAPI returns array data.
   */
  static async getProducts(params?: {
    pageNum?: number;
    pageSize?: number;
    status?: string;
    serviceType?: string;
  }): Promise<ApiResponse<ServiceProduct[]>> {
    return get<ServiceProduct[]>('/api/v1/service-products', params);
  }

  /**
   * Get service product detail
   */
  static async getProductDetail(serviceId: number): Promise<ApiResponse<ServiceProduct>> {
    return get<ServiceProduct>(`/api/v1/service-products/${serviceId}`);
  }

  /**
   * Create service product
   */
  static async createProduct(data: ServiceProductCreateRequest): Promise<ApiResponse<ServiceProduct>> {
    return post<ServiceProduct>('/api/v1/service-products', data);
  }

  /**
   * Update service product
   */
  static async updateProduct(serviceId: number, data: Partial<ServiceProductCreateRequest>): Promise<ApiResponse<ServiceProduct>> {
    return put<ServiceProduct>(`/api/v1/service-products/${serviceId}`, data);
  }
}

/**
 * Order API Service
 */
export class OrderService {
  /**
   * Get order list
   * OpenAPI returns array data.
   */
  static async getOrders(params?: {
    pageNum?: number;
    pageSize?: number;
    orderStatus?: string;
    payStatus?: string;
    studentId?: number;
  }): Promise<ApiResponse<Order[]>> {
    return get<Order[]>('/api/v1/orders', params);
  }

  /**
   * Get order detail
   */
  static async getOrderDetail(orderId: number): Promise<ApiResponse<Order>> {
    return get<Order>(`/api/v1/orders/${orderId}`);
  }

  /**
   * Create order
   */
  static async createOrder(data: OrderCreateRequest): Promise<ApiResponse<Order>> {
    return post<Order>('/api/v1/orders', data);
  }

  /**
   * Audit order
   */
  static async auditOrder(orderId: number, data: OrderAuditRequest): Promise<ApiResponse<Order>> {
    return post<Order>(`/api/v1/orders/${orderId}/audit`, data);
  }

  /**
   * Refund order
   */
  static async refundOrder(orderId: number, data: OrderRefundRequest): Promise<ApiResponse<Order>> {
    return post<Order>(`/api/v1/orders/${orderId}/refund`, data);
  }
}

/**
 * Session Schedule API Service
 */
export class SessionService {
  /**
   * Get session list
   * OpenAPI returns array data.
   */
  static async getSessions(params?: {
    pageNum?: number;
    pageSize?: number;
    serviceProductId?: number;
    sessionDate?: string;
    teacherUserId?: number;
    status?: string;
  }): Promise<ApiResponse<SessionSchedule[]>> {
    return get<SessionSchedule[]>('/api/v1/sessions', params);
  }

  /**
   * Get session detail with students
   */
  static async getSessionDetail(sessionId: number): Promise<ApiResponse<SessionWithStudents>> {
    return get<SessionWithStudents>(`/api/v1/sessions/${sessionId}`);
  }

  /**
   * Create session (Migrated from session.ts)
   */
  static async createSession(data: Partial<SessionSchedule>): Promise<ApiResponse<SessionSchedule>> {
    return post<SessionSchedule>('/api/v1/sessions', data);
  }

  /**
   * Update session (Migrated from session.ts)
   */
  static async updateSession(sessionId: number, data: Partial<SessionSchedule>): Promise<ApiResponse<SessionSchedule>> {
    return post<SessionSchedule>(`/api/v1/sessions/${sessionId}`, data);
  }

  /**
   * Get today's sessions (Migrated from session.ts)
   */
  static async getTodaySessions(params?: {
    teacherUserId?: number;
    serviceProductId?: number;
  }): Promise<ApiResponse<SessionSchedule[]>> {
    const today = new Date().toISOString().split('T')[0];
    return get<SessionSchedule[]>('/api/v1/sessions', { sessionDate: today, ...params });
  }

  /**
   * Auto schedule
   */
  static async autoSchedule(data: AutoScheduleRequest): Promise<ApiResponse<SessionSchedule[]>> {
    return post<SessionSchedule[]>('/api/v1/sessions/generate', data);
  }

  /**
   * Get session students (Migrated from session.ts)
   * Alias for getSessionDetail
   */
  static async getSessionStudents(sessionId: number): Promise<ApiResponse<SessionWithStudents>> {
    return this.getSessionDetail(sessionId);
  }
}
