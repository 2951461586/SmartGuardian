/**
 * SmartGuardian - Parent Messages Page
 * Enhanced message center with unified visual system
 *
 * @optimized Using MessageStore for state management
 * @migrated 2026-04-20 - P2 Migration with Common Components
 */

import { MessageRecord, MessageStatistics } from '../../models/message';
import { MessageService } from '../../services/api/message';
import { MessageStore } from '../../stores/messageStore';
import { LogUtil } from '../../utils/LogUtil';
import { PageHeader, TabBar, EmptyState, LoadingState, EmptyType, LoadingSize, HeaderTheme, MessageListItem } from '../../components/common';

type MessageTab = 'ALL' | 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER';

@Component
export struct ParentMessagesPage {
  @StorageLink('message_list') messages: MessageRecord[] = [];
  @StorageLink('unread_count') unreadCount: number = 0;

  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State selectedTab: MessageTab = 'ALL';
  @State statistics: MessageStatistics | null = null;
  @State filteredMessages: MessageRecord[] = [];

  private lastLoadTime: number = 0;
  private readonly CACHE_DURATION: number = 2 * 60 * 1000;
  private tabs: string[] = ['全部', '系统', '考勤', '作业', '订单'];
  private tabTypes: MessageTab[] = ['ALL', 'SYSTEM', 'ATTENDANCE', 'HOMEWORK', 'ORDER'];

  aboutToAppear() {
    this.loadMessagesWithCache();
    this.loadStatistics();
  }

  async loadMessagesWithCache() {
    const cachedMessages = MessageStore.getMessageList();
    const cachedUnread = MessageStore.getUnreadCount();

    if (cachedMessages.length > 0) {
      this.messages = cachedMessages;
      this.unreadCount = cachedUnread;
      this.filterMessages();
      LogUtil.info('ParentMessagesPage', `Using cached messages: ${cachedMessages.length} items`);
    }

    const now = Date.now();
    const shouldRefresh = (now - this.lastLoadTime) > this.CACHE_DURATION;
    if (shouldRefresh || cachedMessages.length === 0) {
      await this.loadMessages();
    }
  }

  async loadMessages() {
    this.isLoading = true;

    try {
      const resp = await MessageService.getMessages({
        pageNum: 1,
        pageSize: 50
      });

      if (resp.code === 0 && resp.data) {
        const messageList = resp.data.list || [];
        const unread = messageList.filter((message: MessageRecord) => !message.readStatus).length;

        MessageStore.setMessageList(messageList);
        MessageStore.setUnreadCount(unread);

        this.messages = messageList;
        this.unreadCount = unread;
        this.lastLoadTime = Date.now();
        this.filterMessages();
        LogUtil.info('ParentMessagesPage', `Loaded ${messageList.length} messages, unread: ${unread}`);
      } else {
        this.applyFallbackMessages();
      }
    } catch (error) {
      LogUtil.error('ParentMessagesPage', 'Load messages failed');
      this.applyFallbackMessages();
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
      MessageStore.markMessageAsRead(messageId);
      this.loadMessagesWithCache();
      this.loadStatistics();
      LogUtil.info('ParentMessagesPage', `Marked message ${messageId} as read`);
    } catch (error) {
      LogUtil.error('ParentMessagesPage', 'Mark message as read failed');
    }
  }

  async markAllAsRead() {
    try {
      await MessageService.markAllAsRead();

      const updatedMessages = MessageStore.getMessageList().map((message: MessageRecord): MessageRecord => {
        return {
          id: message.id,
          userId: message.userId,
          msgType: message.msgType,
          title: message.title,
          content: message.content,
          bizType: message.bizType,
          bizId: message.bizId,
          readStatus: true,
          readAt: message.readAt,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt
        };
      });

      MessageStore.setMessageList(updatedMessages);
      MessageStore.setUnreadCount(0);

      this.messages = updatedMessages;
      this.unreadCount = 0;
      this.filterMessages();
      this.loadStatistics();
      LogUtil.info('ParentMessagesPage', 'Marked all messages as read');
    } catch (error) {
      LogUtil.error('ParentMessagesPage', 'Mark all messages as read failed');
    }
  }

  private applyFallbackMessages(): void {
    const fallbackMessages = this.getMockMessages();
    const unread = fallbackMessages.filter((message: MessageRecord) => !message.readStatus).length;

    this.messages = fallbackMessages;
    this.unreadCount = unread;
    this.filterMessages();

    MessageStore.setMessageList(fallbackMessages);
    MessageStore.setUnreadCount(unread);
  }

  private handleTabChange(index: number): void {
    this.currentTab = index;
    this.selectedTab = this.tabTypes[index];
    this.filterMessages();
  }

  private filterMessages(): void {
    if (this.selectedTab === 'ALL') {
      this.filteredMessages = this.messages;
      return;
    }

    this.filteredMessages = this.messages.filter((message: MessageRecord) => message.msgType === this.selectedTab);
  }

  private getTotalCount(): number {
    return this.statistics?.total ?? this.messages.length;
  }

