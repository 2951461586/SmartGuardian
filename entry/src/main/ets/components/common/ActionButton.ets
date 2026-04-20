/**
 * SmartGuardian - ActionButton Component
 * 可复用的操作按钮组件
 * 
 * @description 带图标和标签的操作按钮，用于快捷操作区域
 * @example
 * ActionButton({
 *   label: '请假',
 *   icon: $r('app.media.ic_leave'),
 *   bgColor: '#E3F2FD',
 *   iconColor: '#2196F3',
 *   onClick: () => { ... }
 * })
 */

@Component
export struct ActionButton {
  /** 按钮标签文字 */
  @Prop label: string = '';
  
  /** 图标资源 */
  @Prop icon: Resource | string | PixelMap = '';
  
  /** 背景颜色 */
  @Prop bgColor: string = '#E3F2FD';
  
  /** 图标颜色 */
  @Prop iconColor: string = '#2196F3';
  
  /** 点击回调 */
  onButtonClick?: () => void;

  build() {
    Column() {
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
      .backgroundColor(this.bgColor)
      .borderRadius(24)

      Text(this.label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .padding({ top: 8, bottom: 8 })
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
  }
}
