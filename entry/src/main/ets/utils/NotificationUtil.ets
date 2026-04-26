/**
 * SmartGuardian - Notification Utility
 * Handle local notifications and notification click routing.
 */

import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { LogUtil } from './LogUtil';

const TAG = 'NotificationUtil';
const APP_BUNDLE_NAME = 'com.liziai.smartguardian';
const DEFAULT_ENTRY_ABILITY = 'EntryAbility';
const ROUTE_PARAMETER_KEY = 'smartguardian.route';
const PARAMS_PARAMETER_KEY = 'smartguardian.params';

/**
 * Notification channel types
 */
export enum NotificationChannel {
  ATTENDANCE = 'attendance_channel',
  HOMEWORK = 'homework_channel',
  SYSTEM = 'system_channel',
  ALERT = 'alert_channel'
}

/**
 * Notification utility
 */
export class NotificationUtil {
  private static wantAgentCache: Map<string, WantAgent> = new Map();

  /**
   * Initialize notification channels
   * Note: Slots are created automatically by the system.
   */
  static async initChannels(): Promise<void> {
    LogUtil.info(TAG, 'Notification system ready');
  }

  private static buildCacheKey(abilityName: string, route: string, paramsJson: string): string {
    return `${abilityName}|${route}|${paramsJson}`;
  }

  /**
   * Create want agent for notification click.
   */
  private static async getWantAgent(abilityName: string, route?: string, paramsJson?: string): Promise<WantAgent> {
    const resolvedRoute = route ?? '';
    const resolvedParamsJson = paramsJson ?? '';
    const cacheKey = NotificationUtil.buildCacheKey(abilityName, resolvedRoute, resolvedParamsJson);
    const cached = NotificationUtil.wantAgentCache.get(cacheKey);
    if (cached) {
      return cached;
    }

    const parameters: Record<string, string> = {};
    if (resolvedRoute.length > 0) {
      parameters[ROUTE_PARAMETER_KEY] = resolvedRoute;
    }
    if (resolvedParamsJson.length > 0) {
      parameters[PARAMS_PARAMETER_KEY] = resolvedParamsJson;
    }

    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: APP_BUNDLE_NAME,
          abilityName: abilityName,
          parameters: parameters
        }
      ],
      requestCode: 0,
      operationType: wantAgent.OperationType.START_ABILITY,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    try {
      const agent = await wantAgent.getWantAgent(wantAgentInfo);
      NotificationUtil.wantAgentCache.set(cacheKey, agent);
      return agent;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Create want agent failed';
      LogUtil.error(TAG, `Create want agent failed for ${abilityName}: ${message}`);
      throw new Error(message);
    }
  }

  private static buildRequest(title: string, content: string, agent: WantAgent): notificationManager.NotificationRequest {
    return {
      id: Date.now() % 2147483647,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: title,
          text: content
        }
      },
      wantAgent: agent
    };
  }

  /**
   * Show system notification.
   */
  static async showSystemNotification(
    title: string,
    content: string,
    route?: string,
    paramsJson?: string
  ): Promise<void> {
    try {
      const agent = await NotificationUtil.getWantAgent(DEFAULT_ENTRY_ABILITY, route, paramsJson);
      await notificationManager.publish(NotificationUtil.buildRequest(title, content, agent));
      LogUtil.info(TAG, `System notification published: ${title}`);
    } catch (error) {
      const err = error as Error;
      LogUtil.error(TAG, `Show system notification failed: ${err.message}`);
    }
  }

  /**
   * Show attendance notification.
   */
  static async showAttendanceNotification(
    title: string,
    content: string,
    studentName?: string,
    route?: string,
    paramsJson?: string
  ): Promise<void> {
    try {
      const agent = await NotificationUtil.getWantAgent(DEFAULT_ENTRY_ABILITY, route, paramsJson);
      await notificationManager.publish(NotificationUtil.buildRequest(title, content, agent));
      LogUtil.info(TAG, `Attendance notification published: ${title}`);
    } catch (error) {
      const err = error as Error;
      LogUtil.error(TAG, `Show attendance notification failed: ${err.message}`);
    }
  }

  /**
   * Show homework notification.
   */
  static async showHomeworkNotification(
    title: string,
    content: string,
    route?: string,
    paramsJson?: string
  ): Promise<void> {
    try {
      const agent = await NotificationUtil.getWantAgent(DEFAULT_ENTRY_ABILITY, route, paramsJson);
      await notificationManager.publish(NotificationUtil.buildRequest(title, content, agent));
      LogUtil.info(TAG, `Homework notification published: ${title}`);
    } catch (error) {
      const err = error as Error;
      LogUtil.error(TAG, `Show homework notification failed: ${err.message}`);
    }
  }

  /**
   * Show alert notification.
   */
  static async showAlertNotification(
    title: string,
    content: string,
    route?: string,
    paramsJson?: string
  ): Promise<void> {
    try {
      const agent = await NotificationUtil.getWantAgent(DEFAULT_ENTRY_ABILITY, route, paramsJson);
      await notificationManager.publish(NotificationUtil.buildRequest(`提醒 · ${title}`, content, agent));
      LogUtil.info(TAG, `Alert notification published: ${title}`);
    } catch (error) {
      const err = error as Error;
      LogUtil.error(TAG, `Show alert notification failed: ${err.message}`);
    }
  }

  /**
   * Cancel notification by id.
   */
  static async cancelNotification(id: number): Promise<void> {
    try {
      await notificationManager.cancel(id);
      LogUtil.info(TAG, `Notification cancelled: ${id}`);
    } catch (error) {
      const err = error as Error;
      LogUtil.error(TAG, `Cancel notification failed: ${err.message}`);
    }
  }

  /**
   * Cancel all notifications.
   */
  static async cancelAllNotifications(): Promise<void> {
    try {
      await notificationManager.cancelAll();
      LogUtil.info(TAG, 'All notifications cancelled');
    } catch (error) {
      const err = error as Error;
      LogUtil.error(TAG, `Cancel all notifications failed: ${err.message}`);
    }
  }

  /**
   * Get badge number.
   */
  static async getBadgeNumber(): Promise<number> {
    try {
      return await notificationManager.getBadgeNumber();
    } catch (error) {
      const err = error as Error;
      LogUtil.error(TAG, `Get badge number failed: ${err.message}`);
      return 0;
    }
  }

  /**
   * Set badge number.
   */
  static async setBadgeNumber(count: number): Promise<void> {
    try {
      await notificationManager.setBadgeNumber(count);
      LogUtil.info(TAG, `Badge number set: ${count}`);
    } catch (error) {
      const err = error as Error;
      LogUtil.error(TAG, `Set badge number failed: ${err.message}`);
    }
  }
}
