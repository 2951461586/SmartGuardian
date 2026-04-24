/**
 * SmartGuardian - Admin Messages Page
 * Send and manage system messages
 */

import { MessageRecord } from '../../models/message';
import { MessageService } from '../../services/api/message';
import { LoadingState, LoadingSize, EmptyState, EmptyType } from '../../components/common';
import { formatDate, formatTime } from '../../utils/date';

@Entry
@Component
export struct AdminMessagesPage {
  @State messages: MessageRecord[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;

  private readonly tabs = ['消息列表', '发送消息'];

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
      }
    } catch (error) {
      console.error('Failed to load messages:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .width(36)
        .height(36)
        .backgroundColor('#1AFFFFFF')
        .onClick(() => this.getUIContext().getRouter().back())

        Text('消息管理')
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
        colors: [['#722ED1', 0], ['#531DAB', 1]]
      })

      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontColor(this.currentTab === index ? '#722ED1' : '#666666')
              .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)

            if (this.currentTab === index) {
              Divider()
                .width(24)
                .height(2)
                .color('#722ED1')
                .margin({ top: 4 })
            }
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .onClick(() => {
            this.currentTab = index;
          })
        })
      }
      .width('100%')
      .backgroundColor(Color.White)

      Divider().color('#E5E5E5')

      if (this.currentTab === 0) {
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
      } else {
        this.SendMessageForm()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  MessageItem(message: MessageRecord) {
    Row() {
      Column() {
        Text(message.title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(message.content)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(message.msgType ?? 'SYSTEM')
            .fontSize(12)
            .fontColor('#722ED1')
            .backgroundColor('#F9F0FF')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })

          Text(formatDate(message.createdAt ?? '') + ' ' + formatTime(message.createdAt ?? ''))
            .fontSize(12)
            .fontColor('#CCCCCC')
            .margin({ left: 8 })
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  @Builder
  SendMessageForm() {
    Column() {
      Column() {
        Text('消息类型')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Row() {
          Button('系统通知')
            .fontSize(14)
            .backgroundColor('#F9F0FF')
            .fontColor('#722ED1')
          
          Button('考勤提醒')
            .fontSize(14)
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
            .margin({ left: 8 })
          
          Button('缴费通知')
            .fontSize(14)
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8)

      Column() {
        Text('消息标题')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width('100%')

        TextInput({ placeholder: '请输入消息标题' })
          .width('100%')
          .margin({ top: 8 })
          .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin({ top: 8 })

      Column() {
        Text('消息内容')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width('100%')

        TextArea({ placeholder: '请输入消息内容' })
          .width('100%')
          .height(120)
          .margin({ top: 8 })
          .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin({ top: 8 })

      Button('发送消息')
        .width('100%')
        .height(48)
        .backgroundColor('#722ED1')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .borderRadius(8)
        .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .layoutWeight(1)
  }
}

