import { HarmonyColor, harmonyShadowColor } from '../../common/HarmonyDesign';

@Component
export struct IconActionButton {
  @Prop icon: Resource | string | PixelMap = '';
  @Prop iconColor: ResourceColor = HarmonyColor.inkStrong;
  @Prop boxBgColor: ResourceColor = HarmonyColor.surface;
  @Prop boxBorderColor: ResourceColor = HarmonyColor.line;
  @Prop badgeCount: number = 0;
  @Prop badgeColor: ResourceColor = $r('app.color.error');
  @Prop boxSize: number = 46;
  @Prop iconSize: number = 22;
  onButtonClick?: () => void;

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Image(this.icon)
          .width(this.iconSize)
          .height(this.iconSize)
          .objectFit(ImageFit.Contain)
          .fillColor(this.iconColor)
      }
      .width(this.boxSize)
      .height(this.boxSize)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.boxBgColor)
      .borderRadius(20)
      .border({
        width: 1,
        color: this.boxBorderColor,
        radius: 20,
        style: BorderStyle.Solid
      })
      .shadow({
        radius: 10,
        color: harmonyShadowColor(),
        offsetX: 0,
        offsetY: 4
      })

      if (this.badgeCount > 0) {
        Text(this.badgeCount > 99 ? '99+' : `${this.badgeCount}`)
          .fontSize(10)
          .fontColor(HarmonyColor.textInverse)
          .backgroundColor(this.badgeColor)
          .borderRadius(9)
          .padding({ left: 5, right: 5, top: 1, bottom: 1 })
      }
    }
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
  }
}
