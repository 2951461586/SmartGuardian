import { HomeworkTask } from '../../models/homework';
import { HarmonyColor } from '../../common/HarmonyDesign';
import { Card } from './Card';

@Component
export struct ParentHomeworkPreviewCard {
  @Prop tasks: HomeworkTask[] = [];
  @Prop subtitle: string = '及时了解老师反馈和最近作业进度。';
  @Prop fallbackText: string = '老师暂未更新新的学习反馈。';
  @Prop actionText: string = '查看全部';
  onAction?: () => void;

  build() {
    Card({
      title: '学习反馈',
      subtitle: this.subtitle,
      actionText: this.actionText,
      onAction: this.onAction,
      content: this.buildContent
    })
  }

  @Builder
  private buildContent() {
    if (this.tasks.length > 0) {
      Column() {
        ForEach(this.tasks, (item: HomeworkTask, index: number) => {
          Row() {
            Column() {
              Text(item.title || '今日学习任务')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(item.subject || item.content || '查看老师布置的最新任务与反馈')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .lineHeight(18)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 6 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(item.status || '待查看')
              .fontSize(12)
              .fontColor($r('app.color.primary'))
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor(HarmonyColor.surfaceSubtle)
              .borderRadius(999)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })

          if (index < this.tasks.length - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 10, bottom: 10 })
          }
        })
      }
      .width('100%')
    } else {
      Column() {
        Text(this.fallbackText)
          .fontSize(14)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
