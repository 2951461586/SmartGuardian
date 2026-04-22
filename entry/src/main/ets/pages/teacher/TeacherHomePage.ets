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
      return '#2F9B52';
    }
    if (status === 'ENDED') {
      return '#7F8A9A';
    }
    return '#4F7CFF';
  }

  private getSessionStatusBgColor(status?: string): string {
    if (status === 'ONGOING') {
      return '#EAF7EC';
    }
    if (status === 'ENDED') {
      return '#EEF2F6';
    }
    return '#EAF2FF';
  }

  build() {
    Column() {
      GreetingHeader({
        userName: this.userName,
        greeting: '今日班次、考勤异常与作业处理集中查看',
        theme: HeaderTheme.WHITE,
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
    Column() {
      Image($r('app.media.ic_notification'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
    }
    .width(40)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F1F5FB')
    .borderRadius(20)
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
      .padding({ left: 16, right: 16, top: 12, bottom: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildOverviewPanel() {
    Row() {
      this.buildOverviewMetric('今日班次', `${this.todaySessions.length}`, '#4F7CFF', '#EAF2FF')
      Blank().width(10)
      this.buildOverviewMetric('待处理签到', `${this.getUnsignedCount()}`, '#F2994A', '#FFF4E8')
      Blank().width(10)
      this.buildOverviewMetric('已完成签到', `${this.getSignedCount()}`, '#2F9B52', '#EAF7EC')
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
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 16, bottom: 16 })
    .backgroundColor(bgColor)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildQuickActions() {
    Column() {
      Row() {
        Text('快捷操作')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .margin({ bottom: 10 })

      Row() {
        ActionButton({
          label: '扫码签到',
          icon: $r('app.media.ic_qrcode'),
          bgColor: '#EAF7EC',
          iconColor: '#2F9B52',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherScanPage' });
          }
        })

        ActionButton({
          label: '考勤管理',
          icon: $r('app.media.ic_attendance'),
          bgColor: '#EAF2FF',
          iconColor: '#4F7CFF',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 1);
          }
        })

        ActionButton({
          label: '作业处理',
          icon: $r('app.media.ic_homework'),
          bgColor: '#FFF4E8',
          iconColor: '#F2994A',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 2);
          }
        })

        ActionButton({
          label: '班次安排',
          icon: $r('app.media.ic_calendar'),
          bgColor: '#F4EEFF',
          iconColor: '#8E5CF6',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/teacher/TeacherSchedulePage' });
          }
        })
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })
      .backgroundColor(Color.White)
      .borderRadius(20)
    }
    .width('100%')
    .margin({ bottom: 14 })
  }

  @Builder
  buildSessionOverviewCard() {
    Card({
      title: '当前班次',
      subtitle: this.currentSession ? '优先展示当前进行中的班次' : '今日最近班次概览',
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
            Text(this.getDisplaySession()?.serviceProductName ?? '托管班次')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(`${formatTime(this.getDisplaySession()?.startTime ?? '')} - ${formatTime(this.getDisplaySession()?.endTime ?? '')}`)
              .fontSize($r('app.float.text_secondary_size'))
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
          this.buildInlineMetric('已签到', `${this.getSignedCount()}`, '#2F9B52')
          Blank().width(10)
          this.buildInlineMetric('未签到', `${this.getUnsignedCount()}`, '#F2994A')
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '今日暂无班次安排',
        customDescription: this.errorMessage || '可稍后刷新查看最新安排'
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
    .backgroundColor('#F7FAFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTodayStatsCard() {
    Card({
      title: '今日工作摘要',
      subtitle: '快速确认班次执行与签到进度',
      content: this.buildTodayStatsContent
    })
  }

  @Builder
  buildTodayStatsContent() {
    Row() {
      this.buildStatBlock(String(this.todaySessions.length), '今日班次', '#4F7CFF')

      Divider()
        .vertical(true)
        .height(42)
        .color('#E6ECF2')

      this.buildStatBlock(String(this.getSignedCount()), '已签到', '#2F9B52')

      Divider()
        .vertical(true)
        .height(42)
        .color('#E6ECF2')

      this.buildStatBlock(String(this.getUnsignedCount()), '未签到', '#F2994A')
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
      title: '今日班次列表',
      subtitle: '按时间查看当天全部班次安排',
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
        customTitle: '暂无班次记录',
        customDescription: this.errorMessage || '今日还没有可展示的班次安排'
      })
    }
  }
}
