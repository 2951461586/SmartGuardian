/**
 * SmartGuardian - Parent Order Detail Page
 * View order details, payment progress and follow-up actions
 */

import { HarmonyColor, HarmonyReport, harmonyShadowColor } from '../../common/HarmonyDesign';
import { Card, EmptyState, EmptyType, HeaderTheme, InfoCard, InfoItem, LoadingSize, LoadingState, PageHeader, SectionHeader } from '../../components/common';
import { RouteUrls } from '../../constants/app.constants';
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
    const params = this.getUIContext().getRouter().getParams() as RouterParams;
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

  private getPayAmount(): number {
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

  private getServiceAmount(): number {
    if (!this.orderDetail) {
      return 0;
    }
    if (this.orderDetail.totalAmount !== undefined) {
      return this.orderDetail.totalAmount;
    }
    return this.orderDetail.amount || 0;
  }

  private handlePay() {
    if (!this.orderDetail) {
      return;
    }
    try {
      this.getUIContext().getRouter().pushUrl({
        url: RouteUrls.PARENT_PAYMENT,
        params: {
          orderId: this.orderDetail.id,
          amount: this.getPayAmount()
        }
      });
    } catch (error) {
      console.error('ParentOrderDetailPage navigate to payment failed:', String(error));
    }
  }

  private handleCancel() {
    console.log('Cancel order');
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'PENDING':
        return '待审核';
      case 'APPROVED':
        return '待支付';
      case 'REJECTED':
        return '已驳回';
      case 'CANCELLED':
        return '已取消';
      case 'COMPLETED':
        return '已完成';
      case 'REFUNDED':
        return '已退款';
      default:
        return status || '未知状态';
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case 'PENDING':
        return HarmonyReport.caution;
      case 'APPROVED':
        return HarmonyColor.info;
      case 'REJECTED':
        return HarmonyReport.danger;
      case 'CANCELLED':
      case 'REFUNDED':
        return HarmonyColor.textTertiary;
      case 'COMPLETED':
        return HarmonyReport.positive;
      default:
        return HarmonyColor.textSecondary;
    }
  }

  private getStatusHint(): string {
    const status = this.orderDetail?.orderStatus || 'PENDING';
    if (status === 'PENDING') {
      return '订单已提交，等待机构审核。';
    }
    if (status === 'APPROVED' && this.orderDetail?.payStatus === 'UNPAID') {
      return '审核已通过，请尽快完成支付。';
    }
    if (status === 'REJECTED') {
      return this.orderDetail?.auditRemark || '订单未通过审核，请联系机构处理。';
    }
    if (status === 'COMPLETED') {
      return '当前订单已履约完成，可查看相关服务记录。';
    }
    return '可在此查看订单状态、金额和服务周期。';
  }

  private getOrderInfoItems(): InfoItem[] {
    return [
      { label: '订单编号', value: this.orderDetail?.orderNo || '--' },
      { label: '下单时间', value: this.orderDetail?.createdAt || '--' },
      { label: '订单状态', value: this.getStatusText(this.orderDetail?.orderStatus || ''), valueColor: this.getStatusColor(this.orderDetail?.orderStatus || '') },
      { label: '支付状态', value: this.getPayStatusText(this.orderDetail?.payStatus || '') }
    ];
  }

  private getServiceInfoItems(): InfoItem[] {
    return [
      { label: '服务名称', value: this.orderDetail?.serviceProductName || '--' },
      { label: '学生姓名', value: this.orderDetail?.studentName || '--' },
      { label: '开始日期', value: this.orderDetail?.startDate || '--' },
      { label: '结束日期', value: this.orderDetail?.endDate || '--' }
    ];
  }

  private getPayStatusText(status: string): string {
    if (status === 'PAID') {
      return '已支付';
    }
    if (status === 'PARTIAL') {
      return '部分支付';
    }
    if (status === 'UNPAID') {
      return '未支付';
    }
    return status || '--';
  }

  build() {
    Column() {
      PageHeader({
        title: '订单详情',
        subtitle: '查看审核进度、服务周期与支付信息。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.LARGE,
          fullscreen: false
        })
      } else if (!this.orderDetail) {
        EmptyState({
          type: EmptyType.NO_ORDER,
          customTitle: '未找到订单信息',
          customDescription: '订单可能已失效，请返回列表重新查看。',
          actionText: '返回上一页',
          onAction: () => {
            this.getUIContext().getRouter().back();
          }
        })
      } else {
        Scroll() {
          Column() {
            this.buildStatusCard()
            this.buildOrderSummary()
            this.buildAmountPanel()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 120 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        this.buildBottomBar()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildStatusCard() {
    Card({
      title: '当前进度',
      subtitle: this.getStatusHint(),
      content: () => { this.buildStatusCardContent() }
    })
  }

  @Builder
  private buildStatusCardContent() {
    Column() {
      Text(this.getStatusText(this.orderDetail?.orderStatus || ''))
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getStatusColor(this.orderDetail?.orderStatus || ''))

      Text(`应付金额：¥${this.getPayAmount().toFixed(2)}`)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildOrderSummary() {
    Column() {
      SectionHeader({
        title: '订单信息',
        subtitle: '统一查看订单编号、服务周期和学生信息。'
      })

      InfoCard({
        items: this.getOrderInfoItems(),
        columns: 2
      })

      Card({
        title: '服务信息',
        content: () => { this.buildServiceInfo() }
      })
    }
    .width('100%')
  }

  @Builder
  private buildServiceInfo() {
    InfoCard({
      items: this.getServiceInfoItems(),
      columns: 2
    })
  }

  @Builder
  private buildAmountPanel() {
    Column() {
      SectionHeader({
        title: '金额明细',
        subtitle: '包含服务金额、优惠金额和最终应付金额。'
      })

      Card({
        title: '费用结算',
        content: () => { this.buildAmountInfo() }
      })
    }
    .width('100%')
  }

  @Builder
  private buildAmountInfo() {
    Column() {
      this.buildAmountRow('服务费用', `¥${this.getServiceAmount().toFixed(2)}`, false)

      if ((this.orderDetail?.discountAmount || 0) > 0) {
        this.buildAmountRow('优惠金额', `-¥${(this.orderDetail?.discountAmount || 0).toFixed(2)}`, true)
      }

      Divider()
        .color(HarmonyColor.line)
        .margin({ top: 12, bottom: 12 })

      Row() {
        Text('应付金额')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text(`¥${this.getPayAmount().toFixed(2)}`)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(HarmonyReport.danger)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
  }

  @Builder
  private buildAmountRow(label: string, value: string, highlight: boolean) {
    Row() {
      Text(label)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))

      Blank()

      Text(value)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(highlight ? HarmonyReport.caution : $r('app.color.text_primary'))
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  private buildBottomBar() {
    Row() {
      if (this.orderDetail?.orderStatus === 'APPROVED' && this.orderDetail?.payStatus === 'UNPAID') {
        Button('立即支付')
          .width('100%')
          .height(46)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(HarmonyColor.textInverse)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(18)
          .onClick(() => this.handlePay())
      } else if (this.orderDetail?.orderStatus === 'PENDING') {
        Button('取消订单')
          .width('100%')
          .height(46)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(HarmonyColor.surfaceSubtle)
          .borderRadius(18)
          .onClick(() => this.handleCancel())
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 18 })
    .backgroundColor(HarmonyColor.surface)
    .shadow({
      radius: 10,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: -4
    })
  }
}

