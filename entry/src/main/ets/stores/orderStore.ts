/**
 * SmartGuardian - Order Store
 * Order state management with reactive support
 * 
 * @description 订单状态管理 Store，负责订单数据的全局状态管理
 * @features
 * - 订单列表缓存管理
 * - 当前订单状态追踪
 * - 订单筛选条件维护
 * - 订单 CRUD 操作支持
 * - 响应式状态变更通知
 * - 持久化支持
 */

import { Order } from '../models/service';
import { ReactiveStore, StateChangeListener } from './core';

/**
 * Order store keys
 * 
 * @description AppStorage 存储键名常量
 */
const ORDER_LIST_KEY = 'order_list';
const CURRENT_ORDER_KEY = 'current_order';
const ORDER_FILTER_KEY = 'order_filter';
const PENDING_COUNT_KEY = 'pending_order_count';

/**
 * Order status type
 * 
 * @description 订单状态类型定义
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
 * Order state management with reactive support
 * 
 * @description 订单状态管理类，提供订单数据的增删改查操作
 * @class
 * @example
 * ```typescript
 * // 设置订单列表
 * OrderStore.setOrderList(orders);
 * 
 * // 监听订单列表变更
 * OrderStore.onOrderListChange((event) => {
 *   console.log('订单列表已更新');
 * });
 * 
 * // 更新单个订单
 * OrderStore.updateOrderInList(updatedOrder);
 * ```
 */
export class OrderStore extends ReactiveStore {
  // 初始化 Store 配置
  static {
    this.initOptions({
      name: 'OrderStore',
      persistent: false
    });
  }
  
  /**
   * Set order list
   * 
   * @description 设置订单列表到全局状态
   * @param {Order[]} orders - 订单列表数组
   */
  static setOrderList(orders: Order[]): void {
    this.setValue(ORDER_LIST_KEY, orders);
    // 自动更新待处理数量
    const pendingCount = orders.filter(o => o.orderStatus === 'PENDING').length;
    this.setPendingCount(pendingCount);
  }
  
  /**
   * Get order list
   * 
   * @description 从全局状态获取订单列表
   * @returns {Order[]} 订单列表数组，如果为空则返回空数组
   */
  static getOrderList(): Order[] {
    return this.getValue<Order[]>(ORDER_LIST_KEY) ?? [];
  }
  
  /**
   * Set current order
   * 
   * @description 设置当前选中的订单（用于订单详情页）
   * @param {Order} order - 订单对象
   */
  static setCurrentOrder(order: Order): void {
    this.setValue(CURRENT_ORDER_KEY, order);
  }
  
  /**
   * Get current order
   * 
   * @description 获取当前选中的订单
   * @returns {Order | null} 当前订单对象，如果未设置则返回 null
   */
  static getCurrentOrder(): Order | null {
    return this.getValue<Order>(CURRENT_ORDER_KEY) ?? null;
  }
  
  /**
   * Get current order ID
   * 
   * @description 获取当前订单的 ID（便捷方法）
   * @returns {number | null} 当前订单 ID，如果未设置则返回 null
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
   */
  static setOrderFilter(filter: OrderFilter): void {
    this.setValue(ORDER_FILTER_KEY, filter);
  }
  
  /**
   * Get order filter
   * 
   * @description 获取当前的订单筛选条件
   * @returns {OrderFilter} 筛选条件对象，如果未设置则返回空对象
   */
  static getOrderFilter(): OrderFilter {
    return this.getValue<OrderFilter>(ORDER_FILTER_KEY) ?? {};
  }
  
  /**
   * Set pending count
   * 
   * @description 设置待处理订单数量（持久化）
   * @param {number} count - 数量
   */
  static setPendingCount(count: number): void {
    this.setValue(PENDING_COUNT_KEY, count, { persist: true });
  }
  
  /**
   * Get pending count
   * 
   * @description 获取待处理订单数量
   * @returns {number} 待处理数量
   */
  static getPendingCount(): number {
    return this.getValue<number>(PENDING_COUNT_KEY) ?? 0;
  }
  
  /**
   * Update order in list
   * 
   * @description 更新订单列表中的指定订单（用于局部更新）
   * @param {Order} updatedOrder - 更新后的订单对象
   */
  static updateOrderInList(updatedOrder: Order): void {
    const orders = this.getOrderList();
    const index = orders.findIndex(o => o.id === updatedOrder.id);
    if (index > -1) {
      orders[index] = updatedOrder;
      this.setOrderList([...orders]);
    }
  }
  
  /**
   * Add order to list
   * 
   * @description 添加新订单到列表
   * @param {Order} order - 新订单对象
   */
  static addOrder(order: Order): void {
    const orders = this.getOrderList();
    this.setOrderList([order, ...orders]);
  }
  
  /**
   * Remove order from list
   * 
   * @description 从列表中移除订单
   * @param {number} orderId - 订单 ID
   */
  static removeOrder(orderId: number): void {
    const orders = this.getOrderList();
    this.setOrderList(orders.filter(o => o.id !== orderId));
  }
  
  /**
   * Find order by ID
   * 
   * @description 根据 ID 查找订单
   * @param {number} orderId - 订单 ID
   * @returns {Order | undefined} 找到的订单
   */
  static findOrderById(orderId: number): Order | undefined {
    return this.getOrderList().find(o => o.id === orderId);
  }
  
  /**
   * Get orders by status
   * 
   * @description 按状态获取订单列表
   * @param {OrderStatusType} status - 订单状态
   * @returns {Order[]} 筛选后的订单列表
   */
  static getOrdersByStatus(status: OrderStatusType): Order[] {
    return this.getOrderList().filter(o => o.orderStatus === status);
  }
  
  /**
   * Clear order list
   * 
   * @description 清空订单列表
   */
  static clearOrderList(): void {
    this.setOrderList([]);
  }
  
  /**
   * Clear current order
   * 
   * @description 清除当前选中订单
   */
  static clearCurrentOrder(): void {
    this.deleteValue(CURRENT_ORDER_KEY);
  }
  
  // ============ 响应式订阅方法 ============
  
  /**
   * Subscribe to order list changes
   * 
   * @description 订阅订单列表变更
   * @param {StateChangeListener<Order[]>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onOrderListChange(listener: StateChangeListener<Order[]>): () => void {
    return this.subscribe<Order[]>(ORDER_LIST_KEY, listener);
  }
  
  /**
   * Subscribe to current order changes
   * 
   * @description 订阅当前订单变更
   * @param {StateChangeListener<Order>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onCurrentOrderChange(listener: StateChangeListener<Order>): () => void {
    return this.subscribe<Order>(CURRENT_ORDER_KEY, listener);
  }
  
  /**
   * Subscribe to pending count changes
   * 
   * @description 订阅待处理数量变更
   * @param {StateChangeListener<number>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onPendingCountChange(listener: StateChangeListener<number>): () => void {
    return this.subscribe<number>(PENDING_COUNT_KEY, listener);
  }
  
  /**
   * Subscribe to order filter changes
   * 
   * @description 订阅订单筛选条件变更
   * @param {StateChangeListener<OrderFilter>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onOrderFilterChange(listener: StateChangeListener<OrderFilter>): () => void {
    return this.subscribe<OrderFilter>(ORDER_FILTER_KEY, listener);
  }
}
