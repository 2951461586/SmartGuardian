/**
 * SmartGuardian - Parent Message Detail Page
 * 显示消息详情
 */

import { MessageRecord } from '../../models/message';
import { DateUtils } from '../../utils/dateUtils';

@Entry
@Component
struct ParentMessageDetailPage {
  @State message: MessageRecord | null = null;

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as Record<string, Object>;
    if (params && params['message']) {
      this.message = params['message'] as MessageRecord;
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