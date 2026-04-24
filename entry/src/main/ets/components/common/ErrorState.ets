/**
 * SmartGuardian - Error State Component
 * Unified error state display with retry action
 * 
 * @description 统一错误状态组件，支持重试操作
 * @features
 * - 网络错误
 * - 业务错误
 * - 自定义错误
 * - 重试按钮
 */

import { ErrorType } from '../../utils/ErrorHandlerUtil';

/**
 * Error State Type
 */
export enum ErrorStateType {
  /** 网络错误 */
  NETWORK = 'NETWORK',
  /** 服务器错误 */
  SERVER = 'SERVER',
  /** 业务错误 */
  BUSINESS = 'BUSINESS',
  /** 权限错误 */
  PERMISSION = 'PERMISSION',
  /** 自定义错误 */
  CUSTOM = 'CUSTOM'
}

/**
 * Error State Component
 * @description 错误状态组件
 * @example
 * ```typescript
 * ErrorState({
 *   type: ErrorStateType.NETWORK,
 *   message: '网络连接失败',
 *   onRetry: () => this.loadData()
 * })
 * ```
 */
@Component
export struct ErrorState {
  /** 错误类型 */
  @Prop type: ErrorStateType = ErrorStateType.NETWORK;
  /** 错误消息 */
  @Prop message: string = '';
  /** 重试按钮文本 */
  @Prop retryText: string = '重试';
  /** 是否显示重试按钮 */
  @Prop showRetry: boolean = true;
  /** 重试点击事件 */
  onRetry?: () => void;

  build() {
    Column() {
      // 错误图标
      Image(this.getIcon())
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .fillColor($r('app.color.error'))

      // 错误标题
      Text(this.getTitle())
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 16 })

      // 错误消息
      if (this.message) {
        Text(this.message)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      // 重试按钮
      if (this.showRetry && this.onRetry) {
        Button(this.retryText)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(16)
          .height(40)
          .padding({ left: 24, right: 24 })
          .margin({ top: 20 })
          .onClick(() => {
            if (this.onRetry) {
              this.onRetry();
            }
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(32)
  }

  private getIcon(): Resource {
    // 根据错误类型返回不同图标
    return $r('app.media.ic_error');
  }

  private getTitle(): string {
    const titleMap: Record<ErrorStateType, string> = {
      [ErrorStateType.NETWORK]: '网络连接失败',
      [ErrorStateType.SERVER]: '服务器错误',
      [ErrorStateType.BUSINESS]: '操作失败',
      [ErrorStateType.PERMISSION]: '没有权限',
      [ErrorStateType.CUSTOM]: '发生错误'
    };

    return titleMap[this.type];
  }
}

/**
 * Inline Error Message
 * @description 内联错误消息（用于表单等场景）
 */
@Component
export struct InlineError {
  @Prop message: string = '';
  @Prop showIcon: boolean = true;

  build() {
    if (this.message) {
      Row() {
        if (this.showIcon) {
          Image($r('app.media.ic_warning'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Contain)
            .fillColor($r('app.color.error'))
        }

        Text(this.message)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.error'))
          .margin({ left: this.showIcon ? 8 : 0 })
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
    }
  }
}

/**
 * Error Banner
 * @description 错误横幅（用于页面顶部错误提示）
 */
@Component
export struct ErrorBanner {
  @Prop message: string = '';
  @Prop dismissible: boolean = true;
  onDismiss?: () => void;

  build() {
    if (this.message) {
      Row() {
        Image($r('app.media.ic_warning'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .fillColor($r('app.color.error'))

        Text(this.message)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.error'))
          .layoutWeight(1)
          .margin({ left: 8 })

        if (this.dismissible) {
          Image($r('app.media.ic_close'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .fillColor($r('app.color.error'))
            .onClick(() => {
              if (this.onDismiss) {
                this.onDismiss();
              }
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFF0F1')
      .borderRadius($r('app.float.card_border_radius'))
    }
  }
}
