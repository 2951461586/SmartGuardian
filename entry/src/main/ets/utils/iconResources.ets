/**
 * SmartGuardian - 图标资源工具
 * 提供图标资源的统一访问，并为缺失图标提供稳定兜底
 */

const DEFAULT_ICON: Resource = $r('app.media.ic_empty');

const ICON_RESOURCE_MAP: Record<string, Resource> = {
  "ic_home": $r('app.media.ic_home'),
  "ic_order": $r('app.media.ic_order'),
  "ic_message": $r('app.media.ic_message'),
  "ic_profile": $r('app.media.ic_profile'),
  "ic_attendance": $r('app.media.ic_attendance'),
  "ic_homework": $r('app.media.ic_homework'),
  "ic_report": $r('app.media.ic_report'),
  "ic_notification": $r('app.media.ic_notification'),
  "ic_settings": $r('app.media.ic_settings'),
  "ic_warning": $r('app.media.ic_warning'),
  "ic_money": $r('app.media.ic_money'),
  "ic_empty": $r('app.media.ic_empty'),
  "ic_logo": $r('app.media.ic_logo'),
  "ic_user": $r('app.media.ic_user'),
  "ic_lock": $r('app.media.ic_lock'),
  "ic_eye_open": $r('app.media.ic_eye_open'),
  "ic_eye_close": $r('app.media.ic_eye_close'),
  "ic_leave": $r('app.media.ic_leave'),
  "ic_qrcode": $r('app.media.ic_qrcode'),
  "ic_calendar": $r('app.media.ic_calendar'),
  "ic_child": $r('app.media.ic_child'),
  "ic_help": $r('app.media.ic_help'),
  "ic_about": $r('app.media.ic_about'),
  "ic_arrow_right": $r('app.media.ic_arrow_right'),
  "ic_arrow_left": $r('app.media.ic_arrow_left'),
  "ic_add": $r('app.media.ic_add'),
  "ic_close": $r('app.media.ic_close'),
  "ic_search": $r('app.media.ic_search'),
  "ic_filter": $r('app.media.ic_filter'),
  "ic_edit": $r('app.media.ic_edit'),
  "ic_delete": $r('app.media.ic_delete'),
  "ic_refresh": $r('app.media.ic_refresh'),
  "ic_default_avatar": $r('app.media.ic_default_avatar'),
  "ic_system": $r('app.media.ic_system'),
  "ic_chat": $r('app.media.ic_chat'),
  "ic_male": $r('app.media.ic_user'),
  "ic_female": $r('app.media.ic_user'),
  "ic_phone": $r('app.media.ic_message'),
  "ic_email": $r('app.media.ic_message'),
  "ic_location": $r('app.media.ic_child'),
  "ic_time": $r('app.media.ic_calendar'),
  "ic_star": $r('app.media.ic_notification'),
  "ic_heart": $r('app.media.ic_notification'),
  "ic_bell": $r('app.media.ic_notification'),
  "ic_success": $r('app.media.ic_notification'),
  "ic_error": $r('app.media.ic_warning'),
  "ic_info": $r('app.media.ic_notification')
};

export function getIconResource(iconName: string): Resource {
  return ICON_RESOURCE_MAP[iconName] || DEFAULT_ICON;
}

export type IconResource = Resource;

interface GeneratedObjectLiteralInterface_1 {
  HOME: Resource;
  ORDER: Resource;
  MESSAGE: Resource;
  PROFILE: Resource;
  ATTENDANCE: Resource;
  HOMEWORK: Resource;
  REPORT: Resource;
  NOTIFICATION: Resource;
  SETTINGS: Resource;
  WARNING: Resource;
  MONEY: Resource;
  EMPTY: Resource;
  LOGO: Resource;
  USER: Resource;
  LOCK: Resource;
  EYE_OPEN: Resource;
  EYE_CLOSE: Resource;
  LEAVE: Resource;
  QRCODE: Resource;
  CALENDAR: Resource;
  CHILD: Resource;
  HELP: Resource;
  ABOUT: Resource;
  ARROW_RIGHT: Resource;
  ARROW_LEFT: Resource;
  ADD: Resource;
  CLOSE: Resource;
  SEARCH: Resource;
  FILTER: Resource;
  EDIT: Resource;
  DELETE: Resource;
  REFRESH: Resource;
  DEFAULT_AVATAR: Resource;
  SYSTEM: Resource;
  CHAT: Resource;
  MALE: Resource;
  FEMALE: Resource;
  PHONE: Resource;
  EMAIL: Resource;
  LOCATION: Resource;
  TIME: Resource;
  STAR: Resource;
  HEART: Resource;
  BELL: Resource;
  SUCCESS: Resource;
  ERROR: Resource;
  INFO: Resource;
  START_ICON: Resource;
  FOREGROUND: Resource;
  BACKGROUND: Resource;
}

