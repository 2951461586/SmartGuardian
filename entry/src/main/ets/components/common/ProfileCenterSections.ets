import { HarmonyColor, HarmonyRadius, harmonyHeroGradient, harmonyShadowColor, harmonySoftGradient } from '../../common/HarmonyDesign';
import { getCurrentRolePalette } from '../../common/RoleTheme';

export interface ProfileActionItem {
  title: string;
  subtitle: string;
  icon: Resource;
  bgColor: string;
  iconColor: string;
  route: string;
}

export interface ProfileMetricItem {
  label: string;
  value: string;
  icon: Resource;
  color: string;
}

@Component
export struct ProfileHeroCard {
  @Prop userName: string = '';
  @Prop roleLabel: string = '';
  @Prop mobile: string = '';
  @Prop avatar: string = '';
  @Prop primaryMeta: string = '';
  @Prop secondaryMeta: string = '';
  @Prop metaChips: string[] = [];
  @Prop illustration: Resource = $r('app.media.ic_default_avatar');
  @BuilderParam actionContent: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    Column() {
      Row() {
        Image(this.avatar.length > 0 ? this.avatar : $r('app.media.ic_default_avatar'))
          .width(76)
          .height(76)
          .borderRadius(38)
          .objectFit(ImageFit.Cover)
          .border({
            width: 3,
            color: getCurrentRolePalette().border,
            radius: 38,
            style: BorderStyle.Solid
          })

        Column() {
          Row() {
          Text(this.userName.length > 0 ? this.userName : '智慧托管用户')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(HarmonyColor.textPrimary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            if (this.roleLabel.length > 0) {
              Text(this.roleLabel)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(getCurrentRolePalette().primary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(getCurrentRolePalette().light)
                .borderRadius(HarmonyRadius.pill)
                .margin({ left: 8 })
            }
          }

          if (this.mobile.length > 0) {
            Text(this.mobile)
              .fontSize(14)
              .fontColor(HarmonyColor.textSecondary)
              .margin({ top: 8 })
          }

          if (this.primaryMeta.length > 0) {
            Text(this.primaryMeta)
              .fontSize(13)
              .fontColor(getCurrentRolePalette().primary)
              .margin({ top: 10 })
          }

          if (this.secondaryMeta.length > 0) {
            Text(this.secondaryMeta)
              .fontSize(12)
              .fontColor(HarmonyColor.textSecondary)
              .margin({ top: 4 })
          }

          if (this.metaChips.length > 0) {
            Scroll() {
              Row() {
                ForEach(this.metaChips, (chip: string, index: number) => {
                  Text(chip)
                    .fontSize(12)
                    .fontColor(getCurrentRolePalette().primary)
                    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                    .backgroundColor(HarmonyColor.overlaySurface)
                    .borderRadius(HarmonyRadius.pill)
                    .margin({ right: index < this.metaChips.length - 1 ? 8 : 0 })
                }, (chip: string) => chip)
              }
            }
            .width('100%')
            .scrollBar(BarState.Off)
            .margin({ top: 10 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 14 })

        this.actionContent()
      }
      .width('100%')

      Image(this.illustration)
        .width(148)
        .height(90)
        .objectFit(ImageFit.Contain)
        .opacity(0.24)
        .alignSelf(ItemAlign.End)
        .margin({ top: -34, right: 2, bottom: -8 })
    }
    .width('100%')
    .padding({ left: 20, right: 18, top: 18, bottom: 10 })
    .linearGradient(harmonySoftGradient())
    .borderRadius(28)
    .border({
      width: 1,
      color: getCurrentRolePalette().border,
      radius: 28,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 16,
      color: getCurrentRolePalette().shadow,
      offsetX: 0,
      offsetY: 8
    })
  }
}

@Component
export struct ProfileUtilityButton {
  @Prop icon: Resource = $r('app.media.ic_settings');
  onClickAction?: () => void;

  build() {
    Column() {
      Image(this.icon)
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)
        .fillColor(getCurrentRolePalette().primary)
    }
    .width(42)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(16)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 16,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 8,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      if (this.onClickAction) {
        this.onClickAction();
      }
    })
  }
}

