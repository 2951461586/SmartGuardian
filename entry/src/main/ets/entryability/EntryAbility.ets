/**
 * SmartGuardian - 应用入口
 * 初始化应用并加载主页面
 */

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { ApiConfig } from '../config/api.config';
import { RouteUrls } from '../constants/app.constants';
import { AppLaunchCoordinatorService, AppLaunchTarget } from '../services/AppLaunchCoordinatorService';
import { AppInitializationService } from '../services/AppInitializationService';
import { NotificationLaunchService } from '../services/NotificationLaunchService';
import { LogUtil } from '../utils/LogUtil';
import { ErrorHandlerUtil } from '../utils/ErrorHandlerUtil';
import { setRequestUIContext } from '../utils/request';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private initService: AppInitializationService = AppInitializationService.getInstance();
  private windowStageRef: window.WindowStage | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.info('EntryAbility onCreate');
    ApiConfig.ensureRuntimeConfigReady();
    NotificationLaunchService.captureWant(want);
    LogUtil.info(`Runtime config: ${ApiConfig.describeRuntimeConfig()}`);

    // TODO: 初始化 AppGallery Connect SDK
    // 依赖安装完成后取消注释以下代码
    // try {
    //   agconnect.instance().init(this.context);
    //   LogUtil.info('AGC SDK initialized successfully');
    // } catch (err) {
    //   LogUtil.error('Failed to initialize AGC SDK:', String(err));
    // }

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
    this.windowStageRef = windowStage;

    // Keep bootstrap UI minimal and visible before entering LoginPage or MainPage.
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        LogUtil.error('Failed to load bootstrap content:', String(err));
        this.loadFallbackLogin(windowStage);
        return;
      }
      this.initializeUIContext(windowStage);
      LogUtil.info('Succeeded in loading bootstrap content.');
    });
  }

  onWindowStageDestroy(): void {
    LogUtil.info('EntryAbility onWindowStageDestroy');
    this.windowStageRef = null;
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    NotificationLaunchService.captureWant(want);
    this.consumeNotificationLaunch();
    LogUtil.info('EntryAbility onNewWant');
  }

  onForeground(): void {
    LogUtil.info('EntryAbility onForeground');
  }

  onBackground(): void {
    LogUtil.info('EntryAbility onBackground');
  }

  private consumeNotificationLaunch(): void {
    const launch = NotificationLaunchService.consumePendingLaunch();
    if (!launch || !this.windowStageRef) {
      return;
    }

    try {
      const mainWindow = this.windowStageRef.getMainWindowSync();
      const uiContext = mainWindow.getUIContext();
      uiContext.getRouter().replaceUrl({
        url: launch.route,
        params: NotificationLaunchService.parseParams(launch.paramsJson)
      });
    } catch (error) {
      LogUtil.warn('EntryAbility notification launch consume failed: ' + String(error));
      NotificationLaunchService.storePendingLaunch(launch.route, launch.paramsJson);
    }
  }

  private initializeUIContext(windowStage: window.WindowStage): void {
    try {
      const mainWindow: window.Window = windowStage.getMainWindowSync();
      const uiContext = mainWindow.getUIContext();
      ErrorHandlerUtil.setUIContext(uiContext);
      setRequestUIContext(uiContext);
    } catch (error) {
      LogUtil.error('Failed to initialize UIContext after content loaded:', String(error));
    }
  }

  private resolveInitialContentRoute(): string {
    const target: AppLaunchTarget = AppLaunchCoordinatorService.resolveEntryTarget();
    if (target.paramsJson.length > 0) {
      return RouteUrls.MAIN;
    }
    return target.route.length > 0 ? target.route : RouteUrls.LOGIN;
  }

  private loadFallbackLogin(windowStage: window.WindowStage): void {
    windowStage.loadContent(RouteUrls.LOGIN, (err) => {
      if (err.code) {
        LogUtil.error('Failed to load fallback LoginPage:', String(err));
        return;
      }
      this.initializeUIContext(windowStage);
    });
  }
}
