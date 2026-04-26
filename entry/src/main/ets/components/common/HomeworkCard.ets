/**
 * SmartGuardian - HomeworkCard Component
 * 可复用的作业卡片组件
 * 
 * @description 支持简化模式和详细模式两种布局
 * @example
 * // 简化模式（家长端）
 * HomeworkCard({
 *   homework: task,
 *   mode: HomeworkCardMode.SIMPLE
 * })
 * 
 * // 详细模式（教师端）
 * HomeworkCard({
 *   homework: task,
 *   mode: HomeworkCardMode.DETAIL,
 *   showFeedbackButton: true,
 *   onSubmitFeedback: () => { ... }
 * })
 */

import { HomeworkTask } from '../../models/homework';
import { HarmonyColor } from '../../common/HarmonyDesign';
import { HomeworkBadge } from '../StatusBadge';

/** 作业卡片显示模式 */
export enum HomeworkCardMode {
  /** 简化模式 - 家长端，显示科目、内容、状态 */
  SIMPLE = 'simple',
  /** 详细模式 - 教师端，显示学生、内容、日期、操作按钮 */
  DETAIL = 'detail'
}

@Component
export struct HomeworkCard {
  /** 作业数据 */
  @Prop homework: HomeworkTask | null = null;
  
  /** 显示模式 */
  @Prop mode: HomeworkCardMode = HomeworkCardMode.SIMPLE;
  
  /** 是否显示反馈按钮（仅DETAIL模式） */
  @Prop showFeedbackButton: boolean = false;
  
  /** 提交反馈回调 */
  onSubmitFeedback?: () => void;

  build() {
    Column() {
      if (this.homework !== null) {
        if (this.mode === HomeworkCardMode.SIMPLE) {
          this.buildSimpleCard()
        } else {
          this.buildDetailCard()
        }
      }
    }
  }

  /** 简化模式卡片 */
  @Builder
  buildSimpleCard() {
    Row() {
      Column() {
        Text(this.homework?.subject || '作业')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.homework?.content || '--')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 使用HomeworkBadge显示状态
      HomeworkBadge({ status: this.homework?.status || 'PENDING' })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  /** 详细模式卡片 */
  @Builder
  buildDetailCard() {
    Column() {
      Row() {
        Text(this.homework?.studentName || '学生')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        HomeworkBadge({ status: this.homework?.status || 'PENDING' })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: $r('app.float.card_content_margin') })

      Text(this.homework?.content || '')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Text(this.homework?.taskDate || '')
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_tertiary'))

        if (this.showFeedbackButton) {
          Button('提交反馈')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(HarmonyColor.textInverse)
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.button_radius'))
            .padding({
              left: $r('app.float.homework_feedback_button_padding_horizontal'),
              right: $r('app.float.homework_feedback_button_padding_horizontal'),
              top: $r('app.float.homework_feedback_button_padding_vertical'),
              bottom: $r('app.float.homework_feedback_button_padding_vertical')
            })
            .onClick(() => {
              if (this.onSubmitFeedback) {
                this.onSubmitFeedback();
              }
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: $r('app.float.card_content_margin') })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor($r('app.color.card_background'))
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }
}
