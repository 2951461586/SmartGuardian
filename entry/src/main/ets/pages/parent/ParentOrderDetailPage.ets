/**
 * SmartGuardian - Parent Order Detail Page
 * View order details, payment status, and perform actions
 */

import router from '@ohos.router';
import { Order } from '../../models/service';
import { OrderService as OrderAPIService } from '../../services/api/service';
import { OrderStore } from '../../stores/orderStore';

interface RouterParams {
  orderId?: number;
  orderNo?: string;
}

@Entry
@Component
struct ParentOrderDetailPage {
  @State orderId: number = 0;
  @State orderDetail: Order | null = null;
  @State isLoading: boolean = true;

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.orderId) {
      this.orderId = params.orderId;
    }
    this.loadOrderDetail();
  }

  async loadOrderDetail() {
    this.isLoading = true;
    try {
      const cachedOrder = this.orderId > 0 ? OrderStore.findOrderById(this.orderId) : OrderStore.getCurrentOrder();
      if (cachedOrder) {
        this.orderDetail = cachedOrder;
      }

      if (this.orderId > 0) {
        const resp = await OrderAPIService.getOrderDetail(this.orderId);
        if (resp.code === 0 && resp.data) {
          this.orderDetail = resp.data;
          OrderStore.setCurrentOrder(resp.data);
          OrderStore.updateOrderInList(resp.data);
          return;
        }
      }

      if (!this.orderDetail) {
        this.orderDetail = OrderStore.getCurrentOrder();
      }
    } catch (error) {
      console.error('Failed to load order detail:', String(error));
      if (!this.orderDetail) {
        this.orderDetail = OrderStore.getCurrentOrder();
      }
    } finally {
      this.isLoading = false;
    }
  }

  getPayAmount(): number {
    if (!this.orderDetail) {
      return 0;
    }
    if (this.orderDetail.actualAmount !== undefined) {
      return this.orderDetail.actualAmount;
    }
    if (this.orderDetail.totalAmount !== undefined) {
      return this.orderDetail.totalAmount - (this.orderDetail.discountAmount || 0);
    }
    return this.orderDetail.amount || 0;
  }

  getServiceAmount(): number {
    if (!this.orderDetail) {
      return 0;
    }
    if (this.orderDetail.totalAmount !== undefined) {
      return this.orderDetail.totalAmount;
    }
    return this.orderDetail.amount || 0;
  }

  handlePay() {
    if (!this.orderDetail) {
      return;
    }
    router.pushUrl({
      url: 'pages/parent/ParentPaymentPage',
      params: {
        orderId: this.orderDetail.id,
        amount: this.getPayAmount()
      }
    });
  }

  handleCancel() {
    console.log('Cancel order');
  }

  getStatusText(status: string): string {
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

  getStatusColor(status: string): string {
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

  build() {
    Column() {
      this.buildHeader()

      if (this.isLoading) {
        this.buildLoading()
      } else if (this.orderDetail) {
        Scroll() {
          Column() {
            this.buildStatusCard()
            this.buildOrderInfo()
            this.buildStudentInfo()
            this.buildAmountInfo()
          }
          .width('100%')
          .padding($r('app.float.page_padding'))
          .padding({ bottom: 100 })
        }
        .width('100%')
        .layoutWeight(1)

        this.buildBottomBar()
      } else {
        this.buildEmpty()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width($r('app.float.icon_large_size'))
        .height($r('app.float.icon_large_size'))
        .onClick(() => router.back())

      Text('订单详情')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank()
        .width($r('app.float.icon_large_size'))
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: Number($r('app.float.status_bar_height')) + 10 })
  }

  @Builder
  buildLoading() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color($r('app.color.primary'))
      Text('加载中...')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmpty() {
    Column() {
      Text('订单不存在')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildStatusCard() {
    Column() {
      Text(this.getStatusText(this.orderDetail?.orderStatus || 'PENDING'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getStatusColor(this.orderDetail?.orderStatus || 'PENDING'))

      if (this.orderDetail?.orderStatus === 'PENDING') {
        Text('请等待机构审核')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      } else if (this.orderDetail?.orderStatus === 'APPROVED') {
        Text('请在24小时内完成支付')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor('#FF5722')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }

  @Builder
  buildOrderInfo() {
    Column() {
      Text('订单信息')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      this.buildInfoRow('订单编号', this.orderDetail?.orderNo || '')
      this.buildInfoRow('服务名称', this.orderDetail?.serviceProductName || '')
      this.buildInfoRow('下单时间', this.orderDetail?.createdAt || '')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
  }

  @Builder
  buildStudentInfo() {
    Column() {
      Text('学生信息')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      this.buildInfoRow('学生姓名', this.orderDetail?.studentName || '')
      this.buildInfoRow('服务日期', `${this.orderDetail?.startDate || ''} 至 ${this.orderDetail?.endDate || ''}`)
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
  }

  @Builder
  buildAmountInfo() {
    Column() {
      Text('金额信息')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      this.buildInfoRow('服务费用', `¥${this.getServiceAmount().toFixed(2)}`)
      if ((this.orderDetail?.discountAmount || 0) > 0) {
        this.buildInfoRow('优惠金额', `-¥${(this.orderDetail?.discountAmount || 0).toFixed(2)}`, '#FF5722')
      }

      Divider().color('#E0E0E0').margin({ top: 12, bottom: 12 })

      Row() {
        Text('应付金额')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Row() {
          Text('¥')
            .fontSize($r('app.float.text_primary_size'))
            .fontColor('#F44336')
            .fontWeight(FontWeight.Bold)

          Text(this.getPayAmount().toFixed(2))
            .fontSize(24)
            .fontColor('#F44336')
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
  }

  @Builder
  buildInfoRow(label: string, value: string, valueColor?: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(valueColor || $r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  buildBottomBar() {
    Row() {
      if (this.orderDetail?.orderStatus === 'APPROVED' && this.orderDetail?.payStatus === 'UNPAID') {
        Button('立即支付')
          .width('100%')
          .height(44)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(22)
          .onClick(() => this.handlePay())
      } else if (this.orderDetail?.orderStatus === 'PENDING') {
        Button('取消订单')
          .width('100%')
          .height(44)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .onClick(() => this.handleCancel())
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .shadow({
      radius: 10,
      color: '#1A000000',
      offsetY: -2
    })
  }
}
