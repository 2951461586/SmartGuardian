/**
 * SmartGuardian - Parent Messages Page
 * Parent can view messages and notifications
 */

import { MessageService } from '../../services/api/attendance';
import { MessageRecord } from '../../models/attendance';

@Component
export struct ParentMessagesPage {
  @State messages: MessageRecord[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear() {
    this.loadMessages();
  }

  async loadMessages() {
    this.isLoading = true;
    try {
      const resp = await MessageService.getMessages({
        pageNum: 1,
        pageSize: 20
      });

      if (resp.code === 0 && resp.data) {
        this.messages = resp.data.list;
      }
    } catch (error) {
      this.errorMessage = '加载消息失败';
    } finally {
      this.isLoading = false;
    }
  }

  async markAsRead(messageId: number) {
    try {
      await MessageService.markAsRead(messageId);
      this.loadMessages();
    } catch (error) {
      // Handle error silently
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Message list
      this.buildMessageList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Text('消息中心')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: px2vp(AppStorage.get<number>('status_bar_height') || 0) + 20, bottom: 20 })
    .backgroundColor($r('app.color.primary'))
  }

  @Builder
  buildMessageList() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .color($r('app.color.primary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.messages.length === 0) {
      Column() {
        Image($r('app.media.ic_empty'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)
          .alt($r('app.media.ic_empty'))

        Text('暂无消息')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: $r('app.float.card_margin') })
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
      // Icon
      Image(this.getMsgTypeIcon(message.msgType))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
        .backgroundColor(this.getMsgTypeBgColor(message.msgType))
        .borderRadius(20)
        .padding(8)

      // Content
      Column() {
        Row() {
          Text(this.getMsgTypeText(message.msgType))
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          if (!message.readStatus) {
            Row() {}
              .width(8)
              .height(8)
              .backgroundColor($r('app.color.error'))
              .borderRadius(4)
              .margin({ left: 8 })
          }
        }
        .width('100%')

        Text(message.content)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })

        Text(message.createdAt)
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: $r('app.float.card_content_margin') })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(message.readStatus ? Color.White : '#F8F9FA')
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
    .onClick(() => {
      if (!message.readStatus) {
        this.markAsRead(message.id);
      }
    })
  }

  getMsgTypeIcon(msgType: string): Resource {
    const iconMap: Record<string, Resource> = {
      'SYSTEM': $r('app.media.ic_system'),
      'ATTENDANCE': $r('app.media.ic_attendance'),
      'HOMEWORK': $r('app.media.ic_homework'),
      'ORDER': $r('app.media.ic_order'),
      'CHAT': $r('app.media.ic_chat')
    };
    return iconMap[msgType] || $r('app.media.ic_system');
  }

  getMsgTypeText(msgType: string): string {
    const textMap: Record<string, string> = {
      'SYSTEM': '系统通知',
      'ATTENDANCE': '考勤通知',
      'HOMEWORK': '作业通知',
      'ORDER': '订单通知',
      'CHAT': '老师消息'
    };
    return textMap[msgType] || '通知';
  }

  getMsgTypeBgColor(msgType: string): string {
    const colorMap: Record<string, string> = {
      'SYSTEM': '#E3F2FD',
      'ATTENDANCE': '#E8F5E9',
      'HOMEWORK': '#FFF3E0',
      'ORDER': '#F3E5F5',
      'CHAT': '#E0F7FA'
    };
    return colorMap[msgType] || '#F5F5F5';
  }
}
