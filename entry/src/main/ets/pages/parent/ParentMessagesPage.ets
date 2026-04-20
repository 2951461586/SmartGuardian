/**
 * SmartGuardian - Parent Messages Page
 * Enhanced message center with filtering
 * 
 * @optimized Using MessageStore for state management
 * @migrated 2026-04-20 - P2 Migration with Common Components
 */

import router from '@ohos.router';
import { MessageRecord, MessageStatistics } from '../../models/message';
import { MessageService } from '../../services/api/message';
import { MessageStore } from '../../stores/messageStore';
import { LogUtil } from '../../utils/LogUtil';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { MessageQueryParams } from '../../models/common';
// Common Components
import { PageHeader, TabBar, EmptyState, LoadingState, EmptyType, LoadingSize, TabItem, HeaderTheme, MessageListItem } from '../../components/common';

type MessageTab = 'ALL' | 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER';

@Component
export struct ParentMessagesPage {
  // 使用 Store 管理消息数据（缓存优先）
  @StorageLink('message_list') messages: MessageRecord[] = [];
  @StorageLink('unread_count') unreadCount: number = 0;
  
  // 本地 UI 状态
  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State selectedTab: MessageTab = 'ALL';
  @State statistics: MessageStatistics | null = null;
  
  // 缓存时间戳
  private lastLoadTime: number = 0;
  private readonly CACHE_DURATION: number = 2 * 60 * 1000; // 2分钟缓存

  // Tab配置
  private tabs: string[] = ['全部', '系统', '考勤', '作业', '订单'];
  private tabTypes: MessageTab[] = ['ALL', 'SYSTEM', 'ATTENDANCE', 'HOMEWORK', 'ORDER'];

  aboutToAppear() {
    this.loadMessagesWithCache();
    this.loadStatistics();
  }

  /**
   * 带缓存的消息加载策略
   */
  async loadMessagesWithCache() {
    const cachedMessages = MessageStore.getMessageList();
    const cachedUnread = MessageStore.getUnreadCount();
    
    if (cachedMessages.length > 0) {
      this.messages = cachedMessages;
      this.unreadCount = cachedUnread;
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
      // 使用统一的查询参数类型
      const params: MessageQueryParams = {
        pageNum: 1,
        pageSize: 50
      };

      // 根据Tab设置消息类型过滤
      if (this.selectedTab !== 'ALL') {
        params.msgType = this.selectedTab;
      }

      const resp = await MessageService.getMessages(params);
      if (resp.code === 0 && resp.data) {
        const messageList = resp.data.list || [];
        
        MessageStore.setMessageList(messageList);
        
        const unread = messageList.filter((m: MessageRecord) => !m.readStatus).length;
        MessageStore.setUnreadCount(unread);
        
        this.messages = messageList;
        this.unreadCount = unread;
        this.lastLoadTime = Date.now();
        
        LogUtil.info('ParentMessagesPage', `Loaded ${messageList.length} messages, unread: ${unread}`);
      } else {
        this.messages = this.getMockMessages();
        MessageStore.setMessageList(this.messages);
      }
    } catch (error) {
      LogUtil.error('ParentMessagesPage', `Load failed: ${JSON.stringify(error)}`);
      this.messages = this.getMockMessages();
      MessageStore.setMessageList(this.messages);
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
      LogUtil.error('ParentMessagesPage', `Mark as read failed: ${JSON.stringify(error)}`);
    }
  }

  async markAllAsRead() {
    try {
      await MessageService.markAllAsRead();
      const messages = MessageStore.getMessageList();
      messages.forEach((m: MessageRecord) => m.readStatus = true);
      MessageStore.setMessageList(messages);
      MessageStore.setUnreadCount(0);
      this.loadMessagesWithCache();
      this.loadStatistics();
      LogUtil.info('ParentMessagesPage', 'Marked all messages as read');
    } catch (error) {
      LogUtil.error('ParentMessagesPage', `Mark all as read failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理Tab切换
   */
  private handleTabChange(index: number): void {
    this.currentTab = index;
    this.selectedTab = this.tabTypes[index];
    this.loadMessages();
  }

  build() {
    Column() {
      // 使用通用PageHeader（带返回和操作按钮）
      PageHeader({
        title: '消息中心',
        showBack: true,
        onBackClick: () => router.back(),
        theme: HeaderTheme.PRIMARY
      }) {
        // 右侧操作按钮
        if (this.unreadCount > 0) {
          Button('全部已读')
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor('#4CAF50')
            .height(32)
            .onClick(() => this.markAllAsRead())
        }
      }

      // 使用通用TabBar
      TabBar({
        tabs: this.tabs,
        currentIndex: $currentTab,
        onTabChange: (index: number) => this.handleTabChange(index)
      })

      // 内容区域
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildContent() {
    if (this.isLoading) {
      LoadingState({ 
        loadingSize: LoadingSize.LARGE,
        fullscreen: false 
      })
    } else if (this.messages.length === 0) {
      EmptyState({ 
        type: EmptyType.NO_MESSAGE,
        actionText: '刷新',
        onAction: () => { this.loadMessages(); }
      })
    } else {
      this.buildMessageList()
    }
  }

  @Builder
  buildMessageList() {
    Scroll() {
      Column() {
        ForEach(this.messages, (message: MessageRecord) => {
          MessageListItem({
            message: message,
            onMarkRead: () => {
              this.markAsRead(message.id);
            }
          })
        })
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
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
