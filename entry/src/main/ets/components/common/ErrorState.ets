import { HarmonyColor } from '../../common/HarmonyDesign';

export enum ErrorStateType {
  NETWORK = 'NETWORK',
  SERVER = 'SERVER',
  BUSINESS = 'BUSINESS',
  PERMISSION = 'PERMISSION',
  CUSTOM = 'CUSTOM'
}

@Component
export struct ErrorState {
  @Prop type: ErrorStateType = ErrorStateType.NETWORK;
  @Prop message: string = '';
  @Prop retryText: string = '重试';
  @Prop showRetry: boolean = true;
  onRetry?: () => void;

  build() {
    Column() {
      Column() {
        Image($r('app.media.ic_error'))
          .width(32)
          .height(32)
          .objectFit(ImageFit.Contain)
          .fillColor($r('app.color.error'))
      }
      .width(76)
      .height(76)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.surface_error'))
      .borderRadius(24)

      Text(this.getTitle())
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 16 })

      if (this.message) {
        Text(this.message)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
          .textAlign(TextAlign.Center)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      if (this.showRetry && this.onRetry) {
        Button(this.retryText)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(HarmonyColor.textInverse)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(18)
          .height(44)
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
    .padding(24)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(28)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 28,
      style: BorderStyle.Solid
    })
  }

  private getTitle(): string {
    if (this.type === ErrorStateType.SERVER) {
      return '服务暂不可用';
    }
    if (this.type === ErrorStateType.BUSINESS) {
      return '处理失败';
    }
    if (this.type === ErrorStateType.PERMISSION) {
      return '没有权限';
    }
    if (this.type === ErrorStateType.CUSTOM) {
      return '发生错误';
    }
    return '网络连接失败';
  }
}

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
      .backgroundColor($r('app.color.surface_error'))
      .borderRadius(16)
    }
  }
}
