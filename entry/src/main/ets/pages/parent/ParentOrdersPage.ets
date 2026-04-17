/**
 * SmartGuardian - Parent Orders Page
 * Parent can view and manage their orders
 */

import { OrderService } from '../../services/api/service';
import { Order } from '../../models/service';
import { UserStore } from '../../stores/userStore';

@Component
export struct ParentOrdersPage {
  @State orders: Order[] = [];
  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State errorMessage: string = '';

  private tabs: string[] = ['全部', '待审核', '进行中', '已完成'];

  aboutToAppear() {
    this.loadOrders();
  }

  async loadOrders() {
    this.isLoading = true;
    try {
      let orderStatus: string | undefined;
      if (this.currentTab === 1) orderStatus = 'PENDING';
      else if (this.currentTab === 2) orderStatus = 'APPROVED';
      else if (this.currentTab === 3) orderStatus = 'COMPLETED';

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
      Text('我的订单')
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
        .width('25%')
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
      // Order header
      Row() {
        Text(order.orderNo)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(this.getOrderStatusText(order.orderStatus))
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor(this.getOrderStatusColor(order.orderStatus))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: $r('app.float.card_content_margin') })

      // Service name
      Text(order.serviceProductName || '托管服务')
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // Date range
      Text(`${order.startDate} - ${order.endDate}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      // Amount and action
      Row() {
        Column() {
          Text(`¥${order.actualAmount}`)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.error'))

          if (order.discountAmount && order.discountAmount > 0) {
            Text(`已优惠 ¥${order.discountAmount}`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)

        if (order.orderStatus === 'PENDING') {
          Button('取消订单')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.page_background'))
            .borderRadius($r('app.float.button_radius'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        } else if (order.orderStatus === 'APPROVED' && order.payStatus === 'UNPAID') {
          Button('立即支付')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.button_radius'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: $r('app.float.card_content_margin') })
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
      'APPROVED': '已审核',
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
}
