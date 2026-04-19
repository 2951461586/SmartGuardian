/**
 * SmartGuardian - Teacher Home Page
 * Teacher's main dashboard showing today's sessions and tasks
 */

import { UserStore } from '../../stores/userStore';
import { SessionService } from '../../services/api/service';
import { SessionSchedule } from '../../models/service';

@Component
export struct TeacherHomePage {
  @State userName: string = '';
  @State todaySessions: SessionSchedule[] = [];
  @State isLoading: boolean = false;
  @State currentSessionIndex: number = 0;

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadTodaySessions();
  }

  async loadTodaySessions() {
    this.isLoading = true;
    try {
      const today = new Date().toISOString().split('T')[0];
      const resp = await SessionService.getSessions({
        sessionDate: today,
        pageSize: 10
      });

      if (resp.code === 0 && resp.data) {
        this.todaySessions = Array.isArray(resp.data) ? resp.data : [];
      }
    } catch (error) {
      // Handle error
    } finally {
      this.isLoading = false;
    }
  }

  getTotalStudents(): number {
    return this.todaySessions.reduce((sum: number, session: SessionSchedule) => sum + session.currentCount, 0);
  }

  getInProgressCount(): number {
    return this.todaySessions.filter((session: SessionSchedule) => session.status === 'IN_PROGRESS').length;
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Content
      Scroll() {
        Column() {
          // Today's overview
          this.buildTodayOverview()

          // Session list
          this.buildSessionList()
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text(`你好，${this.userName || '老师'}`)
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('今天是托管日')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor('#FFFFFFCC')
      }
      .alignItems(HorizontalAlign.Start)

      Image($r('app.media.ic_notification'))
        .width($r('app.float.icon_large_size'))
        .height($r('app.float.icon_large_size'))
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: Number($r('app.float.status_bar_height')) + 20 })
  }

  @Builder
  buildTodayOverview() {
    Column() {
      Text('今日班次')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: $r('app.float.card_content_margin') })

      if (this.todaySessions.length > 0) {
        Row() {
          Column() {
            Text(`${this.todaySessions.length}`)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary'))

            Text('班次数')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column() {
            Text(`${this.getTotalStudents()}`)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary'))

            Text('学生数')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)

          Column() {
            Text(`${this.getInProgressCount()}`)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary'))

            Text('进行中')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.End)
          .layoutWeight(1)
        }
        .width('100%')
      } else {
        Text('今日暂无班次安排')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildSessionList() {
    Column() {
      Text('班次详情')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: $r('app.float.card_content_margin') })

      if (this.todaySessions.length > 0) {
        ForEach(this.todaySessions, (session: SessionSchedule) => {
          this.buildSessionItem(session)
        })
      } else {
        Text('暂无班次')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .padding({ top: $r('app.float.card_padding'), bottom: $r('app.float.card_padding') })
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }

  @Builder
  buildSessionItem(session: SessionSchedule) {
    Row() {
      Column() {
        Text(session.sessionNo || `班次${session.id}`)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(`${session.startTime} - ${session.endTime}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })

        Row() {
          Text(`已签到 ${session.currentCount} / ${session.maxCapacity}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      this.buildStatusBadge(session.status)
    }
    .width('100%')
    .padding({ top: $r('app.float.card_padding'), bottom: $r('app.float.card_padding') })
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_content_margin') })
  }

  @Builder
  buildStatusBadge(status: string | undefined) {
    Text(this.getStatusText(status || 'SCHEDULED'))
      .fontSize($r('app.float.badge_text_size'))
      .fontColor(this.getStatusColor(status || 'SCHEDULED'))
      .padding({
        left: $r('app.float.badge_padding'),
        right: $r('app.float.badge_padding'),
        top: $r('app.float.badge_padding'),
        bottom: $r('app.float.badge_padding')
      })
      .backgroundColor(this.getStatusBgColor(status || 'SCHEDULED'))
      .borderRadius($r('app.float.badge_radius'))
  }

  getStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      'SCHEDULED': '待开始',
      'IN_PROGRESS': '进行中',
      'COMPLETED': '已完成',
      'CANCELLED': '已取消'
    };
    return statusMap[status] || status;
  }

  getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'SCHEDULED': '#FF9800',
      'IN_PROGRESS': '#4CAF50',
      'COMPLETED': '#9E9E9E',
      'CANCELLED': '#F44336'
    };
    return colorMap[status] || '#666666';
  }

  getStatusBgColor(status: string): string {
    const colorMap: Record<string, string> = {
      'SCHEDULED': '#FFF3E0',
      'IN_PROGRESS': '#E8F5E9',
      'COMPLETED': '#F5F5F5',
      'CANCELLED': '#FFEBEE'
    };
    return colorMap[status] || '#F5F5F5';
  }
}