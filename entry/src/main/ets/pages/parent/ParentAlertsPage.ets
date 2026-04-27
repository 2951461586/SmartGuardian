/**
 * SmartGuardian - Parent Alerts Page
 * Parent-facing alert center on the shared workbench template.
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  EmptyType,
  HeaderTheme,
  IconActionButton,
  PageHeader,
  ParentAlertDetailSheetCard,
  ParentAlertListItemCard,
  ParentAlertResponseCard,
  SectionHeader,
  StatefulContainer,
  StatCardRow,
  StatRowItem,
  ViewState,
  WorkbenchListPageTemplate
} from '../../components/common';
import { AlertRecord, AlertStatistics } from '../../models/alert';
import { AlertService } from '../../services/api/alert';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';

@Entry
@Component
struct ParentAlertsPage {
  build() {
    Stack() {
      ParentAlertsPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentAlertsPageContent {
  @State alerts: AlertRecord[] = [];
  @State statistics: AlertStatistics | null = null;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showDetailDialog: boolean = false;
  @State selectedAlert: AlertRecord | null = null;
  private alertDataSource: LazyArrayDataSource<AlertRecord> = new LazyArrayDataSource<AlertRecord>();

  aboutToAppear() {
    this.loadPageData();
  }

  private async loadPageData(): Promise<void> {
    await this.loadAlerts();
    await this.loadStatistics();
  }

  async loadAlerts() {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const resp = await AlertService.getActiveAlerts(1, 50);
      if (resp.code === 0 && resp.data) {
        this.alerts = resp.data.list ?? [];
        this.alertDataSource.setItems(this.alerts);
      } else {
        this.clearAlerts();
      }
    } catch (error) {
      console.error('Failed to load alerts:', String(error));
      this.clearAlerts();
      this.errorMessage = '预警信息加载失败，请稍后重试。';
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
        await this.loadPageData();
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
        await this.loadPageData();
      }
    } catch (error) {
      console.error('Failed to dismiss alert:', String(error));
    }
  }

  private clearAlerts(): void {
    this.alerts = [];
    this.alertDataSource.clear();
  }

  private getViewState(): ViewState {
    if (this.isLoading) {
      return ViewState.LOADING;
    }
    if (this.errorMessage.length > 0) {
      return ViewState.ERROR;
    }
    if (this.alerts.length === 0) {
      return ViewState.EMPTY;
    }
    return ViewState.CONTENT;
  }

  private getOverviewItems(): StatRowItem[] {
    return [
      {
        value: `${this.statistics?.active ?? 0}`,
        label: '活跃预警',
        icon: $r('app.media.ic_warning'),
        iconColor: HarmonyReport.danger
      },
      {
        value: `${this.statistics?.acknowledged ?? 0}`,
        label: '已确认',
        icon: $r('app.media.ic_info'),
        iconColor: HarmonyReport.caution
      },
      {
        value: `${this.statistics?.resolved ?? 0}`,
        label: '已处理',
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
        controls: () => { this.buildControlSection() },
        content: () => { this.buildAlertsContent() }
      })
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showDetailDialog, this.buildDetailSheet(), {
      height: 460,
      backgroundColor: HarmonyColor.surface,
      dragBar: true
    })
  }

  @Builder
  private buildHeader() {
    PageHeader({
      title: '异常预警',
      subtitle: '集中查看需要家长关注的异常、提醒与安全风险。',
      showBack: true,
      theme: HeaderTheme.WHITE,
      onBackClick: () => this.getUIContext().getRouter().back(),
      rightContent: this.buildHeaderAction
    })
  }

  @Builder
  private buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: HarmonyColor.info,
      boxBgColor: HarmonyColor.surface,
      boxBorderColor: HarmonyColor.line,
      onButtonClick: () => {
        this.loadPageData();
      }
    })
  }

  @Builder
  private buildOverviewSection() {
    StatCardRow({
      items: this.getOverviewItems()
    })
  }

  @Builder
  private buildControlSection() {
    ParentAlertResponseCard({
      onRefresh: () => {
        this.loadPageData();
      }
    })
  }

  @Builder
  private buildAlertsContent() {
    StatefulContainer({
      state: this.getViewState(),
      loadingMessage: '正在同步预警中心...',
      emptyType: EmptyType.DEFAULT,
      emptyTitle: '暂无预警信息',
      emptyDescription: '当前没有需要家长处理的活跃预警。',
      errorMessage: this.errorMessage,
      onRetry: () => {
        this.loadPageData();
      },
      content: () => { this.buildAlertList() }
    })
      .layoutWeight(1)
  }

  @Builder
  private buildAlertList() {
    List() {
      ListItem() {
        SectionHeader({
          title: '预警列表',
          subtitle: '点击卡片可查看详情并直接处理。'
        })
      }

      LazyForEach(this.alertDataSource, (alert: AlertRecord) => {
        ListItem() {
          this.buildAlertCard(alert)
        }
      }, (alert: AlertRecord) => `${alert.id}`)
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0 })
    .scrollBar(BarState.Off)
    .cachedCount(8)
  }

  @Builder
  private buildAlertCard(alert: AlertRecord) {
    ParentAlertListItemCard({
      alert: alert,
      severityTextResolver: (severity: string): string => this.getSeverityText(severity),
      severityColorResolver: (severity: string): string => this.getSeverityColor(severity),
      severityBgColorResolver: (severity: string): string => this.getSeverityBgColor(severity),
      timeResolver: (value: string): string => this.formatTime(value),
      onAlertClick: (currentAlert: AlertRecord): void => {
        this.selectedAlert = currentAlert;
        this.showDetailDialog = true;
      }
    })
  }

  @Builder
  private buildDetailSheet() {
    Column() {
      if (this.selectedAlert) {
        Text('预警详情')
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(HarmonyColor.textPrimary)
          .margin({ top: 16, bottom: 12 })

        ParentAlertDetailSheetCard({
          alert: this.selectedAlert,
          severityTextResolver: (severity: string): string => this.getSeverityText(severity),
          typeTextResolver: (type: string): string => this.getAlertTypeText(type),
          onDismiss: (alertId: number): void => {
            this.dismissAlert(alertId);
          },
          onAcknowledge: (alertId: number): void => {
            this.acknowledgeAlert(alertId);
          }
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  private getSeverityText(severity: string): string {
    if (severity === 'LOW') {
      return '低';
    }
    if (severity === 'MEDIUM') {
      return '中';
    }
    if (severity === 'HIGH') {
      return '高';
    }
    if (severity === 'CRITICAL') {
      return '紧急';
    }
    return '未知';
  }

  private getSeverityColor(severity: string): string {
    if (severity === 'LOW') {
      return HarmonyReport.positive;
    }
    if (severity === 'MEDIUM') {
      return HarmonyReport.caution;
    }
    if (severity === 'HIGH' || severity === 'CRITICAL') {
      return HarmonyReport.danger;
    }
    return HarmonyColor.textSecondary;
  }

  private getSeverityBgColor(severity: string): string {
    if (severity === 'LOW') {
      return HarmonyReport.positiveSurface;
    }
    if (severity === 'MEDIUM') {
      return HarmonyReport.cautionSurface;
    }
    if (severity === 'HIGH' || severity === 'CRITICAL') {
      return HarmonyReport.dangerSurface;
    }
    return HarmonyColor.surfaceSubtle;
  }

  private getAlertTypeText(type: string): string {
    if (type === 'ATTENDANCE_ANOMALY') {
      return '考勤异常';
    }
    if (type === 'SAFETY_CONCERN') {
      return '安全隐患';
    }
    if (type === 'ACADEMIC_PERFORMANCE') {
      return '学业表现';
    }
    if (type === 'BEHAVIORAL_ISSUE') {
      return '行为问题';
    }
    if (type === 'FEE_DUE') {
      return '费用到期';
    }
    if (type === 'SYSTEM') {
      return '系统提醒';
    }
    return '其他';
  }

  private formatTime(time: string): string {
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
