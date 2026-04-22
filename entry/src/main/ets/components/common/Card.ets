/**
 * SmartGuardian - Card Component
 * Unified card component with consistent styling
 */

export enum CardVariant {
  DEFAULT = 'DEFAULT',
  ELEVATED = 'ELEVATED',
  OUTLINED = 'OUTLINED',
  TRANSPARENT = 'TRANSPARENT'
}

export enum CardSize {
  SMALL = 'SMALL',
  DEFAULT = 'DEFAULT',
  LARGE = 'LARGE'
}

interface CardPaddingConfig {
  padding: number;
  borderRadius: number;
  marginBottom: number;
}

const CARD_SIZE_CONFIG: Record<CardSize, CardPaddingConfig> = {
  [CardSize.SMALL]: {
    padding: 14,
    borderRadius: 16,
    marginBottom: 8
  },
  [CardSize.DEFAULT]: {
    padding: 18,
    borderRadius: 20,
    marginBottom: 12
  },
  [CardSize.LARGE]: {
    padding: 22,
    borderRadius: 24,
    marginBottom: 16
  }
};

@Component
export struct Card {
  @Prop cardVariant: CardVariant = CardVariant.DEFAULT;
  @Prop cardSize: CardSize = CardSize.DEFAULT;
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop actionText: string = '';
  @Prop showArrow: boolean = false;
  @Prop clickable: boolean = false;
  @Prop customBgColor?: ResourceColor;
  @Prop customPadding?: number;
  onCardClick?: () => void;
  onAction?: () => void;
  @BuilderParam content?: () => void = this.defaultContent;
  @BuilderParam headerRight?: () => void = this.defaultHeaderRight;

  @Builder
  defaultContent() {}

  @Builder
  defaultHeaderRight() {}

