import { HarmonyColor, harmonyShadowColor } from '../../common/HarmonyDesign';

@Component
export struct ParentNoticeCard {
  @Prop summary: string = '';
  @Prop dateText: string = '今日';

  build() {
    Row() {
      Column() {
        Text('系统')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))

        Text('通知')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))
          .margin({ top: 2 })
      }
      .width(48)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(this.summary)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12, right: 12 })

      Text(this.dateText)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(22)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 22,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 6
    })
  }
}
