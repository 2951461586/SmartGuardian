import { HarmonyColor, harmonyShadowColor } from '../../common/HarmonyDesign';

export interface ReportMetricChip {
  label: string;
  value: string;
  color: string;
}

export interface ReportTrendRow {
  title: string;
  metrics: ReportMetricChip[];
}

@Component
export struct ReportTrendCard {
  @Prop sectionTitle: string = '';
  @Prop sectionSubtitle: string = '';
  @Prop cardTitle: string = '';
  @Prop cardSubtitle: string = '';
  @Prop rows: ReportTrendRow[] = [];

  build() {
    Column() {
      Text(this.cardTitle)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text(this.cardSubtitle)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 6, bottom: 16 })

      ForEach(this.rows, (row: ReportTrendRow, index: number) => {
        this.buildRow(row)
        if (index < this.rows.length - 1) {
          Divider().color(HarmonyColor.line).margin({ top: 10, bottom: 10 })
        }
      }, (row: ReportTrendRow) => row.title)
    }
    .width('100%')
    .padding(18)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(20)
    .shadow({ radius: 12, color: harmonyShadowColor(), offsetX: 0, offsetY: 4 })
  }

  @Builder
  private buildRow(row: ReportTrendRow) {
    Row() {
      Column() {
        Text(row.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      ForEach(row.metrics, (metric: ReportMetricChip, index: number) => {
        this.buildCompactMetric(metric)
        if (index < row.metrics.length - 1) {
          Blank().width(10)
        }
      }, (metric: ReportMetricChip) => `${row.title}-${metric.label}`)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildCompactMetric(metric: ReportMetricChip) {
    Column() {
      Text(metric.value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(metric.color)

      Text(metric.label)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }
}
