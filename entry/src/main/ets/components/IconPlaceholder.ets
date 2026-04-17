/**
 * SmartGuardian - 图标占位符组件
 * 当图标资源缺失时使用此占位符，避免页面渲染失败
 */

@Component
export struct IconPlaceholder {
  @Prop iconName: string = '';
  @Prop iconSize: number = 24;
  @Prop color: ResourceColor = $r('app.color.text_secondary');

  build() {
    Row() {
      // 使用系统图标或文字占位符
      if (this.iconName) {
        Text(this.getIconText(this.iconName))
          .fontSize(this.iconSize * 0.7)
          .fontColor(this.color)
          .textAlign(TextAlign.Center)
      } else {
        Text('?')
          .fontSize(this.iconSize * 0.7)
          .fontColor(this.color)
      }
    }
    .width(this.iconSize)
    .height(this.iconSize)
    .backgroundColor('#F0F0F0')
    .borderRadius(this.iconSize / 8)
    .justifyContent(FlexAlign.Center)
  }

  getIconText(name: string): string {
    const iconMap: Record<string, string> = {
      'ic_home': '🏠',
      'ic_order': '📋',
      'ic_message': '💬',
      'ic_profile': '👤',
      'ic_attendance': '✅',
      'ic_homework': '📝',
      'ic_report': '📊',
      'ic_notification': '🔔',
      'ic_settings': '⚙️',
      'ic_warning': '⚠️',
      'ic_money': '💰',
      'ic_empty': '📭',
      'ic_logo': '🎓',
      'ic_user': '👤',
      'ic_lock': '🔒',
      'ic_eye_open': '👁',
      'ic_eye_close': '👁‍🗨',
      'ic_leave': '📅',
      'ic_qrcode': '📱',
      'ic_calendar': '🗓',
      'ic_child': '👶',
      'ic_help': '❓',
      'ic_about': 'ℹ️',
      'ic_arrow_right': '➡',
      'ic_default_avatar': '👤',
      'ic_system': '📢',
      'ic_chat': '💬'
    };
    return iconMap[name] || '●';
  }
}

/**
 * 智能图标组件 - 优先使用资源图标，失败时使用占位符
 */
@Component
export struct SmartIcon {
  @Prop iconName: string = '';
  @Prop iconSize: number = 24;
  @Prop color: ResourceColor = $r('app.color.text_secondary');
  @Prop useEmoji: boolean = true; // 是否允许使用emoji作为后备

  build() {
    Stack() {
      // 尝试加载资源图片
      Image(this.getIconResource())
        .width(this.iconSize)
        .height(this.iconSize)
        .objectFit(ImageFit.Contain)
        .fillColor(this.color)
    }
  }

  getIconResource(): Resource {
    // 返回资源引用，实际项目中需要确保图标文件存在
    const iconMap: Record<string, Resource> = {
      'ic_home': $r('app.media.ic_home'),
      'ic_order': $r('app.media.ic_order'),
      'ic_message': $r('app.media.ic_message'),
      'ic_profile': $r('app.media.ic_profile'),
      'ic_attendance': $r('app.media.ic_attendance'),
      'ic_homework': $r('app.media.ic_homework'),
      'ic_report': $r('app.media.ic_report'),
      'ic_notification': $r('app.media.ic_notification'),
      'ic_settings': $r('app.media.ic_settings'),
      'ic_warning': $r('app.media.ic_warning'),
      'ic_money': $r('app.media.ic_money'),
      'ic_empty': $r('app.media.ic_empty'),
      'ic_logo': $r('app.media.ic_logo'),
      'ic_user': $r('app.media.ic_user'),
      'ic_lock': $r('app.media.ic_lock'),
      'ic_eye_open': $r('app.media.ic_eye_open'),
      'ic_eye_close': $r('app.media.ic_eye_close'),
      'ic_leave': $r('app.media.ic_leave'),
      'ic_qrcode': $r('app.media.ic_qrcode'),
      'ic_calendar': $r('app.media.ic_calendar'),
      'ic_child': $r('app.media.ic_child'),
      'ic_help': $r('app.media.ic_help'),
      'ic_about': $r('app.media.ic_about'),
      'ic_arrow_right': $r('app.media.ic_arrow_right'),
      'ic_default_avatar': $r('app.media.ic_default_avatar'),
      'ic_system': $r('app.media.ic_system'),
      'ic_chat': $r('app.media.ic_chat')
    };

    return iconMap[this.iconName] || $r('app.media.ic_empty');
  }
}

/**
 * 空状态占位组件
 */
@Component
export struct EmptyState {
  @Prop message: string = '暂无数据';
  @Prop iconName: string = 'ic_empty';

  build() {
    Column() {
      if (this.useEmoji) {
        IconPlaceholder({
          iconName: this.iconName,
          iconSize: 80,
          color: $r('app.color.text_tertiary')
        })
      }

      Text(this.message)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: $r('app.float.card_content_margin') })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  private get useEmoji(): boolean {
    return true;
  }
}