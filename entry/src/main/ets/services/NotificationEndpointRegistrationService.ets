import { ApiConfig } from '../config/api.config';
import { AuthService } from './api/auth';
import { HarmonyPushEndpointService } from './HarmonyPushEndpointService';
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

    const canRegister = await HarmonyPushEndpointService.canRegisterRemoteEndpoint();
    if (!canRegister) {
      const status = await HarmonyPushEndpointService.getStatus();
      LogUtil.warn(TAG, `Skip session endpoint registration: ${status.message}`);
      return;
    }

    const request = await HarmonyPushEndpointService.buildSessionDeviceRegistrationRequest();

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
