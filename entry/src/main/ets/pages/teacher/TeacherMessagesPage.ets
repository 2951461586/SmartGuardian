/**
 * SmartGuardian - 教师消息页
 * 查看系统通知和考勤提醒
 */

import { MessageRecord } from '../../models/message';
import { MessageService } from '../../services/api/message';
import { LoadingState, LoadingSize, EmptyState, EmptyType } from '../../components/common';
import { formatDate, formatTime } from '../../utils/date';

@Entry
@Component
export struct TeacherMessagesPage {
  @State messages: MessageRecord[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;

  private readonly tabs = ['全部', '系统通知', '考勤提醒'];

  async aboutToAppear() {
    await this.loadMessages();
  }

  async loadMessages() {
    this.isLoading = true;
    try {
      const msgType = this.currentTab === 1 ? 'SYSTEM' : (this.currentTab === 2 ? 'ATTENDANCE' : undefined);
      const response = await MessageService.getMessages({
        pageNum: 1,
        pageSize: 50,
        msgType: msgType
      });

      if (response.code === 0 && response.data) {
        this.messages = response.data.list ?? [];
      } else {
        this.messages = [];
      }
    } catch (error) {
      console.error('Failed to load messages:', String(error));
      this.messages = [];
    } finally {
      this.isLoading = false;
    }
  }

  async markAsRead(messageId: number) {
    try {
      await MessageService.markAsRead(messageId);
      this.messages = this.messages.map((message: MessageRecord) => {
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
    } catch (error) {
      console.error('Failed to mark as read:', String(error));
    }
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('返')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .width(36)
        .height(36)
        .backgroundColor('#1AFFFFFF')
        .onClick(() => this.getUIContext().getRouter().back())

        Text('消息通知')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(36)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#52C41A', 0], ['#389E0D', 1]]
      })

      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontColor(this.currentTab === index ? '#52C41A' : '#666666')
              .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)

            if (this.currentTab === index) {
              Divider()
                .width(24)
                .height(2)
                .color('#52C41A')
                .margin({ top: 4 })
            }
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .onClick(async () => {
            if (this.currentTab !== index) {
              this.currentTab = index;
              await this.loadMessages();
            }
          })
        })
      }
      .width('100%')
      .backgroundColor(Color.White)

      Divider().color('#E5E5E5')

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
          ForEach(this.messages, (message: MessageRecord) => {
            ListItem() {
              this.MessageItem(message)
            }
            .margin({ top: 8 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  MessageItem(message: MessageRecord) {
    Row() {
      if (!message.readStatus) {
        Circle()
          .width(8)
          .height(8)
          .fill('#FF4D4F')
      } else {
        Blank().width(8)
      }

      Column() {
        Text(message.title)
          .fontSize(16)
          .fontColor(message.readStatus ? '#666666' : '#333333')
          .fontWeight(message.readStatus ? FontWeight.Normal : FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(message.content)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(formatDate(message.createdAt ?? '') + ' ' + formatTime(message.createdAt ?? ''))
          .fontSize(12)
          .fontColor('#CCCCCC')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .onClick(() => {
      if (!message.readStatus) {
        this.markAsRead(message.id);
      }
    })
  }
}
