/**
 * SmartGuardian - Admin Reports Page
 * Admin can view detailed statistics and reports
 */

import { ReportsService, AttendanceReport, FinanceReport, TeacherPerformance } from '../../services/api/reports';
import {
  AdminAttendanceReportList,
  AdminFinanceReportList,
  AdminReportsOverviewSection,
  AdminTeacherPerformanceList,
  EmptyType,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  PageHeader,
  ReportControlDeck,
  ReportMetricChip,
  ReportTrendRow,
  StatefulContainer,
  StatRowItem,
  ViewState,
  WorkbenchListPageTemplate
} from '../../components/common';
import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { formatDate } from '../../utils/date';

class AttendanceDailyStat {
  date: string = '';
  presentCount: number = 0;
  absentCount: number = 0;
  lateCount: number = 0;
}

class FinanceDailyStat {
  date: string = '';
  income: number = 0;
  refund: number = 0;
}

@Entry
@Component
struct AdminReportsPage {
  build() {
    Stack() {
      AdminReportsPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AdminReportsPageContent {
  @State currentTab: number = 0;
  @State attendanceReport: AttendanceReport | null = null;
  @State financeReport: FinanceReport | null = null;
  @State teacherPerformance: TeacherPerformance[] = [];
  @State isLoading: boolean = false;
  @State dateRange: string = '近7天';

  private tabs: string[] = ['考勤统计', '财务报表', '教师绩效'];
  private reportRequestId: number = 0;
  private rangeOptions: string[] = ['近7天', '近30天', '近90天'];

  aboutToAppear() {
    this.loadReportData();
  }

  async loadReportData() {
    this.isLoading = true;
    const requestId = ++this.reportRequestId;
    const activeTab = this.currentTab;

    try {
      const today = formatDate(new Date());
      const startDate = this.getStartDate();

      if (activeTab === 0) {
        const attendanceResp = await ReportsService.getAttendanceReport({ startDate, endDate: today });
        if (requestId === this.reportRequestId && activeTab === this.currentTab) {
          this.attendanceReport = attendanceResp.code === 0 && attendanceResp.data ? attendanceResp.data : null;
        }
        return;
      }

      if (activeTab === 1) {
        const financeResp = await ReportsService.getFinanceReport({ startDate, endDate: today });
        if (requestId === this.reportRequestId && activeTab === this.currentTab) {
          this.financeReport = financeResp.code === 0 && financeResp.data ? financeResp.data : null;
        }
        return;
      }

      const teacherResp = await ReportsService.getTeacherPerformance({ startDate, endDate: today });
      if (requestId === this.reportRequestId && activeTab === this.currentTab) {
        this.teacherPerformance = teacherResp.code === 0 && teacherResp.data ? teacherResp.data : [];
      }
    } catch (error) {
      if (requestId !== this.reportRequestId || activeTab !== this.currentTab) {
        return;
      }

      if (activeTab === 0) {
        this.attendanceReport = null;
      } else if (activeTab === 1) {
        this.financeReport = null;
      } else {
        this.teacherPerformance = [];
      }
    } finally {
      if (requestId === this.reportRequestId) {
        this.isLoading = false;
      }
    }
  }

  private getStartDate(): string {
    if (this.dateRange === '近30天') {
      return formatDate(Date.now() - 30 * 24 * 60 * 60 * 1000);
    }

    if (this.dateRange === '近90天') {
      return formatDate(Date.now() - 90 * 24 * 60 * 60 * 1000);
    }

    return formatDate(Date.now() - 7 * 24 * 60 * 60 * 1000);
  }

  private handleRangeChange(range: string): void {
    this.dateRange = range;
    this.loadReportData();
  }

  private handleTabChange(index: number): void {
    this.currentTab = index;
    this.loadReportData();
  }

  private getAttendanceOverviewValue(type: string): string {
    if (type === 'students') {
      return `${this.attendanceReport?.totalStudents ?? 0}`;
    }
    if (type === 'rate') {
      return `${this.attendanceReport?.attendanceRate ?? 0}%`;
    }
    return `${this.attendanceReport?.lateCount ?? 0}`;
  }

  private getFinanceOverviewValue(type: string): string {
    if (type === 'income') {
      return `¥${this.financeReport?.totalIncome ?? 0}`;
    }
    if (type === 'refund') {
      return `¥${this.financeReport?.totalRefund ?? 0}`;
    }
    return `¥${this.financeReport?.netIncome ?? 0}`;
  }

  private getPerformanceOverviewValue(type: string): string {
    if (type === 'teachers') {
      return `${this.teacherPerformance.length}`;
    }
    if (type === 'sessions') {
      return `${this.teacherPerformance.reduce((sum: number, teacher: TeacherPerformance) => sum + teacher.totalSessions, 0)}`;
    }
    if (this.teacherPerformance.length === 0) {
      return '0%';
    }

    const totalRate = this.teacherPerformance.reduce((sum: number, teacher: TeacherPerformance) => sum + teacher.avgAttendanceRate, 0);
    return `${Math.round(totalRate / this.teacherPerformance.length)}%`;
  }

  private hasCurrentData(): boolean {
    if (this.currentTab === 0) {
      return this.attendanceReport !== null;
    }
    if (this.currentTab === 1) {
      return this.financeReport !== null;
    }
    return this.teacherPerformance.length > 0;
  }

  private getCurrentReportTitle(): string {
    if (this.currentTab === 0) {
      return '考勤运营观察';
    }
    if (this.currentTab === 1) {
      return '财务结算视图';
    }
    return '教师绩效雷达';
  }

  private getCurrentReportSubtitle(): string {
    if (this.currentTab === 0) {
      return '关注到校率、迟到波动和缺勤变化，快速识别异常时段';
    }
    if (this.currentTab === 1) {
      return '对齐收入、退款和净收入，判断当前经营节奏是否健康';
    }
    return '从课程量、学生覆盖和作业完成情况查看教师队伍状态';
  }

  private getExecutiveValue(): string {
    if (this.currentTab === 0) {
      return this.getAttendanceOverviewValue('rate');
    }
    if (this.currentTab === 1) {
      return this.getFinanceOverviewValue('net');
    }
    return this.getPerformanceOverviewValue('rate');
  }

  private getExecutiveLabel(): string {
    if (this.currentTab === 0) {
      return '核心出勤率';
    }
    if (this.currentTab === 1) {
      return '净收入';
    }
    return '平均出勤率';
  }

  private getExecutiveBadge(): string {
    if (this.currentTab === 0) {
      return '出勤监控';
    }
    if (this.currentTab === 1) {
      return '财务结算';
    }
    return '绩效评估';
  }

  private getViewState(): ViewState {
    if (this.isLoading) {
      return ViewState.LOADING;
    }
    if (!this.hasCurrentData()) {
      return ViewState.EMPTY;
    }
    return ViewState.CONTENT;
  }

  build() {
    Column() {
      WorkbenchListPageTemplate({
        scrollable: false,
        enableWideContent: true,
        header: () => { this.buildHeader() },
        overview: () => { this.buildOverviewSection() },
        controls: () => { this.buildControlDeck() },
        content: () => { this.buildStatefulReportBody() }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHeader() {
    PageHeader({
      title: '数据统计',
      subtitle: '从考勤、财务与教师绩效三方面查看机构运营状态',
      theme: HeaderTheme.WHITE,
      rightContent: this.buildHeaderAction
    })
  }

  @Builder
  buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: HarmonyColor.info,
      boxBgColor: HarmonyColor.surface,
      boxBorderColor: $r('app.color.divider'),
      onButtonClick: (): void => {
        this.loadReportData();
      }
    })
  }

  @Builder
  private buildOverviewSection() {
    AdminReportsOverviewSection({
      reportTitle: this.getCurrentReportTitle(),
      reportSubtitle: this.getCurrentReportSubtitle(),
      badgeText: this.getExecutiveBadge(),
      executiveValue: this.getExecutiveValue(),
      executiveLabel: this.getExecutiveLabel(),
      rangeText: this.dateRange,
      tabText: this.tabs[this.currentTab],
      overviewItems: this.getCurrentOverviewItems()
    })
  }

  @Builder
  private buildStatefulReportBody() {
    StatefulContainer({
      state: this.getViewState(),
      loadingMessage: '正在生成报表...',
      loadingSize: LoadingSize.LARGE,
      emptyType: EmptyType.DEFAULT,
      emptyTitle: '暂无统计数据',
      emptyDescription: '当前时间范围内还没有可展示的报表结果',
      emptyActionText: '刷新',
      onEmptyAction: () => {
        this.loadReportData();
      },
      content: () => { this.buildReportContent() }
    })
      .layoutWeight(1)
      .margin({ top: 12 })
  }

  private getCurrentOverviewItems(): StatRowItem[] {
    if (this.currentTab === 0) {
      return this.getAttendanceOverviewItems();
    }
    if (this.currentTab === 1) {
      return this.getFinanceOverviewItems();
    }
    return this.getPerformanceOverviewItems();
  }

  private getAttendanceOverviewItems(): StatRowItem[] {
    return [
      { value: this.getAttendanceOverviewValue('students'), label: '学生总量', icon: $r('app.media.ic_user'), iconColor: HarmonyReport.accent },
      { value: this.getAttendanceOverviewValue('rate'), label: '出勤率', icon: $r('app.media.ic_attendance'), iconColor: HarmonyReport.positive },
      { value: this.getAttendanceOverviewValue('late'), label: '迟到人数', icon: $r('app.media.ic_warning'), iconColor: HarmonyReport.caution }
    ];
  }

  private getFinanceOverviewItems(): StatRowItem[] {
    return [
      { value: this.getFinanceOverviewValue('income'), label: '总收入', icon: $r('app.media.ic_money'), iconColor: HarmonyReport.positive },
      { value: this.getFinanceOverviewValue('refund'), label: '总退款', icon: $r('app.media.ic_order'), iconColor: HarmonyReport.caution },
      { value: this.getFinanceOverviewValue('net'), label: '净收入', icon: $r('app.media.ic_report'), iconColor: HarmonyReport.accent }
    ];
  }

  private getPerformanceOverviewItems(): StatRowItem[] {
    return [
      { value: this.getPerformanceOverviewValue('teachers'), label: '教师人数', icon: $r('app.media.ic_user'), iconColor: HarmonyColor.brandBlue },
      { value: this.getPerformanceOverviewValue('sessions'), label: '班次总数', icon: $r('app.media.ic_calendar'), iconColor: HarmonyReport.accent },
      { value: this.getPerformanceOverviewValue('rate'), label: '平均出勤率', icon: $r('app.media.ic_attendance'), iconColor: HarmonyReport.positive }
    ];
  }

  @Builder
  buildControlDeck() {
    ReportControlDeck({
      rangeOptions: this.rangeOptions,
      selectedRange: this.dateRange,
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onRangeChange: (range: string): void => {
        this.handleRangeChange(range);
      },
      onTabChange: (index: number): void => {
        this.handleTabChange(index);
      }
    })
    .margin({ left: 16, right: 16, top: 14, bottom: 12 })
  }

  @Builder
  buildReportContent() {
    if (this.currentTab === 0) {
      AdminAttendanceReportList({
        rows: this.getAttendanceRows()
      })
    } else if (this.currentTab === 1) {
      AdminFinanceReportList({
        summaryItems: this.getFinanceSummaryItems(),
        rows: this.getFinanceRows()
      })
    } else {
      AdminTeacherPerformanceList({
        teachers: this.teacherPerformance
      })
    }
  }

  private getFinanceSummaryItems(): StatRowItem[] {
    return [
      { value: `${this.financeReport?.orderCount ?? 0}`, label: '订单总数', icon: $r('app.media.ic_order'), iconColor: HarmonyColor.brandBlue },
      { value: `${this.financeReport?.refundedOrderCount ?? 0}`, label: '退款订单', icon: $r('app.media.ic_warning'), iconColor: HarmonyReport.caution },
      { value: `¥${this.financeReport?.netIncome ?? 0}`, label: '净收入', icon: $r('app.media.ic_money'), iconColor: HarmonyReport.positive }
    ];
  }

  private getAttendanceRows(): ReportTrendRow[] {
    const dailyStats = this.attendanceReport?.dailyStats ?? [];
    return dailyStats.map((day: AttendanceDailyStat): ReportTrendRow => {
      return {
        title: day.date,
        metrics: [
          this.createTrendMetric('出勤', `${day.presentCount}`, HarmonyReport.positive),
          this.createTrendMetric('迟到', `${day.lateCount}`, HarmonyReport.caution),
          this.createTrendMetric('缺勤', `${day.absentCount}`, HarmonyReport.danger)
        ]
      };
    });
  }

  private getFinanceRows(): ReportTrendRow[] {
    const dailyStats = this.financeReport?.dailyStats ?? [];
    return dailyStats.map((day: FinanceDailyStat): ReportTrendRow => {
      return {
        title: day.date,
        metrics: [
          this.createTrendMetric('收入', `¥${day.income}`, HarmonyReport.positive),
          this.createTrendMetric('退款', `¥${day.refund}`, HarmonyReport.danger)
        ]
      };
    });
  }

  private createTrendMetric(label: string, value: string, color: string): ReportMetricChip {
    return {
      label: label,
      value: value,
      color: color
    };
  }

}

