/**
 * SmartGuardian - Teacher Home Page
 * Teacher dashboard with the new light campus style
 */

import {
  Card,
  EmptyState,
  EmptyType,
  GreetingHeader,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState,
  StatCard
} from '../../components/common';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { AttendanceRecord } from '../../models/attendance';
import { AttendanceService } from '../../services/api/attendance';
import { MessageService } from '../../services/api/message';
import { SessionSchedule, SessionService } from '../../services/api/service';
import { UserStore } from '../../stores/userStore';
import { formatDate, formatTime } from '../../utils/date';

interface SessionQueryParams {
  sessionDate: string;
  teacherUserId?: number;
}

@Component
export struct TeacherHomePage {
  @State userName: string = '';
  @State todaySessions: SessionSchedule[] = [];
  @State todayAttendance: AttendanceRecord[] = [];
  @State isLoading: boolean = true;
  @State currentSession: SessionSchedule | null = null;
  @State errorMessage: string = '';
  @State unreadCount: number = 0;

  async aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    await this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const today = formatDate(new Date());
      const teacherUserId = UserStore.getUserInfo()?.id;
      const sessionParams: SessionQueryParams = { sessionDate: today };
      if (teacherUserId) {
        sessionParams.teacherUserId = teacherUserId;
      }

      const sessionsPromise = SessionService.getSessions(sessionParams);
      const unreadPromise = MessageService.getUnreadCount();

      const sessionsResp = await sessionsPromise;
      const unreadResp = await unreadPromise;

      if (sessionsResp.code === 0 && sessionsResp.data) {
        this.todaySessions = sessionsResp.data ?? [];
        this.currentSession = this.todaySessions.find((session: SessionSchedule) => session.status === 'ONGOING') ?? null;
      } else {
        this.todaySessions = [];
        this.currentSession = null;
      }

      this.unreadCount = unreadResp.code === 0 && unreadResp.data ? unreadResp.data.count : 0;

