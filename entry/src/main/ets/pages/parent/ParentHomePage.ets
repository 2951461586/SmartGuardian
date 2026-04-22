/**
 * SmartGuardian - Parent Home Page
 * Parent's main dashboard showing today's status and quick actions
 *
 * @migrated 2026-04-20 - P2 Migration with Common Components
 */

import { UserStore } from '../../stores/userStore';
import { StudentStore } from '../../stores/studentStore';
import { CardService } from '../../services/api/card';
import { TodayStatusCard } from '../../models/card';
import { HomeworkService } from '../../services/api/homework';
import { HomeworkTask } from '../../models/homework';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { HomeworkQueryParams } from '../../models/common';
import { GreetingHeader, Card, LoadingState, LoadingSize, HeaderTheme, ActionButton, HomeworkCard, HomeworkCardMode } from '../../components/common';
import { AttendanceBadge } from '../../components/StatusBadge';

@Component
export struct ParentHomePage {
  @State userName: string = '';
  @State todaySummary: TodayStatusCard | null = null;
  @State recentHomework: HomeworkTask[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State unreadCount: number = 0;

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
      const summaryResp = await CardService.getTodayStatus(studentId);
      if (summaryResp.code === 0 && summaryResp.data) {
        this.todaySummary = summaryResp.data;
      }

      const params: HomeworkQueryParams = {
        pageSize: 3
      };
      const homeworkResp = await HomeworkService.getTasks(params);
      if (homeworkResp.code === 0 && homeworkResp.data && homeworkResp.data.list) {
        this.recentHomework = homeworkResp.data.list;
      } else {
        this.recentHomework = [];
      }
    } catch (error) {
      this.errorMessage = ErrorMessages.DATA_LOAD_FAILED;
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      GreetingHeader({
        userName: this.userName,
        greeting: '今日托管状态、作业与家校沟通一目了然',
        theme: HeaderTheme.WHITE,
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
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F1F5FB')
      .borderRadius(20)

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
        this.buildQuickActions()
        this.buildTodayStatusCard()
        this.buildRecentHomework()
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
      this.buildOverviewMetric('今日状态', this.todaySummary?.status ? '已更新' : '待确认', '#4F7CFF', '#EAF2FF')
      Blank().width(10)
      this.buildOverviewMetric('最新动态', this.todaySummary?.latestDynamic ? '有动态' : '暂无', '#34A853', '#EAF7EC')
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
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(bgColor)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTodayStatusCard() {
    Card({
      title: '今日托管',
      subtitle: this.errorMessage ? this.errorMessage : '查看孩子当前班次、签到状态与最新动态',
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
            Text(this.todaySummary.sessionName || '托管班')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))

            Text(this.todaySummary.sessionTime || '--:-- - --:--')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          AttendanceBadge({ status: this.todaySummary.status || 'NOT_SIGNED' })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        if (this.todaySummary.latestDynamic) {
          Column() {
            Text('最新动态')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))

            Text(this.todaySummary.latestDynamic)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 14, bottom: 14 })
          .backgroundColor('#F7FAFF')
          .borderRadius(14)
          .margin({ top: 16 })
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
    } else {
      Text('暂无今日托管安排')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
    }
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
          label: '请假',
          icon: $r('app.media.ic_leave'),
          bgColor: '#EAF2FF',
          iconColor: '#4F7CFF',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentLeavePage' });
          }
        })

        ActionButton({
          label: '接送码',
          icon: $r('app.media.ic_qrcode'),
          bgColor: '#EAF7EC',
          iconColor: '#34A853',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentQRCodePage' });
          }
        })

        ActionButton({
          label: '联系老师',
          icon: $r('app.media.ic_message'),
          bgColor: '#FFF4E8',
          iconColor: '#F2994A',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 2);
          }
        })

        ActionButton({
          label: '查看班次',
          icon: $r('app.media.ic_calendar'),
          bgColor: '#F4EEFF',
          iconColor: '#8E5CF6',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentSessionsPage' });
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
  buildRecentHomework() {
    Card({
      title: '最近作业',
      subtitle: '查看老师最新布置与辅导进度',
      actionText: '查看全部',
      onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentHomeworkPage' });
      },
      content: this.buildRecentHomeworkContent
    })
  }

  @Builder
  buildRecentHomeworkContent() {
    if (this.recentHomework && this.recentHomework.length > 0) {
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
      Text('暂无作业记录')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .padding({ top: 8, bottom: 8 })
    }
  }
}
