/**
 * SmartGuardian - OrderListItem Component
 * 可复用的订单列表项组件
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { Order } from '../../models/service';
import { OrderBadge } from '../StatusBadge';

export enum OrderItemMode {
  SIMPLE = 'simple',
  DETAIL = 'detail'
}

@Component
export struct OrderListItem {
  @Prop order: Order | null = null;
  @Prop mode: OrderItemMode = OrderItemMode.SIMPLE;
  onItemClick?: () => void;
  onApprove?: () => void;
  onReject?: () => void;
  onCancel?: () => void;
  onPay?: () => void;

  private getDisplayAmount(): number {
    if (this.order?.actualAmount !== undefined && this.order.actualAmount > 0) {
      return this.order.actualAmount;
    }
    if (this.order?.totalAmount !== undefined && this.order.totalAmount > 0) {
      return this.order.totalAmount - (this.order.discountAmount || 0);
    }
    return this.order?.amount || 0;
  }

  build() {
    Column() {
      if (this.order !== null) {
        Row() {
          Text(this.order.orderNo)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))

          OrderBadge({ status: this.order.orderStatus || 'PENDING' })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: $r('app.float.card_content_margin') })

        if (this.mode === OrderItemMode.SIMPLE) {
          this.buildSimpleContent()
        } else {
          this.buildDetailContent()
        }
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(HarmonyColor.surface)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      }
    })
  }

  @Builder
  buildSimpleContent() {
    Text(this.order?.serviceProductName || '托管服务')
      .fontSize($r('app.float.text_primary_size'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_primary'))
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })

    Text(`${this.order?.startDate || ''} - ${this.order?.endDate || ''}`)
      .fontSize($r('app.float.text_secondary_size'))
      .fontColor($r('app.color.text_secondary'))
      .margin({ top: 8 })

    Row() {
      Column() {
        Text(`￥${this.getDisplayAmount().toFixed(2)}`)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.error'))

        if (this.order?.discountAmount && this.order.discountAmount > 0) {
          Text(`已优惠 ￥${this.order.discountAmount.toFixed(2)}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      this.buildSimpleAction()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: $r('app.float.card_content_margin') })
  }

  @Builder
  buildDetailContent() {
    Row() {
      Column() {
        Text('学生')
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_tertiary'))
        Text(this.order?.studentName || '-')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_primary'))
      }
      .layoutWeight(1)

      Column() {
        Text('服务')
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_tertiary'))
        Text(this.order?.serviceProductName || '-')
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
        Text(`￥${this.order?.actualAmount || this.order?.amount || 0}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.error'))
      }
      .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: $r('app.float.card_content_margin') })

    Text(`托管时间：${this.order?.startDate || '-'} - ${this.order?.endDate || '-'}`)
      .fontSize($r('app.float.text_secondary_size'))
      .fontColor($r('app.color.text_secondary'))
      .margin({ bottom: $r('app.float.card_content_margin') })

    if (this.order?.orderStatus === 'PENDING') {
      this.buildAuditButtons()
    }
  }

  @Builder
  buildSimpleAction() {
    if (this.order?.orderStatus === 'PENDING') {
      Button('取消订单')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .backgroundColor($r('app.color.page_background'))
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          if (this.onCancel) {
            this.onCancel();
          }
        })
    } else if (this.order?.orderStatus === 'APPROVED' && this.order?.payStatus === 'UNPAID') {
      Button('立即支付')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyColor.textInverse)
        .backgroundColor($r('app.color.primary'))
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          if (this.onPay) {
            this.onPay();
          }
        })
    }
  }

  @Builder
  buildAuditButtons() {
    Row() {
      Button('拒绝')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyReport.danger)
        .backgroundColor(HarmonyReport.dangerSurface)
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 20, right: 20, top: 8, bottom: 8 })
        .onClick(() => {
          if (this.onReject) {
            this.onReject();
          }
        })

      Button('通过')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyColor.textInverse)
        .backgroundColor(HarmonyReport.positive)
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 20, right: 20, top: 8, bottom: 8 })
        .margin({ left: $r('app.float.card_content_margin') })
        .onClick(() => {
          if (this.onApprove) {
            this.onApprove();
          }
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
  }
}
