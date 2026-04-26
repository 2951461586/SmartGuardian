import { common } from '@kit.AbilityKit';
import agconnect from '@hw-agconnect/api-ohos';
import '@hw-agconnect/core-ohos';
import '@hw-agconnect/auth-ohos';
import '@hw-agconnect/credential-ohos';
import { StorageKeys } from '../../constants/app.constants';
import { LogUtil } from '../../utils/LogUtil';

const TAG = 'AgcRuntimeService';

export interface AgcRuntimeStatus {
  initialized: boolean;
  configReady: boolean;
  gatewayTokenReady: boolean;
  aaid: string;
  userUid: string;
  errorMessage: string;
}

export class AgcRuntimeService {
  private static hasInitializedSdk: boolean = false;

  static async initialize(context: common.UIAbilityContext): Promise<AgcRuntimeStatus> {
    const status: AgcRuntimeStatus = {
      initialized: false,
      configReady: false,
      gatewayTokenReady: false,
      aaid: '',
      userUid: '',
      errorMessage: ''
    };

    try {
      AppStorage.setOrCreate(StorageKeys.AGC_RUNTIME_ERROR, '');
      if (!AgcRuntimeService.hasInitializedSdk) {
        agconnect.instance().init(context.getApplicationContext());
        AgcRuntimeService.hasInitializedSdk = true;
      }
      status.initialized = true;

      const config = await agconnect.instance().getConfig();
      const appId = await config.getString('/client/app_id');
      const clientId = await config.getString('/client/client_id');
      status.configReady = AgcRuntimeService.isValidConfigValue(appId) && AgcRuntimeService.isValidConfigValue(clientId);
      AppStorage.setOrCreate(StorageKeys.AGC_CONFIG_READY, status.configReady);
      AppStorage.setOrCreate(StorageKeys.AGC_APP_ID, appId);
      AppStorage.setOrCreate(StorageKeys.AGC_CLIENT_ID, clientId);

      if (!status.configReady) {
        throw new Error('agconnect-services.json still contains placeholder client values');
      }

      status.aaid = await agconnect.aaid().getAaid();
      AppStorage.setOrCreate(StorageKeys.AGC_AAID, status.aaid);

      try {
        const token = await agconnect.credential().getToken(false);
        status.gatewayTokenReady = token.tokenString.length > 0;
        if (status.gatewayTokenReady) {
          AppStorage.setOrCreate(StorageKeys.AGC_GATEWAY_TOKEN, token.tokenString);
          AppStorage.setOrCreate(StorageKeys.AGC_GATEWAY_TOKEN_EXPIRE_AT, token.expiration);
        }
      } catch (error) {
        LogUtil.warn(TAG, `Get AGC gateway token failed: ${String(error)}`);
        AppStorage.delete(StorageKeys.AGC_GATEWAY_TOKEN);
        AppStorage.delete(StorageKeys.AGC_GATEWAY_TOKEN_EXPIRE_AT);
      }

      try {
        const currentUser = await agconnect.auth().getCurrentUser();
        if (currentUser) {
          status.userUid = currentUser.getUid();
          AppStorage.setOrCreate(StorageKeys.AGC_AUTH_USER_UID, status.userUid);
          AppStorage.setOrCreate(StorageKeys.AGC_AUTH_USER_PHONE, String(currentUser.getPhone()));
        } else {
          AppStorage.delete(StorageKeys.AGC_AUTH_USER_UID);
          AppStorage.delete(StorageKeys.AGC_AUTH_USER_PHONE);
        }
      } catch (error) {
        LogUtil.warn(TAG, `Read AGC auth user failed: ${String(error)}`);
        AppStorage.delete(StorageKeys.AGC_AUTH_USER_UID);
        AppStorage.delete(StorageKeys.AGC_AUTH_USER_PHONE);
      }

      AppStorage.setOrCreate(StorageKeys.AGC_RUNTIME_READY, true);
      AppStorage.setOrCreate(StorageKeys.AGC_RUNTIME_ERROR, '');
      LogUtil.info(TAG, `AGC runtime initialized. configReady=${status.configReady}, tokenReady=${status.gatewayTokenReady}`);
    } catch (error) {
      status.errorMessage = String(error);
      AppStorage.setOrCreate(StorageKeys.AGC_RUNTIME_READY, false);
      AppStorage.setOrCreate(StorageKeys.AGC_RUNTIME_ERROR, status.errorMessage);
      LogUtil.error(TAG, `AGC runtime initialization failed: ${status.errorMessage}`);
    }

    return status;
  }

  static getGatewayToken(): string {
    return AppStorage.get<string>(StorageKeys.AGC_GATEWAY_TOKEN) ?? '';
  }

  static getAaid(): string {
    return AppStorage.get<string>(StorageKeys.AGC_AAID) ?? '';
  }

  static getAuthUserUid(): string {
    return AppStorage.get<string>(StorageKeys.AGC_AUTH_USER_UID) ?? '';
  }

  static getAuthUserPhone(): string {
    return AppStorage.get<string>(StorageKeys.AGC_AUTH_USER_PHONE) ?? '';
  }

  static isRuntimeReady(): boolean {
    return AppStorage.get<boolean>(StorageKeys.AGC_RUNTIME_READY) ?? false;
  }

  static isClientConfigReady(): boolean {
    return AppStorage.get<boolean>(StorageKeys.AGC_CONFIG_READY) ?? false;
  }

  static getRuntimeError(): string {
    return AppStorage.get<string>(StorageKeys.AGC_RUNTIME_ERROR) ?? '';
  }

  static async signOutAuthSession(): Promise<void> {
    try {
      await agconnect.auth().signOut();
    } catch (error) {
      LogUtil.warn(TAG, `AGC auth signOut failed: ${String(error)}`);
    }
    AppStorage.delete(StorageKeys.AGC_AUTH_USER_UID);
    AppStorage.delete(StorageKeys.AGC_AUTH_USER_PHONE);
  }

  private static isValidConfigValue(value: string): boolean {
    if (!value || value.length === 0) {
      return false;
    }
    return value.indexOf('YOUR_') < 0;
  }
}