  private getUnreadStatCount(): number {
    return this.statistics?.unread ?? this.unreadCount;
  }

  private getCurrentTabCount(): number {
    return this.filteredMessages.length;
  }

  private getCurrentTabLabel(): string {
    return this.tabs[this.currentTab] ?? '全部';
  }

  private getEmptyDescription(): string {
    if (this.selectedTab === 'ALL') {
      return '暂时没有新的家校消息，可稍后刷新查看';
    }
    return `${this.getCurrentTabLabel()}分类下暂无消息记录`;
  }

  private openMessageDetail(message: MessageRecord): void {
    if (!message.readStatus) {
      this.markAsRead(message.id);
    }

    MessageStore.setCurrentMessage(message);

    try {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/parent/ParentMessageDetailPage',
        params: {
          messageId: message.id
        }
      });
    } catch (error) {
      LogUtil.error('ParentMessagesPage', 'Open message detail failed');
    }
  }

  build() {
    Column() {
      PageHeader({
        title: '消息中心',
        subtitle: '跟进系统通知、考勤提醒与作业反馈',
        theme: HeaderTheme.WHITE
      }) {
        if (this.unreadCount > 0) {
          Button('全部已读')
            .height(32)
            .fontSize(12)
            .fontColor($r('app.color.primary'))
            .backgroundColor('#EAF2FF')
            .borderRadius(16)
            .padding({ left: 12, right: 12 })
            .onClick(() => this.markAllAsRead())
        }
      }

      this.buildOverviewPanel()
      this.buildTabSection()
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildOverviewPanel() {
    Row() {
      this.buildOverviewMetric('全部消息', `${this.getTotalCount()}`, '#4F7CFF', '#EAF2FF')
      Blank().width(10)
      this.buildOverviewMetric('未读消息', `${this.getUnreadStatCount()}`, '#F2994A', '#FFF4E8')
      Blank().width(10)
      this.buildOverviewMetric(this.getCurrentTabLabel(), `${this.getCurrentTabCount()}`, '#2F9B52', '#EAF7EC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
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
    .padding({ left: 14, right: 14, top: 16, bottom: 16 })
    .backgroundColor(bgColor)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTabSection() {
    Column() {
      TabBar({
        tabs: this.tabs,
        currentIndex: $currentTab,
        onTabChange: (index: number) => this.handleTabChange(index)
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    .backgroundColor(Color.White)
    .borderRadius(18)
    .margin({ left: 16, right: 16, top: 14, bottom: 12 })
  }

  @Builder
  buildContent() {
    if (this.isLoading && this.filteredMessages.length === 0) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false,
        message: '正在加载消息...'
      })
    } else if (this.filteredMessages.length === 0) {
      EmptyState({
        type: EmptyType.NO_MESSAGE,
        customDescription: this.getEmptyDescription(),
        actionText: '刷新',
        onAction: () => {
          this.loadMessages();
          this.loadStatistics();
        }
      })
    } else {
      this.buildMessageList()
    }
  }

  @Builder
  buildMessageList() {
    Scroll() {
      Column() {
        ForEach(this.filteredMessages, (message: MessageRecord) => {
          MessageListItem({
            message: message,
            onMarkRead: () => {
              this.markAsRead(message.id);
            },
            onItemClick: () => {
              this.openMessageDetail(message);
            }
          })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  getMockMessages(): MessageRecord[] {
    return [
      { id: 1, userId: 1, msgType: 'SYSTEM', title: '系统维护通知', content: '系统将在今晚22:00进行维护升级，届时将暂停服务，请提前做好准备。', readStatus: false, createdAt: '2026-04-16 10:00:00', updatedAt: '2026-04-16' },
      { id: 2, userId: 1, msgType: 'ATTENDANCE', title: '签到提醒', content: '您的孩子张三已于08:35签到进入托管中心。', readStatus: false, createdAt: '2026-04-16 14:00:00', updatedAt: '2026-04-16' },
      { id: 3, userId: 1, msgType: 'HOMEWORK', title: '作业完成', content: '您的孩子已完成今日数学作业，正确率95%。', readStatus: true, createdAt: '2026-04-15 16:00:00', updatedAt: '2026-04-15' },
      { id: 4, userId: 1, msgType: 'ORDER', title: '订单审核通过', content: '您提交的托管服务订单已通过审核，请及时完成支付。', readStatus: false, createdAt: '2026-04-15 12:00:00', updatedAt: '2026-04-15' },
      { id: 5, userId: 1, msgType: 'ATTENDANCE', title: '签退提醒', content: '您的孩子张三已于17:30签退离开托管中心。', readStatus: true, createdAt: '2026-04-14 17:30:00', updatedAt: '2026-04-14' }
    ];
  }

  getMockStatistics(): MessageStatistics {
    return {
      total: 5,
      unread: 3,
      byType: { SYSTEM: 1, ATTENDANCE: 2, HOMEWORK: 0, ORDER: 0 }
    };
  }
}
