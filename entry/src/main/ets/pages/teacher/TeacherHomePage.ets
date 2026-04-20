/**
 * SmartGuardian - Teacher Home Page
 * Teacher's main dashboard
 */

import router from '@ohos.router';
import { UserStore } from '../../stores/userStore';
import { AttendanceRecord } from '../../models/attendance';
import { AttendanceService } from '../../services/api/attendance';
import { SessionSchedule, SessionService } from '../../services/api/service';
import { LoadingState, LoadingSize, EmptyState, EmptyType, Card } from '../../components/common';
import { formatDate, formatTime } from '../../utils/date';

@Entry
@Component
export struct TeacherHomePage {
  @State userName: string = '';
  @State todaySessions: SessionSchedule[] = [];
  @State todayAttendance: AttendanceRecord[] = [];
  @State isLoading: boolean = true;
  @State currentSession: SessionSchedule | null = null;

  async aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    await this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    try {
      const today = formatDate(new Date());
      
      const sessionsResp = await SessionService.getSessions({ sessionDate: today });
      if (sessionsResp.code === 0 && sessionsResp.data) {
        this.todaySessions = sessionsResp.data;
        this.currentSession = this.todaySessions.find(s => s.status === 'ONGOING') ?? null;
      }

      if (this.currentSession) {
        const attendanceResp = await AttendanceService.getAttendanceList({
          sessionId: this.currentSession.id,
          attendanceDate: today
        });
        if (attendanceResp.code === 0 && attendanceResp.data) {
          this.todayAttendance = attendanceResp.data.list ?? [];
        }
      }
    } catch (error) {
      console.error('Failed to load data:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(`你好，${this.userName}`)
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
          
          Text('今日工作概览')
            .fontSize(14)
            .fontColor('#CCFFFFFF')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Badge({
          count: 0,
          position: BadgePosition.RightTop,
          style: { badgeSize: 8, badgeColor: '#FF4D4F' }
        }) {
          Button({ type: ButtonType.Circle }) {
            Text('🔔')
              .fontSize(20)
          }
          .width(40)
          .height(40)
          .backgroundColor('#1AFFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/teacher/TeacherMessagesPage' });
          })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .linearGradient({
        angle: 135,
        colors: [['#52C41A', 0], ['#389E0D', 1]]
      })

      if (this.isLoading) {
        Column() {
          LoadingState({ loadingSize: LoadingSize.LARGE })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Row() {
          this.QuickAction('扫码签到', '📷', () => {
            router.pushUrl({ url: 'pages/teacher/TeacherScanPage' });
          })
          
          this.QuickAction('考勤记录', '📋', () => {
            router.pushUrl({ url: 'pages/teacher/TeacherAttendancePage' });
          })
          
          this.QuickAction('班次安排', '📅', () => {
            router.pushUrl({ url: 'pages/teacher/TeacherSchedulePage' });
          })
        }
        .width('100%')
        .padding(16)
        .justifyContent(FlexAlign.SpaceEvenly)
        .backgroundColor(Color.White)

        Divider().color('#E5E5E5')

        if (this.currentSession) {
          Card({
            title: '当前班次',
            content: () => {
              this.CurrentSessionContent()
            }
          })
        }

        Card({
          title: '今日统计',
          content: () => {
            this.StatsContent()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  QuickAction(title: string, icon: string, action: () => void) {
    Column() {
      Text(icon)
        .fontSize(28)
      
      Text(title)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width(80)
    .padding(12)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .onClick(action)
  }

  @Builder
  CurrentSessionContent() {
    Column() {
      Row() {
        Text(this.currentSession?.serviceProductName ?? '托管班次')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        Text('进行中')
          .fontSize(12)
          .fontColor('#52C41A')
          .backgroundColor('#F6FFED')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      }
      .width('100%')

      Row() {
        Text(`${formatTime(this.currentSession?.startTime ?? '')} - ${formatTime(this.currentSession?.endTime ?? '')}`)
          .fontSize(14)
          .fontColor('#666666')
        
        Blank()
        
        Text(`${this.todayAttendance.length}人已签到`)
          .fontSize(14)
          .fontColor('#52C41A')
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  StatsContent() {
    Row() {
      Column() {
        Text(String(this.todaySessions.length))
          .fontSize(24)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
        
        Text('今日班次')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Divider()
        .vertical(true)
        .height(40)
        .color('#E5E5E5')

      Column() {
        Text(String(this.todayAttendance.filter(a => a.status === 'SIGNED_IN' || a.status === 'SIGNED_OUT').length))
          .fontSize(24)
          .fontColor('#52C41A')
          .fontWeight(FontWeight.Bold)
        
        Text('已签到')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Divider()
        .vertical(true)
        .height(40)
        .color('#E5E5E5')

      Column() {
        Text(String(this.todayAttendance.filter(a => a.status === 'NOT_SIGNED').length))
          .fontSize(24)
          .fontColor('#FF4D4F')
          .fontWeight(FontWeight.Bold)
        
        Text('未签到')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
  }
}
