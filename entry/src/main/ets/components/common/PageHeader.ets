/**
 * SmartGuardian - Page Header Component
 * Unified page headers with tokenized surfaces and role-aware gradients.
 */

import { HarmonyColor, HarmonyRadius, harmonyShadowColor } from '../../common/HarmonyDesign';
import { getCurrentRolePalette } from '../../common/RoleTheme';

export enum HeaderTheme {
  PRIMARY = 'PRIMARY',
  WHITE = 'WHITE',
  TRANSPARENT = 'TRANSPARENT'
}

@Component
export struct PageHeader {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop showBack: boolean = false;
  @Prop theme: HeaderTheme = HeaderTheme.PRIMARY;
  onBackClick?: () => void;
  @Prop rightIcon: ResourceStr = '';
  onRightIconClick?: () => void;
  @BuilderParam rightContent?: () => void;

  build() {
    Row() {
      if (this.showBack) {
        this.buildBackButton()
      }

      Column() {
        Text(this.title)
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextColor())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.subtitle) {
          Text(this.subtitle)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.getSubtitleColor())
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.rightContent) {
        this.rightContent()
      } else if (this.rightIcon) {
        this.buildRightIcon()
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(this.getPadding())
    .backgroundColor(this.getBgColor())
  }

  @Builder
  private buildBackButton() {
    Column() {
      Image($r('app.media.ic_arrow_left'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .fillColor(this.getTextColor())
    }
    .width(42)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getActionBgColor())
    .borderRadius(HarmonyRadius.control)
    .border({
      width: 1,
      color: this.getActionBorderColor(),
      radius: HarmonyRadius.control,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 10 : 0,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 4
    })
    .margin({ right: 12 })
    .onClick(() => {
      if (this.onBackClick) {
        this.onBackClick();
      }
    })
  }

  @Builder
  private buildRightIcon() {
    Column() {
      Image(this.rightIcon)
        .width($r('app.float.icon_large_size'))
        .height($r('app.float.icon_large_size'))
        .objectFit(ImageFit.Contain)
        .fillColor(this.getTextColor())
    }
    .width(42)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getActionBgColor())
    .borderRadius(HarmonyRadius.control)
    .border({
      width: 1,
      color: this.getActionBorderColor(),
      radius: HarmonyRadius.control,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 10 : 0,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      if (this.onRightIconClick) {
        this.onRightIconClick();
      }
    })
  }

  private getBgColor(): ResourceColor {
    if (this.theme === HeaderTheme.WHITE) {
      return $r('app.color.page_background');
    }
    if (this.theme === HeaderTheme.TRANSPARENT) {
      return Color.Transparent;
    }
    return getCurrentRolePalette().primary;
  }

  private getTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? HarmonyColor.textPrimary : HarmonyColor.textInverse;
  }

  private getSubtitleColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? HarmonyColor.textSecondary : HarmonyColor.textInverseStrong;
  }

  private getActionBgColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? HarmonyColor.surface : HarmonyColor.overlayInverseSoft;
  }

  private getActionBorderColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? HarmonyColor.line : HarmonyColor.overlayInverseBorder;
  }

  private getPadding(): Padding {
    return {
      left: 16,
      right: 16,
      top: Number($r('app.float.status_bar_height')) + 16,
      bottom: 16
    };
  }
}

@Component
export struct SimplePageHeader {
  @Prop title: string = '';
  @Prop theme: HeaderTheme = HeaderTheme.PRIMARY;

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme === HeaderTheme.WHITE ? HarmonyColor.textPrimary : HarmonyColor.textInverse)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: Number($r('app.float.status_bar_height')) + 20, bottom: 20 })
    .backgroundColor(this.theme === HeaderTheme.WHITE ? $r('app.color.page_background') : getCurrentRolePalette().primary)
  }
}

