/**
 * SmartGuardian - Page Header Component
 * Unified page header with title and actions
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
  @Prop rightIcon?: Resource;
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
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(this.getAccentBgColor())
            .borderRadius(999)

          Text(`Hello, ${this.userName || 'User'}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getTextColor())
            .margin({ top: 14 })

          if (this.greeting) {
            Text(this.greeting)
              .fontSize(14)
              .fontColor(this.getSubtitleColor())
              .lineHeight(20)
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
    .padding({ left: 20, right: 20, top: Number($r('app.float.status_bar_height')) + 20, bottom: 24 })
    .linearGradient(this.getGradient())
    .borderRadius({ bottomLeft: 28, bottomRight: 28 })
    .shadow({
      radius: 14,
      color: '#10203A14',
      offsetX: 0,
      offsetY: 8
    })
  }

  private getTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? $r('app.color.text_primary') : Color.White;
  }

  private getSubtitleColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? $r('app.color.text_secondary') : '#FFFFFFCC';
  }

  private getMutedTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? '#6A768A' : '#FFFFFFA6';
  }

  private getAccentBgColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? '#FFFFFFD9' : '#FFFFFF1F';
  }

  private getAccentTextColor(): ResourceColor {
    return this.theme === HeaderTheme.WHITE ? '#2152CC' : Color.White;
  }

  private getGradient(): LinearGradient {
    if (this.theme === HeaderTheme.WHITE) {
      return {
        angle: 145,
        colors: [['#F7FBFF', 0], ['#EEF5FF', 0.58], ['#F8FAFC', 1]]
      };
    }

    return {
      angle: 145,
      colors: [['#2C68FF', 0], ['#1749C7', 0.62], ['#0F2359', 1]]
    };
  }

  @Builder
  private buildDefaultAction() {
    Column() {
      Image($r('app.media.ic_notification'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .fillColor(this.theme === HeaderTheme.WHITE ? '#12305F' : Color.White)
    }
    .width(46)
    .height(46)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.theme === HeaderTheme.WHITE ? '#FFFFFF' : '#FFFFFF1A')
    .borderRadius(18)
    .border({
      width: 1,
      color: this.theme === HeaderTheme.WHITE ? '#E5EEF9' : '#FFFFFF29',
      radius: 18,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.theme === HeaderTheme.WHITE ? 8 : 0,
      color: '#10203A12',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      if (this.onRightIconClick) {
        this.onRightIconClick();
      }
    })
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
