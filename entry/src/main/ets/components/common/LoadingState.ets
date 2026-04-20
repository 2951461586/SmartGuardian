/**
 * SmartGuardian - Loading State Component
 * Unified loading state display
 * 
 * @description 统一加载状态组件，支持全屏和局部加载
 * @features
 * - 全屏加载
 * - 局部加载
 * - 自定义加载文案
 * - 骨架屏支持
 */

/**
 * Loading Size
 */
export enum LoadingSize {
  /** 小尺寸 */
  SMALL = 'SMALL',
  /** 默认尺寸 */
  DEFAULT = 'DEFAULT',
  /** 大尺寸 */
  LARGE = 'LARGE'
}

/**
 * Loading State Component
 * @description 加载状态组件
 * @example
 * ```typescript
 * if (this.isLoading) {
 *   LoadingState({ size: LoadingSize.LARGE })
 * }
 * ```
 */
@Component
export struct LoadingState {
  /** 加载尺寸 */
  @Prop loadingSize: LoadingSize = LoadingSize.DEFAULT;
  /** 加载文案 */
  @Prop message: string = '';
  /** 是否全屏 */
  @Prop fullscreen: boolean = false;
  /** 进度（0-100，用于进度条模式） */
  @Prop progress?: number;

  build() {
    if (this.fullscreen) {
      this.buildFullscreenLoading()
    } else {
      this.buildInlineLoading()
    }
  }

  @Builder
  buildFullscreenLoading() {
    Column() {
      this.buildLoadingContent()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildInlineLoading() {
    Column() {
      this.buildLoadingContent()
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(32)
  }

  @Builder
  buildLoadingContent() {
    Column() {
      // 进度条模式
      if (this.progress !== undefined) {
        this.buildProgressLoading()
      } else {
        // 普通加载动画
        this.buildSpinnerLoading()
      }
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildSpinnerLoading() {
    LoadingProgress()
      .color($r('app.color.primary'))
      .width(this.getSpinnerSize())
      .height(this.getSpinnerSize())

    if (this.message) {
      Text(this.message)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 16 })
    }
  }

  @Builder
  buildProgressLoading() {
    Column() {
      Progress({
        value: this.progress || 0,
        total: 100,
        type: ProgressType.Linear
      })
        .width(200)
        .color($r('app.color.primary'))

      Text(`${this.progress || 0}%`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      if (this.message) {
        Text(this.message)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
    }
    .alignItems(HorizontalAlign.Center)
  }

  private getSpinnerSize(): number {
    switch (this.loadingSize) {
      case LoadingSize.SMALL:
        return 24;
      case LoadingSize.LARGE:
        return 56;
      default:
        return 40;
    }
  }
}

/**
 * Simple Loading Spinner
 * @description 简化版加载动画
 */
@Component
export struct LoadingSpinner {
  @Prop spinnerColor: ResourceColor = $r('app.color.primary');
  @Prop spinnerSize: number = 40;

  build() {
    LoadingProgress()
      .color(this.spinnerColor)
      .width(this.spinnerSize)
      .height(this.spinnerSize)
  }
}

/**
 * Skeleton Loading
 * @description 骨架屏加载组件
 */
@Component
export struct SkeletonLoading {
  /** 行数 */
  @Prop rows: number = 3;
  /** 是否显示头像 */
  @Prop showAvatar: boolean = false;
  /** 是否显示标题 */
  @Prop showTitle: boolean = true;

  build() {
    Column() {
      // 标题骨架
      if (this.showTitle) {
        Row()
          .width('40%')
          .height(20)
          .backgroundColor('#E5E7EB')
          .borderRadius(4)
          .margin({ bottom: 16 })
      }

      // 内容行骨架
      ForEach(Array.from({ length: this.rows }), (_: Record<string, number>, index: number) => {
        Row() {
          // 头像骨架
          if (this.showAvatar) {
            Column()
              .width(48)
              .height(48)
              .backgroundColor('#E5E7EB')
              .borderRadius(24)
              .margin({ right: 12 })
          }

          // 文本骨架
          Column() {
            Row()
              .width('100%')
              .height(16)
              .backgroundColor('#E5E7EB')
              .borderRadius(4)

            Row()
              .width('60%')
              .height(16)
              .backgroundColor('#E5E7EB')
              .borderRadius(4)
              .margin({ top: 8 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
      })
    }
    .width('100%')
    .padding(16)
  }
}

/**
 * Card Skeleton
 * @description 卡片骨架屏
 */
@Component
export struct CardSkeleton {
  build() {
    Column() {
      // 卡片头部
      Row() {
        Column()
          .width(40)
          .height(40)
          .backgroundColor('#E5E7EB')
          .borderRadius(8)

        Column() {
          Row()
            .width(100)
            .height(16)
            .backgroundColor('#E5E7EB')
            .borderRadius(4)

          Row()
            .width(60)
            .height(12)
            .backgroundColor('#E5E7EB')
            .borderRadius(4)
            .margin({ top: 6 })
        }
        .margin({ left: 12 })
        .layoutWeight(1)
      }
      .width('100%')

      // 卡片内容
      Column() {
        Row()
          .width('100%')
          .height(14)
          .backgroundColor('#E5E7EB')
          .borderRadius(4)

        Row()
          .width('80%')
          .height(14)
          .backgroundColor('#E5E7EB')
          .borderRadius(4)
          .margin({ top: 8 })
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }
}
