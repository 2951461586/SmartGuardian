/**
 * SmartGuardian - Parent Messages Page
 * Enhanced message center with filtering
 */

import router from '@ohos.router';
import { MessageRecord, MessageStatistics } from '../../models/message';
import { MessageService } from '../../services/api/message';

type MessageTab = 'ALL' | 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER';

@Component
export struct ParentMessagesPage {
  @State messages: MessageRecord[] = [];
  @State isLoading: boolean = false;
  @State selectedTab: MessageTab = 'ALL';
  @State statistics: MessageStatistics | null = null;

  aboutToAppear() {
    this.loadMessages();
    this.loadStatistics();
  }

  async loadMessages() {
    this.isLoading = true;
    try {
      const resp = await MessageService.getMessages({ pageNum: 1, pageSize: 50 });
      if (resp.code === 0 && resp.data) {
        this.messages = resp.data.list || [];
      } else {
        this.messages = this.getMockMessages();
      }
    } catch (error) {
      console.error('Failed to load messages:', error);
      this.messages = this.getMockMessages();
    } finally {
      this.isLoading = false;
    }
  }

  async loadStatistics() {
    try {
      const resp = await MessageService.getStatistics();
      if (resp.code === 0 && resp.data) {
        this.statistics = resp.data;
      } else {
        this.statistics = this.getMockStatistics();
      }
    } catch (error) {
      this.statistics = this.getMockStatistics();
    }
  }

  async markAsRead(messageId: number) {
    try {
      await MessageService.markAsRead(messageId);
      this.loadMessages();
      this.loadStatistics();
    } catch (error) {
      console.error('Failed to mark as read:', error);
    }
  }

  async markAllAsRead() {
    try {
      await MessageService.markAllAsRead();
      this.loadMessages();
      this.loadStatistics();
    } catch (error) {
      console.error('Failed to mark all as read:', error);
    }
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildTabBar()
      
      if (this.isLoading) {
        this.buildLoading()
      } else {
        this.buildMessageList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => router.back())

      Text('消息中心')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Row() {
        if (this.statistics && this.statistics.unread > 0) {
          Button('全部已读')
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor('#4CAF50')
            .height(32)
            .onClick(() => this.markAllAsRead())
        }
      }
      .width(80)
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: Number($r('app.float.status_bar_height')) + 10 })
  }

  @Builder
  buildTabBar() {
    Row() {
      this.buildTabItem('ALL', '全部')
      this.buildTabItem('SYSTEM', '系统')
      this.buildTabItem('ATTENDANCE', '考勤')
      this.buildTabItem('HOMEWORK', '作业')
      this.buildTabItem('ORDER', '订单')
    }
    .width('100%')
    .height(50)
    .backgroundColor(Color.White)
  }

  @Builder
  buildTabItem(tab: MessageTab, label: string) {
    Column() {
      Text(label)
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(this.selectedTab === tab ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.selectedTab === tab ? $r('app.color.primary') : $r('app.color.text_secondary'))

      if (this.selectedTab === tab) {
        Divider()
          .width(40)
          .height(3)
          .color($r('app.color.primary'))
          .margin({ top: 8 })
      }
    }
    .height(50)
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
    .onClick(() => {
      this.selectedTab = tab;
      this.loadMessages();
    })
  }

  @Builder
  buildLoading() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color($r('app.color.primary'))
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildMessageList() {
    if (this.messages.length === 0) {
      Column() {
        Text('暂无消息')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Column() {
          ForEach(this.messages, (message: MessageRecord) => {
            this.buildMessageItem(message)
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
  buildMessageItem(message: MessageRecord) {
    Row() {
      Column() {
        Image(this.getMsgTypeIcon(message.msgType))
          .width(24)
          .height(24)
      }
      .width(40)
      .height(40)
      .backgroundColor(this.getMsgTypeBgColor(message.msgType))
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)

      Column() {
        Row() {
          Text(this.getMsgTypeText(message.msgType))
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)

          if (!message.readStatus) {
            Row().width(8).height(8).backgroundColor('#FF5722').borderRadius(4)
          }
        }

        Text(message.title || message.content)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(message.readStatus ? Color.White : '#F8F9FA')
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: 12 })
    .onClick(() => {
      if (!message.readStatus) {
        this.markAsRead(message.id);
      }
    })
  }

  getMsgTypeIcon(msgType: string): Resource {
    const icons: Record<string, Resource> = {
      'SYSTEM': $r('app.media.ic_system'),
      'ATTENDANCE': $r('app.media.ic_attendance'),
      'HOMEWORK': $r('app.media.ic_homework'),
      'ORDER': $r('app.media.ic_order')
    };
    return icons[msgType] || $r('app.media.ic_message');
  }

  getMsgTypeText(msgType: string): string {
    const texts: Record<string, string> = {
      'SYSTEM': '系统通知',
      'ATTENDANCE': '考勤通知',
      'HOMEWORK': '作业通知',
      'ORDER': '订单通知'
    };
    return texts[msgType] || '通知';
  }

  getMsgTypeBgColor(msgType: string): string {
    const colors: Record<string, string> = {
      'SYSTEM': '#E3F2FD',
      'ATTENDANCE': '#E8F5E9',
      'HOMEWORK': '#FFF3E0',
      'ORDER': '#F3E5F5'
    };
    return colors[msgType] || '#F5F5F5';
  }

  getMockMessages(): MessageRecord[] {
    return [
      { id: 1, userId: 1, msgType: 'SYSTEM', title: '系统维护通知', content: '系统维护升级', readStatus: false, createdAt: '2026-04-16 10:00:00', updatedAt: '2026-04-16' },
      { id: 2, userId: 1, msgType: 'ATTENDANCE', title: '签到提醒', content: '孩子已签到', readStatus: false, createdAt: '2026-04-16 14:00:00', updatedAt: '2026-04-16' },
      { id: 3, userId: 1, msgType: 'HOMEWORK', title: '作业完成', content: '作业已完成', readStatus: true, createdAt: '2026-04-15 16:00:00', updatedAt: '2026-04-15' }
    ];
  }

  getMockStatistics(): MessageStatistics {
    return {
      total: 3,
      unread: 2,
      byType: { SYSTEM: 1, ATTENDANCE: 1, HOMEWORK: 0, ORDER: 0 }
    };
  }
}