/**
 * SmartGuardian - Admin Messages Page
 * Send and manage system messages
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  Card,
  EmptyState,
  EmptyType,
  HeaderTheme,
  LoadingSize,
  LoadingState,
  MessageListItem,
  PageHeader,
  SectionHeader,
  TabBar
} from '../../components/common';
import { MessageRecord } from '../../models/message';
import { HarmonyCapabilityService } from '../../services/HarmonyCapabilityService';
import { MessageService } from '../../services/api/message';
import { RouteUrls } from '../../constants/app.constants';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';

@Entry
@Component
struct AdminMessagesPage {
  build() {
    Stack() {
      AdminMessagesPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AdminMessagesPageContent {
  @State messages: MessageRecord[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State sendType: string = 'SYSTEM';
  @State sendTitle: string = '';
  @State sendContent: string = '';
  @State isSending: boolean = false;
  @State pushNow: boolean = true;

  private readonly tabs: string[] = ['消息列表', '发送消息'];
  private readonly sendTypes: string[] = ['SYSTEM', 'ATTENDANCE', 'ORDER'];
  private messageDataSource: LazyArrayDataSource<MessageRecord> = new LazyArrayDataSource<MessageRecord>();

  async aboutToAppear() {
    await this.loadMessages();
  }

  async loadMessages() {
    this.isLoading = true;
    try {
      const response = await MessageService.getMessages({
        pageNum: 1,
        pageSize: 50
      });
      if (response.code === 0 && response.data) {
        this.messages = response.data.list ?? [];
        this.messageDataSource.setItems(this.messages);
      } else {
        this.messages = [];
        this.messageDataSource.clear();
      }
    } catch (error) {
      console.error('Failed to load messages:', error);
      this.messages = [];
      this.messageDataSource.clear();
    } finally {
      this.isLoading = false;
    }
  }

  private getSendTypeLabel(type: string): string {
    if (type === 'ATTENDANCE') {
      return '考勤提醒';
    }
    if (type === 'ORDER') {
      return '缴费通知';
    }
    return '系统通知';
  }

  async sendMessage() {
    if (this.isSending) {
      return;
    }
    if (!this.sendTitle.trim() || !this.sendContent.trim()) {
      return;
    }

    this.isSending = true;
    try {
      await MessageService.sendMessage({
        userId: 0,
        msgType: this.sendType,
        title: this.sendTitle.trim(),
        content: this.sendContent.trim(),
        pushNow: this.pushNow
      });
      if (this.pushNow) {
        await HarmonyCapabilityService.previewMessageDispatch(
          this.sendType,
          this.sendTitle.trim(),
          this.sendContent.trim(),
          RouteUrls.ADMIN_MESSAGES
        );
      }
      this.sendTitle = '';
      this.sendContent = '';
      this.currentTab = 0;
      await this.loadMessages();
    } catch (error) {
      console.error('Failed to send message:', error);
    } finally {
      this.isSending = false;
    }
  }

  build() {
    Column() {
      PageHeader({
        title: '消息管理',
        subtitle: '统一查看机构消息，并按类型向家长或教师发送通知。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      TabBar({
        tabs: this.tabs,
        currentIndex: this.currentTab,
        onTabChange: (index: number) => {
          this.currentTab = index;
        }
      })

      if (this.currentTab === 0) {
        this.buildMessageListPage()
      } else {
        this.buildComposerPage()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildMessageListPage() {
    if (this.isLoading) {
      Column() {
        LoadingState({ loadingSize: LoadingSize.LARGE })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.messages.length === 0) {
      Column() {
        EmptyState({ type: EmptyType.NO_MESSAGE, customTitle: '暂无消息' })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ListItem() {
          SectionHeader({
            title: '消息列表',
            subtitle: `当前共 ${this.messages.length} 条消息`
          })
        }

        ListItem() {
          Card({
            title: '管理说明',
            subtitle: '系统消息会统一进入消息中心，后续可以继续扩展筛选和批量已读能力。',
            content: this.buildMessageSummary
          })
        }

        LazyForEach(this.messageDataSource, (message: MessageRecord) => {
          ListItem() {
            MessageListItem({
              message: message
            })
          }
        }, (message: MessageRecord) => `${message.id}`)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .cachedCount(8)
    }
  }

  @Builder
  private buildMessageSummary() {
    Text(`未读与已读消息统一收口在此处，当前消息总量 ${this.messages.length}。`)
      .fontSize(14)
      .fontColor($r('app.color.text_primary'))
      .width('100%')
  }

  @Builder
  private buildComposerPage() {
    List() {
      ListItem() {
        SectionHeader({
          title: '发送消息',
          subtitle: '选择消息类型，填写标题和正文后直接发送。'
        })
      }

      ListItem() {
        this.buildTypeCard()
      }

      ListItem() {
        this.buildPushOptionCard()
      }

      ListItem() {
        this.buildTitleCard()
      }

      ListItem() {
        this.buildContentCard()
      }

      ListItem() {
        this.buildSendButton()
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 12, bottom: 16 })
    .divider({ strokeWidth: 0 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(8)
  }

  @Builder
  private buildTypeCard() {
    Card({
      title: '消息类型',
      subtitle: '不同类型会在消息中心展示不同标签。',
      content: this.buildTypeCardContent
    })
  }

  @Builder
  private buildTypeCardContent() {
    Row() {
      ForEach(this.sendTypes, (type: string, index: number) => {
        Button(this.getSendTypeLabel(type))
          .fontSize(14)
          .backgroundColor(this.sendType === type ? HarmonyReport.accentSurface : HarmonyColor.surfaceSubtle)
          .fontColor(this.sendType === type ? HarmonyReport.accent : HarmonyColor.textSecondary)
          .margin({ right: index < this.sendTypes.length - 1 ? 8 : 0 })
          .onClick(() => {
            this.sendType = type;
          })
      }, (type: string) => type)
    }
    .width('100%')
  }

  @Builder
  private buildPushOptionCard() {
    Card({
      title: '通知下发',
      subtitle: '模拟环境下使用本地通知预览消息触达效果，真实环境继续走消息接口的 pushNow 标记。',
      content: this.buildPushOptionCardContent
    })
  }

  @Builder
  private buildPushOptionCardContent() {
    Row() {
      Column() {
        Text('立即提醒')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text('开启后会在当前设备触发一次官方通知预览。')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.pushNow })
        .onChange((enabled: boolean) => {
          this.pushNow = enabled;
        })
    }
    .width('100%')
  }

  @Builder
  private buildTitleCard() {
    Card({
      title: '消息标题',
      subtitle: '标题建议简洁明确，方便家长快速识别。',
      content: this.buildTitleCardContent
    })
  }

  @Builder
  private buildTitleCardContent() {
    TextInput({ placeholder: '请输入消息标题', text: this.sendTitle })
      .width('100%')
      .backgroundColor(HarmonyColor.surfaceSubtle)
      .borderRadius(16)
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .onChange((value: string) => {
        this.sendTitle = value;
      })
  }

  @Builder
  private buildContentCard() {
    Card({
      title: '消息内容',
      subtitle: '正文支持详细描述事件和后续行动要求。',
      content: this.buildContentCardContent
    })
  }

  @Builder
  private buildContentCardContent() {
    TextArea({ placeholder: '请输入消息内容', text: this.sendContent })
      .width('100%')
      .height(120)
      .backgroundColor(HarmonyColor.surfaceSubtle)
      .borderRadius(16)
      .padding({ left: 12, right: 12, top: 12, bottom: 12 })
      .onChange((value: string) => {
        this.sendContent = value;
      })
  }

  @Builder
  private buildSendButton() {
    Button(this.isSending ? '发送中...' : '发送消息')
      .width('100%')
      .height(48)
      .backgroundColor($r('app.color.primary'))
      .fontColor(HarmonyColor.textInverse)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .borderRadius(18)
      .enabled(this.sendTitle.trim().length > 0 && this.sendContent.trim().length > 0 && !this.isSending)
      .opacity(this.sendTitle.trim().length > 0 && this.sendContent.trim().length > 0 && !this.isSending ? 1 : 0.6)
      .onClick(() => {
        this.sendMessage();
      })
  }
}
