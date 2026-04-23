/**
 * SmartGuardian - Teacher Messages Page
 * Unified teacher message center
 */

import { MessageRecord } from '../../models/message';
import { MessageService } from '../../services/api/message';
import { PageHeader, HeaderTheme, TabBar, Card, SectionHeader, MessageListItem, EmptyState, EmptyType, LoadingState, LoadingSize, IconActionButton, TabItem, StatCard } from '../../components/common';
import { MessageStore } from '../../stores/messageStore';
import { LogUtil } from '../../utils/LogUtil';

type TeacherMessageTab = 'ALL' | 'SYSTEM' | 'ATTENDANCE';

@Entry
@Component
export struct TeacherMessagesPage {
  @State messages: MessageRecord[] = [];
  @State filteredMessages: MessageRecord[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State selectedTab: TeacherMessageTab = 'ALL';

  private readonly tabs: string[] = ['\u5168\u90e8', '\u7cfb\u7edf\u901a\u77e5', '\u8003\u52e4\u63d0\u9192'];
  private readonly tabTypes: TeacherMessageTab[] = ['ALL', 'SYSTEM', 'ATTENDANCE'];

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
    } catch (error) {
      LogUtil.error('TeacherMessagesPage', `Load messages failed: ${String(error)}`);
      this.messages = [];
      this.filteredMessages = [];
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
    } catch (error) {
      LogUtil.error('TeacherMessagesPage', `Mark all as read failed: ${String(error)}`);
    }
  }

  private filterMessages(): void {
    if (this.selectedTab === 'ALL') {
      this.filteredMessages = this.messages;
      return;
    }

    this.filteredMessages = this.messages.filter((message: MessageRecord) => message.msgType === this.selectedTab);
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
        title: '\u6d88\u606f\u901a\u77e5',
        subtitle: '\u7edf\u4e00\u5904\u7406\u8bf7\u5047\u3001\u8003\u52e4\u4e0e\u7cfb\u7edf\u901a\u77e5',
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
      iconColor: '#1F5EFF',
      boxBgColor: Color.White,
      boxBorderColor: '#E5EDF6',
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
        label: '\u5168\u90e8\u6d88\u606f',
        icon: $r('app.media.ic_message'),
        iconColor: '#1F5EFF'
      })
      .layoutWeight(1)

      Blank().width(12)

      StatCard({
        value: `${this.getUnreadCount()}`,
        label: '\u672a\u8bfb\u6d88\u606f',
        icon: $r('app.media.ic_notification'),
        iconColor: '#F59E0B'
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
      subtitle: '\u6309\u7c7b\u578b\u6307\u5bfc\u5f53\u524d\u9700\u8981\u5904\u7406\u7684\u4fe1\u606f',
      customPadding: 12,
      content: this.buildTabContent
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
        message: '\u6b63\u5728\u52a0\u8f7d\u6d88\u606f...'
      })
    } else if (this.filteredMessages.length === 0) {
      EmptyState({
        type: EmptyType.NO_MESSAGE,
        customDescription: this.selectedTab === 'ALL' ? '\u6682\u65e0\u65b0\u6d88\u606f' : '\u5f53\u524d\u5206\u7c7b\u6682\u65e0\u5185\u5bb9',
        actionText: '\u5237\u65b0',
        onAction: (): void => {
          this.loadMessages();
        }
      })
    } else {
      Scroll() {
        Column() {
          SectionHeader({
            title: '\u6d88\u606f\u5217\u8868',
            subtitle: '\u70b9\u5f00\u67e5\u770b\u8be6\u60c5\uff0c\u5df2\u8bfb\u72b6\u6001\u4f1a\u540c\u6b65\u66f4\u65b0'
          })

          ForEach(this.filteredMessages, (message: MessageRecord) => {
            MessageListItem({
              message: message,
              onMarkRead: (): void => {
                this.markAsRead(message.id);
              },
              onItemClick: (): void => {
                this.markAsRead(message.id);
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
  }
}