@Component
export struct GreetingHeader {
  @Prop userName: string = '';
  @Prop greeting: string = '';
  @Prop theme: HeaderTheme = HeaderTheme.WHITE;
  @Prop badgeText: string = 'SmartGuardian';
  @Prop metaText: string = '';
  onRightIconClick?: () => void;
  @BuilderParam rightContent?: () => void;

  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('智慧学生托管')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getTextColor())
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.badgeText)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getAccentTextColor())
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor(this.getAccentBgColor())
              .borderRadius(HarmonyRadius.pill)
              .margin({ left: 10 })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Text(this.getGreetingTitle())
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getTextColor())
            .margin({ top: 12 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.greeting) {
            Text(this.greeting)
              .fontSize(13)
              .fontColor(this.getSubtitleColor())
              .lineHeight(19)
              .margin({ top: 5 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Text(this.metaText || this.getDefaultMetaText())
            .fontSize(12)
            .fontColor(this.getMutedTextColor())
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(this.getMetaBgColor())
            .borderRadius(HarmonyRadius.pill)
            .margin({ top: 10 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.rightContent) {
          this.rightContent()
        } else {
          this.buildDefaultAction()
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: Number($r('app.float.status_bar_height')) + 18,
      bottom: 18
    })
    .linearGradient(this.getGradient())
    .borderRadius({
      bottomLeft: this.theme === HeaderTheme.WHITE ? 0 : 32,
      bottomRight: this.theme === HeaderTheme.WHITE ? 0 : 32
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 0 : 18,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 10
    })
  }

  @Builder
  private buildDefaultAction() {
    Column() {
      Image($r('app.media.ic_notification'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .fillColor(this.theme === HeaderTheme.WHITE ? HarmonyColor.textPrimary : HarmonyColor.textInverse)
    }
    .width(48)
    .height(48)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.theme === HeaderTheme.WHITE ? HarmonyColor.surface : HarmonyColor.overlayInverseSoft)
    .borderRadius(HarmonyRadius.control)
    .border({
      width: 1,
      color: this.theme === HeaderTheme.WHITE ? HarmonyColor.line : HarmonyColor.overlayInverseBorder,
      radius: HarmonyRadius.control,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 10 : 0,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      if (this.onRightIconClick) {
        this.onRightIconClick();
      }
    })
  }

  private getGreetingTitle(): string {
    if (this.userName.length > 0) {
      return `你好，${this.userName}`;
    }
    if (this.greeting.length > 0) {
      return this.greeting;
    }
    return '欢迎回来';
  }

  private getTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? HarmonyColor.textPrimary : HarmonyColor.textInverse;
  }

  private getSubtitleColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? HarmonyColor.textSecondary : HarmonyColor.textInverseStrong;
  }

  private getMutedTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? HarmonyColor.textSecondary : HarmonyColor.textInverseMuted;
  }

  private getAccentBgColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? getCurrentRolePalette().light : HarmonyColor.overlayInverseSoft;
  }

  private getAccentTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? getCurrentRolePalette().primary : HarmonyColor.surface;
  }

  private getMetaBgColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? HarmonyColor.overlaySurface : HarmonyColor.overlayInverseSoft;
  }

  private getGradient(): LinearGradient {
    if (this.theme === HeaderTheme.WHITE) {
      return {
        angle: 165,
        colors: [[HarmonyColor.surface, 0], [HarmonyColor.page, 0.55], [getCurrentRolePalette().light, 1]]
      };
    }
    return {
      angle: 145,
      colors: [[getCurrentRolePalette().primary, 0], [getCurrentRolePalette().primaryDark, 0.58], [HarmonyColor.inkStrong, 1]]
    };
  }

  private getDefaultMetaText(): string {
    const today = new Date();
    const month = today.getMonth() + 1;
    const day = today.getDate();
    const monthText = month < 10 ? `0${month}` : `${month}`;
    const dayText = day < 10 ? `0${day}` : `${day}`;
    return `${today.getFullYear()}-${monthText}-${dayText}`;
  }
}
