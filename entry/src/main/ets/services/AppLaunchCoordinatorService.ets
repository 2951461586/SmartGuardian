import { RouteUrls, StorageKeys } from '../constants/app.constants';
import { UserStore } from '../stores/userStore';
import { getToken } from '../utils/request';
import { NotificationLaunchService } from './NotificationLaunchService';

export class AppLaunchTarget {
  route: string = RouteUrls.LOGIN;
  paramsJson: string = '';
}

export class AppLaunchCoordinatorService {
  static hasActiveSession(): boolean {
    const token = getToken() ?? '';
    return token.length > 0 && UserStore.isLoggedIn();
  }

  static resolveEntryTarget(): AppLaunchTarget {
    const target = new AppLaunchTarget();
    const pendingLaunch = NotificationLaunchService.peekPendingLaunch();

    if (AppLaunchCoordinatorService.hasActiveSession()) {
      if (pendingLaunch) {
        target.route = pendingLaunch.route;
        target.paramsJson = pendingLaunch.paramsJson;
        return target;
      }

      target.route = RouteUrls.MAIN;
      return target;
    }

    target.route = RouteUrls.LOGIN;
    return target;
  }

  static markAuthLocked(): void {
    AppStorage.setOrCreate(StorageKeys.MAIN_AUTH_LOCKED, true);
  }

  static markAuthUnlocked(): void {
    AppStorage.setOrCreate(StorageKeys.MAIN_AUTH_LOCKED, false);
  }

  static clearExpiredSession(): void {
    UserStore.clearUserInfo();
    AppLaunchCoordinatorService.markAuthLocked();
  }
}
