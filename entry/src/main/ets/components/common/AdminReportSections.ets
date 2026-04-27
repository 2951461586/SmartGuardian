import { TeacherPerformance } from '../../services/api/reports';
import { Card } from './Card';
import { ExecutiveSummaryCard } from './ExecutiveSummaryCard';
import { ReportTrendCard, ReportTrendRow } from './ReportTrendCard';
import { ResponsiveSplitPanel } from './PageScaffold';
import { StatCardRow, StatRowItem } from './StatCardRow';
import { TeacherPerformanceCard } from './TeacherPerformanceCard';

@Component
export struct AdminReportsOverviewSection {
  @Prop reportTitle: string = '';
  @Prop reportSubtitle: string = '';
  @Prop badgeText: string = '';
  @Prop executiveValue: string = '';
  @Prop executiveLabel: string = '';
  @Prop rangeText: string = '';
  @Prop tabText: string = '';
  @Prop overviewItems: StatRowItem[] = [];

  build() {
    ResponsiveSplitPanel({
      primary: () => { this.buildExecutivePanel() },
      secondary: () => { this.buildOverviewPanel() }
    })
      .margin({ bottom: 14 })
  }

  @Builder
  private buildExecutivePanel() {
    ExecutiveSummaryCard({
      title: this.reportTitle,
      subtitle: this.reportSubtitle,
      badgeText: this.badgeText,
      value: this.executiveValue,
      valueLabel: this.executiveLabel,
      firstMetricLabel: '统计周期',
      firstMetricValue: this.rangeText,
      secondMetricLabel: '报告类型',
      secondMetricValue: this.tabText
    })
    .margin({ left: 16, right: 16, top: 12 })
  }

  @Builder
  private buildOverviewPanel() {
    Card({
      title: '关键指标',
      subtitle: '用同一套指标视角快速理解当前报表状态',
      customPadding: 12,
      content: () => { this.buildOverviewMetrics() }
    })
    .margin({ left: 16, right: 16, top: 12 })
  }

  @Builder
  private buildOverviewMetrics() {
    StatCardRow({
      items: this.overviewItems
    })
  }
}

@Component
export struct AdminAttendanceReportList {
  @Prop rows: ReportTrendRow[] = [];

  build() {
    List({ space: 12 }) {
      ListItem() {
        ReportTrendCard({
          cardTitle: '考勤趋势明细',
          cardSubtitle: '按日查看出勤、迟到与缺勤变化',
          rows: this.rows
        })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, bottom: 20 })
    .divider({ strokeWidth: 0 })
    .scrollBar(BarState.Off)
    .cachedCount(4)
  }
}

@Component
export struct AdminFinanceReportList {
  @Prop summaryItems: StatRowItem[] = [];
  @Prop rows: ReportTrendRow[] = [];

  build() {
    List({ space: 12 }) {
      ListItem() {
        Card({
          title: '财务摘要',
          subtitle: '先看订单、退款和净收入三项核心数据',
          customPadding: 18,
          content: () => { this.buildSummaryContent() }
        })
      }

      ListItem() {
        ReportTrendCard({
          cardTitle: '收支趋势明细',
          cardSubtitle: '按日核对收入与退款变化',
          rows: this.rows
        })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, bottom: 20 })
    .divider({ strokeWidth: 0 })
    .scrollBar(BarState.Off)
    .cachedCount(4)
  }

  @Builder
  private buildSummaryContent() {
    StatCardRow({
      items: this.summaryItems
    })
  }
}

@Component
export struct AdminTeacherPerformanceList {
  @Prop teachers: TeacherPerformance[] = [];

  build() {
    List({ space: 12 }) {
      ForEach(this.teachers, (teacher: TeacherPerformance) => {
        ListItem() {
          TeacherPerformanceCard({
            teacher: teacher
          })
        }
      }, (teacher: TeacherPerformance) => teacher.teacherName)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, bottom: 20 })
    .divider({ strokeWidth: 0 })
    .scrollBar(BarState.Off)
    .cachedCount(6)
  }
}
