/**
 * SmartGuardian - 閫氱敤鍥炬爣缁勪欢
 * 浣跨敤绯荤粺Symbol瀛椾綋鏇夸唬鍥剧墖鍥炬爣锛岃В鍐冲浘鏍囪祫婧愮己澶遍棶棰? */

@Component
export struct SymbolIcon {
  @Prop icon: string = 'home';      // 鍥炬爣鍚嶇О
  @Prop iconSize: number = 24;      // 鍥炬爣澶у皬
  @Prop color: ResourceColor = '#172A2A';  // 鍥炬爣棰滆壊
  @Prop fontWeight: number = 400;   // 瀛楅噸

  build() {
    Text(this.getIconChar())
      .fontSize(this.iconSize)
      .fontColor(this.color)
      .fontWeight(this.fontWeight)
      .fontFamily('HarmonyOS Sans')
  }

  private getIconChar(): string {
    const iconMap: Record<string, string> = {
      // 瀵艰埅鍥炬爣
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

      // 琛ㄥ崟鍥炬爣
      'user': '\u{1F464}',
      'lock': '\u{1F512}',
      'eye_open': '\u{1F441}',
      'eye_close': '\u{1F648}',

      // 鎿嶄綔鍥炬爣
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

      // 鏀粯鐩稿叧
      'alipay': '\u{1F4B3}',
      'wechat': '\u{1F4F1}',

      // 鐘舵€佸浘鏍?      'success': '\u{2705}',
      'error': '\u{274C}',
      'info': '\u{2139}\u{FE0F}',
      'pending': '\u{23F3}',
      'done': '\u{2705}',

      // 鎬у埆
      'male': '\u{2640}',
      'female': '\u{2642}',

      // 榛樿澶村儚
      'default_avatar': '\u{1F464}'
    };

    return iconMap[this.icon] || '\u{25CF}';
  }
}

/**
 * 甯﹁儗鏅殑鍦嗗舰鍥炬爣缁勪欢
 */
@Component
export struct SymbolIconBg {
  @Prop icon: string = 'home';
  @Prop containerSize: number = 40;
  @Prop bgColor: ResourceColor = '#EEF4FA';
  @Prop iconColor: ResourceColor = '#526F95';
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
 * 鍥炬爣+鏂囧瓧鐨勭粍鍚堢粍浠? */
@Component
export struct IconText {
  @Prop icon: string = 'home';
  @Prop text: string = '';
  @Prop iconSize: number = 16;
  @Prop textSize: number = 14;
  @Prop iconColor: ResourceColor = '#526F95';
  @Prop textColor: ResourceColor = '#172A2A';
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
