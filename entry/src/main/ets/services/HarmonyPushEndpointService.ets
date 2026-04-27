/**
 * SmartGuardian - Push endpoint capability boundary.
 * Uses AGConnect credential identity today; true Push Kit token source can replace this provider later.
 */

import { AppConstants } from '../constants/app.constants';
import { SessionDeviceRegistrationRequest } from './api/auth';
import { AgcRuntimeService } from './agc/AgcRuntimeService';

export class HarmonyPushEndpointStatus {
  pushKitIntegrated: boolean = false;
  remotePushReady: boolean = false;
  localNotificationReady: boolean = true;
  provider: string = 'LOCAL_NOTIFICATION';
  deviceId: string = '';
  endpointTokenReady: boolean = false;
  message: string = '';
}

export class HarmonyPushEndpointService {
  static getStatus(): HarmonyPushEndpointStatus {
    const status = new HarmonyPushEndpointStatus();
    status.deviceId = AgcRuntimeService.getAaid();
    const gatewayToken = AgcRuntimeService.getGatewayToken();
    status.endpointTokenReady = gatewayToken.length > 0;
    status.remotePushReady = status.deviceId.length > 0 && status.endpointTokenReady;

    if (status.remotePushReady) {
      status.provider = 'AGC_GATEWAY';
      status.message = 'AGC gateway token 可用于服务端会话端点绑定。';
      return status;
    }

    status.provider = 'LOCAL_NOTIFICATION';
    if (!AgcRuntimeService.isClientConfigReady()) {
      status.message = 'AGC 客户端配置未就绪，本地 NotificationKit 仍可使用。';
    } else {
      status.message = '当前仓库尚未安装 Push Kit SDK token 来源，本地 NotificationKit 仍可使用。';
    }
    return status;
  }

  static canRegisterRemoteEndpoint(): boolean {
    return HarmonyPushEndpointService.getStatus().remotePushReady;
  }

  static buildSessionDeviceRegistrationRequest(): SessionDeviceRegistrationRequest {
    const request = new SessionDeviceRegistrationRequest();
    const status = HarmonyPushEndpointService.getStatus();
    request.deviceId = status.deviceId;
    request.notificationToken = AgcRuntimeService.getGatewayToken();
    request.notificationProvider = status.provider;
    request.authUid = AgcRuntimeService.getAuthUserUid();
    request.authPhone = AgcRuntimeService.getAuthUserPhone();
    request.clientVersion = AppConstants.APP_VERSION;
    request.clientPlatform = 'HarmonyOS';
    return request;
  }
}
