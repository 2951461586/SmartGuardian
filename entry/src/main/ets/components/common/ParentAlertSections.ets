import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { AlertRecord } from '../../models/alert';
import { Card } from './Card';

const DEFAULT_ALERT: AlertRecord = {
  id: 0,
  studentId: 0,
  studentName: '',
  alertType: '',
  severity: '',
  title: '',
  description: '',
  status: '',
  createdAt: '',
  updatedAt: ''
};

@Component
export struct ParentAlertResponseCard {
  onRefresh?: () => void;

  build() {
    Card({
      title: '家长响应建议',
      subtitle: '优先处理高风险和与接送、考勤相关的活跃预警。',
      actionText: '刷新',
      onAction: () => {
        if (this.onRefresh) {
          this.onRefresh();
        }
      },
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Column() {
      this.buildGuideItem('高风险预警', '建议第一时间查看详情，并尽快联系老师或机构。')
      this.buildGuideItem('接送与考勤', '优先确认签到签退、到校离校和代接送情况。')
      this.buildGuideItem('家长处置动作', '进入详情后可直接执行“已知悉”或“忽略”。')
    }
    .width('100%')
  }

  @Builder
  private buildGuideItem(title: string, description: string) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(HarmonyColor.textPrimary)

      Text(description)
        .fontSize(12)
        .fontColor(HarmonyColor.textSecondary)
        .lineHeight(18)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(18)
    .margin({ top: 10 })
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct ParentAlertListItemCard {
  @Prop alert: AlertRecord = DEFAULT_ALERT;
  severityTextResolver?: (severity: string) => string;
  severityColorResolver?: (severity: string) => string;
  severityBgColorResolver?: (severity: string) => string;
  timeResolver?: (value: string) => string;
  onAlertClick?: (alert: AlertRecord) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.alert.title)
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor(HarmonyColor.textPrimary)

          Text(this.alert.studentName)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(HarmonyColor.textSecondary)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text(this.resolveSeverityText(this.alert.severity))
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.resolveSeverityColor(this.alert.severity))
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(this.resolveSeverityBgColor(this.alert.severity))
            .borderRadius(999)

          Text(this.resolveTime(this.alert.createdAt))
            .fontSize(11)
            .fontColor(HarmonyColor.textTertiary)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Text(this.alert.description)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyColor.textSecondary)
        .lineHeight(20)
        .margin({ top: 12 })
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.alert.suggestedAction) {
        Row() {
          Image($r('app.media.ic_info'))
            .width(16)
            .height(16)
            .fillColor(HarmonyColor.info)

          Text(`建议操作：${this.alert.suggestedAction}`)
            .fontSize(12)
            .fontColor(HarmonyColor.info)
            .layoutWeight(1)
            .margin({ left: 8 })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor(HarmonyReport.accentSurface)
        .borderRadius(18)
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(24)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 24,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: HarmonyColor.overlaySoft,
      offsetX: 0,
      offsetY: 6
    })
    .margin({ bottom: 12 })
    .onClick(() => {
      if (this.onAlertClick) {
        this.onAlertClick(this.alert);
      }
    })
  }

  private resolveSeverityText(severity: string): string {
    if (this.severityTextResolver) {
      return this.severityTextResolver(severity);
    }
    return severity;
  }

  private resolveSeverityColor(severity: string): string {
    if (this.severityColorResolver) {
      return this.severityColorResolver(severity);
    }
    return HarmonyColor.textSecondary;
  }

  private resolveSeverityBgColor(severity: string): string {
    if (this.severityBgColorResolver) {
      return this.severityBgColorResolver(severity);
    }
    return HarmonyColor.surfaceSubtle;
  }

  private resolveTime(value: string): string {
    if (this.timeResolver) {
      return this.timeResolver(value);
    }
    return value;
  }
}

@Component
export struct ParentAlertDetailSheetCard {
  @Prop alert: AlertRecord = DEFAULT_ALERT;
  severityTextResolver?: (severity: string) => string;
  typeTextResolver?: (type: string) => string;
  onDismiss?: (alertId: number) => void;
  onAcknowledge?: (alertId: number) => void;

  build() {
    Column() {
      Card({
        title: this.alert.title,
        subtitle: `${this.alert.studentName} · ${this.resolveTypeText(this.alert.alertType)}`,
        content: () => { this.buildContent() }
      })

      Row() {
        Button('忽略')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(HarmonyColor.info)
          .backgroundColor(HarmonyReport.accentSurface)
          .borderRadius(18)
          .onClick(() => {
            if (this.onDismiss) {
              this.onDismiss(this.alert.id);
            }
          })

        Button('已知悉')
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(HarmonyColor.textInverse)
          .backgroundColor(HarmonyColor.info)
          .borderRadius(18)
          .margin({ left: 12 })
          .onClick(() => {
            if (this.onAcknowledge) {
              this.onAcknowledge(this.alert.id);
            }
          })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 18 })
    }
    .width('100%')
  }

  @Builder
  private buildContent() {
    Column() {
      this.buildDetailRow('预警类型', this.resolveTypeText(this.alert.alertType))
      this.buildDetailRow('严重程度', this.resolveSeverityText(this.alert.severity))
      this.buildDetailRow('创建时间', this.alert.createdAt)
      this.buildDetailRow('详细描述', this.alert.description)

      if (this.alert.suggestedAction) {
        this.buildDetailRow('建议操作', this.alert.suggestedAction)
      }
    }
    .width('100%')
  }

  @Builder
  private buildDetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor(HarmonyColor.textSecondary)
        .width(72)

      Text(value)
        .fontSize(14)
        .fontColor(HarmonyColor.textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  private resolveSeverityText(severity: string): string {
    if (this.severityTextResolver) {
      return this.severityTextResolver(severity);
    }
    return severity;
  }

  private resolveTypeText(type: string): string {
    if (this.typeTextResolver) {
      return this.typeTextResolver(type);
    }
    return type;
  }
}
