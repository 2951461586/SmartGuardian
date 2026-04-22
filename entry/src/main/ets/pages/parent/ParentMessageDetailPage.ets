/**
 * SmartGuardian - Parent Message Detail Page
 * 显示消息详情
 */

import { MessageDetail, MessageRecord } from '../../models/message';
import { MessageService } from '../../services/api/message';
import { MessageStore } from '../../stores/messageStore';

interface MessageDetailRouteParams {
  messageId?: number | string;
}

@Entry
@Component
struct ParentMessageDetailPage {
  @State message: MessageRecord | MessageDetail | null = null;

  async aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as MessageDetailRouteParams;
    const messageId = Number(params.messageId ?? 0);
    const currentMessage = MessageStore.getCurrentMessage();
    const cachedMessage = MessageStore.findMessageById(messageId);
    const targetMessage = currentMessage?.id === messageId ? currentMessage : cachedMessage;

    if (targetMessage) {
      this.message = targetMessage;
      await this.loadMessageDetail(messageId);
    }
  }

  private async loadMessageDetail(messageId: number): Promise<void> {
    try {
      const response = await MessageService.getMessageDetail(messageId);
      if (response.code === 0 && response.data) {
        this.message = response.data;
      }
    } catch (error) {
      // 保留当前缓存消息作为兜底展示
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.text_primary'))
          .onClick(() => this.getUIContext().getRouter().back())

        Text('消息详情')
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('').width(24)
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
      .backgroundColor(Color.White)

      // Content
      if (this.message) {
        Scroll() {
          Column() {
            // 标题
            Text(this.message.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')

            // 时间
            Text(this.message.createdAt)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_tertiary'))
              .margin({ top: 12 })

            Divider()
              .margin({ top: 16, bottom: 16 })

            // 内容
            Text(this.message.content)
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))
              .lineHeight(24)
              .width('100%')
          }
          .width('100%')
          .padding($r('app.float.page_padding'))
        }
        .layoutWeight(1)
      } else {
        Column() {
          Text('消息不存在')
            .fontSize($r('app.float.text_primary_size'))
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
