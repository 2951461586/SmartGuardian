import { ApiConfig } from '../config/api.config';
import { AppConstants } from '../constants/app.constants';
import { AgcRuntimeService } from './agc/AgcRuntimeService';
import { AuthService, SessionDeviceRegistrationRequest } from './api/auth';
import { LogUtil } from '../utils/LogUtil';
import { getToken } from '../utils/request';

const TAG = 'NotificationEndpointRegistrationService';

export class NotificationEndpointRegistrationService {
  static async syncCurrentSession(): Promise<void> {
    if (!ApiConfig.isAgcEnabled()) {
      return;
    }

    const sessionToken = getToken();
    if (!sessionToken || sessionToken.length === 0) {
      return;
    }

    const deviceId = AgcRuntimeService.getAaid();
    const notificationToken = AgcRuntimeService.getGatewayToken();
    if (deviceId.length === 0 || notificationToken.length === 0) {
      LogUtil.warn(TAG, 'Skip session notification registration because AGC device identity is incomplete');
      return;
    }

    const request = new SessionDeviceRegistrationRequest();
    request.deviceId = deviceId;
    request.notificationToken = notificationToken;
    request.notificationProvider = 'AGC_GATEWAY';
    request.authUid = AgcRuntimeService.getAuthUserUid();
    request.authPhone = AgcRuntimeService.getAuthUserPhone();
    request.clientVersion = AppConstants.APP_VERSION;
    request.clientPlatform = 'HarmonyOS';

    try {
      const response = await AuthService.registerSessionDevice(request);
      if (response.code !== 0) {
        LogUtil.warn(TAG, `Session notification registration rejected: ${response.message}`);
        return;
      }

      if (response.data && response.data.persisted) {
        LogUtil.info(TAG, `Session notification registration persisted for device ${response.data.deviceId}`);
        return;
      }

      if (response.data && !response.data.persisted) {
        LogUtil.info(TAG, `Session notification registration is running in ${response.data.compatibilityMode} mode`);
      }
    } catch (error) {
      LogUtil.warn(TAG, `Session notification registration failed: ${String(error)}`);
    }
  }
}
