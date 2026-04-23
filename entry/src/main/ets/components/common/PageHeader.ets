/**
 * SmartGuardian - Page Header Component
 * Unified page header with a light campus visual language
 */

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

        if (this.subtitle) {
          Text(this.subtitle)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.getSubtitleColor())
            .margin({ top: 4 })
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
    .borderRadius(16)
    .border({
      width: 1,
      color: this.getActionBorderColor(),
      radius: 16,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 10 : 0,
      color: '#2F6BDE10',
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
    .borderRadius(16)
    .border({
      width: 1,
      color: this.getActionBorderColor(),
      radius: 16,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 10 : 0,
      color: '#2F6BDE10',
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
    switch (this.theme) {
      case HeaderTheme.WHITE:
        return $r('app.color.page_background');
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
        return '#F6F9FFD9';
      default:
        return '#F6F9FFD9';
    }
  }

  private getActionBgColor(): ResourceColor {
    if (this.theme === HeaderTheme.WHITE) {
      return '#FFFFFF';
    }
    return '#FFFFFF20';
  }

  private getActionBorderColor(): ResourceColor {
    if (this.theme === HeaderTheme.WHITE) {
      return '#E4ECFA';
    }
    return '#FFFFFF2A';
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
    .backgroundColor(this.theme === HeaderTheme.WHITE ? $r('app.color.page_background') : $r('app.color.primary'))
  }
}

@Component
export struct GreetingHeader {
  @Prop userName: string = '';
  @Prop greeting: string = '';
  @Prop theme: HeaderTheme = HeaderTheme.PRIMARY;
  @Prop badgeText: string = 'SmartGuardian';
  @Prop metaText: string = '';
  onRightIconClick?: () => void;
  @BuilderParam rightContent?: () => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.badgeText)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getAccentTextColor())
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.getAccentBgColor())
            .borderRadius(999)

          Text(`你好，${this.userName || '用户'}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getTextColor())
            .margin({ top: 14 })

          if (this.greeting) {
            Text(this.greeting)
              .fontSize(14)
              .fontColor(this.getSubtitleColor())
              .lineHeight(21)
              .margin({ top: 8 })
          }

          Text(this.metaText || this.getDefaultMetaText())
            .fontSize(12)
            .fontColor(this.getMutedTextColor())
            .margin({ top: 14 })
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
      bottom: this.theme === HeaderTheme.WHITE ? 18 : 24
    })
    .linearGradient(this.getGradient())
    .borderRadius({
      bottomLeft: this.getBottomRadius(),
      bottomRight: this.getBottomRadius()
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 0 : 20,
      color: '#2F6BDE10',
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
        .fillColor(this.theme === HeaderTheme.WHITE ? $r('app.color.text_primary') : Color.White)
    }
    .width(48)
    .height(48)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.theme === HeaderTheme.WHITE ? '#FFFFFF' : '#FFFFFF20')
    .borderRadius(20)
    .border({
      width: 1,
      color: this.theme === HeaderTheme.WHITE ? '#E4ECFA' : '#FFFFFF2A',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 10 : 0,
      color: '#2F6BDE10',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      if (this.onRightIconClick) {
        this.onRightIconClick();
      }
    })
  }

  private getTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? $r('app.color.text_primary') : Color.White;
  }

  private getSubtitleColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? $r('app.color.text_secondary') : '#F7FAFFD9';
  }

  private getMutedTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? '#94A3BD' : '#E7EEFFB8';
  }

  private getAccentBgColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? '#EAF2FF' : '#FFFFFF20';
  }

  private getAccentTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? $r('app.color.primary') : '#FFFFFF';
  }

  private getGradient(): LinearGradient {
    if (this.theme === HeaderTheme.WHITE) {
      return {
        angle: 165,
        colors: [['#F7FAFF', 0], ['#F0F5FF', 0.58], ['#EDF3FF', 1]]
      };
    }

    return {
      angle: 145,
      colors: [['#5A93FF', 0], ['#4B85FF', 0.52], ['#3A72F7', 1]]
    };
  }

  private getBottomRadius(): number {
    return this.theme === HeaderTheme.WHITE ? 0 : 32;
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
