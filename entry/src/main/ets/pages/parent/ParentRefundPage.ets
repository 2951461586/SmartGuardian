/**
 * SmartGuardian - Parent Refund Page
 * Refund application and refund record management
 */

import { Card, HeaderTheme, InfoCard, InfoItem, PageHeader, SectionHeader } from '../../components/common';
import { CreateRefundParams, RefundReasonType, RefundRecord } from '../../models/refund';
import { RefundService } from '../../services/api/refund';

interface RouterParams {
  orderId?: number;
  orderNo?: string;
  serviceName?: string;
  amount?: number;
}

@Entry
@Component
struct ParentRefundPage {
  @State orderId: number = 0;
  @State orderNo: string = '';
  @State serviceName: string = '';
  @State orderAmount: number = 0;
  @State refundAmount: number = 0;
  @State deduction: number = 0;
  @State selectedReasonType: string = RefundReasonType.PERSONAL_REASON;
  @State reason: string = '';
  @State description: string = '';
  @State isSubmitting: boolean = false;
  @State refundRecords: RefundRecord[] = [];

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as RouterParams;
    if (params) {
      this.orderId = params.orderId || 0;
      this.orderNo = params.orderNo || '';
      this.serviceName = params.serviceName || '';
      this.orderAmount = params.amount || 0;
      this.calculateRefund();
    }
    this.loadRefundRecords();
  }

  async calculateRefund() {
    try {
      const resp = await RefundService.calculateRefundAmount(this.orderId);
      if (resp.code === 0 && resp.data) {
        this.refundAmount = resp.data.refundAmount;
        this.deduction = resp.data.deduction;
      } else {
        this.refundAmount = this.orderAmount * 0.9;
        this.deduction = this.orderAmount * 0.1;
      }
    } catch (error) {
      console.error('Failed to calculate refund:', String(error));
      this.refundAmount = this.orderAmount * 0.9;
      this.deduction = this.orderAmount * 0.1;
    }
  }

  async loadRefundRecords() {
    try {
      const resp = await RefundService.getRefunds({ orderId: this.orderId });
      if (resp.code === 0 && resp.data && resp.data.list) {
        this.refundRecords = resp.data.list;
      } else {
        this.refundRecords = [];
      }
    } catch (error) {
      console.error('Failed to load refund records:', String(error));
      this.refundRecords = [];
    }
  }

  async submitRefund() {
    if (!this.reason.trim()) {
      return;
    }

    this.isSubmitting = true;
    try {
      const params: CreateRefundParams = {
        orderId: this.orderId,
        refundAmount: this.refundAmount,
        reasonType: this.selectedReasonType,
        reason: this.reason.trim(),
        description: this.description.trim()
      };

      const resp = await RefundService.createRefund(params);
      if (resp.code === 0) {
        this.getUIContext().getRouter().back();
      }
    } catch (error) {
      console.error('Failed to submit refund:', String(error));
    } finally {
      this.isSubmitting = false;
    }
  }

  private getOrderInfoItems(): InfoItem[] {
    return [
      { label: '订单编号', value: this.orderNo || '--' },
      { label: '服务名称', value: this.serviceName || '--' },
      { label: '订单金额', value: `¥${this.orderAmount.toFixed(2)}` },
      { label: '退款方式', value: '原路退回' }
    ];
  }

  private getRefundLabel(type: string): string {
    switch (type) {
      case RefundReasonType.STUDENT_TRANSFER:
        return '学生转学';
      case RefundReasonType.SERVICE_QUALITY:
        return '服务质量问题';
      case RefundReasonType.SCHEDULE_CHANGE:
        return '时间安排变更';
      case RefundReasonType.PERSONAL_REASON:
        return '个人原因';
      case RefundReasonType.OTHER:
        return '其他原因';
      default:
        return '其他原因';
    }
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'PENDING':
        return '待审核';
      case 'APPROVED':
        return '已批准';
      case 'REJECTED':
        return '已拒绝';
      case 'PROCESSING':
        return '退款中';
      case 'COMPLETED':
        return '已完成';
      case 'CANCELLED':
        return '已取消';
      default:
        return '未知状态';
    }
  }

  build() {
    Column() {
      PageHeader({
        title: '申请退款',
        subtitle: '填写退款原因并查看可退金额与历史记录。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      Scroll() {
        Column() {
          this.buildOrderInfo()
          this.buildAmountInfo()
          this.buildRefundForm()

          if (this.refundRecords.length > 0) {
            this.buildRefundHistory()
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 120 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      this.buildSubmitBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildOrderInfo() {
    Column() {
      SectionHeader({
        title: '订单概览',
        subtitle: '核对当前订单信息后再提交退款。'
      })

      InfoCard({
        items: this.getOrderInfoItems(),
        columns: 2
      })
    }
    .width('100%')
  }

  @Builder
  private buildAmountInfo() {
    Column() {
      SectionHeader({
        title: '退款测算',
        subtitle: '系统会根据规则自动计算可退金额。'
      })

      Card({
        title: '金额说明',
        subtitle: '当前默认按 10% 扣减手续费进行测算。',
        content: this.buildAmountInfoContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildAmountInfoContent() {
    Column() {
      this.buildAmountRow('订单金额', `¥${this.orderAmount.toFixed(2)}`, false)
      this.buildAmountRow('手续费', `-¥${this.deduction.toFixed(2)}`, true)

      Divider()
        .color('#E0E8F2')
        .margin({ top: 12, bottom: 12 })

      Row() {
        Text('可退金额')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text(`¥${this.refundAmount.toFixed(2)}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E5484D')
      }
      .width('100%')

      Text('提交申请后需等待机构审核，审核通过后将按原路退回。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .lineHeight(18)
        .margin({ top: 10 })
    }
    .width('100%')
  }

  @Builder
  private buildRefundForm() {
    Column() {
      SectionHeader({
        title: '退款表单',
        subtitle: '请尽量描述清楚原因，方便机构快速审核。'
      })

      Card({
        title: '退款原因',
        subtitle: '选择类型并填写详细说明。',
        content: this.buildRefundFormContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildRefundFormContent() {
    Column() {
      Text('原因类型')
        .width('100%')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_secondary'))

      Column() {
        ForEach(this.getReasonTypes(), (type: string) => {
          Row() {
            Radio({ value: type, group: 'refundReasonType' })
              .checked(this.selectedReasonType === type)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.selectedReasonType = type;
                }
              })

            Text(this.getRefundLabel(type))
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))
              .margin({ left: 10 })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })
        })
      }
      .width('100%')
      .margin({ top: 10 })

      Text('退款原因')
        .width('100%')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 12 })

      TextArea({
        text: this.reason,
        placeholder: '请说明退款原因'
      })
        .width('100%')
        .height(96)
        .fontSize(15)
        .backgroundColor('#F7FAFD')
        .borderRadius(16)
        .margin({ top: 8 })
        .padding(12)
        .onChange((value: string) => {
          this.reason = value;
        })

      Text('补充说明')
        .width('100%')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 12 })

      TextArea({
        text: this.description,
        placeholder: '选填，可补充服务问题、时间安排等信息'
      })
        .width('100%')
        .height(88)
        .fontSize(15)
        .backgroundColor('#F7FAFD')
        .borderRadius(16)
        .margin({ top: 8 })
        .padding(12)
        .onChange((value: string) => {
          this.description = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildRefundHistory() {
    Column() {
      SectionHeader({
        title: '退款记录',
        subtitle: '查看当前订单的历史退款申请。'
      })

      Card({
        title: '历史记录',
        content: this.buildRefundHistoryContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildRefundHistoryContent() {
    Column() {
      ForEach(this.refundRecords, (record: RefundRecord) => {
        Column() {
          Row() {
            Text(this.getStatusText(record.status))
              .fontSize($r('app.float.text_primary_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Blank()

            Text(record.appliedAt.substring(0, 10))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')

          Text(`退款金额：¥${record.refundAmount.toFixed(2)}`)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6 })

          Text(`原因：${record.reason}`)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })

        Divider()
          .color('#E0E8F2')
      })
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
        .fontColor(highlight ? '#D97706' : $r('app.color.text_primary'))
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  private buildSubmitBar() {
    Column() {
      Button(this.isSubmitting ? '提交中...' : '提交退款申请')
        .width('100%')
        .height(46)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(18)
        .enabled(this.reason.trim().length > 0 && !this.isSubmitting)
        .opacity(this.reason.trim().length > 0 && !this.isSubmitting ? 1 : 0.6)
        .onClick(() => {
          this.submitRefund();
        })

      Text('审核通过后，预计 1-5 个工作日内完成退款。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 18 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 10,
      color: '#10172F14',
      offsetX: 0,
      offsetY: -4
    })
  }

  private getReasonTypes(): string[] {
    return [
      RefundReasonType.STUDENT_TRANSFER,
      RefundReasonType.SERVICE_QUALITY,
      RefundReasonType.SCHEDULE_CHANGE,
      RefundReasonType.PERSONAL_REASON,
      RefundReasonType.OTHER
    ];
  }
}
