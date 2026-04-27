/**
 * SmartGuardian - Teacher Messages Page
 * Unified teacher message center
 */

import { MessageRecord } from '../../models/message';
import { MessageService } from '../../services/api/message';
import { PageHeader, HeaderTheme, TabBar, Card, SectionHeader, MessageListItem, EmptyState, EmptyType, LoadingState, LoadingSize, IconActionButton, TabItem, StatCard } from '../../components/common';
import { MessageStore } from '../../stores/messageStore';
import { LogUtil } from '../../utils/LogUtil';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';
import { HarmonyCapabilityService } from '../../services/HarmonyCapabilityService';
import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';

type TeacherMessageTab = 'ALL' | 'SYSTEM' | 'ATTENDANCE';

@Entry
@Component
struct TeacherMessagesPage {
  build() {
    Stack() {
      TeacherMessagesPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct TeacherMessagesPageContent {
  @State messages: MessageRecord[] = [];
  @State filteredMessages: MessageRecord[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State selectedTab: TeacherMessageTab = 'ALL';

  private readonly tabs: string[] = ['\u5168\u90e8', '\u7cfb\u7edf\u901a\u77e5', '\u8003\u52e4\u63d0\u9192'];
  private readonly tabTypes: TeacherMessageTab[] = ['ALL', 'SYSTEM', 'ATTENDANCE'];
  private messageDataSource: LazyArrayDataSource<MessageRecord> = new LazyArrayDataSource<MessageRecord>();

  async aboutToAppear() {
    await this.loadMessages();
  }

  async loadMessages() {
    this.isLoading = true;
    try {
      const response = await MessageService.getMessages({
        pageNum: 1,
        pageSize: 100
      });

      if (response.code === 0 && response.data) {
        this.messages = response.data.list ?? [];
      } else {
        this.messages = [];
      }
      this.filterMessages();
      await HarmonyCapabilityService.syncMessageBadge(this.getUnreadCount());
    } catch (error) {
      LogUtil.error('TeacherMessagesPage', `Load messages failed: ${String(error)}`);
      this.messages = [];
      this.filteredMessages = [];
      this.messageDataSource.clear();
      await HarmonyCapabilityService.syncMessageBadge(0);
    } finally {
      this.isLoading = false;
    }
  }

  async markAsRead(messageId: number) {
    try {
      await MessageService.markAsRead(messageId);
      this.messages = this.messages.map((message: MessageRecord): MessageRecord => {
        if (message.id !== messageId) {
          return message;
        }

        return {
          id: message.id,
          userId: message.userId,
          title: message.title,
          content: message.content,
          msgType: message.msgType,
          readStatus: true,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt
        };
      });
      this.filterMessages();
      MessageStore.setMessageList(this.messages);
      MessageStore.setUnreadCount(this.getUnreadCount());
      await HarmonyCapabilityService.syncMessageBadge(this.getUnreadCount());
    } catch (error) {
      LogUtil.error('TeacherMessagesPage', `Mark as read failed: ${String(error)}`);
    }
  }

  async markAllAsRead() {
    try {
      await MessageService.markAllAsRead();
      this.messages = this.messages.map((message: MessageRecord): MessageRecord => {
        return {
          id: message.id,
          userId: message.userId,
          title: message.title,
          content: message.content,
          msgType: message.msgType,
          readStatus: true,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt
        };
      });
      this.filterMessages();
      MessageStore.setMessageList(this.messages);
      MessageStore.setUnreadCount(0);
      await HarmonyCapabilityService.syncMessageBadge(0);
    } catch (error) {
      LogUtil.error('TeacherMessagesPage', `Mark all as read failed: ${String(error)}`);
    }
  }

  private filterMessages(): void {
    if (this.selectedTab === 'ALL') {
      this.filteredMessages = this.messages;
      this.messageDataSource.setItems(this.filteredMessages);
      return;
    }

    this.filteredMessages = this.messages.filter((message: MessageRecord) => message.msgType === this.selectedTab);
    this.messageDataSource.setItems(this.filteredMessages);
  }

  private handleTabChange(index: number): void {
    this.currentTab = index;
    this.selectedTab = this.tabTypes[index];
    this.filterMessages();
  }

  private getUnreadCount(): number {
    return this.messages.filter((message: MessageRecord) => !message.readStatus).length;
  }

  private getTabItems(): TabItem[] {
    return this.tabs.map((tab: string, index: number): TabItem => {
      const type = this.tabTypes[index];
      const unreadCount = this.messages.filter((message: MessageRecord) => {
        if (message.readStatus) {
          return false;
        }
        return type === 'ALL' ? true : message.msgType === type;
      }).length;

      return {
        id: type,
        text: tab,
        badge: unreadCount > 0 ? unreadCount : undefined
      };
    });
  }

  build() {
    Column() {
      PageHeader({
        title: '消息通知',
        subtitle: '统一处理请假、考勤与系统通知',
        theme: HeaderTheme.WHITE,
        showBack: true,
        onBackClick: (): void => this.getUIContext().getRouter().back(),
        rightContent: this.buildHeaderAction
      })

      this.buildSummary()
      this.buildTabSection()
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: HarmonyColor.brandBlue,
      boxBgColor: HarmonyColor.surface,
      boxBorderColor: HarmonyColor.line,
      onButtonClick: (): void => {
        this.loadMessages();
      }
    })
  }

  @Builder
  buildSummary() {
    Row() {
      StatCard({
        value: `${this.messages.length}`,
        label: '全部消息',
        icon: $r('app.media.ic_message'),
        iconColor: HarmonyColor.brandBlue
      })
      .layoutWeight(1)

      Blank().width(12)

      StatCard({
        value: `${this.getUnreadCount()}`,
        label: '未读消息',
        icon: $r('app.media.ic_notification'),
        iconColor: HarmonyReport.caution
      })
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
  }

  @Builder
  buildTabSection() {
    Card({
      title: '消息分组',
      subtitle: '按类型指导当前需要处理的信息',
      customPadding: 12,
      content: () => { this.buildTabContent() }
    })
    .margin({ left: 16, right: 16, top: 14, bottom: 12 })
  }

  @Builder
  buildTabContent() {
    TabBar({
      tabItems: this.getTabItems(),
      currentIndex: this.currentTab,
      onTabChange: (index: number) => this.handleTabChange(index)
    })
  }

  @Builder
  buildContent() {
    if (this.isLoading) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false,
        message: '正在加载消息...'
      })
    } else if (this.filteredMessages.length === 0) {
      EmptyState({
        type: EmptyType.NO_MESSAGE,
        customDescription: this.selectedTab === 'ALL' ? '暂无新消息' : '当前分类暂无内容',
        actionText: '刷新',
        onAction: (): void => {
          this.loadMessages();
        }
      })
    } else {
      List({ space: 12 }) {
        ListItem() {
          SectionHeader({
            title: '消息列表',
            subtitle: '点开查看详情，已读状态会同步更新'
          })
        }

        LazyForEach(this.messageDataSource, (message: MessageRecord) => {
          ListItem() {
            this.buildMessageListItem(message)
          }
        }, (message: MessageRecord) => `${message.id}`)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 20 })
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
      .cachedCount(8)
    }
  }

  @Builder
  private buildMessageListItem(message: MessageRecord) {
    MessageListItem({
      message: message,
      onMarkRead: (): void => {
        this.markAsRead(message.id);
      },
      onItemClick: (): void => {
        this.markAsRead(message.id);
      }
    })
  }
}

