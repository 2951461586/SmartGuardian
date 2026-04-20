/**
 * SmartGuardian - Service & Order API Service
 * Service product, order, session scheduling API
 * 
 * @description 服务产品与订单管理 API 服务，包含服务产品管理、订单处理和班次排课功能
 * @features
 * - 服务产品 CRUD
 * - 订单创建、审核、退款
 * - 班次排课与自动调度
 * - 学生名单管理
 */

import { get, post, put } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import { ServiceProduct, ServiceProductCreateRequest, Order, OrderCreateRequest, OrderAuditRequest, OrderRefundRequest, SessionSchedule, AutoScheduleRequest, SessionWithStudents } from '../../models/service';

// Re-export types for convenience
export { SessionSchedule, SessionWithStudents, ServiceProduct, Order };
import { ApiEndpoints, API_BASE } from '../../constants/ApiEndpoints';

/**
 * Service Product API Service
 * 
 * @description 服务产品服务类，提供服务产品的增删改查功能
 * @class
 */
export class ServiceProductService {
  /**
   * Get service product list
   * 
   * @description 获取服务产品列表
   * @param params 查询参数
   * @returns 服务产品数组响应
   */
  static async getProducts(params?: {
    pageNum?: number;
    pageSize?: number;
    status?: string;
    serviceType?: string;
  }): Promise<ApiResponse<ServiceProduct[]>> {
    return get<ServiceProduct[]>(ApiEndpoints.SERVICE_PRODUCTS, params);
  }

  /**
   * Get service product detail
   * 
   * @description 获取服务产品详情
   * @param serviceId 服务产品ID
   * @returns 服务产品详情响应
   */
  static async getProductDetail(serviceId: number): Promise<ApiResponse<ServiceProduct>> {
    return get<ServiceProduct>(ApiEndpoints.serviceProductDetail(serviceId));
  }

  /**
   * Create service product
   * 
   * @description 创建新的服务产品
   * @param data 服务产品创建数据
   * @returns 创建成功的服务产品响应
   */
  static async createProduct(data: ServiceProductCreateRequest): Promise<ApiResponse<ServiceProduct>> {
    return post<ServiceProduct>(ApiEndpoints.SERVICE_PRODUCTS, data);
  }

  /**
   * Update service product
   * 
   * @description 更新服务产品信息
   * @param serviceId 服务产品ID
   * @param data 需要更新的数据
   * @returns 更新成功的服务产品响应
   */
  static async updateProduct(serviceId: number, data: Partial<ServiceProductCreateRequest>): Promise<ApiResponse<ServiceProduct>> {
    return put<ServiceProduct>(ApiEndpoints.serviceProductDetail(serviceId), data);
  }
}

/**
 * Order API Service
 * 
 * @description 订单服务类，提供订单创建、审核、退款等功能
 * @class
 */
export class OrderService {
  /**
   * Get order list
   * 
   * @description 获取订单列表
   * @param params 查询参数
   * @returns 订单数组响应
   */
  static async getOrders(params?: {
    pageNum?: number;
    pageSize?: number;
    orderStatus?: string;
    payStatus?: string;
    studentId?: number;
  }): Promise<ApiResponse<Order[]>> {
    return get<Order[]>(ApiEndpoints.ORDERS, params);
  }

  /**
   * Get order detail
   * 
   * @description 获取订单详情
   * @param orderId 订单ID
   * @returns 订单详情响应
   */
  static async getOrderDetail(orderId: number): Promise<ApiResponse<Order>> {
    return get<Order>(ApiEndpoints.orderDetail(orderId));
  }

  /**
   * Create order
   * 
   * @description 创建新订单
   * @param data 订单创建数据
   * @returns 创建成功的订单响应
   */
  static async createOrder(data: OrderCreateRequest): Promise<ApiResponse<Order>> {
    return post<Order>(ApiEndpoints.ORDERS, data);
  }

