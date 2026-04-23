/**
 * SmartGuardian - ActionButton Component
 * Reusable quick-action tile in the new light campus style
 */

@Component
export struct ActionButton {
  @Prop label: string = '';
  @Prop icon: Resource | string | PixelMap = '';
  @Prop bgColor: string = '#EAF2FF';
  @Prop iconColor: string = '#3F7DFF';
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
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.bgColor)
        .borderRadius(18)

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
    .height(112)
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({
      width: 1,
      color: '#E4ECFA',
      radius: 22,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: '#2F6BDE0D',
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
