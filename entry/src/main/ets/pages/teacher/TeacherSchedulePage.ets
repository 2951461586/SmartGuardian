import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  BadgeSize,
  Card,
  EmptyType,
  HeaderTheme,
  IconActionButton,
  PageHeader,
  SectionHeader,
  SessionBadge,
  StatefulContainer,
  StatCardRow,
  StatRowItem,
  ViewState,
  WorkbenchListPageTemplate
} from '../../components/common';
import { SessionSchedule } from '../../models/service';
import { SessionService } from '../../services/api/service';
import { UserStore } from '../../stores/userStore';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';
import { DateUtils } from '../../utils/dateUtils';

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
struct TeacherSchedulePage {
  build() {
    Stack() {
      TeacherSchedulePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct TeacherSchedulePageContent {
  @State currentWeekStart: Date = DateUtils.getStartOfWeek(new Date());
  @State selectedDate: Date = new Date();
  @State weekDates: Date[] = [];
  @State scheduleList: ScheduleItem[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  private scheduleDataSource: LazyArrayDataSource<ScheduleItem> = new LazyArrayDataSource<ScheduleItem>();

  aboutToAppear() {
    this.generateWeekDates();
    this.loadSchedule();
  }

  private generateWeekDates(): void {
    this.weekDates = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(this.currentWeekStart);
      date.setDate(date.getDate() + i);
      this.weekDates.push(date);
    }
  }

  private shiftWeek(offset: number): void {
    this.currentWeekStart.setDate(this.currentWeekStart.getDate() + offset * 7);
    this.generateWeekDates();
    this.selectedDate = new Date(this.currentWeekStart);
    this.loadSchedule();
  }

  private selectDate(date: Date): void {
    this.selectedDate = date;
    this.loadSchedule();
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
        this.scheduleList = response.data.map((session: SessionSchedule) => this.toScheduleItem(session));
        this.scheduleDataSource.setItems(this.scheduleList);
      } else {
        this.clearScheduleData();
      }
    } catch (error) {
      this.clearScheduleData();
      this.errorMessage = '加载排课失败，请稍后重试。';
    } finally {
      this.isLoading = false;
    }
  }

  private clearScheduleData(): void {
    this.scheduleList = [];
    this.scheduleDataSource.clear();
  }

  private toScheduleItem(session: SessionSchedule): ScheduleItem {
    return {
      id: session.id,
      className: session.serviceProductName ?? session.sessionNo ?? `Session ${session.id}`,
      sessionName: session.serviceProductName ?? '课程',
      startTime: session.startTime,
      endTime: session.endTime,
      location: session.location ?? '待安排场地',
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
    const weekdays: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[date.getDay()];
  }

  private isSelectedDate(date: Date): boolean {
    return this.formatDate(date) === this.formatDate(this.selectedDate);
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

  private getViewState(): ViewState {
    if (this.isLoading) {
      return ViewState.LOADING;
    }
    if (this.scheduleList.length === 0) {
      return ViewState.EMPTY;
    }
    return ViewState.CONTENT;
  }

  build() {
    Column() {
      WorkbenchListPageTemplate({
        scrollable: false,
        enableWideContent: true,
        header: this.buildHeader,
        overview: this.buildOverviewSection,
        controls: this.buildWeekSelectorSection,
        content: this.buildScheduleContent
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHeader() {
    PageHeader({
      title: '我的课表',
      subtitle: '查看每日课程安排、班次状态和学生人数。',
      theme: HeaderTheme.WHITE,
      showBack: true,
      onBackClick: (): void => this.getUIContext().getRouter().back(),
      rightContent: this.buildHeaderAction
    })
  }

  @Builder
  private buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: HarmonyColor.info,
      boxBgColor: HarmonyColor.surface,
      boxBorderColor: $r('app.color.divider'),
      onButtonClick: (): void => {
        this.loadSchedule();
      }
    })
  }

  @Builder
  private buildOverviewSection() {
    StatCardRow({
      items: this.getOverviewItems()
    })
  }

  private getOverviewItems(): StatRowItem[] {
    return [
      { value: `${this.getTodayCount()}`, label: '当日课程', icon: $r('app.media.ic_calendar'), iconColor: HarmonyColor.brandBlue },
      { value: `${this.getOngoingCount()}`, label: '进行中', icon: $r('app.media.ic_attendance'), iconColor: HarmonyReport.positive },
      { value: `${this.getStudentCount()}`, label: '学生总数', icon: $r('app.media.ic_user'), iconColor: HarmonyReport.caution }
    ];
  }

  @Builder
  private buildWeekSelectorSection() {
    Card({
      title: '周视图',
      subtitle: this.formatWeekRange(),
      content: this.buildWeekSelectorContent
    })
  }

  @Builder
  private buildWeekSelectorContent() {
    Column() {
      Row() {
        this.buildWeekSwitchButton('上一周', -1)
        Blank().layoutWeight(1)
        this.buildWeekSwitchButton('下一周', 1)
      }
      .width('100%')

      Row() {
        ForEach(this.weekDates, (date: Date) => {
          this.buildDateChip(date)
        }, (date: Date) => this.formatDate(date))
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
  }

  @Builder
  private buildWeekSwitchButton(label: string, offset: number) {
    Text(label)
      .fontSize(13)
      .fontColor(HarmonyColor.textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(HarmonyColor.surfaceSubtle)
      .borderRadius(16)
      .onClick((): void => {
        this.shiftWeek(offset);
      })
  }

  @Builder
  private buildDateChip(date: Date) {
    Column() {
      Text(this.getWeekDayText(date))
        .fontSize(11)
        .fontColor(this.isSelectedDate(date) ? HarmonyColor.info : HarmonyColor.textSecondary)

      Text(`${date.getDate()}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isSelectedDate(date) ? HarmonyColor.info : HarmonyColor.textPrimary)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(this.isSelectedDate(date) ? $r('app.color.primary_light') : HarmonyColor.clear)
    .borderRadius(16)
    .onClick((): void => {
      this.selectDate(date);
    })
  }

  @Builder
  private buildScheduleContent() {
    StatefulContainer({
      state: this.getViewState(),
      loadingMessage: '正在加载课表...',
      emptyType: EmptyType.DEFAULT,
      emptyTitle: '当天暂无排课',
      emptyDescription: this.errorMessage.length > 0 ? this.errorMessage : '当前日期没有可展示的课程安排。',
      emptyActionText: '刷新',
      onEmptyAction: () => {
        this.loadSchedule();
      },
      content: this.buildScheduleList
    })
      .layoutWeight(1)
  }

  @Builder
  private buildScheduleList() {
    List() {
      ListItem() {
        SectionHeader({
          title: '课程列表',
          subtitle: '按时间顺序展示当前选中日期的全部班次。'
        })
      }

      LazyForEach(this.scheduleDataSource, (item: ScheduleItem) => {
        ListItem() {
          this.buildScheduleCard(item)
        }
      }, (item: ScheduleItem) => `${item.id}`)
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0 })
    .scrollBar(BarState.Off)
    .cachedCount(8)
  }

  @Builder
  private buildScheduleCard(item: ScheduleItem) {
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
        .width(80)
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 12 })

        Column() {
          Text(item.sessionName)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text(item.className)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })

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
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(20)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 20,
      style: BorderStyle.Solid
    })
    .margin({ bottom: 12 })
  }
}
