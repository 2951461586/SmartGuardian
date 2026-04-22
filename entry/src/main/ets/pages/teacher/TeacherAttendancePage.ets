/**
 * SmartGuardian - Teacher Attendance Page
 * Manage student attendance with unified visual system
 */

import { AttendanceRecord } from '../../models/attendance';
import { AttendanceService } from '../../services/api/attendance';
import { SessionSchedule, SessionService } from '../../services/api/service';
import { EmptyState, EmptyType, HeaderTheme, LoadingSize, LoadingState, PageHeader, TabBar } from '../../components/common';
import { AttendanceBadge } from '../../components/StatusBadge';
import { formatDate, formatTime } from '../../utils/date';
import { LogUtil } from '../../utils/LogUtil';

@Component
export struct TeacherAttendancePage {
  @State sessions: SessionSchedule[] = [];
  @State selectedSession: SessionSchedule | null = null;
  @State attendanceList: AttendanceRecord[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State currentSessionIndex: number = 0;

  private readonly tabs: string[] = ['全部', '已签到', '未签到'];
  private attendanceRequestId: number = 0;

  async aboutToAppear() {
    await this.loadSessions();
  }

  async loadSessions() {
    this.isLoading = true;

    try {
      const today = formatDate(new Date());
      const response = await SessionService.getSessions({ sessionDate: today });

      if (response.code === 0 && response.data) {
        this.sessions = response.data ?? [];
        this.currentSessionIndex = this.sessions.findIndex((session: SessionSchedule) => session.status === 'ONGOING');
        if (this.currentSessionIndex < 0) {
          this.currentSessionIndex = 0;
        }
        this.selectedSession = this.sessions[this.currentSessionIndex] ?? null;

        if (this.selectedSession) {
          await this.loadAttendance();
        } else {
          this.attendanceList = [];
        }
      } else {
        this.sessions = [];
        this.currentSessionIndex = 0;
        this.selectedSession = null;
        this.attendanceList = [];
      }
    } catch (error) {
      LogUtil.error('TeacherAttendancePage', 'Load sessions failed');
      this.sessions = [];
      this.currentSessionIndex = 0;
      this.selectedSession = null;
      this.attendanceList = [];
    } finally {
      this.isLoading = false;
    }
  }

  async loadAttendance() {
    if (!this.selectedSession) {
      this.attendanceList = [];
      return;
    }

    const requestId = ++this.attendanceRequestId;
    const selectedSessionId = this.selectedSession.id;
    this.attendanceList = [];

    try {
      const today = formatDate(new Date());
      const response = await AttendanceService.getAttendanceList({
        sessionId: selectedSessionId,
        attendanceDate: today
      });

      if (requestId !== this.attendanceRequestId || this.selectedSession?.id !== selectedSessionId) {
        return;
      }

      if (response.code === 0 && response.data && response.data.list) {
        this.attendanceList = response.data.list;
      } else {
        this.attendanceList = [];
      }
    } catch (error) {
      if (requestId === this.attendanceRequestId) {
        LogUtil.error('TeacherAttendancePage', 'Load attendance failed');
        this.attendanceList = [];
      }
    }
  }

  private getFilteredAttendance(): AttendanceRecord[] {
    if (this.currentTab === 1) {
      return this.attendanceList.filter((record: AttendanceRecord) => record.status === 'SIGNED_IN' || record.status === 'SIGNED_OUT');
    }

    if (this.currentTab === 2) {
      return this.attendanceList.filter((record: AttendanceRecord) => record.status === 'NOT_SIGNED');
    }

    return this.attendanceList;
  }

  private getSignedCount(): number {
    return this.attendanceList.filter((record: AttendanceRecord) => record.status === 'SIGNED_IN' || record.status === 'SIGNED_OUT').length;
  }

  private getUnsignedCount(): number {
    return this.attendanceList.filter((record: AttendanceRecord) => record.status === 'NOT_SIGNED').length;
  }

  private getCurrentTabLabel(): string {
    return this.tabs[this.currentTab] ?? '全部';
  }

  private getEmptyDescription(): string {
    if (!this.selectedSession) {
      return '今天暂无可管理的班次安排';
    }

    if (this.currentTab === 1) {
      return '当前筛选下暂无已签到记录';
    }

    if (this.currentTab === 2) {
      return '当前筛选下暂无未签到记录';
    }

    return '当前班次暂无考勤数据';
  }

  private handleSessionChange(index: number): void {
    this.currentSessionIndex = index;
    this.selectedSession = this.sessions[index] ?? null;
    if (this.selectedSession) {
      this.loadAttendance();
    }
  }

  build() {
    Column() {
      PageHeader({
        title: '考勤管理',
        subtitle: '快速查看班次签到进度与异常情况',
        theme: HeaderTheme.WHITE
      })

      this.buildOverviewPanel()
      this.buildSessionSelector()
      this.buildTabSection()
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildOverviewPanel() {
    Row() {
      this.buildOverviewMetric('今日班次', `${this.sessions.length}`, '#4F7CFF', '#EAF2FF')
      Blank().width(10)
      this.buildOverviewMetric('已签到', `${this.getSignedCount()}`, '#2F9B52', '#EAF7EC')
      Blank().width(10)
      this.buildOverviewMetric('未签到', `${this.getUnsignedCount()}`, '#F2994A', '#FFF4E8')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
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
  buildSessionSelector() {
    Column() {
      if (this.sessions.length === 0) {
        Blank()
      } else {
        Row() {
          Text('班次选择')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')
        .margin({ bottom: 10 })

        Row() {
          TabBar({
            tabs: this.sessions.map((session: SessionSchedule) => session.serviceProductName ?? '班次'),
            currentIndex: $currentSessionIndex,
            onTabChange: (index: number) => this.handleSessionChange(index)
          })
        }
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6 })
  }

  @Builder
  buildTabSection() {
    Column() {
      TabBar({
        tabs: this.tabs,
        currentIndex: $currentTab,
        onTabChange: (index: number) => {
          this.currentTab = index;
        }
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    .backgroundColor(Color.White)
    .borderRadius(18)
    .margin({ left: 16, right: 16, top: 14, bottom: 12 })
  }

  @Builder
  buildContent() {
    if (this.isLoading) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false,
        message: '正在加载考勤数据...'
      })
    } else if (this.getFilteredAttendance().length === 0) {
      EmptyState({
        type: EmptyType.NO_ATTENDANCE,
        customDescription: this.getEmptyDescription(),
        actionText: '刷新',
        onAction: () => {
          this.loadSessions();
        }
      })
    } else {
      this.buildAttendanceList()
    }
  }

  @Builder
  buildAttendanceList() {
    Scroll() {
      Column() {
        ForEach(this.getFilteredAttendance(), (record: AttendanceRecord) => {
          this.buildAttendanceItem(record)
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
  buildAttendanceItem(record: AttendanceRecord) {
    Column() {
      Row() {
        Column() {
          Text(record.studentName ?? `学生${record.studentId}`)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Medium)

          Text(record.studentNo ?? `学号 ${record.studentId}`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        AttendanceBadge({ status: record.status })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        this.buildInlineMetric('签到时间', record.signInTime ? formatTime(record.signInTime) : '--:--', '#4F7CFF')
        Blank().width(10)
        this.buildInlineMetric('签退时间', record.signOutTime ? formatTime(record.signOutTime) : '--:--', '#2F9B52')
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .margin({ bottom: 12 })
    .shadow({
      radius: 12,
      color: '#0F000000',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  buildInlineMetric(label: string, value: string, color: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(18)
        .fontColor(color)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#F7FAFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }
}
