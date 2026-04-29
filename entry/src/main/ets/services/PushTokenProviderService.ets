/**
 * SmartGuardian - Push Kit token provider boundary.
 */

import { AppConstants, StorageKeys } from '../constants/app.constants';
import { SessionDeviceRegistrationRequest } from './api/auth';
import { AgcRuntimeService } from './agc/AgcRuntimeService';

export class PushTokenSnapshot {
  provider: string = 'LOCAL_NOTIFICATION';
  token: string = '';
  deviceId: string = '';
  pushKitIntegrated: boolean = false;
  remotePushReady: boolean = false;
  endpointTokenReady: boolean = false;
  message: string = '';
}

export interface PushTokenSource {
  getSnapshot(): Promise<PushTokenSnapshot>;
}

class StoredPushKitTokenSource implements PushTokenSource {
  async getSnapshot(): Promise<PushTokenSnapshot> {
    const snapshot = new PushTokenSnapshot();
    snapshot.provider = 'PUSH_KIT';
    snapshot.token = AppStorage.get<string>(StorageKeys.PUSH_KIT_TOKEN) ?? '';
    snapshot.deviceId = AppStorage.get<string>(StorageKeys.PUSH_KIT_DEVICE_ID) ?? AgcRuntimeService.getAaid();
    snapshot.pushKitIntegrated = snapshot.token.length > 0;
    snapshot.endpointTokenReady = snapshot.token.length > 0;
    snapshot.remotePushReady = snapshot.deviceId.length > 0 && snapshot.token.length > 0;
    snapshot.message = AppStorage.get<string>(StorageKeys.PUSH_KIT_PROVIDER_MESSAGE) ?? '';

    if (snapshot.message.length === 0) {
      snapshot.message = snapshot.remotePushReady ? 'Push Kit token ready.' : 'Push Kit token is not ready.';
    }
    return snapshot;
  }
}

export class PushTokenProviderService {
  private static customSource: PushTokenSource | null = null;

  static registerSource(source: PushTokenSource): void {
    PushTokenProviderService.customSource = source;
  }

  static clearSource(): void {
    PushTokenProviderService.customSource = null;
  }

  static persistPushKitToken(token: string, deviceId: string, message?: string): void {
    AppStorage.setOrCreate(StorageKeys.PUSH_KIT_TOKEN, token);
    AppStorage.setOrCreate(StorageKeys.PUSH_KIT_DEVICE_ID, deviceId);
    AppStorage.setOrCreate(StorageKeys.PUSH_KIT_TOKEN_UPDATED_AT, new Date().toISOString());
    AppStorage.setOrCreate(StorageKeys.PUSH_KIT_PROVIDER_MESSAGE, message ? message : 'Push Kit token persisted.');
  }

  static async getSnapshot(): Promise<PushTokenSnapshot> {
    if (PushTokenProviderService.customSource !== null) {
      const customSnapshot = await PushTokenProviderService.customSource.getSnapshot();
      if (customSnapshot.remotePushReady) {
        return customSnapshot;
      }
    }

    const storedSource = new StoredPushKitTokenSource();
    const storedSnapshot = await storedSource.getSnapshot();
    if (storedSnapshot.remotePushReady) {
      return storedSnapshot;
    }

    return PushTokenProviderService.buildAgcGatewayFallback(storedSnapshot.message);
  }

  static async buildSessionDeviceRegistrationRequest(): Promise<SessionDeviceRegistrationRequest> {
    const snapshot = await PushTokenProviderService.getSnapshot();
    const request = new SessionDeviceRegistrationRequest();
    request.deviceId = snapshot.deviceId;
    request.notificationToken = snapshot.token;
    request.notificationProvider = snapshot.provider;
    request.authUid = AgcRuntimeService.getAuthUserUid();
    request.authPhone = AgcRuntimeService.getAuthUserPhone();
    request.clientVersion = AppConstants.APP_VERSION;
    request.clientPlatform = 'HarmonyOS';
    return request;
  }

  private static buildAgcGatewayFallback(pushKitMessage: string): PushTokenSnapshot {
    const snapshot = new PushTokenSnapshot();
    snapshot.deviceId = AgcRuntimeService.getAaid();
    snapshot.token = AgcRuntimeService.getGatewayToken();
    snapshot.endpointTokenReady = snapshot.token.length > 0;
    snapshot.remotePushReady = snapshot.deviceId.length > 0 && snapshot.token.length > 0;

    if (snapshot.remotePushReady) {
      snapshot.provider = 'AGC_GATEWAY';
      snapshot.message = 'AGC gateway token is used until Push Kit token is available.';
      return snapshot;
    }

    snapshot.provider = 'LOCAL_NOTIFICATION';
    if (!AgcRuntimeService.isClientConfigReady()) {
      snapshot.message = 'AGC client config is not ready; local NotificationKit remains available.';
    } else if (pushKitMessage.length > 0) {
      snapshot.message = pushKitMessage;
    } else {
      snapshot.message = 'Push Kit token source is not installed; local NotificationKit remains available.';
    }
    return snapshot;
  }
}
