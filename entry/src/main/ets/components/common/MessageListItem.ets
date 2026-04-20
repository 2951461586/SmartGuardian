/**
 * SmartGuardian - MessageListItem Component
 * 可复用的消息列表项组件
 * 
 * @description 支持不同消息类型显示，包含未读标记
 * @example
 * MessageListItem({
 *   message: message,
 *   onMarkRead: () => { ... },
 *   onItemClick: () => { ... }
 * })
 */

import { MessageRecord } from '../../models/message';

@Component
export struct MessageListItem {
  /** 消息数据 */
  @Prop message: MessageRecord | null = null;
  
  /** 标记已读回调 */
  onMarkRead?: () => void;

  /** 点击消息项回调 */
  onItemClick?: () => void;

  /** 获取消息类型图标 */
  private getMsgTypeIcon(msgType: string): Resource {
    const icons: Record<string, Resource> = {
      'SYSTEM': $r('app.media.ic_system'),
      'ATTENDANCE': $r('app.media.ic_attendance'),
      'HOMEWORK': $r('app.media.ic_homework'),
      'ORDER': $r('app.media.ic_order')
    };
    return icons[msgType] || $r('app.media.ic_message');
  }

  /** 获取消息类型背景色 */
  private getMsgTypeBgColor(msgType: string): string {
    const colors: Record<string, string> = {
      'SYSTEM': '#E3F2FD',
      'ATTENDANCE': '#E8F5E9',
      'HOMEWORK': '#FFF3E0',
      'ORDER': '#F3E5F5'
    };
    return colors[msgType] || '#F5F5F5';
  }

  /** 获取消息类型文本 */
  private getMsgTypeText(msgType: string): string {
    const texts: Record<string, string> = {
      'SYSTEM': '系统通知',
      'ATTENDANCE': '考勤通知',
      'HOMEWORK': '作业通知',
      'ORDER': '订单通知'
    };
    return texts[msgType] || '通知';
  }

  build() {
    Row() {
      if (this.message !== null) {
        // 消息类型图标
        Column() {
          Image(this.getMsgTypeIcon(this.message.msgType))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor(this.getMsgTypeBgColor(this.message.msgType))
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)

        // 消息内容
        Column() {
          Row() {
            Text(this.getMsgTypeText(this.message.msgType))
              .fontSize($r('app.float.text_primary_size'))
              .fontWeight(FontWeight.Medium)

            // 未读标记
            if (!this.message.readStatus) {
              Row()
                .width(8)
                .height(8)
                .backgroundColor('#FF5722')
                .borderRadius(4)
                .margin({ left: 8 })
            }
          }

          Text(this.message.title || this.message.content)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)

        // 右箭头
        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(this.message?.readStatus ? Color.White : '#F8F9FA')
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: 12 })
    .onClick(() => {
      // 优先触发消息项点击事件
      if (this.onItemClick) {
        this.onItemClick();
      } else if (!this.message?.readStatus && this.onMarkRead) {
        this.onMarkRead();
      }
    })
  }
}