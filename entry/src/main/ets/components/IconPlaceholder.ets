/**
 * SmartGuardian - Resource-backed icon helpers.
 */

@Component
export struct IconPlaceholder {
  @Prop iconName: string = '';
  @Prop iconSize: number = 24;
  @Prop color: ResourceColor = $r('app.color.text_secondary');

  build() {
    Image(this.getIconResource())
      .width(this.iconSize)
      .height(this.iconSize)
      .objectFit(ImageFit.Contain)
      .fillColor(this.color)
  }

  getIconResource(): Resource {
    if (this.iconName === 'ic_order') return $r('app.media.ic_order');
    if (this.iconName === 'ic_message') return $r('app.media.ic_message');
    if (this.iconName === 'ic_profile') return $r('app.media.ic_profile');
    if (this.iconName === 'ic_attendance') return $r('app.media.ic_attendance');
    if (this.iconName === 'ic_homework') return $r('app.media.ic_homework');
    if (this.iconName === 'ic_report') return $r('app.media.ic_report');
    if (this.iconName === 'ic_notification') return $r('app.media.ic_notification');
    if (this.iconName === 'ic_settings') return $r('app.media.ic_settings');
    if (this.iconName === 'ic_warning') return $r('app.media.ic_warning');
    if (this.iconName === 'ic_money') return $r('app.media.ic_money');
    if (this.iconName === 'ic_empty') return $r('app.media.ic_empty');
    if (this.iconName === 'ic_logo') return $r('app.media.ic_logo');
    if (this.iconName === 'ic_user') return $r('app.media.ic_user');
    if (this.iconName === 'ic_lock') return $r('app.media.ic_lock');
    if (this.iconName === 'ic_eye_open') return $r('app.media.ic_eye_open');
    if (this.iconName === 'ic_eye_close') return $r('app.media.ic_eye_close');
    if (this.iconName === 'ic_leave') return $r('app.media.ic_leave');
    if (this.iconName === 'ic_qrcode') return $r('app.media.ic_qrcode');
    if (this.iconName === 'ic_calendar') return $r('app.media.ic_calendar');
    if (this.iconName === 'ic_child') return $r('app.media.ic_child');
    if (this.iconName === 'ic_help') return $r('app.media.ic_help');
    if (this.iconName === 'ic_about') return $r('app.media.ic_about');
    if (this.iconName === 'ic_arrow_right') return $r('app.media.ic_arrow_right');
    if (this.iconName === 'ic_default_avatar') return $r('app.media.ic_default_avatar');
    if (this.iconName === 'ic_system') return $r('app.media.ic_system');
    if (this.iconName === 'ic_chat') return $r('app.media.ic_chat');
    return $r('app.media.ic_home');
  }
}

@Component
export struct SmartIcon {
  @Prop iconName: string = '';
  @Prop iconSize: number = 24;
  @Prop color: ResourceColor = $r('app.color.text_secondary');
  @Prop useEmoji: boolean = false;

  build() {
    IconPlaceholder({
      iconName: this.iconName,
      iconSize: this.iconSize,
      color: this.color
    })
  }
}

@Component
export struct EmptyState {
  @Prop message: string = '暂无数据';
  @Prop iconName: string = 'ic_empty';

  build() {
    Column() {
      IconPlaceholder({
        iconName: this.iconName,
        iconSize: 80,
        color: $r('app.color.text_tertiary')
      })

      Text(this.message)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: $r('app.float.card_content_margin') })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
