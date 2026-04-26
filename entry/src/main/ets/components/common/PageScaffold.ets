import {
  LayoutBreakpoints,
  resolvePageMaxWidth,
  resolvePageSidePadding,
  shouldUseSplitLayout
} from '../../common/AdaptiveLayout';
import { HarmonyColor } from '../../common/HarmonyDesign';

@Component
export struct PageScaffold {
  @Prop scrollable: boolean = true;
  @Prop enableWideContent: boolean = false;
  @Prop topPadding: number = 12;
  @Prop bottomPadding: number = 24;
  @Prop showFooterDivider: boolean = false;
  @State privateWidth: number = LayoutBreakpoints.MEDIUM;
  @BuilderParam header: () => void = this.emptyBuilder;
  @BuilderParam content: () => void = this.emptyBuilder;
  @BuilderParam footer: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    Column() {
      if (this.header) {
        this.header()
      }

      if (this.scrollable) {
        Scroll() {
          this.buildContentFrame()
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else {
        Column() {
          this.buildContentFrame()
        }
        .width('100%')
          .layoutWeight(1)
      }

      if (this.footer) {
        if (this.showFooterDivider) {
          Divider()
            .color($r('app.color.divider'))
        }
        this.footer()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .onAreaChange((_: Area, area: Area) => {
      const nextWidth = Number(area.width);
      if (nextWidth > 0) {
        this.privateWidth = nextWidth;
      }
    })
  }

  @Builder
  private buildContentFrame() {
    Column() {
      if (this.content) {
        this.content()
      }
    }
    .width('100%')
    .constraintSize({ maxWidth: resolvePageMaxWidth(this.privateWidth, this.enableWideContent) })
    .alignSelf(ItemAlign.Center)
    .padding({
      left: resolvePageSidePadding(this.privateWidth),
      right: resolvePageSidePadding(this.privateWidth),
      top: this.topPadding,
      bottom: this.bottomPadding
    })
  }
}

@Component
export struct ResponsiveSplitPanel {
  @Prop gap: number = 14;
  @Prop splitThreshold: number = LayoutBreakpoints.MEDIUM;
  @State privateWidth: number = LayoutBreakpoints.MEDIUM;
  @BuilderParam primary?: () => void = this.emptyBuilder;
  @BuilderParam secondary?: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    Column() {
      if (shouldUseSplitLayout(this.privateWidth) && this.privateWidth >= this.splitThreshold) {
        Row() {
          Column() {
            if (this.primary) {
              this.primary()
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Blank().width(this.gap)

          Column() {
            if (this.secondary) {
              this.secondary()
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      } else {
        Column() {
          Column() {
            if (this.primary) {
              this.primary()
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column() {
            if (this.secondary) {
              this.secondary()
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: this.gap })
        }
        .width('100%')
      }
    }
    .width('100%')
    .onAreaChange((_: Area, area: Area) => {
      const nextWidth = Number(area.width);
      if (nextWidth > 0) {
        this.privateWidth = nextWidth;
      }
    })
  }
}
