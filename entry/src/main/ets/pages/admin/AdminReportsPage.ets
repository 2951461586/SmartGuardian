/**
 * SmartGuardian - Admin Reports Page
 * Admin can view detailed statistics and reports
 */

import { ReportsService, AttendanceReport, FinanceReport, TeacherPerformance } from '../../services/api/reports';

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

  aboutToAppear() {
    this.loadReportData();
  }

  async loadReportData() {
    this.isLoading = true;
    try {
      const today = new Date().toISOString().split('T')[0];
      let startDate = today;
      if (this.dateRange === '近7天') {
        startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
      } else if (this.dateRange === '近30天') {
        startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
      } else {
        startDate = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
      }

      if (this.currentTab === 0) {
        const attResp = await ReportsService.getAttendanceReport({ startDate, endDate: today });
        if (attResp.code === 0 && attResp.data) {
          this.attendanceReport = attResp.data;
        }
      } else if (this.currentTab === 1) {
        const finResp = await ReportsService.getFinanceReport({ startDate, endDate: today });
        if (finResp.code === 0 && finResp.data) {
          this.financeReport = finResp.data;
        }
      } else {
        const perfResp = await ReportsService.getTeacherPerformance({ startDate, endDate: today });
        if (perfResp.code === 0 && perfResp.data) {
          this.teacherPerformance = perfResp.data;
        }
      }
    } catch (error) {
      // Handle error
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildDateRangeSelector()
      this.buildTabBar()
      this.buildReportContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Text('数据统计')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: Number($r('app.float.status_bar_height')) + 20, bottom: 20 })
    .backgroundColor($r('app.color.primary'))
  }

  @Builder
  buildDateRangeSelector() {
    Row() {
      ForEach(['近7天', '近30天', '近90天'], (range: string) => {
        Text(range)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor(this.dateRange === range ? $r('app.color.primary') : $r('app.color.text_secondary'))
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.dateRange === range ? '#E3F2FD' : Color.Transparent)
          .borderRadius(16)
          .onClick(() => {
            this.dateRange = range;
            this.loadReportData();
          })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(12)
    .backgroundColor(Color.White)
  }

  @Builder
  buildTabBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize($r('app.float.text_primary_size'))
            .fontColor(this.currentTab === index ? $r('app.color.primary') : $r('app.color.text_secondary'))

          if (this.currentTab === index) {
            Row()
              .width(24)
              .height(2)
              .backgroundColor($r('app.color.primary'))
              .borderRadius(1)
          }
        }
        .width('33%')
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentTab = index;
          this.loadReportData();
        })
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  buildReportContent() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .color($r('app.color.primary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      if (this.currentTab === 0) {
        this.buildAttendanceReport()
      } else if (this.currentTab === 1) {
        this.buildFinanceReport()
      } else {
        this.buildTeacherPerformance()
      }
    }
  }

  @Builder
  buildAttendanceReport() {
    Scroll() {
      Column() {
        Row() {
          this.buildSummaryCard('总人数', `${this.attendanceReport?.totalStudents || 0}`, '#2196F3')
          this.buildSummaryCard('出勤率', `${this.attendanceReport?.attendanceRate || 0}%`, '#4CAF50')
          this.buildSummaryCard('迟到', `${this.attendanceReport?.lateCount || 0}`, '#FF9800')
          this.buildSummaryCard('缺勤', `${this.attendanceReport?.absentCount || 0}`, '#F44336')
        }
        .width('100%')
        .margin({ bottom: $r('app.float.card_margin') })

        Column() {
          Text('每日考勤趋势')
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: $r('app.float.card_content_margin') })

          if (this.attendanceReport?.dailyStats && this.attendanceReport.dailyStats.length > 0) {
            ForEach(this.attendanceReport.dailyStats, (day: AttendanceDailyStat) => {
              this.buildDailyStatItem(day)
            })
          } else {
            Text('暂无数据')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
        }
        .width('100%')
        .padding($r('app.float.card_padding'))
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.card_border_radius'))
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildSummaryCard(title: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(title)
        .fontSize($r('app.float.text_tiny_size'))
        .fontColor($r('app.color.text_secondary'))
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildDailyStatItem(day: AttendanceDailyStat) {
    Row() {
      Text(day.date)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .layoutWeight(1)

      Row() {
        Text(`出勤: ${day.presentCount}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor('#4CAF50')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Row() {
        Text(`迟到: ${day.lateCount}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor('#FF9800')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Row() {
        Text(`缺勤: ${day.absentCount}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor('#F44336')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  buildFinanceReport() {
    Scroll() {
      Column() {
        Row() {
          this.buildFinanceCard('总收入', `¥${this.financeReport?.totalIncome || 0}`, '#4CAF50')
          this.buildFinanceCard('总退款', `¥${this.financeReport?.totalRefund || 0}`, '#F44336')
          this.buildFinanceCard('净收入', `¥${this.financeReport?.netIncome || 0}`, '#2196F3')
        }
        .width('100%')
        .margin({ bottom: $r('app.float.card_margin') })

        Row() {
          Column() {
            Text(`${this.financeReport?.orderCount || 0}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#9C27B0')
            Text('订单总数')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Column() {
            Text(`${this.financeReport?.refundedOrderCount || 0}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9800')
            Text('退款订单')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding($r('app.float.card_padding'))
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.card_border_radius'))
        .margin({ bottom: $r('app.float.card_margin') })

        Column() {
          Text('每日收支趋势')
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: $r('app.float.card_content_margin') })

          if (this.financeReport?.dailyStats && this.financeReport.dailyStats.length > 0) {
            ForEach(this.financeReport.dailyStats, (day: FinanceDailyStat) => {
              this.buildFinanceDailyItem(day)
            })
          } else {
            Text('暂无数据')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
        }
        .width('100%')
        .padding($r('app.float.card_padding'))
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.card_border_radius'))
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildFinanceCard(title: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(title)
        .fontSize($r('app.float.text_tiny_size'))
        .fontColor($r('app.color.text_secondary'))
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildFinanceDailyItem(day: FinanceDailyStat) {
    Row() {
      Text(day.date)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .layoutWeight(1)

      Text(`收入: ¥${day.income}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor('#4CAF50')

      Text(`  退款: ¥${day.refund}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor('#F44336')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  buildTeacherPerformance() {
    Scroll() {
      Column() {
        if (this.teacherPerformance.length > 0) {
          ForEach(this.teacherPerformance, (teacher: TeacherPerformance) => {
            this.buildTeacherItem(teacher)
          })
        } else {
          Text('暂无教师绩效数据')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .padding({ top: 40, bottom: 40 })
        }
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildTeacherItem(teacher: TeacherPerformance) {
    Column() {
      Text(teacher.teacherName)
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: $r('app.float.card_content_margin') })

      Row() {
        this.buildTeacherStat('班次数', `${teacher.totalSessions}`)
        this.buildTeacherStat('学生数', `${teacher.totalStudents}`)
        this.buildTeacherStat('出勤率', `${teacher.avgAttendanceRate}%`)
        this.buildTeacherStat('作业数', `${teacher.homeworkCompletedCount}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildTeacherStat(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
      Text(label)
        .fontSize($r('app.float.text_tiny_size'))
        .fontColor($r('app.color.text_secondary'))
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}
