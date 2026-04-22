/**
 * SmartGuardian - ActionButton Component
 * Reusable enterprise quick-action tile
 */

@Component
export struct ActionButton {
  @Prop label: string = '';
  @Prop icon: Resource | string | PixelMap = '';
  @Prop bgColor: string = '#EAF1FF';
  @Prop iconColor: string = '#1F5EFF';
  onButtonClick?: () => void;

  build() {
    Column() {
      Row() {
        Column() {
          Image(this.icon)
            .width(22)
            .height(22)
            .objectFit(ImageFit.Contain)
            .fillColor(this.iconColor)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.bgColor)
        .borderRadius(16)

        Blank()
      }
      .width('100%')

      Text(this.label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .maxLines(2)
        .textAlign(TextAlign.Start)
        .margin({ top: 12 })
    }
    .layoutWeight(1)
    .height(108)
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: '#0F11301A',
      offsetX: 0,
      offsetY: 6
    })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
  }
}
