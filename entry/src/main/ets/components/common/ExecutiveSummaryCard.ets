import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';

import { Card } from './Card';

@Component
export struct ExecutiveSummaryCard {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop badgeText: string = '';
  @Prop value: string = '';
  @Prop valueLabel: string = '';
  @Prop firstMetricLabel: string = '';
  @Prop firstMetricValue: string = '';
  @Prop secondMetricLabel: string = '';
  @Prop secondMetricValue: string = '';

  build() {
    Card({
      title: this.title,
      subtitle: this.subtitle,
      customPadding: 18,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Row() {
      Column() {
        Text(this.badgeText)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(HarmonyReport.cautionSurface)
          .borderRadius(999)

        Text(this.value)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 14 })

        Text(this.valueLabel)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        this.buildCompactMetric(this.firstMetricLabel, this.firstMetricValue, HarmonyReport.accent)
        this.buildCompactMetric(this.secondMetricLabel, this.secondMetricValue, HarmonyColor.inkStrong)
      }
      .width(124)
    }
    .width('100%')
  }

  @Builder
  private buildCompactMetric(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: label === this.secondMetricLabel ? 0 : 10 })
  }
}
