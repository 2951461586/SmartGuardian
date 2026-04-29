/**
 * SmartGuardian - 应用初始化服务
 * 统一管理启动期能力初始化。
 */

import { common } from '@kit.AbilityKit';
import { ApiConfig } from '../config/api.config';
import { LogUtil } from '../utils/LogUtil';
import { OptimizationConfig, OptimizationManager } from '../utils/performance/OptimizationManager';
import { AgcRuntimeService } from './agc/AgcRuntimeService';
import { SmartGuardianAgentFrameworkService } from './agent/SmartGuardianAgentFrameworkService';
import { NotificationEndpointRegistrationService } from './NotificationEndpointRegistrationService';
import { AttendanceSyncService } from './distributed/AttendanceSyncService';
import { DistributedAbilityManager } from './distributed/DistributedAbilityManager';
import { DistributedDataManager } from './distributed/DistributedDataManager';
import { NotificationUtil } from '../utils/NotificationUtil';

export interface InitializationStatus {
  agc: boolean;
  distributedData: boolean;
  distributedAbility: boolean;
  attendanceSync: boolean;
  agentFramework: boolean;
  performanceOptimization: boolean;
  notification: boolean;
  overall: boolean;
}

class InitializationTask {
  key: string = 'overall';
  label: string = '';
  required: boolean = false;
}

export class AppInitializationService {
  private static instance: AppInitializationService;
  private context: common.UIAbilityContext | null = null;
  private distributedDataManager: DistributedDataManager | null = null;
  private distributedAbilityManager: DistributedAbilityManager | null = null;
  private attendanceSyncService: AttendanceSyncService | null = null;
  private status: InitializationStatus = {
    agc: false,
    distributedData: false,
    distributedAbility: false,
    attendanceSync: false,
    agentFramework: false,
    performanceOptimization: false,
    notification: false,
    overall: false
  };

  private constructor() {}

  static getInstance(): AppInitializationService {
    if (!AppInitializationService.instance) {
      AppInitializationService.instance = new AppInitializationService();
    }
    return AppInitializationService.instance;
  }

  async initializeAll(context: common.UIAbilityContext): Promise<InitializationStatus> {
    LogUtil.info('Starting app initialization...');
    this.context = context;

    const startTime = Date.now();
    try {
      await this.initializeAgcRuntime();
      await this.initializeAgentFramework();
      await this.initializePerformanceOptimization();
      await this.initializeNotification();
      await this.initializeDistributedData();
      await this.initializeDistributedAbility();
      await this.initializeAttendanceSync();

      this.status.overall = this.calculateOverallStatus();

      const duration = Date.now() - startTime;
      LogUtil.info(`App initialization completed in ${duration}ms`);
      return this.status;
    } catch (error) {
      LogUtil.error('App initialization failed:', String(error));
      this.status.overall = false;
      return this.status;
    }
  }

  private calculateOverallStatus(): boolean {
    const tasks: InitializationTask[] = [];

    const agcTask = new InitializationTask();
    agcTask.key = 'agc';
    agcTask.label = 'AGC runtime';
    agcTask.required = ApiConfig.isAgcEnabled();
    tasks.push(agcTask);

    const distributedDataTask = new InitializationTask();
    distributedDataTask.key = 'distributedData';
    distributedDataTask.label = 'distributed data';
    distributedDataTask.required = true;
    tasks.push(distributedDataTask);

    const distributedAbilityTask = new InitializationTask();
    distributedAbilityTask.key = 'distributedAbility';
    distributedAbilityTask.label = 'distributed ability';
    distributedAbilityTask.required = true;
    tasks.push(distributedAbilityTask);

    const attendanceSyncTask = new InitializationTask();
    attendanceSyncTask.key = 'attendanceSync';
    attendanceSyncTask.label = 'attendance sync';
    attendanceSyncTask.required = true;
    tasks.push(attendanceSyncTask);

    const optimizationTask = new InitializationTask();
    optimizationTask.key = 'performanceOptimization';
    optimizationTask.label = 'performance optimization';
    optimizationTask.required = true;
    tasks.push(optimizationTask);

    const notificationTask = new InitializationTask();
    notificationTask.key = 'notification';
    notificationTask.label = 'notification';
    notificationTask.required = true;
    tasks.push(notificationTask);

    for (let i = 0; i < tasks.length; i++) {
      const task = tasks[i];
      if (task.required && !this.isTaskReady(task.key)) {
        LogUtil.warn(`Initialization task not ready: ${task.label}`);
        return false;
      }
    }

    return true;
  }

  private isTaskReady(key: string): boolean {
    switch (key) {
      case 'agc':
        return this.status.agc;
      case 'distributedData':
        return this.status.distributedData;
      case 'distributedAbility':
        return this.status.distributedAbility;
      case 'attendanceSync':
        return this.status.attendanceSync;
      case 'agentFramework':
        return this.status.agentFramework;
      case 'performanceOptimization':
        return this.status.performanceOptimization;
      case 'notification':
        return this.status.notification;
      case 'overall':
        return this.status.overall;
      default:
        return false;
    }
  }

