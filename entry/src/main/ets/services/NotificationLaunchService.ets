import { Want } from '@kit.AbilityKit';
import { StorageKeys } from '../constants/app.constants';

export class PendingNotificationLaunch {
  route: string = '';
  paramsJson: string = '';
}

export class NotificationLaunchService {
  private static readonly ROUTE_KEY: string = 'smartguardian.route';
  private static readonly PARAMS_KEY: string = 'smartguardian.params';

  static captureWant(want: Want): void {
    const routeValue = want.parameters?.[NotificationLaunchService.ROUTE_KEY];
    if (typeof routeValue !== 'string' || routeValue.length === 0) {
      return;
    }

    const paramsValue = want.parameters?.[NotificationLaunchService.PARAMS_KEY];
    const paramsJson = typeof paramsValue === 'string' ? paramsValue : '';
    NotificationLaunchService.storePendingLaunch(routeValue, paramsJson);
  }

  static storePendingLaunch(route: string, paramsJson: string): void {
    AppStorage.setOrCreate(StorageKeys.NOTIFICATION_TARGET_ROUTE, route);
    if (paramsJson.length > 0) {
      AppStorage.setOrCreate(StorageKeys.NOTIFICATION_TARGET_PARAMS, paramsJson);
    } else {
      AppStorage.delete(StorageKeys.NOTIFICATION_TARGET_PARAMS);
    }
  }

  static peekPendingLaunch(): PendingNotificationLaunch | null {
    const route = AppStorage.get<string>(StorageKeys.NOTIFICATION_TARGET_ROUTE) ?? '';
    if (route.length === 0) {
      return null;
    }

    const launch = new PendingNotificationLaunch();
    launch.route = route;
    launch.paramsJson = AppStorage.get<string>(StorageKeys.NOTIFICATION_TARGET_PARAMS) ?? '';
    return launch;
  }

  static consumePendingLaunch(): PendingNotificationLaunch | null {
    const launch = NotificationLaunchService.peekPendingLaunch();
    if (!launch) {
      return null;
    }

    AppStorage.delete(StorageKeys.NOTIFICATION_TARGET_ROUTE);
    AppStorage.delete(StorageKeys.NOTIFICATION_TARGET_PARAMS);
    return launch;
  }

  static parseParams(paramsJson: string): Object | undefined {
    if (paramsJson.length === 0) {
      return undefined;
    }

    try {
      return JSON.parse(paramsJson) as Object;
    } catch (_) {
      return undefined;
    }
  }

  static buildParamsJson(messageId: number, source: string): string {
    return JSON.stringify({
      messageId: messageId,
      source: source
    });
  }
}
