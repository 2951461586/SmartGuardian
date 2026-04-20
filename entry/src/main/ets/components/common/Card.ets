/**
 * SmartGuardian - Card Component
 * Unified card component with consistent styling
 * 
 * @description 统一卡片组件，提供一致的卡片样式
 */

/**
 * Card Variant
 */
export enum CardVariant {
  /** 默认白色背景 */
  DEFAULT = 'DEFAULT',
  /** 凸起效果（带阴影） */
  ELEVATED = 'ELEVATED',
  /** 轮廓边框 */
  OUTLINED = 'OUTLINED',
  /** 无背景透明 */
  TRANSPARENT = 'TRANSPARENT'
}

/**
 * Card Size
 */
export enum CardSize {
  /** 小尺寸 */
  SMALL = 'SMALL',
  /** 默认尺寸 */
  DEFAULT = 'DEFAULT',
  /** 大尺寸 */
  LARGE = 'LARGE'
}

/**
 * Card Padding Config
 */
interface CardPaddingConfig {
  padding: number;
  borderRadius: number;
  marginBottom: number;
}

const CARD_SIZE_CONFIG: Record<CardSize, CardPaddingConfig> = {
  [CardSize.SMALL]: {
    padding: 12,
    borderRadius: 8,
    marginBottom: 8
  },
  [CardSize.DEFAULT]: {
    padding: 16,
    borderRadius: 12,
    marginBottom: 12
  },
  [CardSize.LARGE]: {
    padding: 20,
    borderRadius: 16,
    marginBottom: 16
  }
};

/**
 * Card Component
 * @description 通用卡片组件
 */
@Component
export struct Card {
  /** 卡片变体 */
  @Prop cardVariant: CardVariant = CardVariant.DEFAULT;
  /** 卡片尺寸 */
  @Prop cardSize: CardSize = CardSize.DEFAULT;
  /** 标题 */
  @Prop title: string = '';
  /** 副标题 */
  @Prop subtitle: string = '';
  /** 操作按钮文本 */
  @Prop actionText: string = '';
  /** 是否显示箭头 */
  @Prop showArrow: boolean = false;
  /** 是否可点击 */
  @Prop clickable: boolean = false;
  /** 自定义背景色 */
  @Prop customBgColor?: ResourceColor;
  /** 自定义内边距 */
  @Prop customPadding?: number;
  /** 点击事件 */
  onCardClick?: () => void;
  /** 操作按钮点击事件 */
  onAction?: () => void;
  /** 卡片内容 */
  @BuilderParam content?: () => void = this.defaultContent;
  /** 头部右侧自定义内容 */
  @BuilderParam headerRight?: () => void = this.defaultHeaderRight;

  @Builder
  defaultContent() {}

  @Builder
  defaultHeaderRight() {}

  build() {
    Column() {
      // 卡片头部
      if (this.title || this.headerRight) {
        this.buildHeader()
      }

      // 卡片内容
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
      offsetX: this.getShadowOffsetX(),
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
      // 标题区域
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
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧区域
      if (this.headerRight) {
        this.headerRight()
      } else if (this.actionText) {
        Text(this.actionText)
          .fontSize($r('app.float.text_secondary_size'))
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
    .margin({ bottom: this.content ? $r('app.float.card_content_margin') : 0 })
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
    return this.cardVariant === CardVariant.OUTLINED ? 1 : 0;
  }

  private getBorderColor(): ResourceColor {
    return this.cardVariant === CardVariant.OUTLINED ? '#E5E7EB' : Color.Transparent;
  }

  private getShadowRadius(): number {
    return this.cardVariant === CardVariant.ELEVATED ? 8 : 0;
  }

  private getShadowColor(): ResourceColor {
    return this.cardVariant === CardVariant.ELEVATED ? '#1A000000' : Color.Transparent;
  }

  private getShadowOffsetX(): number {
    return 0;
  }

  private getShadowOffsetY(): number {
    return this.cardVariant === CardVariant.ELEVATED ? 2 : 0;
  }
}

/**
 * Simple Card
 * @description 简化版卡片（仅内容区）
 */
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
    .margin({ bottom: CARD_SIZE_CONFIG[this.cardSize].marginBottom })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }
}

/**
 * Stat Card
 * @description 统计数据卡片
 */
@Component
export struct StatCard {
  @Prop value: string | number = '';
  @Prop label: string = '';
  @Prop icon?: Resource;
  @Prop iconColor: string = '#3B82F6';
  @Prop trend?: string;
  @Prop trendValue?: string;

  build() {
    Column() {
      // 图标
      if (this.icon) {
        Image(this.icon)
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .fillColor(this.iconColor)
          .margin({ bottom: 8 })
      }

      // 数值
      Row() {
        Text(`${this.value}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        // 趋势
        if (this.trend && this.trendValue) {
          Text(this.trendValue)
            .fontSize(12)
            .fontColor(this.getTrendColor())
            .margin({ left: 4 })
        }
      }

      // 标签
      Text(this.label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  private getTrendColor(): string {
    if (this.trend === 'up') {
      return '#4CAF50';
    }
    if (this.trend === 'down') {
      return '#F44336';
    }
    return '#9E9E9E';
  }
}

/**
 * Info Item Interface
 */
export interface InfoItem {
  label: string;
  value: string;
  valueColor?: ResourceColor;
}

/**
 * Info Card
 * @description 信息展示卡片（标签:值对）
 */
@Component
export struct InfoCard {
  @Prop title: string = '';
  @Prop items: InfoItem[] = [];
  @Prop columns: number = 2;

  build() {
    Column() {
      // 标题
      if (this.title) {
        Text(this.title)
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: $r('app.float.card_content_margin') })
      }

      // 按行分组显示
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
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
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
        .margin({ top: 4 })
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

/**
 * Action Card
 * @description 操作卡片（带图标和操作）
 */
@Component
export struct ActionCard {
  @Prop icon: Resource = $r('app.media.ic_message');
  @Prop cardTitle: string = '';
  @Prop description: string = '';
  @Prop buttonText: string = '';
  @Prop iconBgColor: string = '#E3F2FD';
  @Prop iconColor: string = '#2196F3';
  onCardClick?: () => void;
  onAction?: () => void;

  build() {
    Column() {
      Row() {
        // 图标
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
        .borderRadius(12)
        .margin({ right: 12 })

        // 文本
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
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 操作按钮
      if (this.buttonText) {
        Button(this.buttonText)
          .width('100%')
          .height(40)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(8)
          .margin({ top: 16 })
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
  }
}
