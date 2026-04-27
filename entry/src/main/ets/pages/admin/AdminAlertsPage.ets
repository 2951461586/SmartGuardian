/**
 * SmartGuardian - Admin Alerts Page
 * Admin alert handling workspace on the shared workbench template.
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  AdminAlertListSection,
  AdminOverviewMetric,
  AdminOverviewMetricSection,
  AdminStatusFilterCard,
  HeaderTheme,
  PageHeader,
  StatefulContainer,
  ViewState,
  WorkbenchListPageTemplate
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
      const alertsResponse = await AlertService.getAlerts(this.buildQueryParams());
      const statisticsResponse = await AlertService.getStatistics();

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
      return HarmonyReport.danger;
    }
    if (severity === 'HIGH') {
      return HarmonyReport.caution;
    }
    if (severity === 'MEDIUM') {
      return HarmonyReport.caution;
    }
    return HarmonyColor.info;
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

  private getViewState(): ViewState {
    if (this.isLoading) {
      return ViewState.LOADING;
    }
    if (this.alerts.length === 0) {
      return ViewState.EMPTY;
    }
    return ViewState.CONTENT;
  }

  private getOverviewMetrics(): AdminOverviewMetric[] {
    return [
      {
        value: this.statistics ? this.statistics.active : 0,
        label: '待处理',
        icon: $r('app.media.ic_alert_center'),
        iconColor: HarmonyReport.danger
      },
      {
        value: this.statistics ? this.statistics.acknowledged : 0,
        label: '已确认',
        icon: $r('app.media.ic_info'),
        iconColor: HarmonyReport.caution
      },
      {
        value: this.statistics ? this.statistics.resolved : 0,
        label: '已解决',
        icon: $r('app.media.ic_attendance'),
        iconColor: HarmonyReport.positive
      }
    ];
  }

  build() {
    Column() {
      WorkbenchListPageTemplate({
        scrollable: false,
        enableWideContent: true,
        header: () => { this.buildHeader() },
        overview: () => { this.buildOverviewSection() },
        controls: () => { this.buildFilterSection() },
        content: () => { this.buildAlertContent() }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildHeader() {
    PageHeader({
      title: '告警中心',
      subtitle: '集中处理考勤、安全、费用等异常告警，形成闭环。',
      showBack: true,
      onBackClick: () => this.getUIContext().getRouter().back(),
      theme: HeaderTheme.WHITE
    })
  }

  @Builder
  private buildOverviewSection() {
    AdminOverviewMetricSection({
      title: '告警概览',
      subtitle: '先看活动量，再看确认与解决进度。',
      metrics: this.getOverviewMetrics()
    })
  }

  @Builder
  private buildFilterSection() {
    AdminStatusFilterCard({
      subtitle: '按当前处理进度切换告警池，避免遗漏。',
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadData();
      }
    })
  }

  @Builder
  private buildAlertContent() {
    StatefulContainer({
      state: this.getViewState(),
      loadingMessage: '正在加载告警...',
      emptyTitle: '暂无告警',
      emptyDescription: this.errorMessage ? this.errorMessage : '当前筛选条件下没有待关注的告警。',
      emptyActionText: '刷新',
      onEmptyAction: () => {
        this.loadData();
      },
      content: () => { this.buildAlertListSection() }
    })
      .layoutWeight(1)
  }

  @Builder
  private buildAlertListSection() {
    AdminAlertListSection({
      alerts: this.alerts,
      subtitle: this.errorMessage ? this.errorMessage : `当前共 ${this.alerts.length} 条告警`,
      severityTextResolver: (severity: string): string => this.getSeverityText(severity),
      severityColorResolver: (severity: string): string => this.getSeverityColor(severity),
      statusTextResolver: (status: string): string => this.getStatusText(status),
      onPrimary: (alert: AlertRecord) => {
        this.acknowledgeAlert(alert);
      },
      onSecondary: (alert: AlertRecord) => {
        this.resolveAlert(alert);
      },
      onTertiary: (alert: AlertRecord) => {
        this.dismissAlert(alert);
      },
      onEmptyAction: () => {
        this.loadData();
      }
    })
  }
}
