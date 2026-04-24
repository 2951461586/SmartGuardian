/**
 * SmartGuardian - Parent Payment Page
 * Payment method selection and payment processing
 */

import { PaymentCreateRequest, PaymentOrder, PaymentCallbackRequest } from '../../models/payment';
import { PaymentService } from '../../services/api/payments';
import { Order } from '../../models/service';
import { OrderStore } from '../../stores/orderStore';
import { LogUtil } from '../../utils/LogUtil';

interface RouterParams {
  orderId?: number;
}

@Entry
@Component
struct ParentPaymentPage {
  @State orderId: number = 0;
  @State amount: number = 0;
  @State selectedChannel: string = 'ALIPAY';
  @State isPaying: boolean = false;
  @State paymentOrder: PaymentOrder | null = null;
  @State countdown: number = 30;

  private timer: number = -1;

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as RouterParams;
    if (params) {
      this.orderId = params.orderId || 0;
    }

    const currentOrder = OrderStore.getCurrentOrder();
    const cachedOrder = currentOrder?.id === this.orderId ? currentOrder : OrderStore.findOrderById(this.orderId);
    if (cachedOrder) {
      this.amount = this.getDisplayAmount(cachedOrder);
      return;
    }

    this.orderId = 0;
    this.amount = 0;
  }

  aboutToDisappear() {
    this.clearTimer();
  }

  clearTimer(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  private getDisplayAmount(order: Order): number {
    if (order.actualAmount !== undefined) {
      return order.actualAmount;
    }
    if (order.totalAmount !== undefined) {
      return order.totalAmount - (order.discountAmount || 0);
    }
    return order.amount || 0;
  }

  async handlePayment() {
    if (this.orderId <= 0 || this.amount <= 0) {
      return;
    }

    this.isPaying = true;
    try {
      const request: PaymentCreateRequest = {
        orderId: this.orderId,
        payChannel: this.selectedChannel as 'ALIPAY' | 'WECHAT' | 'UNIONPAY' | 'CASH' | 'OTHER',
        payAmount: this.amount,
        clientType: 'APP'
      };

      const resp = await PaymentService.createPayment(request);
      if (resp.code === 0 && resp.data) {
        this.paymentOrder = resp.data;
        this.startCountdown();
      }
    } catch (error) {
      LogUtil.error('ParentPaymentPage', 'Payment failed');
    } finally {
      this.isPaying = false;
    }
  }

  startCountdown(): void {
    this.clearTimer();
    this.countdown = 30;
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        this.clearTimer();
        this.handlePaymentSuccess();
      }
    }, 1000);
  }

  async handlePaymentSuccess() {
    try {
      if (this.paymentOrder && this.paymentOrder.paymentNo) {
        const callbackRequest: PaymentCallbackRequest = {
          paymentNo: this.paymentOrder.paymentNo,
          tradeStatus: 'SUCCESS',
          thirdTradeNo: this.paymentOrder.thirdTradeNo,
          payTime: new Date().toISOString(),
          rawPayload: 'mock-payment-success'
        };
        await PaymentService.callback(callbackRequest);
      }
      this.syncLocalOrderStatus();
    } catch (error) {
      LogUtil.error('ParentPaymentPage', 'Payment callback failed');
      this.syncLocalOrderStatus();
    }

    try {
      this.getUIContext().getRouter().replaceUrl({
        url: 'pages/parent/ParentOrderDetailPage',
        params: {
          orderId: this.orderId
        }
      });
    } catch (error) {
      LogUtil.error('ParentPaymentPage', 'Navigate to order detail failed');
    }
  }

  syncLocalOrderStatus(): void {
    const cachedOrder = OrderStore.findOrderById(this.orderId) || OrderStore.getCurrentOrder();
    if (!cachedOrder) {
      return;
    }

    const paidTime = new Date().toISOString();
    const paidAmount = this.amount > 0 ? this.amount : this.getDisplayAmount(cachedOrder);
    const updatedOrder: Order = {
      id: cachedOrder.id,
      orderNo: cachedOrder.orderNo,
      studentId: cachedOrder.studentId,
      serviceProductId: cachedOrder.serviceProductId,
      orderStatus: cachedOrder.orderStatus,
      amount: cachedOrder.amount,
      paidAmount: paidAmount,
      payStatus: 'PAID',
      auditStatus: cachedOrder.auditStatus,
      startDate: cachedOrder.startDate,
      endDate: cachedOrder.endDate,
      totalAmount: cachedOrder.totalAmount,
      discountAmount: cachedOrder.discountAmount,
      actualAmount: cachedOrder.actualAmount,
      payTime: paidTime,
      auditTime: cachedOrder.auditTime,
      auditUserId: cachedOrder.auditUserId,
      auditRemark: cachedOrder.auditRemark,
      createdAt: cachedOrder.createdAt,
      updatedAt: paidTime,
      studentName: cachedOrder.studentName,
      guardianUserId: cachedOrder.guardianUserId,
      guardianName: cachedOrder.guardianName,
      serviceProductName: cachedOrder.serviceProductName
    };

    OrderStore.setCurrentOrder(updatedOrder);
    OrderStore.updateOrderInList(updatedOrder);
  }

  build() {
    Column() {
      this.buildHeader()

      Scroll() {
        Column() {
          this.buildAmountCard()
          this.buildPaymentMethods()
          this.buildPaymentInfo()
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
        .padding({ bottom: 100 })
      }
      .width('100%')
      .layoutWeight(1)

      this.buildBottomBar()
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
        .onClick(() => this.getUIContext().getRouter().back())

      Text('支付订单')
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
  buildAmountCard() {
    Column() {
      Text('支付金额')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))

      Row() {
        Text('¥')
          .fontSize(24)
          .fontColor('#F44336')
          .fontWeight(FontWeight.Bold)

        Text(this.amount.toFixed(2))
          .fontSize(40)
          .fontColor('#F44336')
          .fontWeight(FontWeight.Bold)
      }
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildPaymentMethods() {
    Column() {
      Text('选择支付方式')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      this.buildPaymentMethodItem('ALIPAY', '支付宝', $r('app.media.ic_money'))
      this.buildPaymentMethodItem('WECHAT', '微信支付', $r('app.media.ic_money'))
      this.buildPaymentMethodItem('UNIONPAY', '银联支付', $r('app.media.ic_money'))
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
  }

  @Builder
  buildPaymentMethodItem(channel: string, name: string, icon: Resource) {
    Row() {
      Image(icon)
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)

      Text(name)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ left: 12 })
        .layoutWeight(1)

      Radio({ value: channel, group: 'payment' })
        .checked(this.selectedChannel === channel)
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.selectedChannel = channel;
          }
        })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .onClick(() => {
      this.selectedChannel = channel;
    })
  }

  @Builder
  buildPaymentInfo() {
    Column() {
      Text('支付说明')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Text('1. 请在30分钟内完成支付')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      Text('2. 支付成功后将自动跳转到订单详情')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      Text('3. 如有疑问请联系客服')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      if (this.paymentOrder && this.countdown > 0) {
        Text(`模拟支付处理中，剩余 ${this.countdown}s`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.primary'))
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor('#FFF3E0')
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
  }

  @Builder
  buildBottomBar() {
    Row() {
      Column() {
        Text('应付金额')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Row() {
          Text('¥')
            .fontSize($r('app.float.text_primary_size'))
            .fontColor('#F44336')

          Text(this.amount.toFixed(2))
            .fontSize(24)
            .fontColor('#F44336')
            .fontWeight(FontWeight.Bold)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button(this.paymentOrder ? '支付处理中' : '立即支付')
        .width(160)
        .height(44)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(22)
        .enabled(!this.isPaying && this.paymentOrder === null)
        .onClick(() => this.handlePayment())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 10,
      color: '#1A000000',
      offsetY: -2
    })
  }
}

