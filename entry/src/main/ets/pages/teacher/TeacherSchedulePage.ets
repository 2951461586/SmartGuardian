/**
 * SmartGuardian - Teacher Schedule Page
 * Unified weekly schedule workspace
 */

import { SessionSchedule } from '../../models/service';
import { SessionService } from '../../services/api/service';
import { DateUtils } from '../../utils/dateUtils';
import { UserStore } from '../../stores/userStore';
import { BadgeSize, EmptyState, EmptyType, HeaderTheme, IconActionButton, LoadingSize, LoadingState, PageHeader, SectionHeader, SessionBadge, StatCard } from '../../components/common';

interface ScheduleItem {
  id: number;
  className: string;
  sessionName: string;
  startTime: string;
  endTime: string;
  location: string;
  studentCount: number;
  status: string;
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
      this.scheduleList = [];
      this.errorMessage = '\u52a0\u8f7d\u6392\u8bfe\u5931\u8d25';
    } finally {
      this.isLoading = false;
    }
  }

  private toScheduleItem(session: SessionSchedule): ScheduleItem {
    return {
      id: session.id,
      className: session.serviceProductName ?? session.sessionNo ?? `Session ${session.id}`,
      sessionName: session.serviceProductName ?? '\u8bfe\u7a0b',
      startTime: session.startTime,
      endTime: session.endTime,
      location: session.location ?? '\u672a\u5b9a\u4f4d',
      studentCount: session.currentCount ?? 0,
      status: this.normalizeStatus(session.status)
    };
  }

  private normalizeStatus(status?: string): string {
    if (status === 'IN_PROGRESS' || status === 'COMPLETED' || status === 'CANCELLED') {
      return status;
    }
    return 'SCHEDULED';
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
    const weekdays = ['\u5468\u65e5', '\u5468\u4e00', '\u5468\u4e8c', '\u5468\u4e09', '\u5468\u56db', '\u5468\u4e94', '\u5468\u516d'];
    return weekdays[date.getDay()];
  }

  private getTodayCount(): number {
    return this.scheduleList.length;
  }

  private getOngoingCount(): number {
    return this.scheduleList.filter((item: ScheduleItem) => item.status === 'IN_PROGRESS').length;
  }

  private getStudentCount(): number {
    return this.scheduleList.reduce((sum: number, item: ScheduleItem) => sum + item.studentCount, 0);
  }

  private getStatusText(status: string): string {
    if (status === 'IN_PROGRESS') {
      return '\u8fdb\u884c\u4e2d';
    }
    if (status === 'COMPLETED') {
      return '\u5df2\u5b8c\u6210';
    }
    if (status === 'CANCELLED') {
      return '\u5df2\u53d6\u6d88';
    }
    return '\u5df2\u6392\u7a0b';
  }

  private getStatusColor(status: string): string {
    if (status === 'IN_PROGRESS') {
      return '#2F9E77';
    }
    if (status === 'COMPLETED') {
      return '#7A879A';
    }
    if (status === 'CANCELLED') {
      return '#D14343';
    }
    return '#526F95';
  }

  build() {
    Column() {
      PageHeader({
        title: '\u6211\u7684\u8bfe\u8868',
        subtitle: '\u67e5\u770b\u6bcf\u65e5\u8bfe\u7a0b\u5b89\u6392\u3001\u573a\u6b21\u548c\u5b66\u751f\u4eba\u6570',
        theme: HeaderTheme.WHITE,
        showBack: true,
        onBackClick: (): void => this.getUIContext().getRouter().back(),
        rightContent: this.buildHeaderAction
      })

      this.buildOverviewPanel()
      this.buildWeekSelector()
      this.buildScheduleContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: '#526F95',
      boxBgColor: Color.White,
      boxBorderColor: '#E5EDF6',
      onButtonClick: (): void => {
        this.loadSchedule();
      }
    })
  }

  @Builder
  buildOverviewPanel() {
    Row() {
      StatCard({
        value: `${this.getTodayCount()}`,
        label: '\u5f53\u65e5\u8bfe\u7a0b',
        icon: $r('app.media.ic_calendar'),
        iconColor: '#526F95'
      })
      .layoutWeight(1)

      Blank().width(12)

      StatCard({
        value: `${this.getOngoingCount()}`,
        label: '\u8fdb\u884c\u4e2d',
        icon: $r('app.media.ic_attendance'),
        iconColor: '#2F9E77'
      })
      .layoutWeight(1)

      Blank().width(12)

      StatCard({
        value: `${this.getStudentCount()}`,
        label: '\u5b66\u751f\u603b\u6570',
        icon: $r('app.media.ic_user'),
        iconColor: '#A9794E'
      })
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
  }

  @Builder
  buildWeekSelector() {
    Column() {
      Text('\u5468\u65e5\u7a97\u53e3')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(this.formatWeekRange())
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 6, bottom: 12 })

      this.buildWeekSelectorContent()
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ left: 16, right: 16, top: 14, bottom: 12 })
  }

  @Builder
  buildWeekSelectorContent() {
    Column() {
      Row() {
          Text('\u4e0a\u4e00\u5468')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('#F7FAFD')
            .borderRadius(16)
            .onClick((): void => {
              this.currentWeekStart.setDate(this.currentWeekStart.getDate() - 7);
              this.generateWeekDates();
              this.selectedDate = new Date(this.currentWeekStart);
              this.loadSchedule();
            })

        Blank().layoutWeight(1)

          Text('\u4e0b\u4e00\u5468')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('#F7FAFD')
            .borderRadius(16)
            .onClick((): void => {
              this.currentWeekStart.setDate(this.currentWeekStart.getDate() + 7);
              this.generateWeekDates();
              this.selectedDate = new Date(this.currentWeekStart);
              this.loadSchedule();
            })
      }
      .width('100%')

      Row() {
        ForEach(this.weekDates, (date: Date) => {
          Column() {
            Text(this.getWeekDayText(date))
              .fontSize(11)
              .fontColor(this.formatDate(date) === this.formatDate(this.selectedDate) ? $r('app.color.primary') : $r('app.color.text_secondary'))

            Text(`${date.getDate()}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.formatDate(date) === this.formatDate(this.selectedDate) ? $r('app.color.primary') : $r('app.color.text_primary'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.formatDate(date) === this.formatDate(this.selectedDate) ? '#EEF6F0' : Color.Transparent)
          .borderRadius(16)
          .onClick((): void => {
            this.selectedDate = date;
            this.loadSchedule();
          })
        })
      }
      .width('100%')
      .margin({ top: 12 })
    }
  }

  @Builder
  buildScheduleContent() {
    if (this.isLoading) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false,
        message: '\u6b63\u5728\u52a0\u8f7d\u8bfe\u8868...'
      })
    } else if (this.scheduleList.length === 0) {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '\u5f53\u5929\u6682\u65e0\u6392\u8bfe',
        customDescription: this.errorMessage || '\u5f53\u524d\u65e5\u671f\u6ca1\u6709\u53ef\u5c55\u793a\u7684\u8bfe\u7a0b'
      })
    } else {
      Scroll() {
        Column() {
          SectionHeader({
            title: '\u8bfe\u7a0b\u5217\u8868',
            subtitle: '\u6309\u65f6\u95f4\u987a\u5e8f\u5c55\u793a\u5f53\u524d\u9009\u62e9\u65e5\u671f\u7684\u6392\u8bfe'
          })

          ForEach(this.scheduleList, (item: ScheduleItem) => {
            this.buildScheduleCard(item)
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 24 })
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
          Row() {
            Image($r('app.media.ic_clock'))
              .width(14)
              .height(14)
              .fillColor($r('app.color.primary'))

            Text(item.startTime)
              .fontSize($r('app.float.card_title_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ left: 4 })
          }

          Text(item.endTime)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .width(72)
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 12 })

        Column() {
          Text(item.sessionName)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Row() {
            Image($r('app.media.ic_location'))
              .width(14)
              .height(14)
              .fillColor($r('app.color.text_tertiary'))

            Text(item.location)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 4 })
          }
          .margin({ top: 6 })

          Text(`${item.studentCount}人`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_tertiary'))
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        SessionBadge({
          status: item.status,
          badgeSize: BadgeSize.DEFAULT
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 6
    })
    .margin({ bottom: 12 })
  }
}

