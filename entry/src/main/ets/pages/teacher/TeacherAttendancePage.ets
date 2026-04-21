/**
 * SmartGuardian - Teacher Attendance Page
 * Manage student attendance
 */

import { AttendanceRecord } from '../../models/attendance';
import { AttendanceService } from '../../services/api/attendance';
import { SessionSchedule, SessionService } from '../../services/api/service';
import { LoadingState, LoadingSize, EmptyState, EmptyType } from '../../components/common';
import { formatDate, formatTime } from '../../utils/date';

@Component
export struct TeacherAttendancePage {
  @State sessions: SessionSchedule[] = [];
  @State selectedSession: SessionSchedule | null = null;
  @State attendanceList: AttendanceRecord[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;

  private readonly tabs = ['全部', '已签到', '未签到'];

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
        if (this.sessions && this.sessions.length > 0) {
          this.selectedSession = this.sessions.find(s => s.status === 'ONGOING') ?? this.sessions[0];
          await this.loadAttendance();
        }
      } else {
        this.sessions = [];
      }
    } catch (error) {
      console.error('Failed to load sessions:', error);
      this.sessions = [];
    } finally {
      this.isLoading = false;
    }
  }

  async loadAttendance() {
    if (!this.selectedSession) return;
    
    try {
      const today = formatDate(new Date());
      const response = await AttendanceService.getAttendanceList({
        sessionId: this.selectedSession.id,
        attendanceDate: today
      });
      if (response.code === 0 && response.data && response.data.list) {
        this.attendanceList = response.data.list;
      } else {
        this.attendanceList = [];
      }
    } catch (error) {
      console.error('Failed to load attendance:', error);
      this.attendanceList = [];
    }
  }

  getFilteredAttendance(): AttendanceRecord[] {
    if (this.currentTab === 1) {
      return this.attendanceList.filter(a => 
        a.status === 'SIGNED_IN' || a.status === 'SIGNED_OUT'
      );
    } else if (this.currentTab === 2) {
      return this.attendanceList.filter(a => a.status === 'NOT_SIGNED');
    }
    return this.attendanceList;
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .width(36)
        .height(36)
        .backgroundColor('#1AFFFFFF')
        .onClick(() => this.getUIContext().getRouter().back())

        Text('考勤管理')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(36)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#52C41A', 0], ['#389E0D', 1]]
      })

      if (this.sessions && this.sessions.length > 0) {
        Row() {
          Text('班次: ')
            .fontSize(14)
            .fontColor('#666666')
          
          Select(this.sessions.map((s: SessionSchedule): SelectOption => ({ value: s.serviceProductName ?? '班次' })))
            .selected(this.sessions.findIndex(s => s.id === this.selectedSession?.id))
            .value(this.selectedSession?.serviceProductName ?? '班次')
            .font({ size: 14 })
            .onSelect(async (index: number) => {
              this.selectedSession = this.sessions[index];
              await this.loadAttendance();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
      }

      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontColor(this.currentTab === index ? '#52C41A' : '#666666')
              .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)

            if (this.currentTab === index) {
              Divider()
                .width(24)
                .height(2)
                .color('#52C41A')
                .margin({ top: 4 })
            }
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .onClick(() => {
            this.currentTab = index;
          })
        })
      }
      .width('100%')
      .backgroundColor(Color.White)

      Divider().color('#E5E5E5')

      if (this.isLoading) {
        Column() {
          LoadingState({ loadingSize: LoadingSize.LARGE })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (!this.getFilteredAttendance() || this.getFilteredAttendance().length === 0) {
        Column() {
          EmptyState({ type: EmptyType.NO_ATTENDANCE, customTitle: '暂无考勤记录' })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.getFilteredAttendance(), (record: AttendanceRecord) => {
            ListItem() {
              this.AttendanceItem(record)
            }
            .margin({ top: 8 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  AttendanceItem(record: AttendanceRecord) {
    Row() {
      Column() {
        Text(record.studentName ?? `学生${record.studentId}`)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        
        if (record.signInTime) {
          Text(`签到: ${formatTime(record.signInTime)}`)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (record.status === 'SIGNED_IN' || record.status === 'SIGNED_OUT') {
        Text('已签到')
          .fontSize(12)
          .fontColor('#52C41A')
          .backgroundColor('#F6FFED')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      } else {
        Button('签到')
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor('#52C41A')
          .borderRadius(4)
          .height(28)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ 
              url: 'pages/teacher/TeacherScanPage',
              params: { studentId: record.studentId, sessionId: record.sessionId }
            });
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}
