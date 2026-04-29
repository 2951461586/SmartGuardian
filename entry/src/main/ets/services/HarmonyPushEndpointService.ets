/**
 * SmartGuardian - Push endpoint capability boundary.
 */

import { SessionDeviceRegistrationRequest } from './api/auth';
import { PushTokenProviderService } from './PushTokenProviderService';

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
  static async getStatus(): Promise<HarmonyPushEndpointStatus> {
    const snapshot = await PushTokenProviderService.getSnapshot();
    const status = new HarmonyPushEndpointStatus();
    status.deviceId = snapshot.deviceId;
    status.endpointTokenReady = snapshot.endpointTokenReady;
    status.remotePushReady = snapshot.remotePushReady;
    status.pushKitIntegrated = snapshot.pushKitIntegrated;
    status.provider = snapshot.provider;
    status.message = snapshot.message;
    return status;
  }

  static async canRegisterRemoteEndpoint(): Promise<boolean> {
    const status = await HarmonyPushEndpointService.getStatus();
    return status.remotePushReady;
  }

  static async buildSessionDeviceRegistrationRequest(): Promise<SessionDeviceRegistrationRequest> {
    return PushTokenProviderService.buildSessionDeviceRegistrationRequest();
  }

  static persistPushKitToken(token: string, deviceId: string, message?: string): void {
    PushTokenProviderService.persistPushKitToken(token, deviceId, message);
  }
}
