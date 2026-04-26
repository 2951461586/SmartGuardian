import { HarmonyColor } from '../../common/HarmonyDesign';
import { RefundRecord } from '../../models/refund';
import { Card } from './Card';
import { EmptyType } from './EmptyState';
import { SectionHeader } from './SectionHeader';
import { StatefulContainer, ViewState } from './StatefulContainer';

@Component
export struct RefundReasonSection {
  @Prop reasonTypes: string[] = [];
  @Prop selectedReasonType: string = '';
  @Prop reason: string = '';
  @Prop description: string = '';
  labelResolver?: (type: string) => string;
  onTypeSelect?: (type: string) => void;
  onReasonChange?: (value: string) => void;
  onDescriptionChange?: (value: string) => void;

  build() {
    Column() {
      SectionHeader({
        title: '退款表单',
        subtitle: '请尽量清楚描述原因，便于机构尽快审核。'
      })

      Card({
        title: '退款原因',
        subtitle: '选择原因类型并补充详细说明。',
        content: this.buildCardContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildCardContent() {
    Column() {
      Text('原因类型')
        .width('100%')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_secondary'))

      Column() {
        ForEach(this.reasonTypes, (type: string) => {
          Row() {
            Radio({ value: type, group: 'refundReasonType' })
              .checked(this.selectedReasonType === type)
              .onChange((isChecked: boolean) => {
                if (isChecked && this.onTypeSelect) {
                  this.onTypeSelect(type);
                }
              })

            Text(this.getReasonLabel(type))
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))
              .margin({ left: 10 })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })
        }, (type: string) => type)
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
        .backgroundColor(HarmonyColor.surfaceSubtle)
        .borderRadius(16)
        .border({
          width: 1,
          color: HarmonyColor.line,
          radius: 16,
          style: BorderStyle.Solid
        })
        .margin({ top: 8 })
        .padding(12)
        .onChange((value: string) => {
          if (this.onReasonChange) {
            this.onReasonChange(value);
          }
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
        .backgroundColor(HarmonyColor.surfaceSubtle)
        .borderRadius(16)
        .border({
          width: 1,
          color: HarmonyColor.line,
          radius: 16,
          style: BorderStyle.Solid
        })
        .margin({ top: 8 })
        .padding(12)
        .onChange((value: string) => {
          if (this.onDescriptionChange) {
            this.onDescriptionChange(value);
          }
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private getReasonLabel(type: string): string {
    if (this.labelResolver) {
      return this.labelResolver(type);
    }
    return type;
  }
}

@Component
export struct RefundHistorySection {
  @Prop viewState: ViewState = ViewState.CONTENT;
  @Prop records: RefundRecord[] = [];
  statusTextResolver?: (status: string) => string;
  statusColorResolver?: (status: string) => string;

  build() {
    Column() {
      SectionHeader({
        title: '退款记录',
        subtitle: '查看当前订单历史退款申请和处理状态。'
      })

      Card({
        title: '历史记录',
        content: this.buildHistoryCardContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildHistoryCardContent() {
    StatefulContainer({
      state: this.viewState,
      loadingMessage: '正在加载退款记录...',
      emptyType: EmptyType.DEFAULT,
      emptyTitle: '暂无退款记录',
      emptyDescription: '当前订单还没有历史退款申请。',
      content: this.buildHistoryList
    })
  }

  @Builder
  private buildHistoryList() {
    List() {
      ForEach(this.records, (record: RefundRecord) => {
        ListItem() {
          Column() {
            Row() {
              Text(this.getStatusText(record.status))
                .fontSize($r('app.float.text_primary_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getStatusColor(record.status))

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
        }
      }, (record: RefundRecord) => `${record.id}`)
    }
    .width('100%')
    .height(this.records.length > 2 ? 240 : this.records.length * 98)
    .divider({ strokeWidth: 1, color: HarmonyColor.line })
    .scrollBar(BarState.Off)
  }

  private getStatusText(status: string): string {
    if (this.statusTextResolver) {
      return this.statusTextResolver(status);
    }
    return status;
  }

  private getStatusColor(status: string): string {
    if (this.statusColorResolver) {
      return this.statusColorResolver(status);
    }
    return HarmonyColor.textSecondary;
  }
}
