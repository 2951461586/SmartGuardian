/**
 * SmartGuardian - 应用初始化服务
 * 统一管理所有服务的初始化
 */

import { common } from '@kit.AbilityKit';
import { LogUtil } from '../utils/LogUtil';
import { OptimizationConfig, OptimizationManager } from '../utils/performance/OptimizationManager';
import { DistributedDataManager } from './distributed/DistributedDataManager';
import { DistributedAbilityManager } from './distributed/DistributedAbilityManager';
import { AttendanceSyncService } from './distributed/AttendanceSyncService';
import { NotificationUtil } from '../utils/NotificationUtil';

const TAG = 'AppInitializationService';

/**
 * 初始化状态
 */
export interface InitializationStatus {
  distributedData: boolean;
  distributedAbility: boolean;
  attendanceSync: boolean;
  performanceOptimization: boolean;
  notification: boolean;
  overall: boolean;
}

/**
 * 应用初始化服务
 * 负责在应用启动时初始化所有必要的服务
 */
export class AppInitializationService {
  private static instance: AppInitializationService;
  private context: common.UIAbilityContext | null = null;
  private distributedDataManager: DistributedDataManager | null = null;
  private distributedAbilityManager: DistributedAbilityManager | null = null;
  private attendanceSyncService: AttendanceSyncService | null = null;
  private status: InitializationStatus = {
    distributedData: false,
    distributedAbility: false,
    attendanceSync: false,
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

  /**
   * 初始化所有服务
   */
  async initializeAll(context: common.UIAbilityContext): Promise<InitializationStatus> {
    LogUtil.info('Starting app initialization...');
    this.context = context;

    const startTime = Date.now();

    try {
      // 并行初始化性能优化（最高优先级）
      await this.initializePerformanceOptimization();

      // 初始化通知渠道
      await this.initializeNotification();

      // 顺序初始化分布式能力
      await this.initializeDistributedData();
      await this.initializeDistributedAbility();
      await this.initializeAttendanceSync();

      // 计算总体状态
      this.status.overall = this.status.distributedData && 
        this.status.distributedAbility && 
        this.status.attendanceSync && 
        this.status.performanceOptimization &&
        this.status.notification;

      const duration = Date.now() - startTime;
      LogUtil.info(`App initialization completed in ${duration}ms`);

      return this.status;
    } catch (error) {
      LogUtil.error('App initialization failed:', String(error));
      this.status.overall = false;
      return this.status;
    }
  }

  /**
   * 初始化性能优化管理
   */
  private async initializePerformanceOptimization(): Promise<void> {
    try {
      const optimizationManager = OptimizationManager.getInstance();
      const config = new OptimizationConfig();
      config.enableMemoryOptimization = true;
      config.enableImageCache = true;
      config.enablePerformanceMonitor = true;
      config.memoryWarningThreshold = 100;
      config.gcInterval = 60000;

      await optimizationManager.initialize(this.context!, config);

      this.status.performanceOptimization = true;
      LogUtil.info('Performance optimization initialized');
    } catch (error) {
      LogUtil.error('Failed to initialize performance optimization:', String(error));
      this.status.performanceOptimization = false;
    }
  }

  /**
   * 初始化分布式数据管理
   */
  private async initializeDistributedData(): Promise<void> {
    try {
      this.distributedDataManager = new DistributedDataManager(this.context!);
      const success = await this.distributedDataManager.initialize();

      this.status.distributedData = success;
      LogUtil.info(`Distributed data manager initialized: ${success}`);
    } catch (error) {
      LogUtil.error('Failed to initialize distributed data manager:', String(error));
      this.status.distributedData = false;
    }
  }

  /**
   * 初始化分布式能力管理
   */
  private async initializeDistributedAbility(): Promise<void> {
    try {
      this.distributedAbilityManager = new DistributedAbilityManager(this.context!);
      const success = await this.distributedAbilityManager.initialize();

      this.status.distributedAbility = success;
      LogUtil.info(`Distributed ability manager initialized: ${success}`);
    } catch (error) {
      LogUtil.error('Failed to initialize distributed ability manager:', String(error));
      this.status.distributedAbility = false;
    }
  }

  /**
   * 初始化考勤同步服务
   */
  private async initializeAttendanceSync(): Promise<void> {
    try {
      this.attendanceSyncService = new AttendanceSyncService(this.context!);
      const success = await this.attendanceSyncService.start();

      this.status.attendanceSync = success;
      LogUtil.info(`Attendance sync service initialized: ${success}`);
    } catch (error) {
      LogUtil.error('Failed to initialize attendance sync service:', String(error));
      this.status.attendanceSync = false;
    }
  }

  /**
   * 初始化通知渠道
   */
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

  /**
   * 获取初始化状态
   */
  getInitializationStatus(): InitializationStatus {
    const status: InitializationStatus = {
      distributedData: this.status.distributedData,
      distributedAbility: this.status.distributedAbility,
      attendanceSync: this.status.attendanceSync,
      performanceOptimization: this.status.performanceOptimization,
      notification: this.status.notification,
      overall: this.status.overall
    };
    return status;
  }

  /**
   * 销毁所有服务
   */
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
    
    // 重置状态
    this.status = {
      distributedData: false,
      distributedAbility: false,
      attendanceSync: false,
      performanceOptimization: false,
      notification: false,
      overall: false
    };

    LogUtil.info('All services destroyed');
  }
}

