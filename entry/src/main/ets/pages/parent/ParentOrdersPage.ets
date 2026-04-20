/**
 * SmartGuardian - Parent Orders Page
 * Parent can view and manage their orders
 * 
 * @optimized Using OrderStore for state management
 * @migrated 2026-04-20 - P2 Migration with Common Components
 */

import router from '@ohos.router';
import { OrderService } from '../../services/api/service';
import { Order } from '../../models/service';
import { OrderStore } from '../../stores/orderStore';
import { LogUtil } from '../../utils/LogUtil';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { OrderQueryParams } from '../../models/common';
// Common Components
import { SimplePageHeader, TabBar, EmptyState, LoadingState, EmptyType, LoadingSize, OrderListItem, OrderItemMode } from '../../components/common';
import { StatusBadge, OrderBadge } from '../../components/StatusBadge';
import { StatusType, StatusMappingHelper } from '../../constants/StatusMapping';

@Component
export struct ParentOrdersPage {
  @StorageLink('order_list') orders: Order[] = [];

  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State errorMessage: string = '';
  @State payingOrderId: number = 0;

  private lastLoadTime: number = 0;
  private readonly CACHE_DURATION: number = 5 * 60 * 1000;

  private tabs: string[] = ['全部', '待审核', '进行中', '已完成'];

  aboutToAppear() {
    this.loadOrdersWithCache();
  }

  async loadOrdersWithCache() {
    const cachedOrders = OrderStore.getOrderList();
    if (cachedOrders.length > 0) {
      this.orders = cachedOrders;
      LogUtil.info('ParentOrdersPage', `Using cached orders: ${cachedOrders.length} items`);
    }

    const now = Date.now();
    const shouldRefresh = (now - this.lastLoadTime) > this.CACHE_DURATION;

    if (shouldRefresh || cachedOrders.length === 0) {
      await this.loadOrders();
    }
  }

  async loadOrders() {
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      // 使用统一的查询参数类型
      const params: OrderQueryParams = {
        pageNum: 1,
        pageSize: 20
      };

      // 根据Tab设置状态过滤
      if (this.currentTab === 1) {
        params.orderStatus = 'PENDING';
      } else if (this.currentTab === 2) {
        params.orderStatus = 'APPROVED';
      } else if (this.currentTab === 3) {
        params.orderStatus = 'COMPLETED';
      }

      const resp = await OrderService.getOrders(params);

      if (resp.code === 0 && resp.data) {
        const rawOrders = Array.isArray(resp.data) ? resp.data : [];
        OrderStore.setOrderList(rawOrders);
        this.orders = rawOrders;
        this.lastLoadTime = Date.now();
        LogUtil.info('ParentOrdersPage', `Loaded and cached ${this.orders.length} orders`);
      }
    } catch (error) {
      this.errorMessage = ErrorMessages.ORDER_LOAD_FAILED;
      LogUtil.error('ParentOrdersPage', `Load failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  getDisplayAmount(order: Order): number {
    if (order.actualAmount !== undefined) {
      return order.actualAmount;
    }
    if (order.totalAmount !== undefined) {
      return order.totalAmount - (order.discountAmount || 0);
    }
    return order.amount || 0;
  }

  canPay(order: Order): boolean {
    return order.orderStatus === 'APPROVED' && order.payStatus === 'UNPAID';
  }

  async handlePayOrder(order: Order) {
    this.payingOrderId = order.id;
    try {
      router.pushUrl({
        url: 'pages/parent/ParentPaymentPage',
        params: {
          orderId: order.id,
          orderNo: order.orderNo,
          amount: this.getDisplayAmount(order)
        }
      });
    } catch (error) {
      LogUtil.error('ParentOrdersPage', `Navigate to payment failed: ${JSON.stringify(error)}`);
    } finally {
      this.payingOrderId = 0;
    }
  }

  openOrderDetail(order: Order) {
    OrderStore.setCurrentOrder(order);
    router.pushUrl({
      url: 'pages/parent/ParentOrderDetailPage',
      params: {
        orderId: order.id,
        orderNo: order.orderNo
      }
    });
  }

  build() {
    Column() {
      // 使用通用PageHeader
      SimplePageHeader({ title: '我的订单' })

      // 使用通用TabBar
      TabBar({
        tabs: this.tabs,
        currentIndex: $currentTab,
        onTabChange: () => {
          this.loadOrders();
        }
      })

      // 内容区域
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildContent() {
    if (this.isLoading && this.orders.length === 0) {
      // 使用通用LoadingState
      LoadingState({ 
        loadingSize: LoadingSize.LARGE,
        fullscreen: false 
      })
    } else if (this.orders.length === 0) {
      // 使用通用EmptyState
      EmptyState({ 
        type: EmptyType.NO_ORDER,
        actionText: '刷新',
        onAction: () => { this.loadOrders(); }
      })
    } else {
      this.buildOrderList()
    }
  }

  @Builder
  buildOrderList() {
    Scroll() {
      Column() {
        ForEach(this.orders, (order: Order) => {
          Column() {
            // 订单卡片
            OrderListItem({
              order: order,
              mode: OrderItemMode.SIMPLE,
              onItemClick: () => {
                this.openOrderDetail(order);
              }
            })

            // 立即支付按钮（仅针对已审核未支付的订单）
            if (this.canPay(order)) {
              Button('立即支付')
                .width('100%')
                .height(44)
                .fontSize(16)
                .fontColor(Color.White)
                .backgroundColor($r('app.color.primary'))
                .borderRadius(22)
                .margin({ top: 12 })
                .enabled(this.payingOrderId !== order.id)
                .onClick(() => {
                  this.handlePayOrder(order);
                })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12 })
        })
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}