export const ICONS: GeneratedObjectLiteralInterface_1 = {
  HOME: ICON_RESOURCE_MAP.ic_home,
  ORDER: ICON_RESOURCE_MAP.ic_order,
  MESSAGE: ICON_RESOURCE_MAP.ic_message,
  PROFILE: ICON_RESOURCE_MAP.ic_profile,
  ATTENDANCE: ICON_RESOURCE_MAP.ic_attendance,
  HOMEWORK: ICON_RESOURCE_MAP.ic_homework,
  REPORT: ICON_RESOURCE_MAP.ic_report,
  NOTIFICATION: ICON_RESOURCE_MAP.ic_notification,
  SETTINGS: ICON_RESOURCE_MAP.ic_settings,
  WARNING: ICON_RESOURCE_MAP.ic_warning,
  MONEY: ICON_RESOURCE_MAP.ic_money,
  EMPTY: ICON_RESOURCE_MAP.ic_empty,
  LOGO: ICON_RESOURCE_MAP.ic_logo,
  USER: ICON_RESOURCE_MAP.ic_user,
  LOCK: ICON_RESOURCE_MAP.ic_lock,
  EYE_OPEN: ICON_RESOURCE_MAP.ic_eye_open,
  EYE_CLOSE: ICON_RESOURCE_MAP.ic_eye_close,
  LEAVE: ICON_RESOURCE_MAP.ic_leave,
  QRCODE: ICON_RESOURCE_MAP.ic_qrcode,
  CALENDAR: ICON_RESOURCE_MAP.ic_calendar,
  CHILD: ICON_RESOURCE_MAP.ic_child,
  HELP: ICON_RESOURCE_MAP.ic_help,
  ABOUT: ICON_RESOURCE_MAP.ic_about,
  ARROW_RIGHT: ICON_RESOURCE_MAP.ic_arrow_right,
  ARROW_LEFT: ICON_RESOURCE_MAP.ic_arrow_left,
  ADD: ICON_RESOURCE_MAP.ic_add,
  CLOSE: ICON_RESOURCE_MAP.ic_close,
  SEARCH: ICON_RESOURCE_MAP.ic_search,
  FILTER: ICON_RESOURCE_MAP.ic_filter,
  EDIT: ICON_RESOURCE_MAP.ic_edit,
  DELETE: ICON_RESOURCE_MAP.ic_delete,
  REFRESH: ICON_RESOURCE_MAP.ic_refresh,
  DEFAULT_AVATAR: ICON_RESOURCE_MAP.ic_default_avatar,
  SYSTEM: ICON_RESOURCE_MAP.ic_system,
  CHAT: ICON_RESOURCE_MAP.ic_chat,
  MALE: ICON_RESOURCE_MAP.ic_male,
  FEMALE: ICON_RESOURCE_MAP.ic_female,
  PHONE: ICON_RESOURCE_MAP.ic_phone,
  EMAIL: ICON_RESOURCE_MAP.ic_email,
  LOCATION: ICON_RESOURCE_MAP.ic_location,
  TIME: ICON_RESOURCE_MAP.ic_time,
  STAR: ICON_RESOURCE_MAP.ic_star,
  HEART: ICON_RESOURCE_MAP.ic_heart,
  BELL: ICON_RESOURCE_MAP.ic_bell,
  SUCCESS: ICON_RESOURCE_MAP.ic_success,
  ERROR: ICON_RESOURCE_MAP.ic_error,
  INFO: ICON_RESOURCE_MAP.ic_info,
  START_ICON: $r('app.media.startIcon'),
  FOREGROUND: $r('app.media.foreground'),
  BACKGROUND: $r('app.media.background')
};

export function safeIcon(icon: Resource | undefined): Resource {
  return icon || DEFAULT_ICON;
}
