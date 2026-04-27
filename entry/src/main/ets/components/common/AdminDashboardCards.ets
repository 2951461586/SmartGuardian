import { HarmonyReport } from '../../common/HarmonyDesign';
import { EmptyState, EmptyType } from './EmptyState';
import { Card, StatCard } from './Card';

export interface ActivityFeedItem {
  title: string;
  content: string;
  time: string;
}

@Component
export struct AdminOperationsOverviewCard {
  @Prop subtitle: string = '';
  @Prop totalStudents: number = 0;
  @Prop presentStudents: number = 0;
  @Prop attendanceRateText: string = '0%';
  @Prop netIncomeText: string = '￥0';

  build() {
    Card({
      title: '运营概览',
      subtitle: this.subtitle,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Column() {
      Row() {
        StatCard({
          value: this.totalStudents,
          label: '学生',
          icon: $r('app.media.ic_user'),
          iconColor: HarmonyReport.accent
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.presentStudents,
          label: '到校',
          icon: $r('app.media.ic_attendance'),
          iconColor: HarmonyReport.positive
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: this.attendanceRateText,
          label: '出勤率',
          icon: $r('app.media.ic_home'),
          iconColor: HarmonyReport.accent
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.netIncomeText,
          label: '净收入',
          icon: $r('app.media.ic_money'),
          iconColor: HarmonyReport.caution
        })
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
  }
}

@Component
export struct ActivityFeedCard {
  @Prop items: ActivityFeedItem[] = [];
  @Prop actionText: string = '查看详情';
  onAction?: () => void;

  build() {
    Card({
      title: '实时动态',
      subtitle: '聚焦今天需要关注的重点事项。',
      actionText: this.actionText,
      onAction: this.onAction,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    if (this.items.length > 0) {
      Column() {
        ForEach(this.items, (item: ActivityFeedItem, index: number) => {
          Row() {
            Column() {
              Text(item.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))

              Text(item.content)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .lineHeight(20)
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(item.time)
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .padding({ top: 4, bottom: 4 })

          if (index < this.items.length - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 10, bottom: 10 })
          }
        }, (item: ActivityFeedItem) => `${item.title}-${item.time}`)
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无实时动态',
        customDescription: '暂时没有新的运营动态。'
      })
    }
  }
}
