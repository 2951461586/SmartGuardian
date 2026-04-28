import { UserRole } from '../../models/common';
import { HarmonyColor, HarmonyRadius, harmonyShadowColor } from '../../common/HarmonyDesign';
import { getRolePalette } from '../../common/RoleTheme';

@Component
export struct AdminSummaryHeroCard {
  @Prop netIncome: string = '¥0';
  @Prop attendanceRate: string = '0%';
  @Prop pendingOrders: string = '0';

  build() {
    Row() {
      Column() {
        Text('运营总览')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(getRolePalette(UserRole.ORG_ADMIN).primary)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(getRolePalette(UserRole.ORG_ADMIN).light)
          .borderRadius(HarmonyRadius.pill)

        Text(this.netIncome)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(HarmonyColor.textPrimary)
          .margin({ top: 14 })

        Text('当前统计周期净收入')
          .fontSize(14)
          .fontColor(HarmonyColor.textSecondary)
          .margin({ top: 8 })

        Row() {
          this.buildHeroMetric(this.attendanceRate, '出勤率')
          Blank().width(12)
          this.buildHeroMetric(this.pendingOrders, '待处理')
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('今日摘要')
          .fontSize(12)
          .fontColor(getRolePalette(UserRole.ORG_ADMIN).primary)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(getRolePalette(UserRole.ORG_ADMIN).light)
          .borderRadius(HarmonyRadius.pill)

        Image($r('app.media.sg_scene_admin_operations_v2'))
          .width(116)
          .height(94)
          .objectFit(ImageFit.Cover)
          .borderRadius(22)
          .margin({ top: 16 })
      }
      .alignItems(HorizontalAlign.End)
      .margin({ left: 14 })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .linearGradient({
      angle: 145,
      colors: [[HarmonyColor.surface, 0], [getRolePalette(UserRole.ORG_ADMIN).soft, 1]]
    })
    .border({
      width: 1,
      color: getRolePalette(UserRole.ORG_ADMIN).border,
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
  }

  @Builder
  private buildHeroMetric(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(getRolePalette(UserRole.ORG_ADMIN).primaryDark)

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
