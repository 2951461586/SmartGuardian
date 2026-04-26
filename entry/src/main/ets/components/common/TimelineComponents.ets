import { HarmonyColor } from '../../common/HarmonyDesign';
import { Card } from './Card';
import { EmptyState, EmptyType } from './EmptyState';

export interface TimelineEventViewModel {
  id: number;
  studentId: number;
  eventType: 'ATTENDANCE' | 'HOMEWORK' | 'MESSAGE' | 'ORDER' | 'NOTE';
  eventTime: string;
  title: string;
  content: string;
  icon?: Resource;
}

@Component
export struct TimelineStudentSelectorCard {
  @Prop selectedStudentName: string = '';
  onSelect?: () => void;

  build() {
    Row() {
      Text('当前学生：')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))

      Text(this.selectedStudentName)
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary'))

      Image($r('app.media.ic_arrow_right'))
        .width($r('app.float.icon_small_size'))
        .height($r('app.float.icon_small_size'))
        .margin({ left: 4 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius($r('app.float.card_border_radius'))
    .onClick(() => {
      if (this.onSelect) {
        this.onSelect();
      }
    })
  }
}

@Component
export struct TimelineEventListCard {
  @Prop events: TimelineEventViewModel[] = [];
  @Prop emptyTitle: string = '暂无动态记录';
  @Prop emptyDescription: string = '当前学生还没有新的时间线内容。';

  build() {
    Card({
      title: '成长时间线',
      subtitle: '按时间顺序查看考勤、作业、通知和订单动态。',
      content: this.buildContent
    })
  }

  @Builder
  private buildContent() {
    if (this.events.length === 0) {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: this.emptyTitle,
        customDescription: this.emptyDescription
      })
    } else {
      List({ space: 16 }) {
        ForEach(this.events, (event: TimelineEventViewModel, index: number) => {
          ListItem() {
            this.buildTimelineItem(event, index)
          }
        }, (event: TimelineEventViewModel) => `${event.id}`)
      }
      .width('100%')
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
      .cachedCount(8)
    }
  }

  @Builder
  private buildTimelineItem(event: TimelineEventViewModel, index: number) {
    Row() {
      Column() {
        Circle()
          .width(12)
          .height(12)
          .fill($r('app.color.primary'))

        if (index < this.events.length - 1) {
          Divider()
            .vertical(true)
            .height(60)
            .width(2)
            .color(HarmonyColor.lineStrong)
        }
      }
      .width(20)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Row() {
          if (event.icon) {
            Image(event.icon)
              .width($r('app.float.icon_small_size'))
              .height($r('app.float.icon_small_size'))
          }

          Text(event.title)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ left: 8 })
        }
        .width('100%')

        Text(event.content)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })

        Text(this.formatTime(event.eventTime))
          .fontSize(12)
          .fontColor(HarmonyColor.textTertiary)
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .padding($r('app.float.card_padding'))
      .backgroundColor(HarmonyColor.surface)
      .borderRadius($r('app.float.card_border_radius'))
      .margin({ left: 12 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  private formatTime(time: string): string {
    if (!time) {
      return '';
    }
    return time.replace('T', ' ');
  }
}
