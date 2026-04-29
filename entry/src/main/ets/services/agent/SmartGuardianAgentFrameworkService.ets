/**
 * SmartGuardian Agent Framework Kit bridge.
 */

import { common } from '@kit.AbilityKit';
import { AgentController } from '@kit.AgentFrameworkKit';
import { LogUtil } from '../../utils/LogUtil';
import { SmartGuardianAgentConfig } from './SmartGuardianAgentConfig';

export class SmartGuardianAgentFrameworkService {
  private static controller: AgentController = new AgentController();
  private static supported: boolean = false;
  private static checked: boolean = false;

  static getAgentId(): string {
    return SmartGuardianAgentConfig.AGENT_ID;
  }

  static isSupported(): boolean {
    return SmartGuardianAgentFrameworkService.supported;
  }

  static hasCheckedSupport(): boolean {
    return SmartGuardianAgentFrameworkService.checked;
  }

  static async checkSupport(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const result = await SmartGuardianAgentFrameworkService.controller.isAgentSupport(
        context,
        SmartGuardianAgentConfig.AGENT_ID
      );
      SmartGuardianAgentFrameworkService.supported = result;
      SmartGuardianAgentFrameworkService.checked = true;
      LogUtil.info('AgentFramework', `Agent support: ${result}`);
      return result;
    } catch (error) {
      SmartGuardianAgentFrameworkService.supported = false;
      SmartGuardianAgentFrameworkService.checked = true;
      LogUtil.warn('AgentFramework', `Agent support check failed: ${String(error)}`);
      return false;
    }
  }

  static onDialogOpened(callback: () => void): void {
    SmartGuardianAgentFrameworkService.controller.on('agentDialogOpened', callback);
  }

  static offDialogOpened(callback?: () => void): void {
    SmartGuardianAgentFrameworkService.controller.off('agentDialogOpened', callback);
  }

  static onDialogClosed(callback: () => void): void {
    SmartGuardianAgentFrameworkService.controller.on('agentDialogClosed', callback);
  }

  static offDialogClosed(callback?: () => void): void {
    SmartGuardianAgentFrameworkService.controller.off('agentDialogClosed', callback);
  }
}
