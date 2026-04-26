/**
 * SmartGuardian - Admin Orders Page
 * Admin can review and audit orders
 * 
 * @migrated 2026-04-20 - P2 Migration with Common Components
 */

import { OrderService } from '../../services/api/service';
import { Order, OrderAuditRequest } from '../../models/service';
import { DataMaskUtil } from '../../utils/DataMaskUtil';
import { LogUtil } from '../../utils/LogUtil';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { OrderQueryParams } from '../../models/common';
// Common Components
import {
  AdminOrderAuditSheet,
  AdminOrdersControlCard,
  AdminOrdersOverviewCard,
  AdminOrdersSummaryCard,
  EmptyState,
  EmptyType,
  ErrorBanner,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState,
  OrderItemMode,
  OrderListItem,
  PageHeader,
  SectionHeader,
  TabBar
} from '../../components/common';
import { OrderBadge } from '../../components/StatusBadge';
import { StatusMappingHelper } from '../../constants/StatusMapping';
import { HarmonyColor } from '../../common/HarmonyDesign';

@Entry
@Component
struct AdminOrdersPage {
  build() {
    Stack() {
      AdminOrdersPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AdminOrdersPageContent {
  @State orders: Order[] = [];
  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State selectedOrder: Order | null = null;
  @State showAuditDialog: boolean = false;
  @State auditRemark: string = '';
  @State errorMessage: string = '';

  private tabs: string[] = ['待审核', '已审核', '全部订单'];

  aboutToAppear() {
    this.loadOrders();
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
      if (this.currentTab === 0) {
        params.orderStatus = 'PENDING';
      } else if (this.currentTab === 1) {
        params.orderStatus = 'APPROVED';
      }

      const resp = await OrderService.getOrders(params);

      if (resp.code === 0 && resp.data) {
        const rawOrders = resp.data.list ?? [];
        // 数据脱敏处理
        this.orders = rawOrders.map((order: Order) => this.maskOrder(order));
        LogUtil.info('AdminOrdersPage', `Loaded ${this.orders.length} orders`);
      } else {
        this.orders = [];
        this.errorMessage = resp.message || ErrorMessages.ORDER_LOAD_FAILED;
      }
    } catch (error) {
      this.errorMessage = ErrorMessages.ORDER_LOAD_FAILED;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 订单数据脱敏
   */
  private maskOrder(order: Order): Order {
    return {
      id: order.id,
      orderNo: order.orderNo,
      studentId: order.studentId,
      studentName: DataMaskUtil.maskName(order.studentName || ''),
      serviceProductId: order.serviceProductId,
      serviceProductName: order.serviceProductName,
      startDate: order.startDate,
      endDate: order.endDate,
      actualAmount: order.actualAmount,
      orderStatus: order.orderStatus,
      payStatus: order.payStatus,
      discountAmount: order.discountAmount,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      amount: order.amount,
      paidAmount: order.paidAmount,
      totalAmount: order.totalAmount,
      auditStatus: order.auditStatus,
      auditRemark: order.auditRemark,
      guardianUserId: order.guardianUserId,
      guardianName: order.guardianName,
      auditTime: order.auditTime
    };
  }

  async handleAudit(auditStatus: 'APPROVED' | 'REJECTED') {
    if (!this.selectedOrder) {
      return;
    }

    try {
      const request: OrderAuditRequest = {
        auditStatus,
        auditRemark: this.auditRemark
      };

      const resp = await OrderService.auditOrder(this.selectedOrder.id, request);
      if (resp.code === 0) {
        this.closeAuditDialog();
        this.loadOrders();
      } else {
        this.errorMessage = resp.message || ErrorMessages.ORDER_AUDIT_FAILED;
      }
    } catch (error) {
      this.errorMessage = ErrorMessages.ORDER_AUDIT_FAILED;
    }
  }

  openRejectDialog(order: Order): void {
    this.selectedOrder = order;
    this.auditRemark = '';
    this.showAuditDialog = true;
    this.errorMessage = '';
  }

  closeAuditDialog(): void {
    this.showAuditDialog = false;
    this.selectedOrder = null;
    this.auditRemark = '';
  }

  build() {
    Column() {
      PageHeader({
        title: '订单管理',
        subtitle: '统一审核家长端订单、查看状态和处理异常申请。',
        theme: HeaderTheme.PRIMARY,
        rightContent: this.buildHeaderAction
      })

      Column() {
        this.buildOverviewPanel()
        this.buildTabSection()

        if (this.errorMessage) {
          ErrorBanner({
            message: this.errorMessage,
            onDismiss: () => {
              this.errorMessage = '';
            }
          })
        }

        this.buildContent()
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showAuditDialog, this.buildAuditDialog(), {
      height: 360,
      backgroundColor: HarmonyColor.surface,
      dragBar: true
    })
  }

  @Builder
  buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: HarmonyColor.textInverse,
      boxBgColor: HarmonyColor.overlayInverseSoft,
      boxBorderColor: HarmonyColor.overlayInverseBorder,
      onButtonClick: (): void => {
        this.loadOrders();
      }
    })
  }

  @Builder
  buildOverviewPanel() {
    AdminOrdersOverviewCard({
      title: this.getCurrentModeTitle(),
      subtitle: this.getCurrentModeHint(),
      accent: this.getCurrentModeAccent(),
      totalAmountText: this.getAmountTotalText(),
      pendingCount: this.getPendingAuditCount(),
      approvedCount: this.getApprovedCount(),
      visibleCount: this.getVisibleOrderCount(),
      averageAmount: this.getAverageAmount()
    })
      .margin({ bottom: 12 })
  }

  @Builder
  buildTabSection() {
    AdminOrdersControlCard({
      tabs: this.tabs,
      currentTab: this.currentTab,
      title: this.getCurrentModeTitle(),
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadOrders();
      }
    })
  }

  @Builder
  buildContent() {
    if (this.isLoading) {
      LoadingState({ 
        loadingSize: LoadingSize.LARGE,
        fullscreen: false 
      })
    } else if (!this.orders || this.orders.length === 0) {
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
    Column() {
      SectionHeader({
        title: '订单列表',
        subtitle: `当前共 ${this.orders.length} 条订单记录`
      })

      AdminOrdersSummaryCard({
        modeLabel: this.tabs[this.currentTab],
        orderCount: this.orders.length,
        totalAmountText: this.getAmountTotalText()
      })

      List({ space: 12 }) {
        ForEach(this.orders, (order: Order) => {
          ListItem() {
            this.buildOrderListItem(order)
          }
        }, (order: Order) => `${order.id}`)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: 12, bottom: 12 })
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
      .cachedCount(6)
    }
    .width('100%')
  }

  @Builder
  private buildOrderListItem(order: Order) {
    OrderListItem({
      order: order,
      mode: OrderItemMode.DETAIL,
      onItemClick: () => {},
      onApprove: () => {
        this.selectedOrder = order;
        this.auditRemark = '审核通过';
        this.handleAudit('APPROVED');
      },
      onReject: () => {
        this.openRejectDialog(order);
      }
    })
  }

  @Builder
  buildMiniMetric(label: string, value: string, valueColor: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(valueColor)
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildAuditDialog() {
    AdminOrderAuditSheet({
      selectedOrder: this.selectedOrder,
      auditRemark: this.auditRemark,
      onRemarkChange: (value: string) => {
        this.auditRemark = value;
      },
      onCancel: () => {
        this.closeAuditDialog();
      },
      onConfirmReject: () => {
        this.handleAudit('REJECTED');
      }
    })
  }

  private getVisibleOrderCount(): number {
    return this.orders.length;
  }

  private getPendingAuditCount(): number {
    return this.orders.filter((order: Order) => order.orderStatus === 'PENDING').length;
  }

  private getApprovedCount(): number {
    return this.orders.filter((order: Order) => order.orderStatus === 'APPROVED').length;
  }

  private getCurrentModeTitle(): string {
    if (this.currentTab === 0) {
      return '待审核工作台';
    }
    if (this.currentTab === 1) {
      return '已审核追踪';
    }
    return '全量订单看板';
  }

  private getCurrentModeHint(): string {
    if (this.currentTab === 0) {
      return '聚焦当前需要尽快处理的家长订单申请';
    }
    if (this.currentTab === 1) {
      return '查看已完成审核的记录与处理结果';
    }
    return '从全局视角检视订单流转与审核效率';
  }

  private getCurrentModeAccent(): string {
    if (this.currentTab === 0) {
      return '高优先级';
    }
    if (this.currentTab === 1) {
      return '可回溯';
    }
    return '运营总览';
  }

  private getOrderAmountTotal(): number {
    return this.orders.reduce((sum: number, order: Order) => {
      return sum + Number(order.actualAmount ?? order.totalAmount ?? order.amount ?? 0);
    }, 0);
  }

  private getAverageAmount(): string {
    if (this.orders.length === 0) {
      return '¥0';
    }
    const average = Math.round(this.getOrderAmountTotal() / this.orders.length);
    return `¥${average}`;
  }

  private getAmountTotalText(): string {
    return `¥${this.getOrderAmountTotal()}`;
  }
}

