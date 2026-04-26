/**
 * SmartGuardian - MessageListItem Component
 * 可复用的消息列表项组件
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { MessageRecord } from '../../models/message';

@Component
export struct MessageListItem {
  @Prop message: MessageRecord | null = null;
  onMarkRead?: () => void;
  onItemClick?: () => void;

  private getMsgTypeIcon(msgType: string): Resource {
    if (msgType === 'SYSTEM') {
      return $r('app.media.ic_system');
    }
    if (msgType === 'ATTENDANCE') {
      return $r('app.media.ic_attendance');
    }
    if (msgType === 'HOMEWORK') {
      return $r('app.media.ic_homework');
    }
    if (msgType === 'ORDER') {
      return $r('app.media.ic_order');
    }
    return $r('app.media.ic_message');
  }

  private getMsgTypeBgColor(msgType: string): string {
    if (msgType === 'SYSTEM') {
      return HarmonyReport.accentSurface;
    }
    if (msgType === 'ATTENDANCE') {
      return HarmonyReport.positiveSurface;
    }
    if (msgType === 'HOMEWORK') {
      return HarmonyReport.cautionSurface;
    }
    if (msgType === 'ORDER') {
      return HarmonyColor.surfaceMuted;
    }
    return HarmonyColor.surfaceSubtle;
  }

  private getMsgTypeText(msgType: string): string {
    if (msgType === 'SYSTEM') {
      return '系统通知';
    }
    if (msgType === 'ATTENDANCE') {
      return '考勤通知';
    }
    if (msgType === 'HOMEWORK') {
      return '作业通知';
    }
    if (msgType === 'ORDER') {
      return '订单通知';
    }
    return '通知';
  }

  build() {
    Row() {
      if (this.message !== null) {
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

        Column() {
          Row() {
            Text(this.getMsgTypeText(this.message.msgType))
              .fontSize($r('app.float.text_primary_size'))
              .fontWeight(FontWeight.Medium)

            if (!this.message.readStatus) {
              Row()
                .width(8)
                .height(8)
                .backgroundColor(HarmonyReport.danger)
                .borderRadius(4)
                .margin({ left: 8 })
            }
          }

          Text(this.message.title ? this.message.title : this.message.content)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(this.message?.readStatus ? HarmonyColor.surface : HarmonyColor.surfaceSubtle)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: 12 })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      } else if (!this.message?.readStatus && this.onMarkRead) {
        this.onMarkRead();
      }
    })
  }
}
