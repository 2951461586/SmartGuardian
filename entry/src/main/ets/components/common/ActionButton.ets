/**
 * SmartGuardian - ActionButton Component
 * Reusable quick-action tile in the tri-portal style
 */

import { HarmonyColor, HarmonyRadius, HarmonySpace } from '../../common/HarmonyDesign';
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
            .width($r('app.float.icon_small_size'))
            .height($r('app.float.icon_small_size'))
            .objectFit(ImageFit.Contain)
            .fillColor(this.iconColor || getCurrentRolePalette().primary)
        }
        .width($r('app.float.avatar_medium_size'))
        .height($r('app.float.avatar_medium_size'))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.bgColor || getCurrentRolePalette().light)
        .borderRadius(HarmonyRadius.control)

        Blank()
      }
      .width('100%')

      Text(this.label)
        .fontSize($r('app.float.text_tiny_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .maxLines(2)
        .textAlign(TextAlign.Start)
        .margin({ top: HarmonySpace.section })
    }
    .layoutWeight(1)
    .height($r('app.float.stat_card_height'))
    .padding(HarmonySpace.section)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(HarmonyRadius.card)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: HarmonyRadius.card,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: HarmonySpace.section,
      color: getCurrentRolePalette().shadow,
      offsetX: 0,
      offsetY: HarmonySpace.compact
    })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
  }
}