@Component
export struct ProfileHighlightBanner {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop actionText: string = '';
  onAction?: () => void;

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(HarmonyColor.textInverse)

        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor(HarmonyColor.textInverseStrong)
            .lineHeight(18)
            .margin({ top: 6 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.actionText.length > 0) {
        Text(this.actionText)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(getCurrentRolePalette().primaryDark)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(HarmonyColor.overlaySurface)
          .borderRadius(HarmonyRadius.pill)
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .padding({ left: 18, right: 16, top: 16, bottom: 16 })
    .linearGradient(harmonyHeroGradient())
    .borderRadius(22)
  }
}

@Component
export struct ProfileMetricStrip {
  @Prop metrics: ProfileMetricItem[] = [];

  build() {
    Row() {
      ForEach(this.metrics, (metric: ProfileMetricItem, index: number) => {
        Column() {
          Column() {
            Image(metric.icon)
              .width(22)
              .height(22)
              .objectFit(ImageFit.Contain)
              .fillColor(metric.color)
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(HarmonyColor.surfaceSubtle)
          .borderRadius(16)

          Text(metric.label)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(HarmonyColor.textPrimary)
            .margin({ top: 10 })

          Text(metric.value)
            .fontSize(14)
            .fontColor(HarmonyColor.textSecondary)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 10, bottom: 10 })

        if (index < this.metrics.length - 1) {
          Divider()
            .vertical(true)
            .color(HarmonyColor.line)
            .height(54)
        }
      }, (metric: ProfileMetricItem) => metric.label)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}

@Component
export struct ProfileActionGrid {
  @Prop rows: ProfileActionItem[][] = [];
  onSelect?: (route: string) => void;

  build() {
    Column() {
      ForEach(this.rows, (row: ProfileActionItem[], rowIndex: number) => {
        Row() {
          ForEach(row, (action: ProfileActionItem, actionIndex: number) => {
            this.buildActionItem(action)

            if (actionIndex < row.length - 1) {
              Blank().width(12)
            }
          }, (action: ProfileActionItem) => action.title)
        }
        .width('100%')
        .margin({ top: rowIndex === 0 ? 0 : 12 })
      })
    }
    .width('100%')
  }

  @Builder
  private buildActionItem(action: ProfileActionItem) {
    Row() {
      Column() {
        Image(action.icon)
          .width(21)
          .height(21)
          .objectFit(ImageFit.Contain)
          .fillColor(action.iconColor)
      }
      .width(46)
      .height(46)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(action.bgColor.length > 0 ? action.bgColor : getCurrentRolePalette().light)
      .borderRadius(16)

      Column() {
        Text(action.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(HarmonyColor.textPrimary)

        Text(action.subtitle)
          .fontSize(12)
          .fontColor(HarmonyColor.textSecondary)
          .margin({ top: 5 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })
    }
    .layoutWeight(1)
    .height(88)
    .padding({ left: 12, right: 12 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(20)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 20,
      style: BorderStyle.Solid
    })
    .onClick(() => {
      if (this.onSelect) {
        this.onSelect(action.route);
      }
    })
  }
}

@Component
export struct ProfileSettingsList {
  @Prop items: ProfileActionItem[] = [];
  onSelect?: (route: string) => void;

  build() {
    Column() {
      ForEach(this.items, (item: ProfileActionItem, index: number) => {
        Row() {
          Column() {
            Image(item.icon)
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
              .fillColor(item.iconColor)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(item.bgColor.length > 0 ? item.bgColor : HarmonyColor.surfaceSubtle)
          .borderRadius(14)

          Column() {
            Text(item.title)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(HarmonyColor.textPrimary)

            Text(item.subtitle)
              .fontSize(12)
              .fontColor(HarmonyColor.textSecondary)
              .margin({ top: 5 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })

          Image($r('app.media.ic_arrow_right'))
            .width(18)
            .height(18)
            .objectFit(ImageFit.Contain)
            .fillColor(HarmonyColor.textTertiary)
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .border({
          width: { bottom: index < this.items.length - 1 ? 1 : 0 },
          color: HarmonyColor.line,
          style: BorderStyle.Solid
        })
        .onClick(() => {
          if (this.onSelect) {
            this.onSelect(item.route);
          }
        })
      }, (item: ProfileActionItem) => item.title)
    }
    .width('100%')
  }
}
