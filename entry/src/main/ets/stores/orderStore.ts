/**
 * SmartGuardian - Order Store
 * Order state management
 * 
 * @description 订单状态管理 Store，负责订单数据的全局状态管理
 * @features
 * - 订单列表缓存管理
 * - 当前订单状态追踪
 * - 订单筛选条件维护
 * - 订单 CRUD 操作支持
 */

import { Order } from '../models/service';

/**
 * Order store keys
 * 
 * @description AppStorage 存储键名常量
 */
const ORDER_LIST_KEY = 'order_list';
const CURRENT_ORDER_KEY = 'current_order';
const ORDER_FILTER_KEY = 'order_filter';

/**
 * Order status type
 * 
 * @description 订单状态类型定义
 * @enum
 */
export type OrderStatusType = 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED' | 'COMPLETED' | 'REFUNDED';

/**
 * Order filter
 * 
 * @description 订单筛选条件接口
 */
export interface OrderFilter {
  /** 订单状态 */
  orderStatus?: OrderStatusType;
  
  /** 支付状态 */
  payStatus?: string;
  
  /** 学生ID */
  studentId?: number;
  
  /** 开始日期 */
  startDate?: string;
  
  /** 结束日期 */
  endDate?: string;
}

/**
 * Order state management
 * 
 * @description 订单状态管理类，提供订单数据的增删改查操作
 * @class
 * @example
 * ```typescript
 * // 设置订单列表
 * OrderStore.setOrderList(orders);
 * 
 * // 获取订单列表
 * const orders = OrderStore.getOrderList();
 * 
 * // 更新单个订单
 * OrderStore.updateOrderInList(updatedOrder);
 * ```
 */
export class OrderStore {
  /**
   * Set order list
   * 
   * @description 设置订单列表到全局状态
   * @param {Order[]} orders - 订单列表数组
   * @returns {void}
   * @example
   * ```typescript
   * const orders = await OrderService.getOrders();
   * OrderStore.setOrderList(orders.data);
   * ```
   */
  static setOrderList(orders: Order[]): void {
    AppStorage.setOrCreate(ORDER_LIST_KEY, orders);
  }

  /**
   * Get order list
   * 
   * @description 从全局状态获取订单列表
   * @returns {Order[]} 订单列表数组，如果为空则返回空数组
   * @example
   * ```typescript
   * const orders = OrderStore.getOrderList();
   * console.log('订单数量:', orders.length);
   * ```
   */
  static getOrderList(): Order[] {
    return AppStorage.get<Order[]>(ORDER_LIST_KEY) ?? [];
  }

  /**
   * Set current order
   * 
   * @description 设置当前选中的订单（用于订单详情页）
   * @param {Order} order - 订单对象
   * @returns {void}
   * @example
   * ```typescript
   * OrderStore.setCurrentOrder(order);
   * router.pushUrl({ url: '/pages/parent/ParentOrderDetailPage' });
   * ```
   */
  static setCurrentOrder(order: Order): void {
    AppStorage.setOrCreate(CURRENT_ORDER_KEY, order);
  }

  /**
   * Get current order
   * 
   * @description 获取当前选中的订单
   * @returns {Order | null} 当前订单对象，如果未设置则返回 null
   * @example
   * ```typescript
   * const currentOrder = OrderStore.getCurrentOrder();
   * if (currentOrder) {
   *   console.log('当前订单:', currentOrder.orderNo);
   * }
   * ```
   */
  static getCurrentOrder(): Order | null {
    return AppStorage.get<Order>(CURRENT_ORDER_KEY) ?? null;
  }

  /**
   * Get current order ID
   * 
   * @description 获取当前订单的 ID（便捷方法）
   * @returns {number | null} 当前订单 ID，如果未设置则返回 null
   * @example
   * ```typescript
   * const orderId = OrderStore.getCurrentOrderId();
   * if (orderId) {
   *   await OrderService.getOrderDetail(orderId);
   * }
   * ```
   */
  static getCurrentOrderId(): number | null {
    const order = this.getCurrentOrder();
    return order?.id ?? null;
  }

  /**
   * Set order filter
   * 
   * @description 设置订单筛选条件（用于筛选持久化）
   * @param {OrderFilter} filter - 筛选条件对象
   * @returns {void}
   * @example
   * ```typescript
   * OrderStore.setOrderFilter({ orderStatus: 'PENDING' });
   * ```
   */
  static setOrderFilter(filter: OrderFilter): void {
    AppStorage.setOrCreate(ORDER_FILTER_KEY, filter);
  }

  /**
   * Get order filter
   * 
   * @description 获取当前的订单筛选条件
   * @returns {OrderFilter} 筛选条件对象，如果未设置则返回空对象
   * @example
   * ```typescript
   * const filter = OrderStore.getOrderFilter();
   * if (filter.orderStatus) {
   *   // 应用筛选条件
   * }
   * ```
   */
  static getOrderFilter(): OrderFilter {
    return AppStorage.get<OrderFilter>(ORDER_FILTER_KEY) ?? {};
  }

  /**
   * Update order in list
   * 
   * @description 更新订单列表中的指定订单（用于局部更新）
   * @param {Order} updatedOrder - 更新后的订单对象
   * @returns {void}
   * @example
   * ```typescript
   * const order = OrderStore.findOrderById(123);
   * order.orderStatus = 'APPROVED';
   * OrderStore.updateOrderInList(order);
   * ```
   */
  static updateOrderInList(updatedOrder: Order): void {
    const orders = this.getOrderList();
    const index = orders.findIndex(o => o.id === updatedOrder.id);
    if (index > -1) {
      orders[index] = updatedOrder;
      this.setOrderList(orders);
    }
  }

  /**
   * Find order by ID
   * 
   * @description 在订单列表中查找指定 ID 的订单
   * @param {number} orderId - 订单 ID
   * @returns {Order | null} 找到的订单对象，未找到则返回 null
   * @example
   * ```typescript
   * const order = OrderStore.findOrderById(123);
   * if (order) {
   *   console.log('找到订单:', order.orderNo);
   * }
   * ```
   */
  static findOrderById(orderId: number): Order | null {
    const orders = this.getOrderList();
    return orders.find(o => o.id === orderId) ?? null;
  }

  /**
   * Get orders by status
   * 
   * @description 按订单状态筛选订单列表
   * @param {OrderStatusType} status - 订单状态
   * @returns {Order[]} 符合状态的订单列表
   * @example
   * ```typescript
   * const pendingOrders = OrderStore.getOrdersByStatus('PENDING');
   * console.log('待审核订单:', pendingOrders.length);
   * ```
   */
  static getOrdersByStatus(status: OrderStatusType): Order[] {
    const orders = this.getOrderList();
    return orders.filter(o => o.orderStatus === status);
  }

  /**
   * Clear all order data
   * 
   * @description 清除所有订单相关数据（用于退出登录）
   * @returns {void}
   * @example
   * ```typescript
   * // 用户退出登录时调用
   * OrderStore.clearAll();
   * ```
   */
  static clearAll(): void {
    AppStorage.delete(ORDER_LIST_KEY);
    AppStorage.delete(CURRENT_ORDER_KEY);
    AppStorage.delete(ORDER_FILTER_KEY);
  }
}
