/**
 * SmartGuardian - 通用图标组件
 * 使用系统Symbol字体替代图片图标，解决图标资源缺失问题
 */

@Component
export struct SymbolIcon {
  @Prop icon: string = 'home';      // 图标名称
  @Prop iconSize: number = 24;      // 图标大小
  @Prop color: ResourceColor = '#000000';  // 图标颜色
  @Prop fontWeight: number = 400;   // 字重

  build() {
    Text(this.getIconChar())
      .fontSize(this.iconSize)
      .fontColor(this.color)
      .fontWeight(this.fontWeight)
      .fontFamily('HarmonyOS Sans')
  }

  private getIconChar(): string {
    const iconMap: Record<string, string> = {
      // 导航图标
      'home': '\u{1F3E0}',
      'order': '\u{1F4CB}',
      'message': '\u{1F4AC}',
      'profile': '\u{1F464}',
      'attendance': '\u{1F4C5}',
      'homework': '\u{1F4DA}',
      'report': '\u{1F4CA}',

      // 功能图标
      'notification': '\u{1F514}',
      'settings': '\u{2699}',
      'warning': '\u{26A0}',
      'money': '\u{1F4B0}',
      'empty': '\u{1F4DD}',
      'logo': '\u{1F393}',

      // 表单图标
      'user': '\u{1F464}',
      'lock': '\u{1F512}',
      'eye_open': '\u{1F441}',
      'eye_close': '\u{1F648}',

      // 操作图标
      'leave': '\u{1F4C4}',
      'qrcode': '\u{1F4F7}',
      'calendar': '\u{1F4C5}',
      'child': '\u{1F476}',
      'help': '\u{2753}',
      'about': '\u{2139}',
      'arrow_right': '\u{203A}',
      'arrow_left': '\u{2039}',
      'arrow_up': '\u{25B2}',
      'arrow_down': '\u{25BC}',
      'add': '\u{2795}',
      'close': '\u{2715}',
      'check': '\u{2713}',
      'search': '\u{1F50D}',
      'filter': '\u{1F50D}',
      'edit': '\u{270F}',
      'delete': '\u{1F5D1}',
      'refresh': '\u{1F504}',
      'more': '\u{2026}',
      'phone': '\u{1F4DE}',
      'email': '\u{1F4E7}',
      'location': '\u{1F4CD}',
      'time': '\u{23F0}',
      'star': '\u{2B50}',
      'heart': '\u{2764}',
      'bell': '\u{1F514}',

      // 支付相关
      'alipay': '\u{1F4B3}',
      'wechat': '\u{1F4F1}',

      // 状态图标
      'success': '\u{2705}',
      'error': '\u{274C}',
      'info': '\u{2139}\u{FE0F}',
      'pending': '\u{23F3}',
      'done': '\u{2705}',

      // 性别
      'male': '\u{2640}',
      'female': '\u{2642}',

      // 默认头像
      'default_avatar': '\u{1F464}'
    };

    return iconMap[this.icon] || '\u{25CF}';
  }
}

/**
 * 带背景的圆形图标组件
 */
@Component
export struct SymbolIconBg {
  @Prop icon: string = 'home';
  @Prop containerSize: number = 40;
  @Prop bgColor: ResourceColor = '#E3F2FD';
  @Prop iconColor: ResourceColor = '#007AFF';
  @Prop iconSize: number = 20;

  build() {
    Column() {
      SymbolIcon({
        icon: this.icon,
        iconSize: this.iconSize,
        color: this.iconColor
      })
    }
    .width(this.containerSize)
    .height(this.containerSize)
    .backgroundColor(this.bgColor)
    .borderRadius(this.containerSize / 2)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 图标+文字的组合组件
 */
@Component
export struct IconText {
  @Prop icon: string = 'home';
  @Prop text: string = '';
  @Prop iconSize: number = 16;
  @Prop textSize: number = 14;
  @Prop iconColor: ResourceColor = '#007AFF';
  @Prop textColor: ResourceColor = '#1C1C1E';
  @Prop gap: number = 4;

  build() {
    Row({ space: this.gap }) {
      SymbolIcon({
        icon: this.icon,
        iconSize: this.iconSize,
        color: this.iconColor
      })

      Text(this.text)
        .fontSize(this.textSize)
        .fontColor(this.textColor)
    }
  }
}