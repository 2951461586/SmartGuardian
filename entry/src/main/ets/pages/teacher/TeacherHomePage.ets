/**
 * SmartGuardian - Teacher Home Page
 * Teacher dashboard with real attendance and session data
 */

import {
  GreetingHeader,
  HeaderTheme,
  LoadingState,
  LoadingSize,
  EmptyState,
  EmptyType,
  Card,
  ActionButton,
  SectionHeader,
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
      return '#16A34A';
    }
    if (status === 'ENDED') {
      return '#7A879A';
    }
    return '#1F5EFF';
  }

  private getSessionStatusBgColor(status?: string): string {
    if (status === 'ONGOING') {
      return '#ECFDF5';
    }
    if (status === 'ENDED') {
      return '#EEF3F8';
    }
    return '#EDF4FF';
  }

  build() {
    Column() {
      GreetingHeader({
        userName: this.userName,
        greeting: '统一查看场次安排、考勤进度和作业处理情况。',
        theme: HeaderTheme.WHITE,
        badgeText: '教师工作台',
        metaText: this.currentSession?.serviceProductName ? `当前场次：${this.currentSession.serviceProductName}` : '',
        onRightIconClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherMessagesPage' });
        }
      }) {
        this.buildMessageEntry()
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
  buildMessageEntry() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Image($r('app.media.ic_notification'))
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .fillColor('#12305F')
      }
      .width(46)
      .height(46)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .border({
        width: 1,
        color: '#E5EEF9',
        radius: 18,
        style: BorderStyle.Solid
      })

      if (this.unreadCount > 0) {
        Text(this.unreadCount > 99 ? '99+' : `${this.unreadCount}`)
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.error'))
          .borderRadius(9)
          .padding({ left: 5, right: 5, top: 1, bottom: 1 })
      }
    }
    .onClick(() => {
      this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherMessagesPage' });
    })
  }

  @Builder
  buildContent() {
    Scroll() {
      Column() {
        this.buildOverviewPanel()
        this.buildQuickActions()
        this.buildSessionOverviewCard()
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
  buildOverviewPanel() {
    Column() {
      Row() {
        StatCard({
          value: `${this.todaySessions.length}`,
          label: '今日场次',
          icon: $r('app.media.ic_calendar'),
          iconColor: '#1F5EFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `${this.getUnsignedCount()}`,
          label: '待签到',
          icon: $r('app.media.ic_warning'),
          iconColor: '#F59E0B'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: `${this.getSignedCount()}`,
          label: '已签到',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#16A34A'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `${this.unreadCount}`,
          label: '未读消息',
          icon: $r('app.media.ic_message'),
          iconColor: '#8B5CF6'
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
  buildOverviewMetric(title: string, value: string, valueColor: string, bgColor: string) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(valueColor)
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(bgColor)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildQuickActions() {
    Column() {
      SectionHeader({
        title: '快捷操作',
        subtitle: '把高频教学任务集中到首页'
      })

      Row() {
        ActionButton({
          label: '扫码签到',
          icon: $r('app.media.ic_qrcode'),
          bgColor: '#ECFDF5',
          iconColor: '#16A34A',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherScanPage' });
          }
        })

        Blank().width(10)

        ActionButton({
          label: '考勤管理',
          icon: $r('app.media.ic_attendance'),
          bgColor: '#EDF4FF',
          iconColor: '#1F5EFF',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 1);
          }
        })
      }
      .width('100%')

      Row() {
        ActionButton({
          label: '作业管理',
          icon: $r('app.media.ic_homework'),
          bgColor: '#FFF7E8',
          iconColor: '#F59E0B',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 2);
          }
        })

        Blank().width(10)

        ActionButton({
          label: '课程安排',
          icon: $r('app.media.ic_calendar'),
          bgColor: '#F5F0FF',
          iconColor: '#8B5CF6',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherSchedulePage' });
          }
        })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .margin({ bottom: 14 })
  }

  @Builder
  buildSessionOverviewCard() {
    Card({
      title: '当前场次',
      subtitle: this.currentSession ? '聚焦当前进行中的场次和签到进度。' : '当前没有进行中的场次，展示今日最近安排。',
      showArrow: this.getDisplaySession() !== null,
      clickable: this.getDisplaySession() !== null,
      onCardClick: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherSchedulePage' });
      },
      content: this.buildSessionOverviewContent
    })
  }

  @Builder
  buildSessionOverviewContent() {
    if (this.getDisplaySession()) {
      Column() {
        Row() {
          Column() {
            Text(this.getDisplaySession()?.serviceProductName ?? '托管场次')
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
        .alignItems(VerticalAlign.Top)

        Row() {
          this.buildInlineMetric('已签到', `${this.getSignedCount()}`, '#16A34A')
          Blank().width(10)
          this.buildInlineMetric('待签到', `${this.getUnsignedCount()}`, '#F59E0B')
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无场次安排',
        customDescription: this.errorMessage || '稍后再刷新，或前往课程安排页查看最新计划。'
      })
    }
  }

  @Builder
  buildInlineMetric(label: string, value: string, color: string) {
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
    .backgroundColor('#F7FAFD')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTodayStatsCard() {
    Card({
      title: '今日概览',
      subtitle: '查看场次执行情况和当前签到完成度。',
      content: this.buildTodayStatsContent
    })
  }

  @Builder
  buildTodayStatsContent() {
    Row() {
      this.buildStatBlock(String(this.todaySessions.length), '场次', '#1F5EFF')

      Divider()
        .vertical(true)
        .height(42)
        .color('#E6ECF2')

      this.buildStatBlock(String(this.getSignedCount()), '已签到', '#16A34A')

      Divider()
        .vertical(true)
        .height(42)
        .color('#E6ECF2')

      this.buildStatBlock(String(this.unreadCount), '待处理消息', '#8B5CF6')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildStatBlock(value: string, label: string, color: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontColor(color)
        .fontWeight(FontWeight.Bold)

      Text(label)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildTodaySessionsCard() {
    Card({
      title: '今日场次',
      subtitle: '查看今天全部已排班次。',
      actionText: '查看全部',
      onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherSchedulePage' });
      },
      content: this.buildTodaySessionsContent
    })
  }

  @Builder
  buildTodaySessionsContent() {
    if (this.todaySessions.length > 0) {
      Column() {
        ForEach(this.todaySessions, (session: SessionSchedule, index: number) => {
          Row() {
            Column() {
              Text(session.serviceProductName ?? '托管场次')
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
          .padding({ top: 4, bottom: 4 })

          if (index < this.todaySessions.length - 1) {
            Divider().color('#EEF2F7').margin({ top: 10, bottom: 10 })
          }
        })
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无场次记录',
        customDescription: this.errorMessage || '当前没有可展示的场次数据。'
      })
    }
  }
}
