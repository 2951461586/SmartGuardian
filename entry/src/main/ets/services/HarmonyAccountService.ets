/**
 * SmartGuardian - Harmony account capability boundary.
 * Keeps Account Kit integration replaceable while the repo only carries AGConnect auth packages.
 */

import { AgcRuntimeService } from './agc/AgcRuntimeService';

export class HarmonyAccountStatus {
  accountKitIntegrated: boolean = false;
  agcAuthReady: boolean = false;
  provider: string = 'AGC_AUTH';
  userUid: string = '';
  userPhone: string = '';
  message: string = '';
}

export class HarmonyAccountService {
  static getStatus(): HarmonyAccountStatus {
    const status = new HarmonyAccountStatus();
    status.userUid = AgcRuntimeService.getAuthUserUid();
    status.userPhone = AgcRuntimeService.getAuthUserPhone();
    status.agcAuthReady = status.userUid.length > 0 || status.userPhone.length > 0;

    if (status.agcAuthReady) {
      status.message = 'AGC Auth 会话可用于后端身份绑定。';
    } else if (AgcRuntimeService.isClientConfigReady()) {
      status.message = 'AGC 客户端配置已就绪，当前仓库尚未安装 Huawei Account Kit SDK。';
    } else {
      status.message = 'AGC 客户端配置未就绪，账号绑定暂不可用。';
    }

    return status;
  }

  static async signOut(): Promise<void> {
    await AgcRuntimeService.signOutAuthSession();
  }
}
