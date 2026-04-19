/**
 * SmartGuardian - Parent Refund Page
 * Refund application and management
 */

import router from '@ohos.router';
import { RefundRecord, CreateRefundParams, RefundReasonType } from '../../models/refund';
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
  @State selectedReasonType: string = 'PERSONAL_REASON';
  @State reason: string = '';
  @State description: string = '';
  @State isSubmitting: boolean = false;
  @State refundRecords: RefundRecord[] = [];

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
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
        // Mock calculation
        this.refundAmount = this.orderAmount * 0.9;
        this.deduction = this.orderAmount * 0.1;
      }
    } catch (error) {
      console.error('Failed to calculate refund:', error);
      this.refundAmount = this.orderAmount * 0.9;
      this.deduction = this.orderAmount * 0.1;
    }
  }

  async loadRefundRecords() {
    try {
      const resp = await RefundService.getRefunds({ orderId: this.orderId });
      if (resp.code === 0 && resp.data) {
        this.refundRecords = resp.data.list || [];
      }
    } catch (error) {
      console.error('Failed to load refund records:', error);
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
        reason: this.reason,
        description: this.description
      };

      const resp = await RefundService.createRefund(params);
      if (resp.code === 0) {
        router.back();
      }
    } catch (error) {
      console.error('Failed to submit refund:', error);
    } finally {
      this.isSubmitting = false;
    }
  }

  build() {
    Column() {
      this.buildHeader()

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
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      this.buildSubmitButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => router.back())

      Text('申请退费')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank().width(24)
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: Number($r('app.float.status_bar_height')) + 10 })
  }

  @Builder
  buildOrderInfo() {
    Column() {
      Text('订单信息')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      Row() {
        Text('订单编号')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(this.orderNo)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .margin({ top: 8 })

      Row() {
        Text('服务名称')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(this.serviceName)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .margin({ top: 8 })

      Row() {
        Text('订单金额')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(`¥${this.orderAmount.toFixed(2)}`)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor('#FF5722')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }

  @Builder
  buildAmountInfo() {
    Column() {
      Text('退费金额')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      Row() {
        Text('订单金额')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(`¥${this.orderAmount.toFixed(2)}`)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')

      Row() {
        Text('手续费')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(`-¥${this.deduction.toFixed(2)}`)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor('#FF5722')
      }
      .width('100%')
      .margin({ top: 8 })

      Divider().color('#E0E0E0').margin({ top: 12, bottom: 12 })

      Row() {
        Text('可退金额')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text(`¥${this.refundAmount.toFixed(2)}`)
          .fontSize(20)
          .fontColor('#FF5722')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')

      Row() {
        Image($r('app.media.ic_info'))
          .width(16)
          .height(16)

        Text('退费将收取10%手续费')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
  }

  @Builder
  buildRefundForm() {
    Column() {
      Text('退费信息')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      Text('退费原因类型')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      Column() {
        ForEach(['STUDENT_TRANSFER', 'SERVICE_QUALITY', 'SCHEDULE_CHANGE', 'PERSONAL_REASON', 'OTHER'], (type: string) => {
          Row() {
            Radio({ value: type, group: 'reasonType' })
              .checked(this.selectedReasonType === type)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.selectedReasonType = type;
                }
              })

            Text(this.getReasonTypeText(type))
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        })
      }
      .width('100%')

      Text('退费原因')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 16 })

      TextArea({ placeholder: '请输入退费原因', text: $$this.reason })
        .width('100%')
        .height(80)
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
        .margin({ top: 8 })

      Text('补充说明（选填）')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 16 })

      TextArea({ placeholder: '请输入补充说明', text: $$this.description })
        .width('100%')
        .height(60)
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildRefundHistory() {
    Column() {
      Text('退款记录')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      ForEach(this.refundRecords, (record: RefundRecord) => {
        Row() {
          Column() {
            Text(this.getStatusText(record.status))
              .fontSize($r('app.float.text_primary_size'))
              .fontWeight(FontWeight.Medium)

            Text(`¥${record.refundAmount.toFixed(2)}`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(record.appliedAt.substring(0, 10))
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSubmitButton() {
    Column() {
      Button('提交退费申请')
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(22)
        .enabled(this.reason.trim().length > 0 && !this.isSubmitting)
        .onClick(() => this.submitRefund())

      Text('提交后需等待机构审核，审核通过后将在3-5个工作日内退款')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8 })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  getReasonTypeText(type: string): string {
    const texts: Record<string, string> = {
      'STUDENT_TRANSFER': '学生转学',
      'SERVICE_QUALITY': '服务质量问题',
      'SCHEDULE_CHANGE': '时间变动',
      'PERSONAL_REASON': '个人原因',
      'OTHER': '其他'
    };
    return texts[type] || '其他';
  }

  getStatusText(status: string): string {
    const texts: Record<string, string> = {
      'PENDING': '待审核',
      'APPROVED': '已批准',
      'REJECTED': '已拒绝',
      'PROCESSING': '退款中',
      'COMPLETED': '已完成',
      'CANCELLED': '已取消'
    };
    return texts[status] || '未知';
  }
}