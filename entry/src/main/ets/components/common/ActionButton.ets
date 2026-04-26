/**
 * SmartGuardian - ActionButton Component
 * Reusable quick-action tile in the tri-portal style
 */

import { HarmonyColor } from '../../common/HarmonyDesign';
import { getCurrentRolePalette } from '../../common/RoleTheme';

@Component
export struct ActionButton {
  @Prop label: string = '';
  @Prop icon: Resource | string | PixelMap = '';
  @Prop bgColor: string = '';
  @Prop iconColor: string = '';
  onButtonClick?: () => void;

  build() {
    Column() {
      Row() {
        Column() {
          Image(this.icon)
            .width(22)
            .height(22)
            .objectFit(ImageFit.Contain)
            .fillColor(this.iconColor || getCurrentRolePalette().primary)
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.bgColor || getCurrentRolePalette().light)
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
      color: getCurrentRolePalette().shadow,
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
