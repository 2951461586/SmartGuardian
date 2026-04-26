import { HarmonyColor } from '../../common/HarmonyDesign';

export enum EmptyType {
  DEFAULT = 'DEFAULT',
  NO_ORDER = 'NO_ORDER',
  NO_MESSAGE = 'NO_MESSAGE',
  NO_STUDENT = 'NO_STUDENT',
  NO_HOMEWORK = 'NO_HOMEWORK',
  NO_ATTENDANCE = 'NO_ATTENDANCE',
  NO_RESULT = 'NO_RESULT',
  NO_NETWORK = 'NO_NETWORK'
}

@Component
export struct EmptyState {
  @Prop type: EmptyType = EmptyType.DEFAULT;
  @Prop customTitle: string = '';
  @Prop customDescription: string = '';
  @Prop actionText: string = '';
  onAction?: () => void;

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(156)
          .height(156)
          .backgroundColor($r('app.color.state_illustration_background'))
          .borderRadius(28)

        Image(this.getVisual())
          .width(132)
          .height(132)
          .objectFit(ImageFit.Contain)
      }

      Text(this.getTitle())
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 14 })

      if (this.getDescription().length > 0) {
        Text(this.getDescription())
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .lineHeight(21)
          .margin({ top: 8 })
      }

      if (this.actionText.length > 0 && this.onAction) {
        Button(this.actionText)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(HarmonyColor.textInverse)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(18)
          .height(44)
          .padding({ left: 24, right: 24 })
          .margin({ top: 20 })
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(20)
  }

  private getVisual(): Resource {
    if (this.type === EmptyType.NO_NETWORK) {
      return $r('app.media.ic_error');
    }
    return $r('app.media.sg_state_empty_learning');
  }

  private getTitle(): string {
    if (this.customTitle.length > 0) {
      return this.customTitle;
    }
    if (this.type === EmptyType.NO_ORDER) {
      return '暂无订单';
    }
    if (this.type === EmptyType.NO_MESSAGE) {
      return '暂无消息';
    }
    if (this.type === EmptyType.NO_STUDENT) {
      return '暂无学生';
    }
    if (this.type === EmptyType.NO_HOMEWORK) {
      return '暂无作业';
    }
    if (this.type === EmptyType.NO_ATTENDANCE) {
      return '暂无考勤记录';
    }
    if (this.type === EmptyType.NO_RESULT) {
      return '未找到相关内容';
    }
    if (this.type === EmptyType.NO_NETWORK) {
      return '网络连接失败';
    }
    return '暂无数据';
  }

  private getDescription(): string {
    if (this.customDescription.length > 0) {
      return this.customDescription;
    }
    if (this.type === EmptyType.NO_ORDER) {
      return '当前还没有可展示的订单记录。';
    }
    if (this.type === EmptyType.NO_MESSAGE) {
      return '消息中心暂时没有新的内容。';
    }
    if (this.type === EmptyType.NO_STUDENT) {
      return '学生信息将在完成绑定后显示。';
    }
    if (this.type === EmptyType.NO_HOMEWORK) {
      return '老师暂时还没有发布新的作业。';
    }
    if (this.type === EmptyType.NO_ATTENDANCE) {
      return '当前时间范围内没有考勤记录。';
    }
    if (this.type === EmptyType.NO_RESULT) {
      return '请尝试调整筛选条件后重新搜索。';
    }
    if (this.type === EmptyType.NO_NETWORK) {
      return '请检查当前网络后重试。';
    }
    return '';
  }
}

@Component
export struct SimpleEmptyState {
  @Prop message: string = '暂无数据';
  @Prop showIcon: boolean = false;
  @Prop icon: Resource = $r('app.media.sg_state_empty_learning');

  build() {
    Column() {
      if (this.showIcon) {
        Image(this.icon)
          .width(80)
          .height(80)
          .objectFit(ImageFit.Contain)
      }

      Text(this.message)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: this.showIcon ? 16 : 0 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(32)
  }
}
