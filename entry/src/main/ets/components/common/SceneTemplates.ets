import { PageScaffold, ResponsiveSplitPanel } from './PageScaffold';
import { FormSurface } from './FormFields';

@Component
export struct FormPageTemplate {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop illustration: ResourceStr = '';
  @Prop maxWidth: number = 620;
  @BuilderParam content: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    PageScaffold({
      scrollable: true,
      enableWideContent: true,
      topPadding: 28,
      bottomPadding: 28,
      content: () => { this.buildBody() }
    })
  }

  @Builder
  private buildBody() {
    Column() {
      FormSurface({
        title: this.title,
        subtitle: this.subtitle,
        illustration: this.illustration,
        maxWidth: this.maxWidth,
        content: () => { this.buildFormContent() }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildFormContent() {
    this.content()
  }
}

@Component
export struct DashboardPageTemplate {
  @Prop scrollable: boolean = false;
  @Prop enableWideContent: boolean = true;
  @Prop topSpacing: number = 12;
  @Prop bottomSpacing: number = 24;
  @BuilderParam header: () => void = this.emptyBuilder;
  @BuilderParam hero: () => void = this.emptyBuilder;
  @BuilderParam primary: () => void = this.emptyBuilder;
  @BuilderParam secondary: () => void = this.emptyBuilder;
  @BuilderParam tail: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    PageScaffold({
      scrollable: this.scrollable,
      enableWideContent: this.enableWideContent,
      header: () => { this.buildHeaderSlot() },
      content: () => { this.buildBody() }
    })
  }

  @Builder
  private buildBody() {
    Column() {
      this.buildHeroSlot()

      ResponsiveSplitPanel({
        primary: () => { this.buildPrimarySlot() },
        secondary: () => { this.buildSecondarySlot() }
      })

      this.buildTailSlot()
    }
    .width('100%')
    .padding({ top: this.topSpacing, bottom: this.bottomSpacing })
  }

  @Builder
  private buildHeaderSlot() {
    this.header()
  }

  @Builder
  private buildHeroSlot() {
    this.hero()
  }

  @Builder
  private buildPrimarySlot() {
    this.primary()
  }

  @Builder
  private buildSecondarySlot() {
    this.secondary()
  }

  @Builder
  private buildTailSlot() {
    this.tail()
  }
}

@Component
export struct WorkbenchListPageTemplate {
  @Prop scrollable: boolean = false;
  @Prop enableWideContent: boolean = true;
  @Prop topSpacing: number = 12;
  @Prop bottomSpacing: number = 20;
  @BuilderParam header: () => void = this.emptyBuilder;
  @BuilderParam overview: () => void = this.emptyBuilder;
  @BuilderParam controls: () => void = this.emptyBuilder;
  @BuilderParam content: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    PageScaffold({
      scrollable: this.scrollable,
      enableWideContent: this.enableWideContent,
      header: () => { this.buildHeaderSlot() },
      content: () => { this.buildBody() }
    })
  }

  @Builder
  private buildBody() {
    Column() {
      this.buildOverviewSlot()
      this.buildControlsSlot()
      this.buildContentSlot()
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.topSpacing, bottom: this.bottomSpacing })
  }

  @Builder
  private buildHeaderSlot() {
    this.header()
  }

  @Builder
  private buildOverviewSlot() {
    this.overview()
  }

  @Builder
  private buildControlsSlot() {
    this.controls()
  }

  @Builder
  private buildContentSlot() {
    this.content()
  }
}

@Component
export struct ProfileWorkspaceTemplate {
  @Prop enableWideContent: boolean = true;
  @Prop topSpacing: number = 14;
  @Prop bottomSpacing: number = 24;
  @BuilderParam hero: () => void = this.emptyBuilder;
  @BuilderParam summary: () => void = this.emptyBuilder;
  @BuilderParam actions: () => void = this.emptyBuilder;
  @BuilderParam support: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    PageScaffold({
      scrollable: true,
      enableWideContent: this.enableWideContent,
      topPadding: 0,
      bottomPadding: this.bottomSpacing,
      content: () => { this.buildBody() }
    })
  }

  @Builder
  private buildBody() {
    Column() {
      this.buildHeroSlot()

      ResponsiveSplitPanel({
        primary: () => { this.buildSummarySlot() },
        secondary: () => { this.buildActionsSlot() }
      })
        .margin({ top: this.topSpacing, bottom: 14 })

      this.buildSupportSlot()
    }
    .width('100%')
  }

  @Builder
  private buildHeroSlot() {
    this.hero()
  }

  @Builder
  private buildSummarySlot() {
    this.summary()
  }

  @Builder
  private buildActionsSlot() {
    this.actions()
  }

  @Builder
  private buildSupportSlot() {
    this.support()
  }
}
