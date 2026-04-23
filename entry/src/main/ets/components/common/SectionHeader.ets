/**
 * SmartGuardian - Section Header Component
 * Unified header for section titles and actions
 */

@Component
export struct SectionHeader {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop actionText: string = '';
  @Prop showDivider: boolean = false;
  @Prop accentColor: ResourceColor = $r('app.color.primary');
  onAction?: () => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.title)
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .lineHeight(19)
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.actionText) {
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
        }
      }
      .width('100%')

      if (this.showDivider) {
        Divider()
          .color($r('app.color.divider'))
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .margin({ bottom: 12 })
  }
}
