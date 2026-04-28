/**
 * SmartGuardian - Resource Icon Adapter
 * Keeps legacy string icon names while rendering project SVG resources.
 */

import { HarmonyColor } from '../common/HarmonyDesign';

@Component
export struct SymbolIcon {
  @Prop icon: string = 'home';
  @Prop iconSize: number = 24;
  @Prop color: ResourceColor = HarmonyColor.inkStrong;
  @Prop fontWeight: number = 400;

  build() {
    Image(this.getIconResource())
      .width(this.iconSize)
      .height(this.iconSize)
      .objectFit(ImageFit.Contain)
      .fillColor(this.color)
  }

  private getIconResource(): Resource {
    if (this.icon === 'order') return $r('app.media.ic_order');
    if (this.icon === 'message') return $r('app.media.ic_message');
    if (this.icon === 'profile') return $r('app.media.ic_profile');
    if (this.icon === 'attendance') return $r('app.media.ic_attendance');
    if (this.icon === 'homework') return $r('app.media.ic_homework');
    if (this.icon === 'report') return $r('app.media.ic_report');
    if (this.icon === 'notification' || this.icon === 'bell') return $r('app.media.ic_notification');
    if (this.icon === 'settings') return $r('app.media.ic_settings');
    if (this.icon === 'warning' || this.icon === 'pending') return $r('app.media.ic_warning');
    if (this.icon === 'money' || this.icon === 'alipay' || this.icon === 'wechat') return $r('app.media.ic_money');
    if (this.icon === 'empty') return $r('app.media.ic_empty');
    if (this.icon === 'logo') return $r('app.media.ic_logo');
    if (this.icon === 'user' || this.icon === 'default_avatar') return $r('app.media.ic_user');
    if (this.icon === 'lock') return $r('app.media.ic_lock');
    if (this.icon === 'eye_open') return $r('app.media.ic_eye_open');
    if (this.icon === 'eye_close') return $r('app.media.ic_eye_close');
    if (this.icon === 'leave') return $r('app.media.ic_leave');
    if (this.icon === 'qrcode') return $r('app.media.ic_qrcode');
    if (this.icon === 'calendar' || this.icon === 'time') return $r('app.media.ic_calendar');
    if (this.icon === 'child') return $r('app.media.ic_child');
    if (this.icon === 'help') return $r('app.media.ic_help');
    if (this.icon === 'about' || this.icon === 'info') return $r('app.media.ic_info');
    if (this.icon === 'arrow_right') return $r('app.media.ic_arrow_right');
    if (this.icon === 'arrow_left') return $r('app.media.ic_arrow_left');
    if (this.icon === 'add') return $r('app.media.ic_add');
    if (this.icon === 'close') return $r('app.media.ic_close');
    if (this.icon === 'search' || this.icon === 'filter') return $r('app.media.ic_search');
    if (this.icon === 'edit') return $r('app.media.ic_edit');
    if (this.icon === 'delete') return $r('app.media.ic_delete');
    if (this.icon === 'refresh') return $r('app.media.ic_refresh');
    if (this.icon === 'location') return $r('app.media.ic_location');
    if (this.icon === 'success' || this.icon === 'done' || this.icon === 'check') return $r('app.media.ic_success');
    if (this.icon === 'error') return $r('app.media.ic_error');
    return $r('app.media.ic_home');
  }
}

@Component
export struct SymbolIconBg {
  @Prop icon: string = 'home';
  @Prop containerSize: number = 40;
  @Prop bgColor: ResourceColor = HarmonyColor.surfaceSubtle;
  @Prop iconColor: ResourceColor = HarmonyColor.textSecondary;
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

@Component
export struct IconText {
  @Prop icon: string = 'home';
  @Prop text: string = '';
  @Prop iconSize: number = 16;
  @Prop textSize: number = 14;
  @Prop iconColor: ResourceColor = HarmonyColor.textSecondary;
  @Prop textColor: ResourceColor = HarmonyColor.textPrimary;
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
