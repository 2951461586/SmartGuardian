/**
 * SmartGuardian - Admin Orders Page
 * Admin can review and audit orders
 */

import { OrderService } from '../../services/api/service';
import { Order, OrderAuditRequest } from '../../models/service';

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
    try {
      let orderStatus: string | undefined;
      if (this.currentTab === 0) orderStatus = 'PENDING';
      else if (this.currentTab === 1) orderStatus = 'APPROVED';

      const resp = await OrderService.getOrders({
        pageNum: 1,
        pageSize: 20,
        orderStatus
      });

      if (resp.code === 0 && resp.data) {
        this.orders = resp.data.list;
      }
    } catch (error) {
      this.errorMessage = '加载订单失败';
    } finally {
      this.isLoading = false;
    }
  }

  async handleAudit(auditStatus: 'APPROVED' | 'REJECTED') {
    if (!this.selectedOrder) return;

    try {
      const request: OrderAuditRequest = {
        auditStatus,
        auditRemark: this.auditRemark
      };

      await OrderService.auditOrder(this.selectedOrder.id, request);
      this.showAuditDialog = false;
      this.selectedOrder = null;
      this.auditRemark = '';
      this.loadOrders();
    } catch (error) {
      this.errorMessage = '审核失败';
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Tab bar
      this.buildTabBar()

      // Order list
      this.buildOrderList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Text('订单管理')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: Number($r('app.float.status_bar_height')) + 20, bottom: 20 })
    .backgroundColor($r('app.color.primary'))
  }

  @Builder
  buildTabBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize($r('app.float.text_primary_size'))
            .fontColor(this.currentTab === index ? $r('app.color.primary') : $r('app.color.text_secondary'))

          if (this.currentTab === index) {
            Row()
              .width(20)
              .height(2)
              .backgroundColor($r('app.color.primary'))
              .borderRadius(1)
          }
        }
        .width('33%')
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentTab = index;
          this.loadOrders();
        })
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  buildOrderList() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .color($r('app.color.primary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.orders.length === 0) {
      Column() {
        Image($r('app.media.ic_empty'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)

        Text('暂无订单')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: $r('app.float.card_margin') })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Column() {
          ForEach(this.orders, (order: Order) => {
            this.buildOrderItem(order)
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

  @Builder
  buildOrderItem(order: Order) {
    Column() {
      // Header
      Row() {
        Text(order.orderNo)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(this.getOrderStatusText(order.orderStatus))
          .fontSize($r('app.float.badge_text_size'))
          .fontColor(this.getOrderStatusColor(order.orderStatus))
          .padding({
            left: $r('app.float.badge_padding'),
            right: $r('app.float.badge_padding'),
            top: 2,
            bottom: 2
          })
          .backgroundColor(this.getOrderStatusBgColor(order.orderStatus))
          .borderRadius($r('app.float.badge_radius'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: $r('app.float.card_content_margin') })

      // Student and service info
      Row() {
        Column() {
          Text('学生')
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor($r('app.color.text_tertiary'))
          Text(order.studentName || '-')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_primary'))
        }
        .layoutWeight(1)

        Column() {
          Text('服务')
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor($r('app.color.text_tertiary'))
          Text(order.serviceProductName || '-')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)

        Column() {
          Text('金额')
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor($r('app.color.text_tertiary'))
          Text(`¥${order.actualAmount}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.error'))
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: $r('app.float.card_content_margin') })

      // Date range
      Text(`托管时间：${order.startDate} - ${order.endDate}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: $r('app.float.card_content_margin') })

      // Actions
      if (order.orderStatus === 'PENDING') {
        Row() {
          Button('拒绝')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor('#F44336')
            .backgroundColor('#FFEBEE')
            .borderRadius($r('app.float.button_radius'))
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .onClick(() => {
              this.selectedOrder = order;
              this.showAuditDialog = true;
              this.auditRemark = '';
            })

          Button('通过')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(Color.White)
            .backgroundColor('#4CAF50')
            .borderRadius($r('app.float.button_radius'))
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .margin({ left: $r('app.float.card_content_margin') })
            .onClick(() => {
              this.selectedOrder = order;
              this.handleAudit('APPROVED');
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  getOrderStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      'PENDING': '待审核',
      'APPROVED': '已通过',
      'REJECTED': '已拒绝',
      'CANCELLED': '已取消',
      'COMPLETED': '已完成',
      'REFUNDED': '已退款'
    };
    return statusMap[status] || status;
  }

  getOrderStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'PENDING': '#FF9800',
      'APPROVED': '#4CAF50',
      'REJECTED': '#F44336',
      'CANCELLED': '#9E9E9E',
      'COMPLETED': '#2196F3',
      'REFUNDED': '#9E9E9E'
    };
    return colorMap[status] || '#666666';
  }

  getOrderStatusBgColor(status: string): string {
    const colorMap: Record<string, string> = {
      'PENDING': '#FFF3E0',
      'APPROVED': '#E8F5E9',
      'REJECTED': '#FFEBEE',
      'CANCELLED': '#F5F5F5',
      'COMPLETED': '#E3F2FD',
      'REFUNDED': '#F5F5F5'
    };
    return colorMap[status] || '#F5F5F5';
  }
}