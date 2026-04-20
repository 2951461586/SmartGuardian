/**
 * SmartGuardian - OrderListItem Component
 * 可复用的订单列表项组件
 * 
 * @description 支持简化模式和详细模式两种布局
 * @example
 * // 简化模式（家长端）
 * OrderListItem({
 *   order: order,
 *   mode: OrderItemMode.SIMPLE,
 *   onClick: () => { ... }
 * })
 * 
 * // 详细模式（管理端）
 * OrderListItem({
 *   order: order,
 *   mode: OrderItemMode.DETAIL,
 *   onApprove: () => { ... },
 *   onReject: () => { ... }
 * })
 */

import { Order } from '../../models/service';
import { OrderBadge } from '../StatusBadge';

/** 订单项显示模式 */
export enum OrderItemMode {
  /** 简化模式 - 家长端，显示基本信息和操作按钮 */
  SIMPLE = 'simple',
  /** 详细模式 - 管理端，显示完整信息和审核按钮 */
  DETAIL = 'detail'
}

@Component
export struct OrderListItem {
  /** 订单数据 */
  @Prop order: Order | null = null;
  
  /** 显示模式 */
  @Prop mode: OrderItemMode = OrderItemMode.SIMPLE;
  
  /** 点击回调 */
  onItemClick?: () => void;
  
  /** 审核通过回调（仅DETAIL模式） */
  onApprove?: () => void;
  
  /** 审核拒绝回调（仅DETAIL模式） */
  onReject?: () => void;
  
  /** 取消订单回调（仅SIMPLE模式） */
  onCancel?: () => void;
  
  /** 支付回调（仅SIMPLE模式） */
  onPay?: () => void;

  /** 获取显示金额 */
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
        // 订单头部：订单号 + 状态
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
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      }
    })
  }

  /** 简化模式内容 */
  @Builder
  buildSimpleContent() {
    // 服务名称
    Text(this.order?.serviceProductName || '托管服务')
      .fontSize($r('app.float.text_primary_size'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_primary'))
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })

    // 服务日期
    Text(`${this.order?.startDate || ''} - ${this.order?.endDate || ''}`)
      .fontSize($r('app.float.text_secondary_size'))
      .fontColor($r('app.color.text_secondary'))
      .margin({ top: 8 })

    // 底部：金额 + 操作
    Row() {
      Column() {
        Text(`¥${this.getDisplayAmount().toFixed(2)}`)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.error'))

        if (this.order?.discountAmount && this.order.discountAmount > 0) {
          Text(`已优惠 ¥${this.order.discountAmount.toFixed(2)}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      // 操作按钮
      this.buildSimpleAction()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: $r('app.float.card_content_margin') })
  }

  /** 详细模式内容 */
  @Builder
  buildDetailContent() {
    // 订单信息行
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
        Text(`¥${this.order?.actualAmount || this.order?.amount || 0}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.error'))
      }
      .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: $r('app.float.card_content_margin') })

    // 托管时间
    Text(`托管时间：${this.order?.startDate || '-'} - ${this.order?.endDate || '-'}`)
      .fontSize($r('app.float.text_secondary_size'))
      .fontColor($r('app.color.text_secondary'))
      .margin({ bottom: $r('app.float.card_content_margin') })

    // 审核操作按钮
    if (this.order?.orderStatus === 'PENDING') {
      this.buildAuditButtons()
    }
  }

  /** 简化模式操作按钮 */
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
        .fontColor(Color.White)
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

  /** 审核按钮 */
  @Builder
  buildAuditButtons() {
    Row() {
      Button('拒绝')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor('#F44336')
        .backgroundColor('#FFEBEE')
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 20, right: 20, top: 8, bottom: 8 })
        .onClick(() => {
          if (this.onReject) {
            this.onReject();
          }
        })

      Button('通过')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(Color.White)
        .backgroundColor('#4CAF50')
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
