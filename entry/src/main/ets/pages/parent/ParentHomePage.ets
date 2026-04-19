/**
 * SmartGuardian - Parent Home Page
 * Parent's main dashboard showing today's status and quick actions
 */

import { UserStore } from '../../stores/userStore';
import { CardsService, TodaySummaryCard } from '../../services/api/reports';
import { HomeworkService } from '../../services/api/homework';
import { HomeworkTask } from '../../models/homework';

@Component
export struct ParentHomePage {
  @State userName: string = '';
  @State todaySummary: TodaySummaryCard | null = null;
  @State recentHomework: HomeworkTask[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

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
      const summaryResp = await CardsService.getTodaySummary(1); // TODO: Use actual student ID
      if (summaryResp.code === 0 && summaryResp.data) {
        this.todaySummary = summaryResp.data;
      }

      // Load recent homework
      const homeworkResp = await HomeworkService.getTasks({ pageSize: 3 });
      if (homeworkResp.code === 0 && homeworkResp.data) {
        this.recentHomework = homeworkResp.data.list;
      }
    } catch (error) {
      this.errorMessage = '加载数据失败';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Content
      Scroll() {
        Column() {
          // Today's status card
          this.buildTodayStatusCard()

          // Quick actions
          this.buildQuickActions()

          // Recent homework
          this.buildRecentHomework()
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
        Text(`你好，${this.userName || '家长'}`)
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text('查看孩子今天的托管情况')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
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
  buildTodayStatusCard() {
    Column() {
      Text('今日托管')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      if (this.todaySummary) {
        Row() {
          Column() {
            Text(this.todaySummary.sessionName)
              .fontSize($r('app.float.text_primary_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Text(this.todaySummary.sessionTime)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Start)

          this.buildStatusBadge(this.todaySummary.status)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: $r('app.float.card_content_margin') })
      } else {
        Text('暂无今日托管安排')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: $r('app.float.card_content_margin') })
      }

      // Latest dynamic
      if (this.todaySummary?.latestDynamic) {
        Text(this.todaySummary.latestDynamic)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: $r('app.float.card_content_margin') })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildStatusBadge(status: string) {
    Text(this.getStatusText(status))
      .fontSize($r('app.float.badge_text_size'))
      .fontColor(this.getStatusColor(status))
      .padding({
        left: $r('app.float.badge_padding'),
        right: $r('app.float.badge_padding'),
        top: $r('app.float.badge_padding'),
        bottom: $r('app.float.badge_padding')
      })
      .backgroundColor(this.getStatusBgColor(status))
      .borderRadius($r('app.float.badge_radius'))
  }

  getStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      'NOT_SIGNED': '待签到',
      'SIGNED_IN': '已签到',
      'IN_PROGRESS': '托管中',
      'SIGNED_OUT': '已签退'
    };
    return statusMap[status] || status;
  }

  getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'NOT_SIGNED': '#FF9800',
      'SIGNED_IN': '#4CAF50',
      'IN_PROGRESS': '#2196F3',
      'SIGNED_OUT': '#9E9E9E'
    };
    return colorMap[status] || '#666666';
  }

  getStatusBgColor(status: string): string {
    const colorMap: Record<string, string> = {
      'NOT_SIGNED': '#FFF3E0',
      'SIGNED_IN': '#E8F5E9',
      'IN_PROGRESS': '#E3F2FD',
      'SIGNED_OUT': '#F5F5F5'
    };
    return colorMap[status] || '#F5F5F5';
  }

  @Builder
  buildQuickActions() {
    Row() {
      this.buildActionButton('请假', $r('app.media.ic_leave'), () => {
        // TODO: Navigate to leave application
      })
      this.buildActionButton('接送码', $r('app.media.ic_qrcode'), () => {
        // TODO: Show pickup QR code
      })
      this.buildActionButton('联系老师', $r('app.media.ic_message'), () => {
        // TODO: Navigate to messages
      })
      this.buildActionButton('查看班次', $r('app.media.ic_calendar'), () => {
        // TODO: Navigate to session list
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildActionButton(label: string, icon: Resource, action: () => void) {
    Column() {
      Image(icon)
        .width($r('app.float.action_icon_size'))
        .height($r('app.float.action_icon_size'))
        .objectFit(ImageFit.Contain)

      Text(label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ top: $r('app.float.text_margin_small') })
    }
    .layoutWeight(1)
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .onClick(action)
  }

  @Builder
  buildRecentHomework() {
    Column() {
      Row() {
        Text('最近作业')
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text('查看全部')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: $r('app.float.card_content_margin') })

      if (this.recentHomework.length > 0) {
        ForEach(this.recentHomework, (item: HomeworkTask) => {
          this.buildHomeworkItem(item)
        })
      } else {
        Text('暂无作业记录')
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
  buildHomeworkItem(item: HomeworkTask) {
    Row() {
      Column() {
        Text(item.subject || '作业')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))

        Text(item.content)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(item.status === 'COMPLETED' ? '已完成' : '待完成')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(item.status === 'COMPLETED' ? $r('app.color.success') : $r('app.color.warning'))
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: $r('app.float.card_content_margin') })
  }
}
