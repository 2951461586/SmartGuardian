import { UserRole } from '../../models/common';
import { HarmonyColor, harmonyShadowColor } from '../../common/HarmonyDesign';
import { getRolePalette } from '../../common/RoleTheme';

@Component
export struct ParentStudentHeroCard {
  @Prop studentName: string = '';
  @Prop studentMeta: string = '';
  @Prop studentNo: string = '--';
  @Prop schoolName: string = '';
  @Prop sessionTitle: string = '';

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_default_avatar'))
          .width(70)
          .height(70)
          .objectFit(ImageFit.Cover)
      }
      .width(86)
      .height(86)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(HarmonyColor.surface)
      .borderRadius(43)

      Column() {
        Row() {
          Text(this.studentName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(HarmonyColor.textInverse)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.studentMeta)
            .fontSize(11)
            .fontColor(getRolePalette(UserRole.PARENT).primary)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(getRolePalette(UserRole.PARENT).light)
            .borderRadius(999)
            .margin({ left: 10 })
        }
        .width('100%')

        Text(`学号：${this.studentNo}`)
          .fontSize(14)
          .fontColor(HarmonyColor.textInverseStrong)
          .margin({ top: 10 })

        Text(`学校：${this.schoolName}`)
          .fontSize(14)
          .fontColor(HarmonyColor.textInverseStrong)
          .margin({ top: 6 })

        Text(this.sessionTitle)
          .fontSize(13)
          .fontColor(HarmonyColor.textInverseMuted)
          .margin({ top: 10 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })

      Image($r('app.media.sg_illustration_children'))
        .width(104)
        .height(92)
        .objectFit(ImageFit.Contain)
        .opacity(0.88)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .linearGradient({
      angle: 130,
      colors: [[getRolePalette(UserRole.PARENT).primary, 0], [getRolePalette(UserRole.PARENT).primaryDark, 0.62], [getRolePalette(UserRole.PARENT).light, 1]]
    })
    .border({
      width: 1,
      color: getRolePalette(UserRole.PARENT).border,
      radius: 28,
      style: BorderStyle.Solid
    })
    .borderRadius(28)
    .shadow({
      radius: 18,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 10
    })
    .alignItems(VerticalAlign.Center)
  }
}
