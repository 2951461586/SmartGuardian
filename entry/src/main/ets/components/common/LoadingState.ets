import { harmonyShadowColor } from '../../common/HarmonyDesign';

export enum LoadingSize {
  SMALL = 'SMALL',
  DEFAULT = 'DEFAULT',
  LARGE = 'LARGE'
}

@Component
export struct LoadingState {
  @Prop loadingSize: LoadingSize = LoadingSize.DEFAULT;
  @Prop message: string = '';
  @Prop fullscreen: boolean = false;
  @Prop progress: number = -1;

  build() {
    if (this.fullscreen) {
      Column() {
        this.buildLoadingContent()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.page_background'))
    } else {
      Column() {
        this.buildLoadingContent()
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(24)
    }
  }

  @Builder
  private buildLoadingContent() {
    Column() {
      if (this.progress >= 0) {
        this.buildProgressMode()
      } else {
        this.buildSpinnerMode()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildSpinnerMode() {
    Column() {
      LoadingProgress()
        .color($r('app.color.primary'))
        .width(this.getSpinnerSize())
        .height(this.getSpinnerSize())
    }
    .width(this.getSpinnerShellSize())
    .height(this.getSpinnerShellSize())
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(24)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 24,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 14,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 6
    })

    if (this.message) {
      Text(this.message)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 14 })
    }
  }

  @Builder
  private buildProgressMode() {
    Column() {
      Progress({
        value: this.progress >= 0 ? this.progress : 0,
        total: 100,
        type: ProgressType.Linear
      })
        .width(220)
        .color($r('app.color.primary'))

      Text(`${this.progress >= 0 ? this.progress : 0}%`)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      if (this.message) {
        Text(this.message)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
    }
    .alignItems(HorizontalAlign.Center)
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(24)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 24,
      style: BorderStyle.Solid
    })
  }

  private getSpinnerSize(): number {
    if (this.loadingSize === LoadingSize.SMALL) {
      return 24;
    }
    if (this.loadingSize === LoadingSize.LARGE) {
      return 56;
    }
    return 40;
  }

  private getSpinnerShellSize(): number {
    if (this.loadingSize === LoadingSize.SMALL) {
      return 72;
    }
    if (this.loadingSize === LoadingSize.LARGE) {
      return 104;
    }
    return 88;
  }
}

@Component
export struct LoadingSpinner {
  @Prop spinnerColor: ResourceColor = $r('app.color.primary');
  @Prop spinnerSize: number = 40;

  build() {
    LoadingProgress()
      .color(this.spinnerColor)
      .width(this.spinnerSize)
      .height(this.spinnerSize)
  }
}

@Component
export struct SkeletonLoading {
  @Prop rows: number = 3;
  @Prop showAvatar: boolean = false;
  @Prop showTitle: boolean = true;

  build() {
    Column() {
      if (this.showTitle) {
        Row()
          .width('40%')
          .height(20)
          .backgroundColor($r('app.color.card_background_soft'))
          .borderRadius(4)
          .margin({ bottom: 16 })
      }

      ForEach(Array.from({ length: this.rows }), (_: Record<string, number>, index: number) => {
        Row() {
          if (this.showAvatar) {
            Column()
              .width(48)
              .height(48)
              .backgroundColor($r('app.color.card_background_soft'))
              .borderRadius(24)
              .margin({ right: 12 })
          }

          Column() {
            Row()
              .width('100%')
              .height(16)
              .backgroundColor($r('app.color.card_background_soft'))
              .borderRadius(4)

            Row()
              .width('60%')
              .height(16)
              .backgroundColor($r('app.color.card_background_soft'))
              .borderRadius(4)
              .margin({ top: 8 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
      })
    }
    .width('100%')
    .padding(16)
  }
}

@Component
export struct CardSkeleton {
  build() {
    Column() {
      Row() {
        Column()
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.card_background_soft'))
          .borderRadius(8)

        Column() {
          Row()
            .width(100)
            .height(16)
            .backgroundColor($r('app.color.card_background_soft'))
            .borderRadius(4)

          Row()
            .width(60)
            .height(12)
            .backgroundColor($r('app.color.card_background_soft'))
            .borderRadius(4)
            .margin({ top: 6 })
        }
        .margin({ left: 12 })
        .layoutWeight(1)
      }
      .width('100%')

      Column() {
        Row()
          .width('100%')
          .height(14)
          .backgroundColor($r('app.color.card_background_muted'))
          .borderRadius(4)

        Row()
          .width('80%')
          .height(14)
          .backgroundColor($r('app.color.card_background_muted'))
          .borderRadius(4)
          .margin({ top: 8 })
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius($r('app.float.card_border_radius'))
  }
}
