import { HarmonyColor, HarmonyReport, harmonyShadowColor } from '../../common/HarmonyDesign';
import { AlertRecord } from '../../models/alert';
import { RefundRecord } from '../../models/refund';
import { Card, StatCard } from './Card';
import { EmptyState, EmptyType } from './EmptyState';
import { SectionHeader } from './SectionHeader';
import { TabBar } from './TabBar';

export interface AdminOverviewMetric {
  value: string | number;
  label: string;
  icon: ResourceStr;
  iconColor: string;
}

@Component
export struct AdminOverviewMetricSection {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop metrics: AdminOverviewMetric[] = [];

  build() {
    Column() {
      SectionHeader({
        title: this.title,
        subtitle: this.subtitle
      })

      Row() {
        ForEach(this.metrics, (metric: AdminOverviewMetric, index: number) => {
          StatCard({
            value: metric.value,
            label: metric.label,
            icon: metric.icon,
            iconColor: metric.iconColor
          })
          .layoutWeight(1)

          if (index < this.metrics.length - 1) {
            Blank().width(12)
          }
        }, (metric: AdminOverviewMetric) => `${metric.label}`)
      }
      .width('100%')
    }
    .width('100%')
  }
}

@Component
export struct AdminStatusFilterCard {
  @Prop title: string = '状态筛选';
  @Prop subtitle: string = '';
  @Prop tabs: string[] = [];
  @Prop currentIndex: number = 0;
  onTabChange?: (index: number) => void;

  build() {
    Card({
      title: this.title,
      subtitle: this.subtitle,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: this.currentIndex,
      onTabChange: (index: number) => {
        if (this.onTabChange) {
          this.onTabChange(index);
        }
      }
    })
  }
}

@Component
export struct AdminAlertListSection {
  @Prop alerts: AlertRecord[] = [];
  @Prop subtitle: string = '';
  severityTextResolver?: (severity: string) => string;
  severityColorResolver?: (severity: string) => string;
  statusTextResolver?: (status: string) => string;
  onPrimary?: (alert: AlertRecord) => void;
  onSecondary?: (alert: AlertRecord) => void;
  onTertiary?: (alert: AlertRecord) => void;
  onEmptyAction?: () => void;

  build() {
    Column() {
      SectionHeader({
        title: '告警列表',
        subtitle: this.subtitle
      })

      if (this.alerts.length === 0) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '暂无告警',
          customDescription: this.subtitle,
          actionText: '刷新',
          onAction: this.onEmptyAction
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.alerts, (alert: AlertRecord) => {
            ListItem() {
              AdminAlertListItemCard({
                alert: alert,
                severityText: this.resolveSeverityText(alert.severity),
                severityColor: this.resolveSeverityColor(alert.severity),
                statusText: this.resolveStatusText(alert.status),
                onPrimary: (): void => {
                  if (this.onPrimary) {
                    this.onPrimary(alert);
                  }
                },
                onSecondary: (): void => {
                  if (this.onSecondary) {
                    this.onSecondary(alert);
                  }
                },
                onTertiary: (): void => {
                  if (this.onTertiary) {
                    this.onTertiary(alert);
                  }
                }
              })
            }
          }, (alert: AlertRecord) => `${alert.id}`)
        }
        .width('100%')
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)
        .cachedCount(6)
      }
    }
    .width('100%')
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

  private resolveStatusText(status: string): string {
    if (this.statusTextResolver) {
      return this.statusTextResolver(status);
    }
    return status;
  }
}

