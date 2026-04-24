/**
 * SmartGuardian - Parent Alerts Page
 * Alert and warning center for parents
 */

import { AlertRecord, AlertStatistics } from '../../models/alert';
import { AlertService } from '../../services/api/alert';

@Entry
@Component
struct ParentAlertsPage {
  @State alerts: AlertRecord[] = [];
  @State isLoading: boolean = false;
  @State statistics: AlertStatistics | null = null;
  @State showDetailDialog: boolean = false;
  @State selectedAlert: AlertRecord | null = null;

  aboutToAppear() {
    this.loadAlerts();
    this.loadStatistics();
  }

  async loadAlerts() {
    this.isLoading = true;
    try {
      const resp = await AlertService.getActiveAlerts(1, 50);
      if (resp.code === 0 && resp.data) {
        this.alerts = resp.data.list ?? [];
      } else {
        this.alerts = [];
      }
    } catch (error) {
      console.error('Failed to load alerts:', String(error));
      this.alerts = [];
    } finally {
      this.isLoading = false;
    }
  }

  async loadStatistics() {
    try {
      const resp = await AlertService.getStatistics();
      if (resp.code === 0 && resp.data) {
        this.statistics = resp.data;
      } else {
        this.statistics = null;
      }
    } catch (error) {
      console.error('Failed to load statistics:', String(error));
      this.statistics = null;
    }
  }

  async acknowledgeAlert(alertId: number) {
    try {
      const resp = await AlertService.acknowledgeAlert({ alertId: alertId });
      if (resp.code === 0) {
        this.showDetailDialog = false;
        this.loadAlerts();
        this.loadStatistics();
      }
    } catch (error) {
      console.error('Failed to acknowledge alert:', String(error));
    }
  }

  async dismissAlert(alertId: number) {
    try {
      const resp = await AlertService.dismissAlert(alertId);
      if (resp.code === 0) {
        this.showDetailDialog = false;
        this.loadAlerts();
        this.loadStatistics();
      }
    } catch (error) {
      console.error('Failed to dismiss alert:', String(error));
    }
  }

  build() {
    Column() {
      this.buildHeader()

      if (this.statistics) {
        this.buildStatistics()
      }

      if (this.isLoading) {
        this.buildLoading()
      } else {
        this.buildAlertList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showDetailDialog, this.buildDetailSheet(), {
      height: 420,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => this.getUIContext().getRouter().back())

      Text('异常预警')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank().width(24)
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: Number($r('app.float.status_bar_height')) + 10 })
  }

  @Builder
  buildStatistics() {
    Column() {
      Row() {
        this.buildStatItem('活跃预警', this.statistics?.active || 0, '#FF5722')
        this.buildStatItem('已确认', this.statistics?.acknowledged || 0, '#FF9800')
        this.buildStatItem('已解决', this.statistics?.resolved || 0, '#4CAF50')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
  }

  @Builder
  buildStatItem(label: string, count: number, color: string) {
    Column() {
      Text(count.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildLoading() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color($r('app.color.primary'))
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildAlertList() {
    if (this.alerts.length === 0) {
      Column() {
        Image($r('app.media.ic_empty'))
          .width(120)
          .height(120)

        Text('暂无预警信息')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Column() {
          ForEach(this.alerts, (alert: AlertRecord) => {
            this.buildAlertItem(alert)
          })
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  buildAlertItem(alert: AlertRecord) {
    Column() {
      Row() {
        Column() {
          Text(alert.title)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(alert.studentName)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text(this.getSeverityText(alert.severity))
            .fontSize(12)
            .fontColor(Color.White)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(this.getSeverityColor(alert.severity))
            .borderRadius(4)

          Text(this.formatTime(alert.createdAt))
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Text(alert.description)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (alert.suggestedAction) {
        Row() {
          Image($r('app.media.ic_info'))
            .width(16)
            .height(16)

          Text('建议操作：' + alert.suggestedAction)
            .fontSize(12)
            .fontColor('#2196F3')
            .margin({ left: 4 })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })
        .padding(8)
        .backgroundColor('#E3F2FD')
        .borderRadius(4)
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: 12 })
    .onClick(() => {
      this.selectedAlert = alert;
      this.showDetailDialog = true;
    })
  }

  @Builder
  buildDetailSheet() {
    Column() {
      if (this.selectedAlert) {
        Text('预警详情')
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 16 })

        Column() {
          this.buildDetailRow('标题', this.selectedAlert.title)
          this.buildDetailRow('学生', this.selectedAlert.studentName)
          this.buildDetailRow('类型', this.getAlertTypeText(this.selectedAlert.alertType))
          this.buildDetailRow('严重程度', this.getSeverityText(this.selectedAlert.severity))
          this.buildDetailRow('描述', this.selectedAlert.description)

          if (this.selectedAlert.suggestedAction) {
            this.buildDetailRow('建议操作', this.selectedAlert.suggestedAction)
          }
        }
        .width('100%')
        .padding(16)

        Row() {
          Button('忽略')
            .fontSize(14)
            .fontColor($r('app.color.primary'))
            .backgroundColor('#E3F2FD')
            .layoutWeight(1)
            .onClick(() => {
              if (this.selectedAlert) {
                this.dismissAlert(this.selectedAlert.id);
              }
            })

          Button('已知悉')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .layoutWeight(1)
            .margin({ left: 12 })
            .onClick(() => {
              if (this.selectedAlert) {
                this.acknowledgeAlert(this.selectedAlert.id);
              }
            })
        }
        .width('100%')
        .padding(16)
      }
    }
    .width('100%')
  }

  @Builder
  buildDetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width(80)

      Text(value)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  getSeverityText(severity: string): string {
    switch (severity) {
      case 'LOW':
        return '低';
      case 'MEDIUM':
        return '中';
      case 'HIGH':
        return '高';
      case 'CRITICAL':
        return '紧急';
      default:
        return '未知';
    }
  }

  getSeverityColor(severity: string): string {
    switch (severity) {
      case 'LOW':
        return '#4CAF50';
      case 'MEDIUM':
        return '#FF9800';
      case 'HIGH':
        return '#FF5722';
      case 'CRITICAL':
        return '#D32F2F';
      default:
        return '#9E9E9E';
    }
  }

  getAlertTypeText(type: string): string {
    switch (type) {
      case 'ATTENDANCE_ANOMALY':
        return '考勤异常';
      case 'SAFETY_CONCERN':
        return '安全隐患';
      case 'ACADEMIC_PERFORMANCE':
        return '学业表现';
      case 'BEHAVIORAL_ISSUE':
        return '行为问题';
      case 'FEE_DUE':
        return '费用到期';
      case 'SYSTEM':
        return '系统提醒';
      default:
        return '其他';
    }
  }

  formatTime(time: string): string {
    if (!time) {
      return '';
    }
    const date = new Date(time);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));

    if (hours < 1) {
      return '刚刚';
    }
    if (hours < 24) {
      return `${hours}小时前`;
    }
    return time.substring(0, 10);
  }
}