  /**
   * Audit order
   * 
   * @description 审核订单（管理员操作）
   * @param orderId 订单ID
   * @param data 审核数据
   * @returns 审核后的订单响应
   */
  static async auditOrder(orderId: number, data: OrderAuditRequest): Promise<ApiResponse<Order>> {
    return post<Order>(ApiEndpoints.orderAudit(orderId), data);
  }

  /**
   * Refund order
   * 
   * @description 订单退款
   * @param orderId 订单ID
   * @param data 退款数据
   * @returns 退款后的订单响应
   */
  static async refundOrder(orderId: number, data: OrderRefundRequest): Promise<ApiResponse<Order>> {
    return post<Order>(ApiEndpoints.orderRefund(orderId), data);
  }
}

/**
 * Session Schedule API Service
 * 
 * @description 班次服务类，提供班次排课、查询和自动调度功能
 * @class
 */
export class SessionService {
  /**
   * Get session list
   * 
   * @description 获取班次列表
   * @param params 查询参数
   * @returns 班次数组响应
   */
  static async getSessions(params?: {
    pageNum?: number;
    pageSize?: number;
    serviceProductId?: number;
    sessionDate?: string;
    teacherUserId?: number;
    status?: string;
  }): Promise<ApiResponse<SessionSchedule[]>> {
    return get<SessionSchedule[]>(ApiEndpoints.SESSIONS, params);
  }

  /**
   * Get session detail with students
   * 
   * @description 获取班次详情及学生名单
   * @param sessionId 班次ID
   * @returns 包含学生信息的班次详情响应
   */
  static async getSessionDetail(sessionId: number): Promise<ApiResponse<SessionWithStudents>> {
    return get<SessionWithStudents>(ApiEndpoints.sessionDetail(sessionId));
  }

  /**
   * Create session (Migrated from session.ts)
   * 
   * @description 创建新班次
   * @param data 班次创建数据
   * @returns 创建成功的班次响应
   */
  static async createSession(data: Partial<SessionSchedule>): Promise<ApiResponse<SessionSchedule>> {
    return post<SessionSchedule>(ApiEndpoints.SESSIONS, data);
  }

  /**
   * Update session (Migrated from session.ts)
   * 
   * @description 更新班次信息
   * @param sessionId 班次ID
   * @param data 更新数据
   * @returns 更新成功的班次响应
   */
  static async updateSession(sessionId: number, data: Partial<SessionSchedule>): Promise<ApiResponse<SessionSchedule>> {
    return post<SessionSchedule>(ApiEndpoints.sessionDetail(sessionId), data);
  }

  /**
   * Get today's sessions (Migrated from session.ts)
   * 
   * @description 获取今日班次列表
   * @param params 查询参数
   * @returns 今日班次数组响应
   */
  static async getTodaySessions(params?: {
    teacherUserId?: number;
    serviceProductId?: number;
  }): Promise<ApiResponse<SessionSchedule[]>> {
    const today = new Date().toISOString().split('T')[0];
    return get<SessionSchedule[]>(ApiEndpoints.SESSIONS, { sessionDate: today, ...params });
  }

  /**
   * Auto schedule
   * 
   * @description 自动排课生成班次
   * @param data 自动排课请求数据
   * @returns 生成的班次数组响应
   */
  static async autoSchedule(data: AutoScheduleRequest): Promise<ApiResponse<SessionSchedule[]>> {
    return post<SessionSchedule[]>(`${API_BASE}/sessions/generate`, data);
  }

  /**
   * Get session students (Migrated from session.ts)
   * 
   * @description 获取班次学生列表（getSessionDetail 的别名）
   * @param sessionId 班次ID
   * @returns 包含学生信息的班次详情响应
   */
  static async getSessionStudents(sessionId: number): Promise<ApiResponse<SessionWithStudents>> {
    return this.getSessionDetail(sessionId);
  }
}
