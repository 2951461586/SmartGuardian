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
import { SimplePageHeader, TabBar, EmptyState, LoadingState, ErrorBanner, EmptyType, LoadingSize, OrderListItem, OrderItemMode } from '../../components/common';
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
        const rawOrders = Array.isArray(resp.data) ? resp.data : [];
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
      // 使用通用PageHeader
      SimplePageHeader({ title: '订单管理' })

      // 使用通用TabBar
      TabBar({
        tabs: this.tabs,
        currentIndex: $currentTab,
        onTabChange: () => {
          this.loadOrders();
        }
      })

      // 错误提示
      if (this.errorMessage) {
        ErrorBanner({
          message: this.errorMessage,
          onDismiss: () => {
            this.errorMessage = '';
          }
        })
      }

      // 内容区域
      this.buildContent()
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
  buildContent() {
    if (this.isLoading) {
      LoadingState({ 
        loadingSize: LoadingSize.LARGE,
        fullscreen: false 
      })
    } else if (this.orders.length === 0) {
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
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
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
          .enabled(this.auditRemark.trim().length > 0)
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
}
