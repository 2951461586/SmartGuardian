/**
 * SmartGuardian - Icon Action Button
 * Reusable icon capsule with optional badge count
 */

@Component
export struct IconActionButton {
  @Prop icon: Resource | string | PixelMap = '';
  @Prop iconColor: ResourceColor = '#1F2D4D';
  @Prop boxBgColor: ResourceColor = '#FFFFFF';
  @Prop boxBorderColor: ResourceColor = '#E4ECFA';
  @Prop badgeCount: number = 0;
  @Prop badgeColor: ResourceColor = $r('app.color.error');
  @Prop boxSize: number = 46;
  @Prop iconSize: number = 22;
  onButtonClick?: () => void;

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Image(this.icon)
          .width(this.iconSize)
          .height(this.iconSize)
          .objectFit(ImageFit.Contain)
          .fillColor(this.iconColor)
      }
      .width(this.boxSize)
      .height(this.boxSize)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.boxBgColor)
      .borderRadius(20)
      .border({
        width: 1,
        color: this.boxBorderColor,
        radius: 20,
        style: BorderStyle.Solid
      })
      .shadow({
        radius: 10,
        color: '#2F6BDE0C',
        offsetX: 0,
        offsetY: 4
      })

      if (this.badgeCount > 0) {
        Text(this.badgeCount > 99 ? '99+' : `${this.badgeCount}`)
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor(this.badgeColor)
          .borderRadius(9)
          .padding({ left: 5, right: 5, top: 1, bottom: 1 })
      }
    }
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
  }
}
