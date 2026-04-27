import { HarmonyColor } from '../../common/HarmonyDesign';
import { Card } from './Card';

export interface ParentScheduleNode {
  time: string;
  title: string;
  statusText: string;
  statusColor: string;
  statusBgColor: string;
}

@Component
export struct ParentScheduleCard {
  @Prop title: string = '今日托管安排';
  @Prop actionText: string = '查看全部';
  @Prop hintText: string = '温馨提示：请关注孩子的托管时间安排，及时查看动态。';
  @Prop items: ParentScheduleNode[] = [];
  onAction?: () => void;

  build() {
    Card({
      title: this.title,
      actionText: this.actionText,
      onAction: this.onAction,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Column() {
      ForEach(this.items, (item: ParentScheduleNode) => {
        this.buildScheduleItem(item)
      }, (item: ParentScheduleNode) => `${item.time}-${item.title}`)

      Row() {
        Image($r('app.media.ic_info'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.primary'))

        Text(this.hintText)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      .backgroundColor(HarmonyColor.surfaceSubtle)
      .borderRadius(16)
      .margin({ top: 16 })
    }
    .width('100%')
  }

  @Builder
  private buildScheduleItem(item: ParentScheduleNode) {
    Row() {
      Text(item.time)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .width(94)

      Text(item.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)

      Text(item.statusText)
        .fontSize(12)
        .fontColor(item.statusColor)
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor(item.statusBgColor)
        .borderRadius(999)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }
}
