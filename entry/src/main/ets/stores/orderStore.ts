/**
 * SmartGuardian - Order Store
 * Order state management
 */

import { Order, OrderStatus } from '../models/service';

/**
 * Order store keys
 */
const ORDER_LIST_KEY = 'order_list';
const CURRENT_ORDER_KEY = 'current_order';
const ORDER_FILTER_KEY = 'order_filter';

/**
 * Order filter
 */
export interface OrderFilter {
  orderStatus?: OrderStatus;
  payStatus?: string;
  studentId?: number;
  startDate?: string;
  endDate?: string;
}

/**
 * Order state management
 */
export class OrderStore {
  /**
   * Set order list
   */
  static setOrderList(orders: Order[]): void {
    AppStorage.setOrCreate(ORDER_LIST_KEY, orders);
  }

  /**
   * Get order list
   */
  static getOrderList(): Order[] {
    return AppStorage.get<Order[]>(ORDER_LIST_KEY) ?? [];
  }

  /**
   * Set current order
   */
  static setCurrentOrder(order: Order): void {
    AppStorage.setOrCreate(CURRENT_ORDER_KEY, order);
  }

  /**
   * Get current order
   */
  static getCurrentOrder(): Order | null {
    return AppStorage.get<Order>(CURRENT_ORDER_KEY) ?? null;
  }

  /**
   * Get current order ID
   */
  static getCurrentOrderId(): number | null {
    const order = this.getCurrentOrder();
    return order?.id ?? null;
  }

  /**
   * Set order filter
   */
  static setOrderFilter(filter: OrderFilter): void {
    AppStorage.setOrCreate(ORDER_FILTER_KEY, filter);
  }

  /**
   * Get order filter
   */
  static getOrderFilter(): OrderFilter {
    return AppStorage.get<OrderFilter>(ORDER_FILTER_KEY) ?? {};
  }

  /**
   * Update order in list
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
   */
  static findOrderById(orderId: number): Order | null {
    const orders = this.getOrderList();
    return orders.find(o => o.id === orderId) ?? null;
  }

  /**
   * Get orders by status
   */
  static getOrdersByStatus(status: OrderStatus): Order[] {
    const orders = this.getOrderList();
    return orders.filter(o => o.orderStatus === status);
  }

  /**
   * Clear all order data
   */
  static clearAll(): void {
    AppStorage.delete(ORDER_LIST_KEY);
    AppStorage.delete(CURRENT_ORDER_KEY);
    AppStorage.delete(ORDER_FILTER_KEY);
  }
}
