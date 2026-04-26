import { UserRole } from '../../models/common';
import { HarmonyColor, harmonyShadowColor } from '../../common/HarmonyDesign';
import { getRolePalette } from '../../common/RoleTheme';

@Component
export struct TeacherSessionHeroCard {
  @Prop sessionTitle: string = '';
  @Prop timeText: string = '';
  @Prop sessionCount: string = '0';
  @Prop signedCount: string = '0';
  @Prop statusText: string = '';

  build() {
    Row() {
      Column() {
        Text('今日在岗')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(getRolePalette(UserRole.TEACHER).primary)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(getRolePalette(UserRole.TEACHER).light)
          .borderRadius(999)

        Text(this.sessionTitle)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(HarmonyColor.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 14 })

        Text(this.timeText)
          .fontSize(14)
          .fontColor(HarmonyColor.textSecondary)
          .margin({ top: 8 })

        Row() {
          this.buildHeroMetric(this.sessionCount, '今日班次')
          Blank().width(12)
          this.buildHeroMetric(this.signedCount, '已签到')
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text(this.statusText)
          .fontSize(12)
          .fontColor(getRolePalette(UserRole.TEACHER).primary)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(getRolePalette(UserRole.TEACHER).light)
          .borderRadius(999)

        Image($r('app.media.sg_illustration_teaching'))
          .width(108)
          .height(92)
          .objectFit(ImageFit.Contain)
          .opacity(0.88)
          .margin({ top: 16 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .linearGradient({
      angle: 145,
      colors: [[HarmonyColor.surface, 0], [getRolePalette(UserRole.TEACHER).soft, 1]]
    })
    .border({
      width: 1,
      color: getRolePalette(UserRole.TEACHER).border,
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
  }

  @Builder
  private buildHeroMetric(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(getRolePalette(UserRole.TEACHER).primaryDark)

      Text(label)
        .fontSize(12)
        .fontColor(HarmonyColor.textSecondary)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(HarmonyColor.overlaySurface)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }
}
