/**
 * SmartGuardian - Parent Messages Page
 * Enhanced message center with unified visual system
 */

import { MessageRecord, MessageStatistics } from '../../models/message';
import { MessageService } from '../../services/api/message';
import { PageHeader, TabBar, EmptyState, LoadingState, EmptyType, LoadingSize, HeaderTheme, MessageListItem, Card, SectionHeader, StatCard, TabItem } from '../../components/common';
import { MessageStore } from '../../stores/messageStore';
import { LogUtil } from '../../utils/LogUtil';

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
  private tabs: string[] = ['\u5168\u90e8', '\u7cfb\u7edf', '\u8003\u52e4', '\u4f5c\u4e1a', '\u8ba2\u5355'];
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
        const messageList = resp.data.list ?? [];
        const unread = messageList.filter((message: MessageRecord) => !message.readStatus).length;

        MessageStore.setMessageList(messageList);
        MessageStore.setUnreadCount(unread);

        this.messages = messageList;
        this.unreadCount = unread;
        this.lastLoadTime = Date.now();
        this.filterMessages();
        LogUtil.info('ParentMessagesPage', `Loaded ${messageList.length} messages, unread: ${unread}`);
      } else {
        this.applyEmptyMessages();
      }
    } catch (error) {
      LogUtil.error('ParentMessagesPage', `Load messages failed: ${String(error)}`);
      this.applyEmptyMessages();
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
        this.statistics = this.getEmptyStatistics();
      }
    } catch (error) {
      LogUtil.error('ParentMessagesPage', `Load statistics failed: ${String(error)}`);
      this.statistics = this.getEmptyStatistics();
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
      LogUtil.error('ParentMessagesPage', `Mark message as read failed: ${String(error)}`);
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
      LogUtil.error('ParentMessagesPage', `Mark all messages as read failed: ${String(error)}`);
    }
  }

  private applyEmptyMessages(): void {
    this.messages = [];
    this.unreadCount = 0;
    this.filteredMessages = [];
    MessageStore.setMessageList([]);
    MessageStore.setUnreadCount(0);
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

  private getTabItems(): TabItem[] {
    return this.tabs.map((tab: string, index: number): TabItem => {
      const type = this.tabTypes[index];
      const badge = this.messages.filter((message: MessageRecord) => {
        if (message.readStatus) {
          return false;
        }
        return type === 'ALL' ? true : message.msgType === type;
      }).length;

      return {
        id: type,
        text: tab,
        badge: badge > 0 ? badge : undefined
      };
    });
  }

  private getCurrentTabLabel(): string {
    return this.tabs[this.currentTab] ?? '\u5168\u90e8';
  }

  private getEmptyDescription(): string {
    if (this.selectedTab === 'ALL') {
      return '\u6682\u65e0\u65b0\u7684\u5bb6\u6821\u6d88\u606f\uff0c\u53ef\u7a0d\u540e\u5237\u65b0\u67e5\u770b';
    }
    return `${this.getCurrentTabLabel()}\u5206\u7c7b\u4e0b\u6682\u65e0\u6d88\u606f\u8bb0\u5f55`;
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
      LogUtil.error('ParentMessagesPage', `Open message detail failed: ${String(error)}`);
    }
  }

  build() {
    Column() {
      PageHeader({
        title: '\u6d88\u606f\u4e2d\u5fc3',
        subtitle: '\u96c6\u4e2d\u5904\u7406\u7cfb\u7edf\u901a\u77e5\u3001\u8003\u52e4\u63d0\u9192\u4e0e\u4f5c\u4e1a\u53cd\u9988',
        theme: HeaderTheme.WHITE
      }) {
        if (this.unreadCount > 0) {
          Button('\u5168\u90e8\u5df2\u8bfb')
            .height(32)
            .fontSize(12)
            .fontColor($r('app.color.primary'))
            .backgroundColor('#EEF4FA')
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
      StatCard({
        value: `${this.getTotalCount()}`,
        label: '\u5168\u90e8\u6d88\u606f',
        icon: $r('app.media.ic_message'),
        iconColor: '#4F7CFF'
      })
      .layoutWeight(1)

      Blank().width(12)

      StatCard({
        value: `${this.getUnreadStatCount()}`,
        label: '\u672a\u8bfb\u6d88\u606f',
        icon: $r('app.media.ic_notification'),
        iconColor: '#F2994A'
      })
      .layoutWeight(1)

      Blank().width(12)

      StatCard({
        value: `${this.getCurrentTabCount()}`,
        label: this.getCurrentTabLabel(),
        icon: $r('app.media.ic_home'),
        iconColor: '#2F9B52'
      })
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
  }

  @Builder
  buildTabSection() {
    Card({
      title: '\u6d88\u606f\u5206\u7ec4',
      subtitle: '\u6309\u4e1a\u52a1\u7c7b\u578b\u5feb\u901f\u805a\u7126\u5f53\u524d\u9700\u8981\u5904\u7406\u7684\u6d88\u606f',
      customPadding: 12,
      content: this.buildTabSectionContent
    })
    .margin({ left: 16, right: 16, top: 14, bottom: 12 })
  }

  @Builder
  buildTabSectionContent() {
    TabBar({
      tabItems: this.getTabItems(),
      currentIndex: this.currentTab,
      onTabChange: (index: number) => this.handleTabChange(index)
    })
  }

  @Builder
  buildContent() {
    if (this.isLoading && this.filteredMessages.length === 0) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false,
        message: '\u6b63\u5728\u52a0\u8f7d\u6d88\u606f...'
      })
    } else if (this.filteredMessages.length === 0) {
      EmptyState({
        type: EmptyType.NO_MESSAGE,
        customDescription: this.getEmptyDescription(),
        actionText: '\u5237\u65b0',
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
        SectionHeader({
          title: '\u6d88\u606f\u5217\u8868',
          subtitle: '\u70b9\u5f00\u53ef\u67e5\u770b\u8be6\u60c5\uff0c\u4e5f\u53ef\u76f4\u63a5\u6807\u8bb0\u5df2\u8bfb'
        })

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

  private getEmptyStatistics(): MessageStatistics {
    return {
      total: this.messages.length,
      unread: this.unreadCount,
      byType: {}
    };
  }
}

