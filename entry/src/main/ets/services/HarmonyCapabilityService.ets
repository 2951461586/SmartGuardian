/**
 * SmartGuardian - Harmony Capability Service
 * Centralizes NotificationKit based badge sync and local reminder dispatch.
 */

import { RouteUrls } from '../constants/app.constants';
import { UserStore } from '../stores/userStore';
import { NotificationLaunchService } from './NotificationLaunchService';
import { NotificationUtil } from '../utils/NotificationUtil';

export class HarmonyCapabilityService {
  static isNotificationEnabled(): boolean {
    return UserStore.getUserPreferences().enableNotifications !== false;
  }

  static isAttendanceReminderEnabled(): boolean {
    return UserStore.getUserPreferences().enableAttendanceReminder !== false;
  }

  static async syncMessageBadge(unreadCount: number): Promise<void> {
    if (!HarmonyCapabilityService.isNotificationEnabled()) {
      await NotificationUtil.setBadgeNumber(0);
      return;
    }

    const badgeCount = unreadCount > 0 ? unreadCount : 0;
    await NotificationUtil.setBadgeNumber(badgeCount);
  }

  static async disableNotifications(): Promise<void> {
    await NotificationUtil.cancelAllNotifications();
    await NotificationUtil.setBadgeNumber(0);
  }

  static async previewMessageDispatch(
    messageType: string,
    title: string,
    content: string,
    route?: string
  ): Promise<void> {
    if (!HarmonyCapabilityService.isNotificationEnabled()) {
      return;
    }

    const targetRoute = route ?? RouteUrls.ADMIN_MESSAGES;
    const paramsJson = NotificationLaunchService.buildParamsJson(0, messageType);

    if (messageType === 'ATTENDANCE') {
      await NotificationUtil.showAttendanceNotification(title, content, '', targetRoute, paramsJson);
      return;
    }

    if (messageType === 'HOMEWORK') {
      await NotificationUtil.showHomeworkNotification(title, content, targetRoute, paramsJson);
      return;
    }

    await NotificationUtil.showSystemNotification(title, content, targetRoute, paramsJson);
  }

  static async notifyAttendanceResult(
    actionLabel: string,
    studentName?: string,
    route?: string
  ): Promise<void> {
    if (!HarmonyCapabilityService.isAttendanceReminderEnabled()) {
      return;
    }

    const safeStudentName = studentName && studentName.length > 0 ? studentName : '学生';
    const targetRoute = route ?? RouteUrls.TEACHER_ATTENDANCE;
    const paramsJson = NotificationLaunchService.buildParamsJson(0, 'ATTENDANCE');

    await NotificationUtil.showAttendanceNotification(
      `${safeStudentName}${actionLabel}`,
      '考勤结果已同步到当前设备，请及时核对记录。',
      safeStudentName,
      targetRoute,
      paramsJson
    );
  }
}
