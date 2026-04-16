/**
 * SmartGuardian - 教师排课日历页
 * 教师查看和管理个人课表
 */

import { router } from '@kit.ArkUI';
import { DateUtils } from '../../utils/dateUtils';

interface ScheduleItem {
  id: string;
  className: string;
  sessionName: string;
  startTime: string;
  endTime: string;
  location: string;
  studentCount: number;
  status: 'SCHEDULED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
}

@Component
struct TeacherSchedulePage {
  @State currentWeekStart: Date = DateUtils.getStartOfWeek(new Date());
  @State selectedDate: Date = new Date();
  @State weekDates: Date[] = [];
  @State scheduleList: ScheduleItem[] = [];
  @State isLoading: boolean = false;

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
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));

      // Mock data
      this.scheduleList = [
        {
          id: '1',
          className: '一年级(1)班',
          sessionName: '作业辅导',
          startTime: '15:30',
          endTime: '17:30',
          location: '101教室',
          studentCount: 25,
          status: 'SCHEDULED'
        },
        {
          id: '2',
          className: '一年级(2)班',
          sessionName: '作业辅导',
          startTime: '17:30',
          endTime: '19:30',
          location: '102教室',
          studentCount: 22,
          status: 'SCHEDULED'
        }
      ];
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Week navigation
      this.buildWeekNav()

      // Date tabs
      this.buildDateTabs()

      // Schedule list
      this.buildScheduleList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Text('我的课表')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
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
      Column() {
        Image($r('app.media.ic_empty'))
          .width(100)
          .height(100)
          .opacity(0.5)

        Text('当日无课程安排')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: $r('app.float.card_margin') })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
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
    }
  }

  @Builder
  buildScheduleCard(item: ScheduleItem) {
    Column() {
      // Time indicator
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

        // Timeline bar
        Column() {
          Column() {
            Text(item.sessionName)
              .fontSize($r('app.float.text_primary_size'))
              .fontColor(Color.White)
          }
          .width('100%')
          .padding(8)
          .backgroundColor($r('app.color.primary'))
          .borderRadius($r('app.float.badge_radius'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // Class info
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

            Text(` | ${item.studentCount}人`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_tertiary'))
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        this.getStatusBadge(item.status)
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  getStatusBadge(status: string) {
    const statusConfig: Record<string, { text: string; color: string }> = {
      'SCHEDULED': { text: '待上课', color: '#FF9800' },
      'IN_PROGRESS': { text: '进行中', color: '#4CAF50' },
      'COMPLETED': { text: '已完成', color: '#2196F3' },
      'CANCELLED': { text: '已取消', color: '#9E9E9E' }
    };

    const config = statusConfig[status] || { text: '未知', color: '#999' };

    Text(config.text)
      .fontSize($r('app.float.text_tiny_size'))
      .fontColor(config.color)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(config.color + '20')
      .borderRadius($r('app.float.badge_radius'))
  }

  formatWeekRange(): string {
    const start = this.currentWeekStart;
    const end = new Date(start);
    end.setDate(end.getDate() + 6);
    return `${start.getMonth() + 1}月${start.getDate()}日 - ${end.getMonth() + 1}月${end.getDate()}日`;
  }

  getWeekDayText(date: Date): string {
    const days = ['日', '一', '二', '三', '四', '五', '六'];
    return '周' + days[date.getDay()];
  }
}