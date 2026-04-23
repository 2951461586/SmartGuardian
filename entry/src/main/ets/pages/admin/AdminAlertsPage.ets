/**
 * SmartGuardian - Admin Alerts Page
 * Admin alert handling workspace
 */

import {
  Card,
  EmptyState,
  EmptyType,
  HeaderTheme,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader,
  StatCard,
  TabBar
} from '../../components/common';
import { AlertQueryParams, AlertRecord, AlertStatistics } from '../../models/alert';
import { AlertService } from '../../services/api/alert';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { LogUtil } from '../../utils/LogUtil';

@Entry
@Component
struct AdminAlertsPage {
  @State alerts: AlertRecord[] = [];
  @State statistics: AlertStatistics | null = null;
  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State errorMessage: string = '';

  private readonly tabs: string[] = ['活动告警', '已确认', '已解决', '全部'];

  aboutToAppear() {
    ErrorHandlerUtil.setUIContext(this.getUIContext());
    this.loadData();
  }

  private buildQueryParams(): AlertQueryParams {
    const params: AlertQueryParams = {
      pageNum: 1,
      pageSize: 100
    };
    if (this.currentTab === 0) {
      params.status = 'ACTIVE';
    } else if (this.currentTab === 1) {
      params.status = 'ACKNOWLEDGED';
    } else if (this.currentTab === 2) {
      params.status = 'RESOLVED';
    }
    return params;
  }

  async loadData() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const alertsPromise = AlertService.getAlerts(this.buildQueryParams());
      const statisticsPromise = AlertService.getStatistics();
      const alertsResponse = await alertsPromise;
      const statisticsResponse = await statisticsPromise;

      if (alertsResponse.code === 0 && alertsResponse.data) {
        this.alerts = alertsResponse.data.list ? alertsResponse.data.list : [];
      } else {
        this.alerts = [];
        this.errorMessage = alertsResponse.message ? alertsResponse.message : '告警加载失败';
      }