      if (this.currentSession) {
        const attendanceResp = await AttendanceService.getAttendanceList({
          sessionId: this.currentSession.id,
          attendanceDate: today
        });
        if (attendanceResp.code === 0 && attendanceResp.data && attendanceResp.data.list) {
          this.todayAttendance = attendanceResp.data.list;
        } else {
          this.todayAttendance = [];
        }
      } else {
        this.todayAttendance = [];
      }
    } catch (error) {
      this.todaySessions = [];
      this.todayAttendance = [];
      this.currentSession = null;
      this.unreadCount = 0;
      this.errorMessage = ErrorMessages.DATA_LOAD_FAILED;
    } finally {
      this.isLoading = false;
    }
  }

  private getDisplaySession(): SessionSchedule | null {
    if (this.currentSession) {
      return this.currentSession;
    }
    if (this.todaySessions.length > 0) {
      return this.todaySessions[0];
    }
    return null;
  }

  private getSignedCount(): number {
    return this.todayAttendance.filter((record: AttendanceRecord) =>
      record.status === 'SIGNED_IN' || record.status === 'SIGNED_OUT'
    ).length;
  }

  private getUnsignedCount(): number {
    return this.todayAttendance.filter((record: AttendanceRecord) => record.status === 'NOT_SIGNED').length;
  }

  private getSessionStatusText(status?: string): string {
    if (status === 'ONGOING') {
      return '进行中';
    }
    if (status === 'ENDED') {
      return '已结束';
    }
    return '待开始';
  }

  private getSessionStatusColor(status?: string): string {
    if (status === 'ONGOING') {
      return '#34C759';
    }
    if (status === 'ENDED') {
      return '#7E8EAB';
    }
    return '#3F7DFF';
  }

  private getSessionStatusBgColor(status?: string): string {
    if (status === 'ONGOING') {
      return '#EAF9EF';
    }
    if (status === 'ENDED') {
      return '#F2F5FB';
    }
    return '#EAF2FF';
  }

  build() {
    Column() {
      GreetingHeader({
        userName: this.userName,
        greeting: '统一查看班次安排、考勤进度和作业处理情况。',
        theme: HeaderTheme.WHITE,
        badgeText: '教师端',
        metaText: this.currentSession?.serviceProductName ? `当前班次：${this.currentSession.serviceProductName}` : '今日授课安排与签到状态总览'
      }) {
        this.buildHeaderActions()
      }

      if (this.isLoading) {
        LoadingState({ loadingSize: LoadingSize.DEFAULT })
      } else {
        this.buildContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildHeaderActions() {
    IconActionButton({
      icon: $r('app.media.ic_notification'),
      badgeCount: this.unreadCount,
      onButtonClick: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherMessagesPage' });
      }
    })
  }

  @Builder
  private buildContent() {
    Scroll() {
      Column() {
        this.buildHeroCard()
        this.buildOverviewPanel()
        this.buildQuickActionsCard()
        this.buildTodayStatsCard()
        this.buildTodaySessionsCard()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 24 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildHeroCard() {
    Row() {
      Column() {
        Text('今日在岗')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#DCE8FF')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#FFFFFF22')
          .borderRadius(999)

        Text(this.getDisplaySession()?.serviceProductName || '今日暂无授课班次')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 14 })

        Text(this.getDisplaySession() ? `${formatTime(this.getDisplaySession()?.startTime ?? '')} - ${formatTime(this.getDisplaySession()?.endTime ?? '')}` : '可以前往课程安排查看后续排班')
          .fontSize(14)
          .fontColor('#EAF1FF')
          .margin({ top: 8 })

        Row() {
          this.buildHeroMetric(`${this.todaySessions.length}`, '今日班次')
          Blank().width(12)
          this.buildHeroMetric(`${this.getSignedCount()}`, '已签到')
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text(this.getSessionStatusText(this.getDisplaySession()?.status))
          .fontSize(12)
          .fontColor('#3F7DFF')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#F5F9FF')
          .borderRadius(999)

        Image($r('app.media.startIcon'))
          .width(84)
          .height(84)
          .objectFit(ImageFit.Contain)
          .opacity(0.22)
          .margin({ top: 16 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .linearGradient({
      angle: 145,
      colors: [['#5A96FF', 0], ['#4B85FF', 0.55], ['#3970F5', 1]]
    })
    .borderRadius(28)
    .shadow({
      radius: 18,
      color: '#2F6BDE18',
      offsetX: 0,
      offsetY: 10
    })
    .margin({ bottom: 14 })
  }

  @Builder
  private buildHeroMetric(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(label)
        .fontSize(12)
        .fontColor('#DCE8FF')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF16')
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildOverviewPanel() {
    Column() {
      Row() {
        StatCard({
          value: `${this.todaySessions.length}`,
          label: '今日班次',
          icon: $r('app.media.ic_calendar'),
          iconColor: '#3F7DFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `${this.getUnsignedCount()}`,
          label: '待签到',
          icon: $r('app.media.ic_warning'),
          iconColor: '#FFB74D'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: `${this.getSignedCount()}`,
          label: '已签到',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#34C759'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `${this.unreadCount}`,
          label: '未读消息',
          icon: $r('app.media.ic_message'),
          iconColor: '#8B6CF6'
        })
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .margin({ bottom: 14 })
  }

  @Builder
  private buildQuickActionsCard() {
    Card({
      title: '常用操作',
      subtitle: '把高频教学任务集中到首页。',
      content: this.buildQuickActionsContent
    })
  }

  @Builder
  private buildQuickActionsContent() {
    Column() {
      Row() {
        this.buildFeatureItem('扫码签到', '快速核验', $r('app.media.ic_qrcode'), '#EAF9EF', '#34C759', () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherScanPage' });
        })
        this.buildFeatureItem('考勤管理', '查看明细', $r('app.media.ic_attendance'), '#EAF2FF', '#3F7DFF', () => {
          AppStorage.setOrCreate('main_current_index', 1);
        })
        this.buildFeatureItem('作业管理', '布置反馈', $r('app.media.ic_homework'), '#FFF4E8', '#FF8A4D', () => {
          AppStorage.setOrCreate('main_current_index', 2);
        })
        this.buildFeatureItem('课程安排', '查看排班', $r('app.media.ic_calendar'), '#F2EEFF', '#8B6CF6', () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherSchedulePage' });
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private buildFeatureItem(title: string, subtitle: string, icon: Resource, bgColor: string, iconColor: string, onClick: () => void) {
    Column() {
      Column() {
        Image(icon)
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .fillColor(iconColor)
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(bgColor)
      .borderRadius(18)

      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 10 })

      Text(subtitle)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => onClick())
  }

  @Builder
  private buildTodayStatsCard() {
    Card({
      title: '当前班次',
      subtitle: this.currentSession ? '聚焦当前进行中的班次和签到进度。' : '当前没有进行中的班次，展示今日最近安排。',
      content: this.buildTodayStatsContent
    })
  }

  @Builder
  private buildTodayStatsContent() {
    if (this.getDisplaySession()) {
      Column() {
        Row() {
          Column() {
            Text(this.getDisplaySession()?.serviceProductName ?? '托管班次')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(`${formatTime(this.getDisplaySession()?.startTime ?? '')} - ${formatTime(this.getDisplaySession()?.endTime ?? '')}`)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(this.getSessionStatusText(this.getDisplaySession()?.status))
            .fontSize(12)
            .fontColor(this.getSessionStatusColor(this.getDisplaySession()?.status))
            .backgroundColor(this.getSessionStatusBgColor(this.getDisplaySession()?.status))
            .borderRadius(12)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        }
        .width('100%')

        Row() {
          this.buildInlineMetric('已签到', `${this.getSignedCount()}`, '#34C759')
          Blank().width(10)
          this.buildInlineMetric('待签到', `${this.getUnsignedCount()}`, '#FFB74D')
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无班次安排',
        customDescription: this.errorMessage || '稍后再刷新，或前往课程安排查看最新计划。'
      })
    }
  }

  @Builder
  private buildInlineMetric(label: string, value: string, color: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#F7FAFF')
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildTodaySessionsCard() {
    Card({
      title: '今日班次',
      actionText: '查看全部',
      onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherSchedulePage' });
      },
      content: this.buildTodaySessionsContent
    })
  }

  @Builder
  private buildTodaySessionsContent() {
    if (this.todaySessions.length > 0) {
      Column() {
        ForEach(this.todaySessions, (session: SessionSchedule, index: number) => {
          Row() {
            Column() {
              Text(session.serviceProductName ?? '托管班次')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(`${formatTime(session.startTime)} - ${formatTime(session.endTime)} · ${formatDate(new Date())}`)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(this.getSessionStatusText(session.status))
              .fontSize(12)
              .fontColor(this.getSessionStatusColor(session.status))
              .backgroundColor(this.getSessionStatusBgColor(session.status))
              .borderRadius(12)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })

          if (index < this.todaySessions.length - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 10, bottom: 10 })
          }
        })
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无班次记录',
        customDescription: this.errorMessage || '当前没有可展示的班次数据。'
      })
    }
  }
}
