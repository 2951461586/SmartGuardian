import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { Card } from './Card';
import { EmptyState, EmptyType } from './EmptyState';

export interface TeacherSessionSummaryData {
  title: string;
  timeText: string;
  statusText: string;
  statusColor: string;
  statusBgColor: string;
  signedCount: string;
  unsignedCount: string;
}

export interface TeacherSessionListItemData {
  id: number;
  title: string;
  subtitle: string;
  statusText: string;
  statusColor: string;
  statusBgColor: string;
}

@Component
export struct TeacherSessionStatsCard {
  @Prop hasSession: boolean = false;
  @Prop subtitle: string = '';
  @Prop emptyDescription: string = '';
  @Prop summary: TeacherSessionSummaryData = {
    title: '',
    timeText: '',
    statusText: '',
    statusColor: HarmonyReport.positive,
    statusBgColor: HarmonyReport.positiveSurface,
    signedCount: '0',
    unsignedCount: '0'
  };

  build() {
    Card({
      title: '当前班次',
      subtitle: this.subtitle,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    if (this.hasSession) {
      Column() {
        Row() {
          Column() {
            Text(this.summary.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.summary.timeText)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(this.summary.statusText)
            .fontSize(12)
            .fontColor(this.summary.statusColor)
            .backgroundColor(this.summary.statusBgColor)
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        }
        .width('100%')

        Row() {
          this.buildInlineMetric('已签到', this.summary.signedCount, HarmonyReport.positive)
          Blank().width(10)
          this.buildInlineMetric('待签到', this.summary.unsignedCount, HarmonyReport.caution)
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无班次安排',
        customDescription: this.emptyDescription
      })
    }
  }

  @Builder
  private buildInlineMetric(label: string, value: string, color: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct TeacherSessionsPreviewCard {
  @Prop items: TeacherSessionListItemData[] = [];
  @Prop emptyDescription: string = '';
  @Prop actionText: string = '查看全部';
  onAction?: () => void;

  build() {
    Card({
      title: '今日班次',
      actionText: this.actionText,
      onAction: this.onAction,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    if (this.items.length > 0) {
      Column() {
        ForEach(this.items, (item: TeacherSessionListItemData, index: number) => {
          Row() {
            Column() {
              Text(item.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(item.subtitle)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(item.statusText)
              .fontSize(12)
              .fontColor(item.statusColor)
              .backgroundColor(item.statusBgColor)
              .borderRadius(12)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })

          if (index < this.items.length - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 10, bottom: 10 })
          }
        }, (item: TeacherSessionListItemData) => `${item.id}`)
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无班次记录',
        customDescription: this.emptyDescription
      })
    }
  }
}
