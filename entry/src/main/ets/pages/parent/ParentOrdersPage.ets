/**
 * SmartGuardian - Parent Orders Page
 * Parent can view and manage their orders
 *
 * @optimized Using OrderStore for state management
 * @migrated 2026-04-20 - P2 Migration with Common Components
 */

import { OrderService } from '../../services/api/service';
import { Order } from '../../models/service';
import { OrderStore } from '../../stores/orderStore';
import { LogUtil } from '../../utils/LogUtil';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { OrderQueryParams } from '../../models/common';
import {
  PageHeader,
  HeaderTheme,
  TabBar,
  EmptyState,
  LoadingState,
  EmptyType,
  LoadingSize,
  OrderListItem,
  OrderItemMode,
  SectionHeader,
  Card,
  StatCard
} from '../../components/common';
import { RouteUrls } from '../../constants/app.constants';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';
import { HarmonyColor, HarmonyReport, harmonyShadowColor } from '../../common/HarmonyDesign';

@Entry
@Component
struct ParentOrdersPage {
  build() {
    Stack() {
      ParentOrdersPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentOrdersPageContent {
  @StorageLink('order_list') orders: Order[] = [];

  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State errorMessage: string = '';
  @State payingOrderId: number = 0;

  private lastLoadTime: number = 0;
  private readonly CACHE_DURATION: number = 5 * 60 * 1000;
  private tabs: string[] = ['全部', '待审核', '进行中', '已完成'];
  private orderDataSource: LazyArrayDataSource<Order> = new LazyArrayDataSource<Order>();

  aboutToAppear() {
    this.loadOrdersWithCache();
  }

  async loadOrdersWithCache() {
    const cachedOrders = OrderStore.getOrderList();
    if (cachedOrders.length > 0) {
      this.orders = cachedOrders;
      this.orderDataSource.setItems(cachedOrders);
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
      const params: OrderQueryParams = {
        pageNum: 1,
        pageSize: 20
      };

      if (this.currentTab === 1) {
        params.orderStatus = 'PENDING';
      } else if (this.currentTab === 2) {
        params.orderStatus = 'APPROVED';
      } else if (this.currentTab === 3) {
        params.orderStatus = 'COMPLETED';
      }

      const resp = await OrderService.getOrders(params);

      if (resp.code === 0 && resp.data) {
        const rawOrders = resp.data.list ?? [];
        OrderStore.setOrderList(rawOrders);
        this.orders = rawOrders;
        this.orderDataSource.setItems(rawOrders);
        this.lastLoadTime = Date.now();
        LogUtil.info('ParentOrdersPage', `Loaded and cached ${this.orders.length} orders`);
      } else {
        this.orders = [];
        this.orderDataSource.clear();
        this.errorMessage = resp.message || ErrorMessages.ORDER_LOAD_FAILED;
      }
    } catch (error) {
      this.errorMessage = ErrorMessages.ORDER_LOAD_FAILED;
      this.orders = [];
      this.orderDataSource.clear();
      LogUtil.error('ParentOrdersPage', 'Load orders failed');
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

  getPendingCount(): number {
    return this.orders.filter((order: Order) => order.orderStatus === 'PENDING').length;
  }

  getPayableCount(): number {
    return this.orders.filter((order: Order) => this.canPay(order)).length;
  }

  getCompletedCount(): number {
    return this.orders.filter((order: Order) => order.orderStatus === 'COMPLETED').length;
  }

  async handlePayOrder(order: Order) {
    this.payingOrderId = order.id;
    try {
      OrderStore.setCurrentOrder(order);
      this.getUIContext().getRouter().pushUrl({
        url: RouteUrls.PARENT_PAYMENT,
        params: {
          orderId: order.id
        }
      });
    } catch (error) {
      LogUtil.error('ParentOrdersPage', 'Navigate to payment failed');
    } finally {
      this.payingOrderId = 0;
    }
  }

  openOrderDetail(order: Order) {
    OrderStore.setCurrentOrder(order);
    try {
      this.getUIContext().getRouter().pushUrl({
        url: RouteUrls.PARENT_ORDER_DETAIL,
        params: {
          orderId: order.id,
          orderNo: order.orderNo
        }
      });
    } catch (error) {
      LogUtil.error('ParentOrdersPage', 'Open order detail failed');
    }
  }

  build() {
    Column() {
      PageHeader({
        title: '我的订单',
        subtitle: '集中管理报名、支付与托管服务进度',
        theme: HeaderTheme.WHITE
      })

      this.buildOverviewPanel()
      this.buildTabSection()
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildOverviewPanel() {
    Row() {
      StatCard({
        value: `${this.orders.length}`,
        label: '当前列表',
        icon: $r('app.media.ic_order'),
        iconColor: HarmonyReport.accent
      })
      .layoutWeight(1)

      Blank().width(12)

      StatCard({
        value: `${this.getPendingCount()}`,
        label: '待审核',
        icon: $r('app.media.ic_warning'),
        iconColor: HarmonyReport.caution
      })
      .layoutWeight(1)

      Blank().width(12)

      StatCard({
        value: `${this.getPayableCount()}`,
        label: '待支付',
        icon: $r('app.media.ic_money'),
        iconColor: HarmonyReport.positive
      })
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
  }

  @Builder
  buildTabSection() {
    Card({
      title: '订单筛选',
      subtitle: '按状态切换当前工作视图',
      customPadding: 12,
      content: () => { this.buildTabSectionContent() }
    })
    .margin({ left: 16, right: 16, top: 14, bottom: 12 })
  }

  @Builder
  buildTabSectionContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadOrders();
      }
    })
  }

  @Builder
  buildContent() {
    if (this.isLoading && this.orders.length === 0) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false,
        message: '正在加载订单...'
      })
    } else if (this.orders.length === 0) {
      EmptyState({
        type: EmptyType.NO_ORDER,
        customDescription: this.errorMessage || '当前筛选条件下暂无订单记录',
        actionText: '刷新',
        onAction: () => {
          this.loadOrders();
        }
      })
    } else {
      this.buildOrderList()
    }
  }

  @Builder
  buildOrderList() {
    Column() {
      SectionHeader({
        title: '订单列表',
        subtitle: '支持查看详情与处理待支付订单'
      })
      .margin({ left: 16, right: 16 })

      List({ space: 12 }) {
        LazyForEach(this.orderDataSource, (order: Order) => {
          ListItem() {
            Column() {
              OrderListItem({
                order: order,
                mode: OrderItemMode.SIMPLE,
                onItemClick: () => {
                  this.openOrderDetail(order);
                }
              })

              if (this.canPay(order)) {
                Button(this.payingOrderId === order.id ? '处理中...' : '立即支付')
                  .width('100%')
                  .height(46)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(HarmonyColor.textInverse)
                  .backgroundColor($r('app.color.primary'))
                  .borderRadius(14)
                  .margin({ top: 10 })
                  .enabled(this.payingOrderId !== order.id)
                  .opacity(this.payingOrderId === order.id ? 0.75 : 1)
                  .onClick(() => {
                    this.handlePayOrder(order);
                  })
              }
            }
            .width('100%')
            .padding(18)
            .backgroundColor(HarmonyColor.surface)
            .borderRadius(20)
            .shadow({
              radius: 12,
              color: harmonyShadowColor(),
              offsetX: 0,
              offsetY: 4
            })
          }
        }, (order: Order) => `${order.id}`)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 20 })
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
      .cachedCount(6)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

