/**
 * SmartGuardian - 教师排课页
 * 教师查看每日课次安排
 */

import { SessionService } from '../../services/api/service';
import { SessionSchedule } from '../../models/service';
import { DateUtils } from '../../utils/dateUtils';
import { UserStore } from '../../stores/userStore';
import { EmptyState, EmptyType } from '../../components/common';

interface ScheduleItem {
  id: number;
  className: string;
  sessionName: string;
  startTime: string;
  endTime: string;
  location: string;
  studentCount: number;
  status: 'SCHEDULED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
}

@Entry
@Component
export struct TeacherSchedulePage {
  @State currentWeekStart: Date = DateUtils.getStartOfWeek(new Date());
  @State selectedDate: Date = new Date();
  @State weekDates: Date[] = [];
  @State scheduleList: ScheduleItem[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear() {
    this.generateWeekDates();
    this.loadSchedule();
  }

  generateWeekDates() {
    this.weekDates = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(this.currentWeekStart);
      date.setDate(date.getDate() + i);
      this.weekDates.push(date);
    }
  }

  async loadSchedule() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const teacherUserId = UserStore.getUserInfo()?.id;
      const response = await SessionService.getSessions({
        sessionDate: this.formatDate(this.selectedDate),
        teacherUserId: teacherUserId
      });

      if (response.code === 0 && response.data) {
        const sessions = Array.isArray(response.data) ? response.data : [];
        this.scheduleList = sessions.map((session: SessionSchedule) => this.toScheduleItem(session));
      } else {
        this.scheduleList = [];
      }
    } catch (error) {
      console.error('Load schedule failed:', String(error));
      this.scheduleList = [];
      this.errorMessage = '加载排课失败';
    } finally {
      this.isLoading = false;
    }
  }

  private toScheduleItem(session: SessionSchedule): ScheduleItem {
    return {
      id: session.id,
      className: session.serviceProductName ?? session.sessionNo ?? `Session ${session.id}`,
      sessionName: session.serviceProductName ?? 'Session',
      startTime: session.startTime,
      endTime: session.endTime,
      location: session.location ?? 'unset',
      studentCount: session.currentCount ?? 0,
      status: (session.status ?? 'SCHEDULED') as ScheduleItem['status']
    };
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private formatWeekRange(): string {
    if (this.weekDates.length === 0) {
      return '';
    }
    return `${this.formatDate(this.weekDates[0])} - ${this.formatDate(this.weekDates[6])}`;
  }

  private getWeekDayText(date: Date): string {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[date.getDay()];
  }

  private getStatusText(status: string): string {
    if (status === 'IN_PROGRESS') {
      return 'In progress';
    }
    if (status === 'COMPLETED') {
      return 'Completed';
    }
    if (status === 'CANCELLED') {
      return 'Cancelled';
    }
    return 'Scheduled';
  }

  private getStatusColor(status: string): string {
    if (status === 'IN_PROGRESS') {
      return '#16A34A';
    }
    if (status === 'COMPLETED') {
      return '#7A879A';
    }
    if (status === 'CANCELLED') {
      return '#D14343';
    }
    return '#1F5EFF';
  }

  private getStatusBgColor(status: string): string {
    if (status === 'IN_PROGRESS') {
      return '#ECFDF5';
    }
    if (status === 'COMPLETED') {
      return '#EEF3F8';
    }
    if (status === 'CANCELLED') {
      return '#FEF2F2';
    }
    return '#EDF4FF';
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildWeekNav()
      this.buildDateTabs()
      this.buildScheduleList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(20)
        .height(20)
        .fillColor($r('app.color.text_primary'))
        .onClick(() => this.getUIContext().getRouter().back())

      Text('我的课表')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor(Color.White)
  }

  @Builder
  buildWeekNav() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(20)
        .height(20)
        .fillColor($r('app.color.text_primary'))
        .onClick(() => {
          this.currentWeekStart.setDate(this.currentWeekStart.getDate() - 7);
          this.generateWeekDates();
          this.selectedDate = new Date(this.currentWeekStart);
          this.loadSchedule();
        })

      Text(this.formatWeekRange())
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Image($r('app.media.ic_arrow_right'))
        .width(20)
        .height(20)
        .fillColor($r('app.color.text_primary'))
        .onClick(() => {
          this.currentWeekStart.setDate(this.currentWeekStart.getDate() + 7);
          this.generateWeekDates();
          this.selectedDate = new Date(this.currentWeekStart);
          this.loadSchedule();
        })
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor(Color.White)
  }

  @Builder
  buildDateTabs() {
    Row() {
      ForEach(this.weekDates, (date: Date) => {
        Column() {
          Text(this.getWeekDayText(date))
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor(DateUtils.isToday(date) ? $r('app.color.primary') : $r('app.color.text_secondary'))

          Text(date.getDate().toString())
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor(DateUtils.isToday(date) ? $r('app.color.primary') : $r('app.color.text_primary'))
            .margin({ top: 4 })
        }
        .width(40)
        .padding({ top: 8, bottom: 8 })
        .backgroundColor(DateUtils.isToday(date) ? $r('app.color.primary_light') : Color.Transparent)
        .borderRadius($r('app.float.button_radius'))
        .onClick(() => {
          this.selectedDate = date;
          this.loadSchedule();
        })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding({ left: 8, right: 8 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildScheduleList() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .color($r('app.color.primary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.scheduleList.length === 0) {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '当天暂无排课',
        customDescription: this.errorMessage || 'No sessions for this date.'
      })
    } else {
      Scroll() {
        Column() {
          ForEach(this.scheduleList, (item: ScheduleItem) => {
            this.buildScheduleCard(item)
          })
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  buildScheduleCard(item: ScheduleItem) {
    Column() {
      Row() {
        Column() {
          Text(item.startTime)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text(item.endTime)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 16 })

        Column() {
          Text(item.sessionName)
            .fontSize($r('app.float.text_primary_size'))
            .fontColor(Color.White)
        }
        .width('100%')
        .padding(8)
        .backgroundColor($r('app.color.primary'))
        .borderRadius($r('app.float.badge_radius'))
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Column() {
          Text(item.className)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Row() {
            Text(item.location)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))

            Text(`  ${item.studentCount}人`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.getStatusText(item.status))
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor(this.getStatusColor(item.status))
          .backgroundColor(this.getStatusBgColor(item.status))
          .borderRadius(12)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }
}