      if (statisticsResponse.code === 0 && statisticsResponse.data) {
        this.statistics = statisticsResponse.data;
      } else {
        this.statistics = null;
      }
    } catch (error) {
      this.alerts = [];
      this.statistics = null;
      this.errorMessage = '告警加载失败，请稍后重试';
      LogUtil.error(`AdminAlertsPage loadData failed: ${String(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  async acknowledgeAlert(alert: AlertRecord) {
    try {
      const response = await AlertService.acknowledgeAlert({
        alertId: alert.id,
        note: '管理员已确认'
      });
      if (response.code === 0) {
        ErrorHandlerUtil.showSuccessToast('告警已确认');
        await this.loadData();
      } else {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '告警确认失败');
      }
    } catch (error) {
      LogUtil.error(`AdminAlertsPage acknowledgeAlert failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('告警确认失败');
    }
  }

  async resolveAlert(alert: AlertRecord) {
    try {
      const response = await AlertService.resolveAlert({
        alertId: alert.id,
        resolution: '管理员已完成排查并处理'
      });
      if (response.code === 0) {
        ErrorHandlerUtil.showSuccessToast('告警已标记解决');
        await this.loadData();
      } else {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '告警解决失败');
      }
    } catch (error) {
      LogUtil.error(`AdminAlertsPage resolveAlert failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('告警解决失败');
    }
  }

  async dismissAlert(alert: AlertRecord) {
    try {
      const response = await AlertService.dismissAlert(alert.id);
      if (response.code === 0) {
        ErrorHandlerUtil.showSuccessToast('告警已忽略');
        await this.loadData();
      } else {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '告警忽略失败');
      }
    } catch (error) {
      LogUtil.error(`AdminAlertsPage dismissAlert failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('告警忽略失败');
    }
  }

  private getSeverityText(severity: string): string {
    if (severity === 'CRITICAL') {
      return '紧急';
    }
    if (severity === 'HIGH') {
      return '高';
    }
    if (severity === 'MEDIUM') {
      return '中';
    }
    if (severity === 'LOW') {
      return '低';
    }
    return severity;
  }

  private getSeverityColor(severity: string): string {
    if (severity === 'CRITICAL') {
      return '#DC2626';
    }
    if (severity === 'HIGH') {
      return '#EA580C';
    }
    if (severity === 'MEDIUM') {
      return '#D97706';
    }
    return '#1F5EFF';
  }

  private getStatusText(status: string): string {
    if (status === 'ACTIVE') {
      return '待处理';
    }
    if (status === 'ACKNOWLEDGED') {
      return '已确认';
    }
    if (status === 'RESOLVED') {
      return '已解决';
    }
    if (status === 'DISMISSED') {
      return '已忽略';
    }
    return status;
  }

  build() {
    Column() {
      PageHeader({
        title: '告警中心',
        subtitle: '集中处理考勤、安全、费用等异常告警，形成闭环。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.DEFAULT,
          message: '正在加载告警...'
        })
      } else {
        Scroll() {
          Column() {
            this.buildOverviewPanel()
            this.buildFilterPanel()
            this.buildAlertList()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildOverviewPanel() {
    Column() {
      SectionHeader({
        title: '告警概览',
        subtitle: '先看活动量，再看确认与解决进度。'
      })

      Row() {
        StatCard({
          value: this.statistics ? this.statistics.active : 0,
          label: '待处理',
          icon: $r('app.media.ic_alert_center'),
          iconColor: '#DC2626'
        })
        .layoutWeight(1)

        StatCard({
          value: this.statistics ? this.statistics.acknowledged : 0,
          label: '已确认',
          icon: $r('app.media.ic_info'),
          iconColor: '#D97706'
        })
        .layoutWeight(1)
        .margin({ left: 12, right: 12 })

        StatCard({
          value: this.statistics ? this.statistics.resolved : 0,
          label: '已解决',
          icon: $r('app.media.ic_success'),
          iconColor: '#15803D'
        })
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private buildFilterPanel() {
    Card({
      title: '状态筛选',
      subtitle: '按当前处理进度切换告警池，避免遗漏。',
      content: this.buildFilterContent
    })
  }

  @Builder
  private buildFilterContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadData();
      }
    })
  }

  @Builder
  private buildAlertList() {
    Column() {
      SectionHeader({
        title: '告警列表',
        subtitle: this.errorMessage ? this.errorMessage : `当前共 ${this.alerts.length} 条告警`
      })

      if (this.alerts.length === 0) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '暂无告警',
          customDescription: this.errorMessage ? this.errorMessage : '当前筛选条件下没有待关注的告警。',
          actionText: '刷新',
          onAction: () => {
            this.loadData();
          }
        })
      } else {
        Column() {
          ForEach(this.alerts, (alert: AlertRecord) => {
            this.buildAlertItem(alert);
          })
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private buildAlertItem(alert: AlertRecord) {
    Column() {
      Row() {
        Column() {
          Text(alert.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(`${alert.studentName} · ${alert.alertType}`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.getStatusText(alert.status))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getSeverityColor(alert.severity))
      }
      .width('100%')

      Text(alert.description)
        .width('100%')
        .fontSize(13)
        .lineHeight(20)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 12 })

      Row() {
        Text(`严重级别：${this.getSeverityText(alert.severity)}`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getSeverityColor(alert.severity))

        Blank()

        Text(alert.createdAt)
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
      }
      .width('100%')
      .margin({ top: 12 })

      if (alert.suggestedAction) {
        Text(`建议动作：${alert.suggestedAction}`)
          .width('100%')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 10 })
      }

      if (alert.status === 'ACTIVE') {
        Row() {
          this.buildActionText('确认', '#1F5EFF', () => {
            this.acknowledgeAlert(alert);
          })

          this.buildActionText('解决', '#15803D', () => {
            this.resolveAlert(alert);
          })

          this.buildActionText('忽略', '#DC2626', () => {
            this.dismissAlert(alert);
          })
        }
        .width('100%')
        .margin({ top: 14 })
      } else if (alert.status === 'ACKNOWLEDGED') {
        Row() {
          this.buildActionText('标记解决', '#15803D', () => {
            this.resolveAlert(alert);
          })
        }
        .width('100%')
        .margin({ top: 14 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 12 })
  }

  @Builder
  private buildActionText(label: string, color: string, onClick: () => void) {
    Text(label)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(color)
      .margin({ right: 18 })
      .onClick(() => {
        onClick();
      })
  }
}
