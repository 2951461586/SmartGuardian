/**
 * SmartGuardian - Parent Home Page
 * Parent dashboard with enterprise education style and real data hooks
 */

import { GreetingHeader, Card, LoadingState, LoadingSize, HeaderTheme, ActionButton, HomeworkCard, HomeworkCardMode } from '../../components/common';
import { AttendanceBadge } from '../../components/StatusBadge';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { TodayStatusCard } from '../../models/card';
import { HomeworkQueryParams } from '../../models/common';
import { HomeworkTask } from '../../models/homework';
import { CardService } from '../../services/api/card';
import { HomeworkService } from '../../services/api/homework';
import { MessageService } from '../../services/api/message';
import { StudentStore } from '../../stores/studentStore';
import { UserStore } from '../../stores/userStore';

@Component
export struct ParentHomePage {
  @State userName: string = '';
  @State todaySummary: TodayStatusCard | null = null;
  @State recentHomework: HomeworkTask[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State unreadCount: number = 0;
  @State alertSummary: string = '';

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const studentId = StudentStore.getCurrentStudentId() ?? undefined;
      const params: HomeworkQueryParams = { pageSize: 3 };

      const [summaryResp, homeworkResp, unreadResp, alertResp] = await Promise.all([
        CardService.getTodayStatus(studentId),
        HomeworkService.getTasks(params),
        MessageService.getUnreadCount(),
        CardService.getAbnormalAlert(studentId)
      ]);

      if (summaryResp.code === 0 && summaryResp.data) {
        this.todaySummary = summaryResp.data;
      }

      if (homeworkResp.code === 0 && homeworkResp.data && homeworkResp.data.list) {
        this.recentHomework = homeworkResp.data.list;
      } else {
        this.recentHomework = [];
      }

      this.unreadCount = unreadResp.code === 0 && unreadResp.data ? unreadResp.data.count : (this.todaySummary?.messages ?? 0);

      if (alertResp.code === 0 && alertResp.data) {
        this.alertSummary = alertResp.data.alertTitle || alertResp.data.alertContent || '';
      } else {
        this.alertSummary = '';
      }
    } catch (error) {
      this.errorMessage = ErrorMessages.DATA_LOAD_FAILED;
      this.todaySummary = null;
      this.recentHomework = [];
      this.unreadCount = 0;
      this.alertSummary = '';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      GreetingHeader({
        userName: this.userName,
        greeting: "Track the current care session, homework progress, and school messages in one place.",
        theme: HeaderTheme.WHITE,
        badgeText: "Parent workspace",
        metaText: this.todaySummary?.studentName ? `Watching: ${this.todaySummary.studentName}` : '',
        onRightIconClick: () => {
          AppStorage.setOrCreate('main_current_index', 2);
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
      AppStorage.setOrCreate('main_current_index', 2);
    })
  }

  @Builder
  buildContent() {
    Scroll() {
      Column() {
        this.buildOverviewPanel()

        if (this.alertSummary) {
          this.buildAlertBanner()
        }

        this.buildQuickActions()
        this.buildTodayStatusCard()
        this.buildRecentHomework()
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
        this.buildStatusMetric('Attendance', this.getAttendanceText(), '#1F5EFF', '#EDF4FF')
        Blank().width(10)
        this.buildStatusMetric('Homework', this.getHomeworkProgressText(), '#14B8A6', '#ECFDF5')
      }
      .width('100%')

      Row() {
        this.buildStatusMetric('Unread', `${this.unreadCount}`, '#F59E0B', '#FFF7E8')
        Blank().width(10)
        this.buildStatusMetric('Session', this.todaySummary?.sessionName || 'Pending', '#8B5CF6', '#F5F0FF')
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .margin({ bottom: 14 })
  }

  @Builder
  buildStatusMetric(title: string, value: string, valueColor: string, bgColor: string) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(valueColor)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(bgColor)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildAlertBanner() {
    Row() {
      Column() {
        Image($r('app.media.ic_warning'))
          .width(20)
          .height(20)
          .fillColor('#F59E0B')
      }
      .width(38)
      .height(38)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFF4DE')
      .borderRadius(14)

      Column() {
        Text('Today alert')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.alertSummary)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .lineHeight(19)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFDF6')
    .borderRadius(20)
    .border({
      width: 1,
      color: '#FDE7B0',
      radius: 20,
      style: BorderStyle.Solid
    })
    .margin({ bottom: 14 })
  }

  @Builder
  buildQuickActions() {
    Column() {
      Text('Quick actions')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 10 })

      Row() {
        ActionButton({
          label: 'Leave request',
          icon: $r('app.media.ic_leave'),
          bgColor: '#EAF1FF',
          iconColor: '#1F5EFF',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentLeavePage' });
          }
        })

        Blank().width(10)

        ActionButton({
          label: 'Pickup QR',
          icon: $r('app.media.ic_qrcode'),
          bgColor: '#ECFDF5',
          iconColor: '#16A34A',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentQRCodePage' });
          }
        })
      }
      .width('100%')

      Row() {
        ActionButton({
          label: 'Message teacher',
          icon: $r('app.media.ic_message'),
          bgColor: '#FFF7E8',
          iconColor: '#F59E0B',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 2);
          }
        })

        Blank().width(10)

        ActionButton({
          label: 'Session plan',
          icon: $r('app.media.ic_calendar'),
          bgColor: '#F5F0FF',
          iconColor: '#8B5CF6',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentSessionsPage' });
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
  buildTodayStatusCard() {
    Card({
      title: 'Today care',
      subtitle: this.errorMessage ? this.errorMessage : "Review the current session, attendance, and teacher feedback.",
      showArrow: true,
      clickable: true,
      onCardClick: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentTimelinePage' });
      },
      content: this.buildTodayStatusCardContent
    })
  }

  @Builder
  buildTodayStatusCardContent() {
    if (this.todaySummary) {
      Column() {
        Row() {
          Column() {
            Text(this.todaySummary.sessionName || 'Care session')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))

            Text(this.todaySummary.sessionTime || '--:-- - --:--')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          AttendanceBadge({ status: this.todaySummary.status || 'NOT_SIGNED' })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Row() {
          this.buildInlineTag('Student', this.todaySummary.studentName || '--')
          Blank().width(8)
          this.buildInlineTag('Homework', this.getHomeworkProgressText())
        }
        .width('100%')
        .margin({ top: 16 })

        Column() {
          Text('Teacher feedback')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Text(this.todaySummary.latestDynamic || 'No teacher update yet.')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .lineHeight(21)
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 14, bottom: 14 })
        .backgroundColor('#F7FAFD')
        .borderRadius(16)
        .margin({ top: 16 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    } else {
      Text('No schedule for today.')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
    }
  }

  @Builder
  buildInlineTag(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_tertiary'))

      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor('#F7FAFD')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildRecentHomework() {
    Card({
      title: 'Recent homework',
      subtitle: 'Stay aligned with the latest assignments and coaching progress.',
      actionText: 'View all',
      onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentHomeworkPage' });
      },
      content: this.buildRecentHomeworkContent
    })
  }

  @Builder
  buildRecentHomeworkContent() {
    if (this.recentHomework.length > 0) {
      Column() {
        ForEach(this.recentHomework, (item: HomeworkTask, index: number) => {
          HomeworkCard({
            homework: item,
            mode: HomeworkCardMode.SIMPLE
          })
          if (index < this.recentHomework.length - 1) {
            Divider().color('#EEF2F7').margin({ top: 10, bottom: 10 })
          }
        })
      }
      .width('100%')
    } else {
      Text('No homework records yet.')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .padding({ top: 8, bottom: 8 })
    }
  }

  private getAttendanceText(): string {
    switch (this.todaySummary?.status) {
      case 'SIGNED_IN':
        return 'On site';
      case 'SIGNED_OUT':
        return 'Checked out';
      case 'IN_PROGRESS':
        return 'In progress';
      default:
        return 'Pending';
    }
  }

  private getHomeworkProgressText(): string {
    const progress = this.todaySummary?.homeworkProgress ?? 0;
    if (progress <= 0) {
      return 'Not started';
    }
    if (progress >= 100) {
      return 'Completed';
    }
    return `${progress}%`;
  }
}
