/**
 * SmartGuardian - 应用入口
 * 初始化应用并加载主页面
 */

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AppInitializationService } from '../services/AppInitializationService';
import { LogUtil } from '../utils/LogUtil';
import { ErrorHandlerUtil } from '../utils/ErrorHandlerUtil';
import { setRequestUIContext } from '../utils/request';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private initService: AppInitializationService = AppInitializationService.getInstance();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.info('EntryAbility onCreate');

    // 设置颜色模式
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      LogUtil.error('Failed to set colorMode:', String(err));
    }

    // 初始化所有服务
    this.initializeServices();
  }

  /**
   * 初始化应用服务
   */
  private async initializeServices(): Promise<void> {
    try {
      const status = await this.initService.initializeAll(this.context);
      
      if (status.overall) {
        LogUtil.info('All services initialized successfully');
      } else {
        LogUtil.warn('Some services failed to initialize: ' + JSON.stringify(status));
      }
    } catch (error) {
      LogUtil.error('Service initialization error:', String(error));
    }
  }

  onDestroy(): void {
    LogUtil.info('EntryAbility onDestroy');
    
    // 销毁所有服务
    this.initService.destroy();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LogUtil.info('EntryAbility onWindowStageCreate');

    try {
      const mainWindow: window.Window = windowStage.getMainWindowSync();
      const uiContext = mainWindow.getUIContext();
      ErrorHandlerUtil.setUIContext(uiContext);
      setRequestUIContext(uiContext);
    } catch (error) {
      LogUtil.error('Failed to initialize ErrorHandler UIContext:', String(error));
    }

    // 统一入口到 Index，由 Index 负责登录态分流
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        LogUtil.error('Failed to load content:', String(err));
        return;
      }
      LogUtil.info('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    LogUtil.info('EntryAbility onWindowStageDestroy');
  }

  onForeground(): void {
    LogUtil.info('EntryAbility onForeground');
  }

  onBackground(): void {
    LogUtil.info('EntryAbility onBackground');
  }
}