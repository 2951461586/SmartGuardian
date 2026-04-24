/**
 * SmartGuardian - Empty State Component
 * Unified empty state display for lists and data
 * 
 * @description 统一空状态组件，用于列表无数据时的展示
 * @features
 * - 支持自定义图标
 * - 支持自定义文案
 * - 支持操作按钮
 * - 多种预设样式
 */

/**
 * Empty State Type
 */
export enum EmptyType {
  /** 默认空状态 */
  DEFAULT = 'DEFAULT',
  /** 无订单 */
  NO_ORDER = 'NO_ORDER',
  /** 无消息 */
  NO_MESSAGE = 'NO_MESSAGE',
  /** 无学生 */
  NO_STUDENT = 'NO_STUDENT',
  /** 无作业 */
  NO_HOMEWORK = 'NO_HOMEWORK',
  /** 无考勤 */
  NO_ATTENDANCE = 'NO_ATTENDANCE',
  /** 搜索无结果 */
  NO_RESULT = 'NO_RESULT',
  /** 无网络 */
  NO_NETWORK = 'NO_NETWORK'
}

/**
 * Empty State Config
 */
interface EmptyConfig {
  icon: Resource;
  title: string;
  description: string;
}

/**
 * Empty State Component
 * @description 空状态组件
 * @example
 * ```typescript
 * EmptyState({
 *   type: EmptyType.NO_ORDER,
 *   onAction: () => this.loadData()
 * })
 * ```
 */
@Component
export struct EmptyState {
  /** 空状态类型 */
  @Prop type: EmptyType = EmptyType.DEFAULT;
  /** 自定义图标 */
  @Prop customIcon?: Resource;
  /** 自定义标题 */
  @Prop customTitle?: string;
  /** 自定义描述 */
  @Prop customDescription?: string;
  /** 操作按钮文本 */
  @Prop actionText: string = '';
  /** 操作按钮点击事件 */
  onAction?: () => void;

  build() {
    Column() {
      // 图标
      Image(this.getIcon())
        .width(88)
        .height(88)
        .objectFit(ImageFit.Contain)
        .fillColor($r('app.color.text_tertiary'))

      // 标题
      Text(this.getTitle())
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ top: $r('app.float.card_margin') })

      // 描述
      if (this.getDescription()) {
        Text(this.getDescription())
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
          .textAlign(TextAlign.Center)
      }

      // 操作按钮
      if (this.actionText && this.onAction) {
        Button(this.actionText)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(16)
          .height(40)
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
  }

  private getIcon(): Resource {
    if (this.customIcon) {
      return this.customIcon;
    }

    // 根据类型返回默认图标
    return $r('app.media.ic_empty');
  }

  private getTitle(): string {
    if (this.customTitle) {
      return this.customTitle;
    }

    const titleMap: Record<EmptyType, string> = {
      [EmptyType.DEFAULT]: '暂无数据',
      [EmptyType.NO_ORDER]: '暂无订单',
      [EmptyType.NO_MESSAGE]: '暂无消息',
      [EmptyType.NO_STUDENT]: '暂无学生',
      [EmptyType.NO_HOMEWORK]: '暂无作业',
      [EmptyType.NO_ATTENDANCE]: '暂无考勤记录',
      [EmptyType.NO_RESULT]: '未找到相关内容',
      [EmptyType.NO_NETWORK]: '网络连接失败'
    };

    return titleMap[this.type];
  }

  private getDescription(): string {
    if (this.customDescription) {
      return this.customDescription;
    }

    const descMap: Record<EmptyType, string> = {
      [EmptyType.DEFAULT]: '',
      [EmptyType.NO_ORDER]: '您还没有任何订单记录',
      [EmptyType.NO_MESSAGE]: '您还没有收到任何消息',
      [EmptyType.NO_STUDENT]: '暂无学生信息',
      [EmptyType.NO_HOMEWORK]: '暂无作业记录',
      [EmptyType.NO_ATTENDANCE]: '暂无考勤记录',
      [EmptyType.NO_RESULT]: '请尝试其他搜索条件',
      [EmptyType.NO_NETWORK]: '请检查网络设置后重试'
    };

    return descMap[this.type];
  }
}

/**
 * Simple Empty State
 * @description 简化版空状态
 */
@Component
export struct SimpleEmptyState {
  @Prop message: string = '暂无数据';
  @Prop icon?: Resource;

  build() {
    Column() {
      if (this.icon) {
        Image(this.icon)
          .width(80)
          .height(80)
          .objectFit(ImageFit.Contain)
      }

      Text(this.message)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: this.icon ? 16 : 0 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(32)
  }
}