  private async initializeAgcRuntime(): Promise<void> {
    try {
      const context = this.requireContext();
      const result = await AgcRuntimeService.initialize(context);
      this.status.agc = result.initialized && result.configReady;
      await NotificationEndpointRegistrationService.syncCurrentSession();
      LogUtil.info(`AGC runtime initialized: ${this.status.agc}`);
    } catch (error) {
      LogUtil.error('Failed to initialize AGC runtime:', String(error));
      this.status.agc = false;
    }
  }

  private async initializePerformanceOptimization(): Promise<void> {
    try {
      const context = this.requireContext();
      const optimizationManager = OptimizationManager.getInstance();
      const config = new OptimizationConfig();
      config.enableMemoryOptimization = true;
      config.enableImageCache = true;
      config.enablePerformanceMonitor = true;
      config.memoryWarningThreshold = 100;
      config.gcInterval = 60000;

      await optimizationManager.initialize(context, config);
      this.status.performanceOptimization = true;
      LogUtil.info('Performance optimization initialized');
    } catch (error) {
      LogUtil.error('Failed to initialize performance optimization:', String(error));
      this.status.performanceOptimization = false;
    }
  }

  private async initializeDistributedData(): Promise<void> {
    try {
      const context = this.requireContext();
      this.distributedDataManager = new DistributedDataManager(context);
      const success = await this.distributedDataManager.initialize();
      this.status.distributedData = success;
      LogUtil.info(`Distributed data manager initialized: ${success}`);
    } catch (error) {
      LogUtil.error('Failed to initialize distributed data manager:', String(error));
      this.status.distributedData = false;
    }
  }

  private async initializeDistributedAbility(): Promise<void> {
    try {
      const context = this.requireContext();
      this.distributedAbilityManager = new DistributedAbilityManager(context);
      const success = await this.distributedAbilityManager.initialize();
      this.status.distributedAbility = success;
      LogUtil.info(`Distributed ability manager initialized: ${success}`);
    } catch (error) {
      LogUtil.error('Failed to initialize distributed ability manager:', String(error));
      this.status.distributedAbility = false;
    }
  }

  private async initializeAttendanceSync(): Promise<void> {
    try {
      const context = this.requireContext();
      this.attendanceSyncService = new AttendanceSyncService(context);
      const success = await this.attendanceSyncService.start();
      this.status.attendanceSync = success;
      LogUtil.info(`Attendance sync service initialized: ${success}`);
    } catch (error) {
      LogUtil.error('Failed to initialize attendance sync service:', String(error));
      this.status.attendanceSync = false;
    }
  }

  private async initializeNotification(): Promise<void> {
    try {
      await NotificationUtil.initChannels();
      this.status.notification = true;
      LogUtil.info('Notification channels initialized');
    } catch (error) {
      LogUtil.error('Failed to initialize notification channels:', String(error));
      this.status.notification = false;
    }
  }

  private async initializeAgentFramework(): Promise<void> {
    try {
      const context = this.requireContext();
      this.status.agentFramework = await SmartGuardianAgentFrameworkService.checkSupport(context);
      LogUtil.info(`Agent Framework Kit support initialized: ${this.status.agentFramework}`);
    } catch (error) {
      LogUtil.warn('Agent Framework Kit support check skipped:', String(error));
      this.status.agentFramework = false;
    }
  }

  private requireContext(): common.UIAbilityContext {
    if (!this.context) {
      throw new Error('UIAbilityContext is not ready');
    }
    return this.context;
  }

  getInitializationStatus(): InitializationStatus {
    return {
      agc: this.status.agc,
      distributedData: this.status.distributedData,
      distributedAbility: this.status.distributedAbility,
      attendanceSync: this.status.attendanceSync,
      agentFramework: this.status.agentFramework,
      performanceOptimization: this.status.performanceOptimization,
      notification: this.status.notification,
      overall: this.status.overall
    };
  }

  destroy(): void {
    LogUtil.info('Destroying all services...');

    if (this.attendanceSyncService) {
      this.attendanceSyncService.stop();
      this.attendanceSyncService = null;
    }
    if (this.distributedAbilityManager) {
      this.distributedAbilityManager.destroy();
      this.distributedAbilityManager = null;
    }
    if (this.distributedDataManager) {
      this.distributedDataManager.destroy();
      this.distributedDataManager = null;
    }

    this.status = {
      agc: false,
      distributedData: false,
      distributedAbility: false,
      attendanceSync: false,
      agentFramework: false,
      performanceOptimization: false,
      notification: false,
      overall: false
    };

    LogUtil.info('All services destroyed');
  }
}
