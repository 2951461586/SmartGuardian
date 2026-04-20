/**
 * SmartGuardian - Parent Home Page
 * Parent's main dashboard showing today's status and quick actions
 * 
 * @migrated 2026-04-20 - P2 Migration with Common Components
 */

import router from '@ohos.router';
import { UserStore } from '../../stores/userStore';
import { CardService } from '../../services/api/card';
import { TodayStatusCard } from '../../models/card';
import { HomeworkService } from '../../services/api/homework';
import { HomeworkTask } from '../../models/homework';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { HomeworkQueryParams } from '../../models/common';
// Common Components
import { GreetingHeader, Card, StatCard, LoadingState, LoadingSize, HeaderTheme, ActionButton, HomeworkCard, HomeworkCardMode } from '../../components/common';
import { AttendanceBadge, HomeworkBadge } from '../../components/StatusBadge';
import { StatusType } from '../../constants/StatusMapping';

@Entry
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
    try {
      // Load today's summary
      const summaryResp = await CardService.getTodayStatus(1);
      if (summaryResp.code === 0 && summaryResp.data) {
        this.todaySummary = summaryResp.data;
      }

      // Load recent homework - 使用统一查询参数
      const params: HomeworkQueryParams = {
        pageSize: 3
      };
      const homeworkResp = await HomeworkService.getTasks(params);
      if (homeworkResp.code === 0 && homeworkResp.data) {
        this.recentHomework = homeworkResp.data.list ?? [];
      }
    } catch (error) {
      this.errorMessage = ErrorMessages.DATA_LOAD_FAILED;
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 使用通用GreetingHeader
      GreetingHeader({
        userName: this.userName,
        greeting: '查看孩子今天的托管情况',
        theme: HeaderTheme.PRIMARY,
        onRightIconClick: () => {
          router.pushUrl({ url: 'pages/parent/ParentMessagesPage' });
        }
      })

      // 内容区域
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
  buildContent() {
    Scroll() {
      Column() {
        // 今日托管卡片
        this.buildTodayStatusCard()

        // 快捷操作
        this.buildQuickActions()

        // 最近作业
        this.buildRecentHomework()
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildTodayStatusCard() {
    // 使用通用Card组件
    Card({
      title: '今日托管',
      showArrow: true,
      clickable: true,
      onCardClick: () => {
        router.pushUrl({ url: 'pages/parent/ParentAttendancePage' });
      },
      content: this.buildTodayStatusCardContent
    })
  }

  @Builder
  buildTodayStatusCardContent() {
    if (this.todaySummary) {
      Row() {
        Column() {
          Text(this.todaySummary.sessionName || '托管班')
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text(this.todaySummary.sessionTime || '--:-- - --:--')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 使用AttendanceBadge显示状态
        AttendanceBadge({ status: this.todaySummary.status || 'NOT_SIGNED' })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 最新动态
      if (this.todaySummary.latestDynamic) {
        Row() {
          Image($r('app.media.ic_calendar'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .fillColor($r('app.color.text_tertiary'))

          Text(this.todaySummary.latestDynamic)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 8 })
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .margin({ top: 12 })
      }
    } else {
      Text('暂无今日托管安排')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
    }
  }

  @Builder
  buildQuickActions() {
    Row() {
      ActionButton({
        label: '请假',
        icon: $r('app.media.ic_leave'),
        bgColor: '#E3F2FD',
        iconColor: '#2196F3',
        onButtonClick: () => {
          router.pushUrl({ url: 'pages/parent/ParentLeavePage' });
        }
      })

      ActionButton({
        label: '接送码',
        icon: $r('app.media.ic_qrcode'),
        bgColor: '#E8F5E9',
        iconColor: '#4CAF50',
        onButtonClick: () => {
          router.pushUrl({ url: 'pages/parent/ParentQRCodePage' });
        }
      })

      ActionButton({
        label: '联系老师',
        icon: $r('app.media.ic_message'),
        bgColor: '#FFF3E0',
        iconColor: '#FF9800',
        onButtonClick: () => {
          router.pushUrl({ url: 'pages/parent/ParentMessagesPage' });
        }
      })

      ActionButton({
        label: '查看班次',
        icon: $r('app.media.ic_calendar'),
        bgColor: '#F3E5F5',
        iconColor: '#9C27B0',
        onButtonClick: () => {
          router.pushUrl({ url: 'pages/parent/ParentSessionsPage' });
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildRecentHomework() {
    Card({
      title: '最近作业',
      actionText: '查看全部',
      onAction: () => {
        router.pushUrl({ url: 'pages/parent/ParentHomeworkPage' });
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
            Divider().margin({ top: 8, bottom: 8 })
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