@Component
struct AdminAlertListItemCard {
  @Prop alert: AlertRecord = {
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
  @Prop severityText: string = '';
  @Prop severityColor: string = HarmonyColor.textSecondary;
  @Prop statusText: string = '';
  onPrimary?: () => void;
  onSecondary?: () => void;
  onTertiary?: () => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.alert.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(HarmonyColor.textPrimary)

          Text(`${this.alert.studentName} · ${this.alert.alertType}`)
            .fontSize(12)
            .fontColor(HarmonyColor.textSecondary)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.statusText)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.severityColor)
      }
      .width('100%')

      Text(this.alert.description)
        .width('100%')
        .fontSize(13)
        .lineHeight(20)
        .fontColor(HarmonyColor.textSecondary)
        .margin({ top: 12 })

      Row() {
        Text(`严重级别：${this.severityText}`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.severityColor)

        Blank()

        Text(this.alert.createdAt)
          .fontSize(12)
          .fontColor(HarmonyColor.textTertiary)
      }
      .width('100%')
      .margin({ top: 12 })

      if (this.alert.suggestedAction) {
        Text(`建议动作：${this.alert.suggestedAction}`)
          .width('100%')
          .fontSize(12)
          .fontColor(HarmonyColor.textTertiary)
          .margin({ top: 10 })
      }

      if (this.alert.status === 'ACTIVE') {
        Row() {
          this.buildActionText('确认', HarmonyColor.info, this.onPrimary)
          this.buildActionText('解决', HarmonyReport.positive, this.onSecondary)
          this.buildActionText('忽略', HarmonyReport.danger, this.onTertiary)
        }
        .width('100%')
        .margin({ top: 14 })
      } else if (this.alert.status === 'ACKNOWLEDGED') {
        Row() {
          this.buildActionText('标记解决', HarmonyReport.positive, this.onSecondary)
        }
        .width('100%')
        .margin({ top: 14 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(20)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  private buildActionText(label: string, color: string, action?: () => void) {
    Text(label)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(color)
      .margin({ right: 18 })
      .onClick(() => {
        if (action) {
          action();
        }
      })
  }
}

@Component
export struct AdminRefundListSection {
  @Prop refunds: RefundRecord[] = [];
  @Prop subtitle: string = '';
  statusTextResolver?: (status: string) => string;
  statusColorResolver?: (status: string) => string;
  onCancel?: (refund: RefundRecord) => void;
  onEmptyAction?: () => void;

  build() {
    Column() {
      SectionHeader({
        title: '退款列表',
        subtitle: this.subtitle
      })

      if (this.refunds.length === 0) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '暂无退款记录',
          customDescription: this.subtitle,
          actionText: '刷新',
          onAction: this.onEmptyAction
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.refunds, (refund: RefundRecord) => {
            ListItem() {
              AdminRefundListItemCard({
                refund: refund,
                statusText: this.resolveStatusText(refund.status),
                statusColor: this.resolveStatusColor(refund.status),
                onCancel: (): void => {
                  if (this.onCancel) {
                    this.onCancel(refund);
                  }
                }
              })
            }
          }, (refund: RefundRecord) => `${refund.id}`)
        }
        .width('100%')
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)
        .cachedCount(6)
      }
    }
    .width('100%')
  }

  private resolveStatusText(status: string): string {
    if (this.statusTextResolver) {
      return this.statusTextResolver(status);
    }
    return status;
  }

  private resolveStatusColor(status: string): string {
    if (this.statusColorResolver) {
      return this.statusColorResolver(status);
    }
    return HarmonyColor.textSecondary;
  }
}

@Component
struct AdminRefundListItemCard {
  @Prop refund: RefundRecord = {
    id: 0,
    orderNo: '',
    orderId: 0,
    studentId: 0,
    studentName: '',
    serviceProductId: 0,
    serviceName: '',
    refundAmount: 0,
    reason: '',
    reasonType: '',
    status: '',
    appliedAt: '',
    createdAt: '',
    updatedAt: ''
  };
  @Prop statusText: string = '';
  @Prop statusColor: string = HarmonyColor.textSecondary;
  onCancel?: () => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(`${this.refund.studentName} · ${this.refund.serviceName}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(HarmonyColor.textPrimary)

          Text(`订单 ${this.refund.orderNo}`)
            .fontSize(12)
            .fontColor(HarmonyColor.textSecondary)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.statusText)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.statusColor)
      }
      .width('100%')

      Row() {
        this.buildMetricColumn('退款金额', `¥${Number(this.refund.refundAmount).toFixed(2)}`)
        this.buildMetricColumn('申请时间', this.refund.appliedAt.substring(0, 10))
      }
      .width('100%')
      .margin({ top: 14 })

      Text(`原因：${this.refund.reason}`)
        .width('100%')
        .fontSize(13)
        .fontColor(HarmonyColor.textSecondary)
        .margin({ top: 12 })

      if (this.refund.description) {
        Text(`补充说明：${this.refund.description}`)
          .width('100%')
          .fontSize(12)
          .lineHeight(20)
          .fontColor(HarmonyColor.textTertiary)
          .margin({ top: 8 })
      }

      Row() {
        if (this.refund.status === 'PENDING') {
          Text('撤销申请')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(HarmonyReport.danger)
            .onClick(() => {
              if (this.onCancel) {
                this.onCancel();
              }
            })
        } else if (this.refund.reviewRemark) {
          Text(this.refund.reviewRemark)
            .fontSize(12)
            .fontColor(HarmonyColor.textTertiary)
        } else {
          Text('已记录流转状态')
            .fontSize(12)
            .fontColor(HarmonyColor.textTertiary)
        }
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(20)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  private buildMetricColumn(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(HarmonyColor.textPrimary)

      Text(label)
        .fontSize(12)
        .fontColor(HarmonyColor.textSecondary)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
