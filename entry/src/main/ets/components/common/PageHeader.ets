/**
 * SmartGuardian - Page Header Component
 * Unified page header with title and actions
 * 
 * @description 统一页面头部组件，支持标题、返回按钮、右侧操作按钮
 * @features
 * - 自动处理状态栏高度
 * - 支持返回按钮
 * - 支持右侧操作按钮
 * - 支持不同主题色
 */

import { UserRole } from '../../models/common';

/**
 * Header Theme
 */
export enum HeaderTheme {
  /** 主色调（默认） */
  PRIMARY = 'PRIMARY',
  /** 白色背景 */
  WHITE = 'WHITE',
  /** 透明背景 */
  TRANSPARENT = 'TRANSPARENT'
}

/**
 * Page Header Component
 * @description 页面头部组件
 * @example
 * ```typescript
 * PageHeader({
 *   title: '我的订单',
 *   showBack: true,
 *   onBackClick: () => router.back()
 * })
 * ```
 */
@Component
export struct PageHeader {
  /** 标题 */
  @Prop title: string = '';
  /** 副标题 */
  @Prop subtitle: string = '';
  /** 是否显示返回按钮 */
  @Prop showBack: boolean = false;
  /** 主题 */
  @Prop theme: HeaderTheme = HeaderTheme.PRIMARY;
  /** 返回按钮点击事件 */
  onBackClick?: () => void;
  /** 右侧图标资源 */
  @Prop rightIcon?: Resource;
  /** 右侧图标点击事件 */
  onRightIconClick?: () => void;
  /** 自定义右侧内容 */
  @BuilderParam rightContent?: () => void;

  build() {
    Row() {
      // 返回按钮
      if (this.showBack) {
        this.buildBackButton()
      }

      // 标题区域
      Column() {
        Text(this.title)
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextColor())

        if (this.subtitle) {
          Text(this.subtitle)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.getSubtitleColor())
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧内容
      if (this.rightContent) {
        this.rightContent()
      } else if (this.rightIcon) {
        this.buildRightIcon()
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(this.getPadding())
    .backgroundColor(this.getBgColor())
  }

  @Builder
  buildBackButton() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .fillColor(this.getTextColor())
    }
    .width(40)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.onBackClick) {
        this.onBackClick();
      }
    })
  }

  @Builder
  buildRightIcon() {
    Image(this.rightIcon)
      .width($r('app.float.icon_large_size'))
      .height($r('app.float.icon_large_size'))
      .objectFit(ImageFit.Contain)
      .onClick(() => {
        if (this.onRightIconClick) {
          this.onRightIconClick();
        }
      })
  }

  private getBgColor(): ResourceColor {
    switch (this.theme) {
      case HeaderTheme.WHITE:
        return Color.White;
      case HeaderTheme.TRANSPARENT:
        return Color.Transparent;
      default:
        return $r('app.color.primary');
    }
  }

  private getTextColor(): ResourceColor {
    switch (this.theme) {
      case HeaderTheme.WHITE:
        return $r('app.color.text_primary');
      case HeaderTheme.TRANSPARENT:
        return Color.White;
      default:
        return Color.White;
    }
  }

  private getSubtitleColor(): ResourceColor {
    switch (this.theme) {
      case HeaderTheme.WHITE:
        return $r('app.color.text_secondary');
      case HeaderTheme.TRANSPARENT:
        return '#FFFFFFCC';
      default:
        return '#FFFFFFCC';
    }
  }

  private getPadding(): Padding {
    const statusBarHeight = Number($r('app.float.status_bar_height'));
    return {
      left: 16,
      right: 16,
      top: statusBarHeight + 16,
      bottom: 16
    };
  }
}

/**
 * Simple Page Header
 * @description 简化版页面头部（居中标题）
 */
@Component
export struct SimplePageHeader {
  @Prop title: string = '';
  @Prop theme: HeaderTheme = HeaderTheme.PRIMARY;

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme === HeaderTheme.WHITE ? $r('app.color.text_primary') : Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      top: Number($r('app.float.status_bar_height')) + 20,
      bottom: 20
    })
    .backgroundColor(this.theme === HeaderTheme.WHITE ? Color.White : $r('app.color.primary'))
  }
}

/**
 * User Greeting Header
 * @description 用户问候头部（首页使用）
 */
@Component
export struct GreetingHeader {
  @Prop userName: string = '';
  @Prop greeting: string = '';
  @Prop theme: HeaderTheme = HeaderTheme.PRIMARY;
  onRightIconClick?: () => void;
  @BuilderParam rightContent?: () => void;

  build() {
    Row() {
      Column() {
        Text(`你好，${this.userName || '用户'}`)
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextColor())

        if (this.greeting) {
          Text(this.greeting)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.getSubtitleColor())
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.rightContent) {
        this.rightContent()
      } else {
        Image($r('app.media.ic_notification'))
          .width($r('app.float.icon_large_size'))
          .height($r('app.float.icon_large_size'))
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            if (this.onRightIconClick) {
              this.onRightIconClick();
            }
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding($r('app.float.page_padding'))
    .backgroundColor(this.getBgColor())
    .padding({ top: Number($r('app.float.status_bar_height')) + 20 })
  }

  private getBgColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? Color.White : $r('app.color.primary');
  }

  private getTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? $r('app.color.text_primary') : Color.White;
  }

  private getSubtitleColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? $r('app.color.text_secondary') : '#FFFFFFCC';
  }
}
