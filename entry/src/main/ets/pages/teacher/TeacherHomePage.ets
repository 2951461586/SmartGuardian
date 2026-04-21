/**
 * SmartGuardian - Teacher Home Page
 * Teacher dashboard with unified common components
 */

import { UserStore } from '../../stores/userStore';
import { AttendanceRecord } from '../../models/attendance';
import { AttendanceService } from '../../services/api/attendance';
import { SessionSchedule, SessionService } from '../../services/api/service';
import {
  GreetingHeader,
  HeaderTheme,
  LoadingState,
  LoadingSize,
  EmptyState,
  EmptyType,
  Card,
  ActionButton
} from '../../components/common';
import { formatDate, formatTime } from '../../utils/date';
import { ErrorMessages } from '../../constants/ErrorMessages';

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
      const userInfo = UserStore.getUserInfo();
      const teacherUserId = userInfo?.id;
      const sessionParams: SessionQueryParams = { sessionDate: today };
      if (teacherUserId) {
        sessionParams.teacherUserId = teacherUserId;
      }

      const sessionsResp = await SessionService.getSessions(sessionParams);
      if (sessionsResp.code === 0 && sessionsResp.data) {
        this.todaySessions = sessionsResp.data ?? [];
        this.currentSession = this.todaySessions.find((session: SessionSchedule) => session.status === 'ONGOING') ?? null;
      } else {
        this.todaySessions = [];
        this.currentSession = null;
      }

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
    return '未开始';
  }

  private getSessionStatusColor(status?: string): string {
    if (status === 'ONGOING') {
      return '#4CAF50';
    }
    if (status === 'ENDED') {
      return '#9E9E9E';
    }
    return '#4F7CFF';
  }

  private getSessionStatusBgColor(status?: string): string {
    if (status === 'ONGOING') {
      return '#E8F5E9';
    }
    if (status === 'ENDED') {
      return '#F5F5F5';
    }
    return '#EAF2FF';
  }

  build() {
    Column() {
      GreetingHeader({
        userName: this.userName,
        greeting: '查看今日班次、考勤与作业处理',
        theme: HeaderTheme.PRIMARY,
        onRightIconClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherMessagesPage' });
        }
      })

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
  buildContent() {
    Scroll() {
      Column() {
        this.buildQuickActions()
        this.buildSessionOverviewCard()
        this.buildTodayStatsCard()
        this.buildTodaySessionsCard()
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildQuickActions() {
    Row() {
      ActionButton({
        label: '扫码签到',
        icon: $r('app.media.ic_qrcode'),
        bgColor: '#E8F5E9',
        iconColor: '#4CAF50',
        onButtonClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherScanPage' });
        }
      })

      ActionButton({
        label: '考勤管理',
        icon: $r('app.media.ic_attendance'),
        bgColor: '#E3F2FD',
        iconColor: '#2196F3',
        onButtonClick: () => {
          AppStorage.setOrCreate('main_current_index', 1);
        }
      })

      ActionButton({
        label: '作业处理',
        icon: $r('app.media.ic_homework'),
        bgColor: '#FFF3E0',
        iconColor: '#FF9800',
        onButtonClick: () => {
          AppStorage.setOrCreate('main_current_index', 2);
        }
      })

      ActionButton({
        label: '班次安排',
        icon: $r('app.media.ic_calendar'),
        bgColor: '#F3E5F5',
        iconColor: '#9C27B0',
        onButtonClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherSchedulePage' });
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildSessionOverviewCard() {
    Card({
      title: '班次概览',
      subtitle: this.currentSession ? '当前正在进行的班次' : '今日最近班次',
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
      Row() {
        Column() {
          Text(this.getDisplaySession()?.serviceProductName ?? '托管班次')
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${formatTime(this.getDisplaySession()?.startTime ?? '')} - ${formatTime(this.getDisplaySession()?.endTime ?? '')}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })

          Text(this.currentSession ? `${this.getSignedCount()} 人已签到` : '可进入班次安排查看详情')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.currentSession ? '#4CAF50' : $r('app.color.text_secondary'))
            .margin({ top: 8 })
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
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '今日暂无班次安排',
        customDescription: this.errorMessage || '可稍后刷新查看最新安排'
      })
    }
  }

  @Builder
  buildTodayStatsCard() {
    Card({
      title: '今日统计',
      content: this.buildTodayStatsContent
    })
  }

  @Builder
  buildTodayStatsContent() {
    Row() {
      this.buildStatBlock(String(this.todaySessions.length), '今日班次', '#333333')

      Divider()
        .vertical(true)
        .height(40)
        .color('#E5E5E5')

      this.buildStatBlock(String(this.getSignedCount()), '已签到', '#4CAF50')

      Divider()
        .vertical(true)
        .height(40)
        .color('#E5E5E5')

      this.buildStatBlock(String(this.getUnsignedCount()), '未签到', '#F44336')
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
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildTodaySessionsCard() {
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
  buildTodaySessionsContent() {
    if (this.todaySessions.length > 0) {
      Column() {
        ForEach(this.todaySessions, (session: SessionSchedule, index: number) => {
          Row() {
            Column() {
              Text(session.serviceProductName ?? '托管班次')
                .fontSize($r('app.float.text_primary_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(`${formatTime(session.startTime)} - ${formatTime(session.endTime)}`)
                .fontSize($r('app.float.text_secondary_size'))
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

          if (index < this.todaySessions.length - 1) {
            Divider()
              .margin({ top: 10, bottom: 10 })
          }
        })
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无班次记录',
        customDescription: this.errorMessage || '今日还没有可展示的班次安排'
      })
    }
  }
}
