/**
 * SmartGuardian - Admin Reports Page
 * Admin can view detailed statistics and reports
 */

import { ReportsService, AttendanceReport, FinanceReport, TeacherPerformance } from '../../services/api/reports';
import { EmptyState, EmptyType, HeaderTheme, IconActionButton, LoadingSize, LoadingState, PageHeader, TabBar, Card, SectionHeader, StatCard } from '../../components/common';
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

@Component
export struct AdminReportsPage {
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

  build() {
    Column() {
      PageHeader({
        title: '数据统计',
        subtitle: '从考勤、财务与教师绩效三方面查看机构运营状态',
        theme: HeaderTheme.WHITE,
        rightContent: this.buildHeaderAction
      })

      this.buildExecutivePanel()
      this.buildOverviewPanel()
      this.buildControlDeck()
      this.buildReportContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: '#1F5EFF',
      boxBgColor: Color.White,
      boxBorderColor: '#E5EDF6',
      onButtonClick: (): void => {
        this.loadReportData();
      }
    })
  }

  @Builder
  buildExecutivePanel() {
    Card({
      title: this.getCurrentReportTitle(),
      subtitle: this.getCurrentReportSubtitle(),
      customPadding: 18,
      content: this.buildExecutiveContent
    })
    .margin({ left: 16, right: 16, top: 12 })
  }

  @Builder
  buildExecutiveContent() {
    Row() {
      Column() {
        Text(this.getExecutiveBadge())
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#EAF2FF')
          .borderRadius(999)

        Text(this.getExecutiveValue())
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 14 })

        Text(this.getExecutiveLabel())
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        this.buildCompactMetric('统计周期', this.dateRange, '#1F5EFF')
        this.buildCompactMetric('报告类型', this.tabs[this.currentTab], '#10203A')
      }
      .width(124)
    }
    .width('100%')
  }

  @Builder
  buildOverviewPanel() {
    Card({
      title: '关键指标',
      subtitle: '用同一套指标视角快速理解当前报表状态',
      customPadding: 12,
      content: this.buildOverviewMetricsContent
    })
    .margin({ left: 16, right: 16, top: 12 })
  }

  @Builder
  buildOverviewMetricsContent() {
    if (this.currentTab === 0) {
      Row() {
        StatCard({
          value: this.getAttendanceOverviewValue('students'),
          label: '学生总量',
          icon: $r('app.media.ic_user'),
          iconColor: '#4F7CFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.getAttendanceOverviewValue('rate'),
          label: '出勤率',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#2F9B52'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.getAttendanceOverviewValue('late'),
          label: '迟到人数',
          icon: $r('app.media.ic_warning'),
          iconColor: '#F2994A'
        })
        .layoutWeight(1)
      }
      .width('100%')
    } else if (this.currentTab === 1) {
      Row() {
        StatCard({
          value: this.getFinanceOverviewValue('income'),
          label: '总收入',
          icon: $r('app.media.ic_money'),
          iconColor: '#2F9B52'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.getFinanceOverviewValue('refund'),
          label: '总退款',
          icon: $r('app.media.ic_order'),
          iconColor: '#F2994A'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.getFinanceOverviewValue('net'),
          label: '净收入',
          icon: $r('app.media.ic_report'),
          iconColor: '#4F7CFF'
        })
        .layoutWeight(1)
      }
      .width('100%')
    } else {
      Row() {
        StatCard({
          value: this.getPerformanceOverviewValue('teachers'),
          label: '教师人数',
          icon: $r('app.media.ic_user'),
          iconColor: '#8E5CF6'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.getPerformanceOverviewValue('sessions'),
          label: '班次总数',
          icon: $r('app.media.ic_calendar'),
          iconColor: '#4F7CFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.getPerformanceOverviewValue('rate'),
          label: '平均出勤率',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#2F9B52'
        })
        .layoutWeight(1)
      }
      .width('100%')
    }
  }

  @Builder
  buildControlDeck() {
    Card({
      title: '报告控制台',
      subtitle: '统一控制统计周期和分析维度，再进入数据明细',
      customPadding: 12,
      content: this.buildControlDeckContent
    })
    .margin({ left: 16, right: 16, top: 14, bottom: 12 })
  }

  @Builder
  buildControlDeckContent() {
    Column() {
      Row() {
        ForEach(this.rangeOptions, (range: string) => {
          Text(range)
            .fontSize(13)
            .fontWeight(this.dateRange === range ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.dateRange === range ? $r('app.color.primary') : $r('app.color.text_secondary'))
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.dateRange === range ? '#EAF2FF' : '#F7FAFF')
            .borderRadius(16)
            .margin({ right: range === this.rangeOptions[this.rangeOptions.length - 1] ? 0 : 10 })
            .onClick(() => {
              this.handleRangeChange(range);
            })
        })
      }
      .width('100%')

      TabBar({
        tabs: this.tabs,
        currentIndex: this.currentTab,
        onTabChange: (index: number) => this.handleTabChange(index)
      })
      .margin({ top: 14 })
    }
  }

  @Builder
  buildReportContent() {
    if (this.isLoading) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false,
        message: '正在生成报表...'
      })
    } else if (!this.hasCurrentData()) {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无统计数据',
        customDescription: '当前时间范围内还没有可展示的报表结果',
        actionText: '刷新',
        onAction: () => {
          this.loadReportData();
        }
      })
    } else if (this.currentTab === 0) {
      this.buildAttendanceReport()
    } else if (this.currentTab === 1) {
      this.buildFinanceReport()
    } else {
      this.buildTeacherPerformance()
    }
  }

  @Builder
  buildAttendanceReport() {
    Scroll() {
      Column() {
        SectionHeader({
          title: '考勤趋势',
          subtitle: '按日查看出勤、迟到与缺勤变化'
        })

        Column() {
          Text('考勤趋势明细')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text('按日查看出勤、迟到与缺勤变化')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6, bottom: 16 })

          ForEach(this.attendanceReport?.dailyStats ?? [], (day: AttendanceDailyStat, index: number) => {
            this.buildAttendanceDailyItem(day)
            if (this.attendanceReport?.dailyStats && index < this.attendanceReport.dailyStats.length - 1) {
              Divider().color('#EEF2F7').margin({ top: 10, bottom: 10 })
            }
          })
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({ radius: 12, color: '#0F000000', offsetX: 0, offsetY: 4 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildAttendanceDailyItem(day: AttendanceDailyStat) {
    Row() {
      Column() {
        Text(day.date)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      this.buildCompactMetric('出勤', `${day.presentCount}`, '#2F9B52')
      Blank().width(10)
      this.buildCompactMetric('迟到', `${day.lateCount}`, '#F2994A')
      Blank().width(10)
      this.buildCompactMetric('缺勤', `${day.absentCount}`, '#E25B5B')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildFinanceReport() {
    Scroll() {
      Column() {
        this.buildFinanceSummaryCard()

        SectionHeader({
          title: '收支趋势',
          subtitle: '按日核对收入与退款变化'
        })

        Column() {
          Text('收支趋势明细')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text('按日核对收入与退款变化')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6, bottom: 16 })

          ForEach(this.financeReport?.dailyStats ?? [], (day: FinanceDailyStat, index: number) => {
            this.buildFinanceDailyItem(day)
            if (this.financeReport?.dailyStats && index < this.financeReport.dailyStats.length - 1) {
              Divider().color('#EEF2F7').margin({ top: 10, bottom: 10 })
            }
          })
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({ radius: 12, color: '#0F000000', offsetX: 0, offsetY: 4 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildFinanceSummaryCard() {
    Row() {
      this.buildCompactMetric('订单总数', `${this.financeReport?.orderCount ?? 0}`, '#8E5CF6')
      Blank().width(10)
      this.buildCompactMetric('退款订单', `${this.financeReport?.refundedOrderCount ?? 0}`, '#F2994A')
      Blank().width(10)
      this.buildCompactMetric('净收入', `¥${this.financeReport?.netIncome ?? 0}`, '#2F9B52')
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .margin({ bottom: 12 })
    .shadow({ radius: 12, color: '#0F000000', offsetX: 0, offsetY: 4 })
  }

  @Builder
  buildFinanceDailyItem(day: FinanceDailyStat) {
    Row() {
      Column() {
        Text(day.date)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      this.buildCompactMetric('收入', `¥${day.income}`, '#2F9B52')
      Blank().width(10)
      this.buildCompactMetric('退款', `¥${day.refund}`, '#E25B5B')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildTeacherPerformance() {
    Scroll() {
      Column() {
        SectionHeader({
          title: '教师绩效列表',
          subtitle: '关注评分、出勤率和作业完成情况'
        })

        ForEach(this.teacherPerformance, (teacher: TeacherPerformance) => {
          this.buildTeacherItem(teacher)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildTeacherItem(teacher: TeacherPerformance) {
    Column() {
      Row() {
        Column() {
          Text(teacher.teacherName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text(`平均评分 ${teacher.avgRating}`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(`${teacher.avgAttendanceRate}%`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2F9B52')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        this.buildCompactMetric('班次数', `${teacher.totalSessions}`, '#4F7CFF')
        Blank().width(10)
        this.buildCompactMetric('学生数', `${teacher.totalStudents}`, '#8E5CF6')
        Blank().width(10)
        this.buildCompactMetric('作业完成', `${teacher.homeworkCompletedCount}`, '#F2994A')
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .margin({ bottom: 12 })
    .shadow({ radius: 12, color: '#0F000000', offsetX: 0, offsetY: 4 })
  }

  @Builder
  buildCompactMetric(label: string, value: string, color: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 14, bottom: 14 })
    .backgroundColor('#F7FAFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }
}
