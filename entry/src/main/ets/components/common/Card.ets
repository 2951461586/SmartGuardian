/**
 * SmartGuardian - Card Component
 * Unified card component with a bright campus dashboard hierarchy
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
    borderRadius: 20,
    marginBottom: 8
  },
  [CardSize.DEFAULT]: {
    padding: 18,
    borderRadius: 24,
    marginBottom: 12
  },
  [CardSize.LARGE]: {
    padding: 22,
    borderRadius: 28,
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
  @Prop customBgColor: ResourceColor = '';
  @Prop customPadding: number = -1;
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
  private buildHeader() {
    Row() {
      Column() {
        if (this.title) {
          Text(this.title)
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Bold)
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
        Row() {
          Text(this.actionText)
            .fontSize($r('app.float.text_secondary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary'))

          Image($r('app.media.ic_arrow_right'))
            .width(14)
            .height(14)
            .objectFit(ImageFit.Contain)
            .fillColor($r('app.color.primary'))
            .margin({ left: 4 })
        }
        .padding({ left: 2, right: 2, top: 4, bottom: 4 })
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
    .margin({ bottom: this.content ? 14 : 0 })
  }

  private getPadding(): number {
    return this.customPadding >= 0 ? this.customPadding : CARD_SIZE_CONFIG[this.cardSize].padding;
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
    return '#FFFFFF';
  }

  private getBorderWidth(): number {
    return this.cardVariant === CardVariant.TRANSPARENT ? 0 : 1;
  }

  private getBorderColor(): ResourceColor {
    if (this.cardVariant === CardVariant.OUTLINED) {
      return '#DCE6FA';
    }
    if (this.cardVariant === CardVariant.TRANSPARENT) {
      return Color.Transparent;
    }
    return '#E4ECFA';
  }

  private getShadowRadius(): number {
    if (this.cardVariant === CardVariant.TRANSPARENT) {
      return 0;
    }
    return this.cardVariant === CardVariant.ELEVATED ? 18 : 12;
  }

  private getShadowColor(): ResourceColor {
    if (this.cardVariant === CardVariant.TRANSPARENT) {
      return Color.Transparent;
    }
    return this.cardVariant === CardVariant.ELEVATED ? '#2F6BDE16' : '#2F6BDE0E';
  }

  private getShadowOffsetY(): number {
    if (this.cardVariant === CardVariant.TRANSPARENT) {
      return 0;
    }
    return this.cardVariant === CardVariant.ELEVATED ? 12 : 6;
  }
}

@Component
export struct SimpleCard {
  @Prop cardVariant: CardVariant = CardVariant.DEFAULT;
  @Prop cardSize: CardSize = CardSize.DEFAULT;
  @Prop customBgColor: ResourceColor = '';
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
    .backgroundColor(this.customBgColor || '#FFFFFF')
    .borderRadius(CARD_SIZE_CONFIG[this.cardSize].borderRadius)
    .border({
      width: 1,
      color: '#E4ECFA',
      radius: CARD_SIZE_CONFIG[this.cardSize].borderRadius,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#2F6BDE0C',
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
  @Prop icon: ResourceStr = '';
  @Prop iconColor: string = '#3F7DFF';
  @Prop trend: string = '';
  @Prop trendValue: string = '';

  build() {
    Column() {
      Row() {
        if (this.icon) {
          Column() {
            Image(this.icon)
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
              .fillColor(this.iconColor)
          }
          .width(42)
          .height(42)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.getIconBgColor())
          .borderRadius(16)
        }

        Blank()

        if (this.trend && this.trendValue) {
          Text(this.trendValue)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getTrendColor())
            .backgroundColor(this.getTrendBgColor())
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(999)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(`${this.value}`)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 16 })

      Text(this.label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 6 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({
      width: 1,
      color: '#E4ECFA',
      radius: 24,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: '#2F6BDE0E',
      offsetX: 0,
      offsetY: 6
    })
    .alignItems(HorizontalAlign.Start)
  }

  private getIconBgColor(): string {
    if (this.iconColor === '#16A34A' || this.iconColor === '#34C759') {
      return '#EAF9EF';
    }
    if (this.iconColor === '#F59E0B' || this.iconColor === '#FFB74D') {
      return '#FFF4E8';
    }
    if (this.iconColor === '#8B5CF6') {
      return '#F2EEFF';
    }
    return '#EAF2FF';
  }

  private getTrendColor(): string {
    if (this.trend === 'up') {
      return '#34C759';
    }
    if (this.trend === 'down') {
      return '#FF5D73';
    }
    return '#7E8EAB';
  }

  private getTrendBgColor(): string {
    if (this.trend === 'up') {
      return '#EAF9EF';
    }
    if (this.trend === 'down') {
      return '#FFECEF';
    }
    return '#F1F5FE';
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
          .fontWeight(FontWeight.Bold)
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
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({
      width: 1,
      color: '#E4ECFA',
      radius: 24,
      style: BorderStyle.Solid
    })
  }

  @Builder
  private buildInfoItem(item: InfoItem) {
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
  @Prop iconBgColor: string = '#EAF2FF';
  @Prop iconColor: string = '#3F7DFF';
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
        .borderRadius(18)
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
          .borderRadius(18)
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
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({
      width: 1,
      color: '#E4ECFA',
      radius: 24,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#2F6BDE0C',
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
