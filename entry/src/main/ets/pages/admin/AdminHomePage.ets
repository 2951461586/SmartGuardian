/**
 * SmartGuardian - Admin Home Page
 * Admin's main dashboard showing overview statistics
 */

import { UserStore } from '../../stores/userStore';
import { ReportsService, AttendanceReport, FinanceReport } from '../../services/api/reports';

@Component
struct AdminHomePage {
  @State userName: string = '';
  @State attendanceReport: AttendanceReport | null = null;
  @State financeReport: FinanceReport | null = null;
  @State isLoading: boolean = false;
  @State pendingOrdersCount: number = 0;
  @State abnormalAttendanceCount: number = 0;

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadDashboardData();
  }

  async loadDashboardData() {
    this.isLoading = true;
    try {
      // Load attendance report
      const today = new Date().toISOString().split('T')[0];
      const startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
      
      const attResp = await ReportsService.getAttendanceReport({
        startDate,
        endDate: today
      });

      if (attResp.code === 0 && attResp.data) {
        this.attendanceReport = attResp.data;
      }

      // Load finance report
      const finResp = await ReportsService.getFinanceReport({
        startDate,
        endDate: today
      });

      if (finResp.code === 0 && finResp.data) {
        this.financeReport = finResp.data;
      }
    } catch (error) {
      // Handle error
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Dashboard content
      Scroll() {
        Column() {
          // Quick stats
          this.buildQuickStats()

          // Attendance overview
          this.buildAttendanceOverview()

          // Finance overview
          this.buildFinanceOverview()

          // Pending tasks
          this.buildPendingTasks()
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text(`你好，${this.userName || '管理员'}`)
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('管理后台概览')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor('#FFFFFFCC')
      }
      .alignItems(HorizontalAlign.Start)

      Image($r('app.media.ic_settings'))
        .width($r('app.float.icon_large_size'))
        .height($r('app.float.icon_large_size'))
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: $r('app.float.status_bar_height') + 20 })
  }

  @Builder
  buildQuickStats() {
    Row() {
      this.buildStatCard('待审核订单', `${this.pendingOrdersCount}`, $r('app.media.ic_order'), '#FF9800')
      this.buildStatCard('异常考勤', `${this.abnormalAttendanceCount}`, $r('app.media.ic_warning'), '#F44336')
      this.buildStatCard('今日出勤率', this.attendanceReport ? `${this.attendanceReport.attendanceRate}%` : '--', $r('app.media.ic_attendance'), '#4CAF50')
      this.buildStatCard('总收入', this.financeReport ? `¥${this.financeReport.totalIncome}` : '--', $r('app.media.ic_money'), '#2196F3')
    }
    .width('100%')
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildStatCard(title: string, value: string, icon: Resource, color: string) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .fillColor(color)

      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8 })

      Text(title)
        .fontSize($r('app.float.text_tiny_size'))
        .fontColor($r('app.color.text_secondary'))
    }
    .width('23%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildAttendanceOverview() {
    Column() {
      Text('考勤概览 (近7天)')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: $r('app.float.card_content_margin') })

      if (this.attendanceReport) {
        Row() {
          Column() {
            Text(`${this.attendanceReport.presentCount}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')
            Text('出勤人数')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Column() {
            Text(`${this.attendanceReport.lateCount}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9800')
            Text('迟到人数')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Column() {
            Text(`${this.attendanceReport.absentCount}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F44336')
            Text('缺勤人数')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Column() {
            Text(`${this.attendanceReport.leaveCount}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2196F3')
            Text('请假人数')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)
        }
        .width('100%')
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
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildFinanceOverview() {
    Column() {
      Text('财务概览 (近7天)')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: $r('app.float.card_content_margin') })

      if (this.financeReport) {
        Row() {
          Column() {
            Text(`¥${this.financeReport.totalIncome}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')
            Text('总收入')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Column() {
            Text(`¥${this.financeReport.totalRefund}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F44336')
            Text('总退款')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Column() {
            Text(`¥${this.financeReport.netIncome}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2196F3')
            Text('净收入')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)

          Column() {
            Text(`${this.financeReport.orderCount}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#9C27B0')
            Text('订单数')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .layoutWeight(1)
        }
        .width('100%')
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
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildPendingTasks() {
    Column() {
      Text('待处理事项')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: $r('app.float.card_content_margin') })

      this.buildTaskItem('待审核订单', `${this.pendingOrdersCount}笔`, () => {})
      this.buildTaskItem('异常考勤待处理', `${this.abnormalAttendanceCount}条`, () => {})
      this.buildTaskItem('待确认作业反馈', '0条', () => {})
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }

  @Builder
  buildTaskItem(title: string, count: string, action: () => void) {
    Row() {
      Text(title)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))

      Text(count)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: $r('app.float.card_padding'), bottom: $r('app.float.card_padding') })
    .onClick(action)
  }
}