import { normalizeWorkbenchRole } from '../common/WorkbenchRegistry';
import { UserRole } from '../models/common';
import { UserInfo } from '../models/user';
import { UserStore } from '../stores/userStore';
import { AuthService } from './api/auth';
import { AppLaunchCoordinatorService } from './AppLaunchCoordinatorService';

export class SessionBootstrapResult {
  success: boolean = false;
  reason: string = '';
  userInfo: UserInfo | null = null;
  role: UserRole = UserRole.PARENT;
}

export class SessionBootstrapService {
  static async bootstrapCurrentSession(): Promise<SessionBootstrapResult> {
    const result = new SessionBootstrapResult();

    if (!AppLaunchCoordinatorService.hasActiveSession()) {
      AppLaunchCoordinatorService.clearExpiredSession();
      result.reason = 'LOCAL_SESSION_MISSING';
      return result;
    }

    try {
      const resp = await AuthService.getCurrentUser();
      if (resp.code !== 0 || !resp.data) {
        AppLaunchCoordinatorService.clearExpiredSession();
        result.reason = 'REMOTE_SESSION_INVALID';
        return result;
      }

      UserStore.setUserInfo(resp.data);
      AppLaunchCoordinatorService.markAuthUnlocked();
      result.success = true;
      result.userInfo = resp.data;
      result.role = normalizeWorkbenchRole(resp.data.roleType);
      return result;
    } catch (error) {
      AppLaunchCoordinatorService.clearExpiredSession();
      result.reason = 'REMOTE_SESSION_ERROR';
      return result;
    }
  }
}
