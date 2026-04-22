/**
 * SmartGuardian - Parent Home Page
 * Parent dashboard with enterprise education style and real data hooks
 */

import { GreetingHeader, Card, LoadingState, LoadingSize, HeaderTheme, ActionButton, HomeworkCard, HomeworkCardMode, SectionHeader, StatCard } from '../../components/common';
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

      const summaryPromise = CardService.getTodayStatus(studentId);
      const homeworkPromise = HomeworkService.getTasks(params);
      const unreadPromise = MessageService.getUnreadCount();
      const alertPromise = CardService.getAbnormalAlert(studentId);

      const summaryResp = await summaryPromise;
      const homeworkResp = await homeworkPromise;
      const unreadResp = await unreadPromise;
      const alertResp = await alertPromise;

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
        greeting: '在一个页面掌握今日托管、作业进度和校园消息。',
        theme: HeaderTheme.WHITE,
        badgeText: '家长工作台',
        metaText: this.todaySummary?.studentName ? `当前关注：${this.todaySummary.studentName}` : '',
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
        StatCard({
          value: this.getAttendanceText(),
          label: '考勤状态',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#1F5EFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.getHomeworkProgressText(),
          label: '作业进度',
          icon: $r('app.media.ic_homework'),
          iconColor: '#14B8A6'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: `${this.unreadCount}`,
          label: '未读消息',
          icon: $r('app.media.ic_message'),
          iconColor: '#F59E0B'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.todaySummary?.sessionName || '待安排',
          label: '托管场次',
          icon: $r('app.media.ic_calendar'),
          iconColor: '#8B5CF6'
        })
        .layoutWeight(1)
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
        Text('今日提醒')
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
      SectionHeader({
        title: '快捷操作',
        subtitle: '一键进入高频业务入口'
      })

      Row() {
        ActionButton({
          label: '请假申请',
          icon: $r('app.media.ic_leave'),
          bgColor: '#EAF1FF',
          iconColor: '#1F5EFF',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentLeavePage' });
          }
        })

        Blank().width(10)

        ActionButton({
          label: '接送码',
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
          label: '联系老师',
          icon: $r('app.media.ic_message'),
          bgColor: '#FFF7E8',
          iconColor: '#F59E0B',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 2);
          }
        })

        Blank().width(10)

        ActionButton({
          label: '托管安排',
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
      title: '今日托管',
      subtitle: this.errorMessage ? this.errorMessage : '查看当前场次、考勤状态和老师反馈。',
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
            Text(this.todaySummary.sessionName || '托管场次')
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
          this.buildInlineTag('学生', this.todaySummary.studentName || '--')
          Blank().width(8)
          this.buildInlineTag('作业', this.getHomeworkProgressText())
        }
        .width('100%')
        .margin({ top: 16 })

        Column() {
          Text('老师反馈')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Text(this.todaySummary.latestDynamic || '老师暂未更新动态。')
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
      Text('今日暂无托管安排。')
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
      title: '最近作业',
      subtitle: '及时了解最新作业和辅导进度。',
      actionText: '查看全部',
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
      Text('暂无作业记录。')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .padding({ top: 8, bottom: 8 })
    }
  }

  private getAttendanceText(): string {
    switch (this.todaySummary?.status) {
      case 'SIGNED_IN':
        return '已到校';
      case 'SIGNED_OUT':
        return '已签退';
      case 'IN_PROGRESS':
        return '进行中';
      default:
        return '待签到';
    }
  }

  private getHomeworkProgressText(): string {
    const progress = this.todaySummary?.homeworkProgress ?? 0;
    if (progress <= 0) {
      return '未开始';
    }
    if (progress >= 100) {
      return '已完成';
    }
    return `${progress}%`;
  }
}