  build() {
    Column() {
      if (this.title || this.headerRight) {
        this.buildHeader()
      }

      if (this.content) {
        this.content()
      }
    }
    .width('100%')
    .padding(this.getPadding())
    .backgroundColor(this.getBgColor())
    .borderRadius(this.getBorderRadius())
    .margin({ bottom: this.getMarginBottom() })
    .border({
      width: this.getBorderWidth(),
      color: this.getBorderColor(),
      radius: this.getBorderRadius(),
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.getShadowRadius(),
      color: this.getShadowColor(),
      offsetX: 0,
      offsetY: this.getShadowOffsetY()
    })
    .onClick(() => {
      if (this.clickable && this.onCardClick) {
        this.onCardClick();
      }
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Column() {
        if (this.title) {
          Text(this.title)
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }

        if (this.subtitle) {
          Text(this.subtitle)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(20)
            .margin({ top: 6 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.headerRight) {
        this.headerRight()
      } else if (this.actionText) {
        Text(this.actionText)
          .fontSize($r('app.float.text_secondary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      } else if (this.showArrow) {
        Image($r('app.media.ic_arrow_right'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .fillColor($r('app.color.text_tertiary'))
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: this.content ? 12 : 0 })
  }

  private getPadding(): number {
    return this.customPadding ?? CARD_SIZE_CONFIG[this.cardSize].padding;
  }

  private getBorderRadius(): number {
    return CARD_SIZE_CONFIG[this.cardSize].borderRadius;
  }

  private getMarginBottom(): number {
    return CARD_SIZE_CONFIG[this.cardSize].marginBottom;
  }

  private getBgColor(): ResourceColor {
    if (this.customBgColor) {
      return this.customBgColor;
    }
    if (this.cardVariant === CardVariant.TRANSPARENT) {
      return Color.Transparent;
    }
    return Color.White;
  }

  private getBorderWidth(): number {
    return this.cardVariant === CardVariant.TRANSPARENT ? 0 : 1;
  }

  private getBorderColor(): ResourceColor {
    if (this.cardVariant === CardVariant.OUTLINED) {
      return '#D9E3F1';
    }
    if (this.cardVariant === CardVariant.TRANSPARENT) {
      return Color.Transparent;
    }
    return '#EEF3F8';
  }

  private getShadowRadius(): number {
    return this.cardVariant === CardVariant.TRANSPARENT ? 0 : 14;
  }

  private getShadowColor(): ResourceColor {
    return this.cardVariant === CardVariant.TRANSPARENT ? Color.Transparent : '#10172F12';
  }

  private getShadowOffsetY(): number {
    return this.cardVariant === CardVariant.TRANSPARENT ? 0 : 6;
  }
}

@Component
export struct SimpleCard {
  @Prop cardVariant: CardVariant = CardVariant.DEFAULT;
  @Prop cardSize: CardSize = CardSize.DEFAULT;
  @Prop customBgColor?: ResourceColor;
  onCardClick?: () => void;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {}

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(CARD_SIZE_CONFIG[this.cardSize].padding)
    .backgroundColor(this.customBgColor ?? Color.White)
    .borderRadius(CARD_SIZE_CONFIG[this.cardSize].borderRadius)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: CARD_SIZE_CONFIG[this.cardSize].borderRadius,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: CARD_SIZE_CONFIG[this.cardSize].marginBottom })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }
}

@Component
export struct StatCard {
  @Prop value: string | number = '';
  @Prop label: string = '';
  @Prop icon?: Resource;
  @Prop iconColor: string = '#1F5EFF';
  @Prop trend?: string;
  @Prop trendValue?: string;

  build() {
    Column() {
      if (this.icon) {
        Column() {
          Image(this.icon)
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .fillColor(this.iconColor)
        }
        .width(38)
        .height(38)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F4F8FD')
        .borderRadius(14)
        .margin({ bottom: 12 })
      }

      Row() {
        Text(`${this.value}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        if (this.trend && this.trendValue) {
          Text(this.trendValue)
            .fontSize(12)
            .fontColor(this.getTrendColor())
            .margin({ left: 6, top: 8 })
        }
      }

      Text(this.label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 6 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(18)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 18,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 4
    })
    .alignItems(HorizontalAlign.Start)
  }

  private getTrendColor(): string {
    if (this.trend === 'up') {
      return '#16A34A';
    }
    if (this.trend === 'down') {
      return '#E5484D';
    }
    return '#7A879A';
  }
}

export interface InfoItem {
  label: string;
  value: string;
  valueColor?: ResourceColor;
}

@Component
export struct InfoCard {
  @Prop title: string = '';
  @Prop items: InfoItem[] = [];
  @Prop columns: number = 2;

  build() {
    Column() {
      if (this.title) {
        Text(this.title)
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: 12 })
      }

      ForEach(this.getRows(), (row: InfoItem[], rowIndex: number) => {
        Row() {
          ForEach(row, (item: InfoItem) => {
            this.buildInfoItem(item)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: rowIndex === 0 ? 0 : 12 })
      })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
  }

  @Builder
  buildInfoItem(item: InfoItem) {
    Column() {
      Text(item.label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))

      Text(item.value)
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor(item.valueColor ?? $r('app.color.text_primary'))
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  private getRows(): InfoItem[][] {
    const rows: InfoItem[][] = [];
    for (let i = 0; i < this.items.length; i += this.columns) {
      rows.push(this.items.slice(i, i + this.columns));
    }
    return rows;
  }
}

@Component
export struct ActionCard {
  @Prop icon: Resource = $r('app.media.ic_message');
  @Prop cardTitle: string = '';
  @Prop description: string = '';
  @Prop buttonText: string = '';
  @Prop iconBgColor: string = '#EAF1FF';
  @Prop iconColor: string = '#1F5EFF';
  onCardClick?: () => void;
  onAction?: () => void;

  build() {
    Column() {
      Row() {
        Column() {
          Image(this.icon)
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain)
            .fillColor(this.iconColor)
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.iconBgColor)
        .borderRadius(16)
        .margin({ right: 12 })

        Column() {
          Text(this.cardTitle)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          if (this.description) {
            Text(this.description)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      if (this.buttonText) {
        Button(this.buttonText)
          .width('100%')
          .height(42)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(14)
          .margin({ top: 16 })
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }
}
