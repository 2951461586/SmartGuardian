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
  Card,
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
  StatCard,
  TabBar
} from '../../components/common';
import { OrderBadge } from '../../components/StatusBadge';
import { StatusMappingHelper } from '../../constants/StatusMapping';

@Component
export struct AdminOrdersPage {
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

      Scroll() {
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
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showAuditDialog, this.buildAuditDialog(), {
      height: 360,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: Color.White,
      boxBgColor: '#FFFFFF1F',
      boxBorderColor: '#FFFFFF29',
      onButtonClick: (): void => {
        this.loadOrders();
      }
    })
  }

  @Builder
  buildOverviewPanel() {
    Column() {
      Card({
        title: this.getCurrentModeTitle(),
        subtitle: this.getCurrentModeHint(),
        customPadding: 18,
        content: this.buildOverviewHeroContent
      })

      Row() {
        StatCard({
          value: this.getVisibleOrderCount(),
          label: '当前列表',
          icon: $r('app.media.ic_order'),
          iconColor: '#1F5EFF'
        })
        .layoutWeight(1)

        StatCard({
          value: this.getPendingAuditCount(),
          label: '待审核',
          icon: $r('app.media.ic_warning'),
          iconColor: '#D97706'
        })
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        StatCard({
          value: this.getApprovedCount(),
          label: '已审核',
          icon: $r('app.media.ic_success'),
          iconColor: '#15803D'
        })
        .layoutWeight(1)

        StatCard({
          value: this.getAverageAmount(),
          label: '平均金额',
          icon: $r('app.media.ic_money'),
          iconColor: '#8B5CF6'
        })
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ top: 12 })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  buildOverviewHeroContent() {
    Row() {
      Column() {
        Text(this.getCurrentModeAccent())
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#EAF2FF')
          .borderRadius(999)

        Text(this.getAmountTotalText())
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 14 })

        Text('当前筛选范围内的订单金额总量')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        this.buildMiniMetric('待处理', `${this.getPendingAuditCount()}`, '#D97706')
        this.buildMiniMetric('已完成', `${this.getApprovedCount()}`, '#15803D')
      }
      .width(112)
    }
    .width('100%')
  }

  @Builder
  buildTabSection() {
    Column() {
      SectionHeader({
        title: '审核控制台',
        subtitle: '先锁定审核范围，再进入订单流逐条处理'
      })

      Card({
        customPadding: 12,
        content: this.buildTabSectionContent
      })
    }
  }

  @Builder
  buildTabSectionContent() {
    Column() {
      Row() {
        Text(this.getCurrentModeTitle())
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Blank().layoutWeight(1)

        Text('实时同步')
          .fontSize(11)
          .fontColor('#2F9B52')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#ECFDF5')
          .borderRadius(999)
      }
      .width('100%')
      .margin({ bottom: 12 })

      TabBar({
        tabs: this.tabs,
        currentIndex: this.currentTab,
        onTabChange: (index: number) => {
          this.currentTab = index;
          this.loadOrders();
        }
      })
    }
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

      Card({
        customPadding: 14,
        customBgColor: '#F8FBFF',
        content: this.buildStreamSummary
      })

      Scroll() {
        Column() {
          ForEach(this.orders, (order: Order) => {
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
          })
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }

  @Builder
  buildStreamSummary() {
    Row() {
      this.buildMiniMetric('模式', this.tabs[this.currentTab], '#1F5EFF')
      Blank().width(10)
      this.buildMiniMetric('订单量', `${this.orders.length}`, '#10203A')
      Blank().width(10)
      this.buildMiniMetric('总金额', this.getAmountTotalText(), '#15803D')
    }
    .width('100%')
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
    .backgroundColor(Color.White)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildAuditDialog() {
    Column() {
      Text('拒绝订单')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8, bottom: 16 })

      if (this.selectedOrder) {
        Column() {
          Text(`订单号：${this.selectedOrder.orderNo}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .width('100%')

          Text(`学生：${this.selectedOrder.studentName || '-'}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .margin({ top: 8 })
        }
        .width('100%')
      }

      TextArea({
        placeholder: '请输入拒绝原因',
        text: this.auditRemark
      })
        .width('100%')
        .height(120)
        .fontSize($r('app.float.text_primary_size'))
        .backgroundColor($r('app.color.page_background'))
        .borderRadius($r('app.float.button_radius'))
        .margin({ top: 16 })
        .onChange((value: string) => {
          this.auditRemark = value;
        })

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .onClick(() => {
            this.closeAuditDialog();
          })

        Button('确认拒绝')
          .layoutWeight(1)
          .height(44)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(Color.White)
          .backgroundColor('#F44336')
          .borderRadius(22)
          .margin({ left: 12 })
          .enabled(this.auditRemark?.trim().length > 0)
          .onClick(() => {
            this.handleAudit('REJECTED');
          })
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .padding(20)
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
