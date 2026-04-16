/**
 * SmartGuardian - 图标资源配置
 * 定义所有媒体图标资源的路径映射
 * 注意：由于图标文件是二进制资源，建议在开发时添加实际的图标文件
 * 这里提供资源路径映射，用于开发阶段的代码引用
 */

export interface IconConfig {
  // 导航图标
  ic_home: string;
  ic_order: string;
  ic_message: string;
  ic_profile: string;
  ic_attendance: string;
  ic_homework: string;
  ic_report: string;

  // 功能图标
  ic_notification: string;
  ic_settings: string;
  ic_warning: string;
  ic_money: string;
  ic_empty: string;
  ic_logo: string;

  // 表单图标
  ic_user: string;
  ic_lock: string;
  ic_eye_open: string;
  ic_eye_close: string;

  // 操作图标
  ic_leave: string;
  ic_qrcode: string;
  ic_calendar: string;
  ic_child: string;
  ic_help: string;
  ic_about: string;
  ic_arrow_right: string;
  ic_default_avatar: string;

  // 消息类型图标
  ic_system: string;
  ic_chat: string;
}

/**
 * 图标资源路径映射
 * 开发时需要将实际图标文件放置在 resources/base/media/ 目录下
 */
export const ICON_PATH_MAP: IconConfig = {
  // 导航图标
  ic_home: 'common/icons/home.png',
  ic_order: 'common/icons/order.png',
  ic_message: 'common/icons/message.png',
  ic_profile: 'common/icons/profile.png',
  ic_attendance: 'common/icons/attendance.png',
  ic_homework: 'common/icons/homework.png',
  ic_report: 'common/icons/report.png',

  // 功能图标
  ic_notification: 'common/icons/notification.png',
  ic_settings: 'common/icons/settings.png',
  ic_warning: 'common/icons/warning.png',
  ic_money: 'common/icons/money.png',
  ic_empty: 'common/icons/empty.png',
  ic_logo: 'common/icons/logo.png',

  // 表单图标
  ic_user: 'common/icons/user.png',
  ic_lock: 'common/icons/lock.png',
  ic_eye_open: 'common/icons/eye_open.png',
  ic_eye_close: 'common/icons/eye_close.png',

  // 操作图标
  ic_leave: 'common/icons/leave.png',
  ic_qrcode: 'common/icons/qrcode.png',
  ic_calendar: 'common/icons/calendar.png',
  ic_child: 'common/icons/child.png',
  ic_help: 'common/icons/help.png',
  ic_about: 'common/icons/about.png',
  ic_arrow_right: 'common/icons/arrow_right.png',
  ic_default_avatar: 'common/icons/default_avatar.png',

  // 消息类型图标
  ic_system: 'common/icons/system.png',
  ic_chat: 'common/icons/chat.png'
};

/**
 * 获取图标资源的$rawfile路径
 * @param iconName 图标名称
 * @returns $rawfile格式的资源路径
 */
export function getIconPath(iconName: keyof IconConfig): string {
  return $rawfile(ICON_PATH_MAP[iconName]);
}