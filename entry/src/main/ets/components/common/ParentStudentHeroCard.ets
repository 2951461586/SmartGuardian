import { UserRole } from '../../models/common';
import { HarmonyColor, HarmonyRadius, harmonyShadowColor } from '../../common/HarmonyDesign';
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
      Column() {
        Row() {
          Image($r('app.media.ic_default_avatar'))
            .width(50)
            .height(50)
            .objectFit(ImageFit.Cover)
            .margin({ right: 12 })

          Column() {
            Text(this.studentName)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(HarmonyColor.textPrimary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.studentMeta)
              .fontSize(12)
              .fontColor(getRolePalette(UserRole.PARENT).primary)
              .margin({ top: 5 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(`学号：${this.studentNo}`)
          .fontSize(13)
          .fontColor(HarmonyColor.textSecondary)
          .margin({ top: 14 })

        Text(`学校：${this.schoolName}`)
          .fontSize(13)
          .fontColor(HarmonyColor.textSecondary)
          .margin({ top: 6 })

        Text(this.sessionTitle)
          .fontSize(13)
          .fontColor(getRolePalette(UserRole.PARENT).primaryDark)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(getRolePalette(UserRole.PARENT).light)
          .borderRadius(HarmonyRadius.pill)
          .margin({ top: 12 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Image($r('app.media.sg_scene_parent_care_v2'))
        .width(120)
        .height(104)
        .objectFit(ImageFit.Cover)
        .borderRadius(22)
        .margin({ left: 14 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .linearGradient({
      angle: 145,
      colors: [[HarmonyColor.surface, 0], [getRolePalette(UserRole.PARENT).soft, 1]]
    })
    .border({
      width: 1,
      color: getRolePalette(UserRole.PARENT).border,
      radius: 28,
      style: BorderStyle.Solid
    })
    .borderRadius(28)
    .shadow({
      radius: 14,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 8
    })
    .alignItems(VerticalAlign.Center)
  }
}
