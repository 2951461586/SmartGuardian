/**
 * SmartGuardian - 性能优化管理器(Simplified)
 * 综合管理应用性能优化策略
 */

import { common } from '@kit.AbilityKit';
import { LogUtil } from '../LogUtil';
import { PerformanceMonitor, MetricType } from './PerformanceMonitor';
import { ImageLoader } from './ImageLoader';

const TAG = 'OptimizationManager';

/**
 * 内存警告级别
 */
export enum MemoryWarningLevel {
  NORMAL = 'NORMAL',
  WARNING = 'WARNING',
  CRITICAL = 'CRITICAL'
}

/**
 * 优化配置类
 */
export class OptimizationConfig {
  enableMemoryOptimization: boolean = true;
  enableImageCache: boolean = true;
  enablePerformanceMonitor: boolean = true;
  memoryWarningThreshold: number = 100;
  gcInterval: number = 60000;
}

/**
 * 性能优化管理器
 * 提供内存优化、缓存管理、性能监控等综合能力
 */
export class OptimizationManager {
  private static instance: OptimizationManager;
  private context: common.UIAbilityContext | null = null;
  private config: OptimizationConfig;
  private monitor: PerformanceMonitor;
  private imageLoader: ImageLoader;
  private gcTimerId: number = 0;
  private isInitialized: boolean = false;

  private constructor() {
    this.monitor = PerformanceMonitor.getInstance();
    this.imageLoader = ImageLoader.getInstance();
    this.config = new OptimizationConfig();
  }

  static getInstance(): OptimizationManager {
    if (!OptimizationManager.instance) {
      OptimizationManager.instance = new OptimizationManager();
    }
    return OptimizationManager.instance;
  }

  /**
   * 初始化优化管理器
   */
  async initialize(context: common.UIAbilityContext, config?: OptimizationConfig): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    this.context = context;
    if (config !== undefined) {
      this.config.enableMemoryOptimization = config.enableMemoryOptimization;
      this.config.enableImageCache = config.enableImageCache;
      this.config.enablePerformanceMonitor = config.enablePerformanceMonitor;
      this.config.memoryWarningThreshold = config.memoryWarningThreshold;
      this.config.gcInterval = config.gcInterval;
    }

    // 初始化性能监控
    if (this.config.enablePerformanceMonitor) {
      this.monitor.initialize({
        enableLogging: true,
        enableReporting: false,
        slowThreshold: 1000
      });
    }

    // 初始化图片加载器
    if (this.config.enableImageCache) {
      this.imageLoader.initialize(context);
    }

    // 注册内存监听
    if (this.config.enableMemoryOptimization) {
      this.startPeriodicGC();
    }

    this.isInitialized = true;
    LogUtil.info('OptimizationManager initialized');
  }

  /**
   * 触发垃圾回收提醒（HarmonyOS不直接支持GC API）
   */
  triggerGC(): void {
    LogUtil.info('GC suggestion logged (HarmonyOS manages memory automatically)');
  }

  /**
   * 清理缓存
   */
  clearCache(): void {
    this.imageLoader.clearCache();
    LogUtil.info('Cache cleared');
  }

  /**
   * 优化内存
   */
  optimizeMemory(): void {
    LogUtil.info('Memory optimization triggered');
    this.clearCache();
  }

  /**
   * 获取性能报告
   */
  getPerformanceReport(): PerformanceReport {
    const performanceStats = this.monitor.getStats();
    const imageCacheStats = this.imageLoader.getCacheStats();

    const perfInfo: PerformanceInfo = {
      totalMetrics: performanceStats.totalMetrics,
      averageDuration: performanceStats.averageDuration.toFixed(2),
      slowOperations: performanceStats.slowOperations
    };

    const cacheInfo: ImageCacheInfo = {
      count: imageCacheStats.count,
      memoryUsage: (imageCacheStats.memoryUsage / (1024 * 1024)).toFixed(2) + 'MB',
      hitRate: (imageCacheStats.hitRate * 100).toFixed(2) + '%'
    };

    const report: PerformanceReport = {
      timestamp: Date.now(),
      performance: perfInfo,
      imageCache: cacheInfo
    };
    return report;
  }

  /**
   * 启动定期GC
   */
  private startPeriodicGC(): void {
    this.gcTimerId = setInterval((): void => {
      this.optimizeMemory();
    }, this.config.gcInterval);

    LogUtil.info('Periodic memory check started');
  }

  /**
   * 监控页面加载性能
   */
  trackPageLoad(pageName: string, startTime: number): void {
    const duration: number = Date.now() - startTime;
    
    this.monitor.recordMetric({
      type: MetricType.PAGE_LOAD,
      name: `page_load_${pageName}`,
      duration: duration,
      timestamp: Date.now()
    });

    if (duration > 1000) {
      LogUtil.warn(`Slow page load: ${pageName} took ${duration}ms`);
    }
  }

  /**
   * 监控API请求性能
   */
  trackApiRequest(apiName: string, durationParam: number, success: boolean): void {
    this.monitor.recordMetric({
      type: MetricType.API_REQUEST,
      name: `api_${apiName}`,
      duration: durationParam,
      timestamp: Date.now()
    });

    if (durationParam > 2000) {
      LogUtil.warn(`Slow API request: ${apiName} took ${durationParam}ms`);
    }
  }

  /**
   * 销毁
   */
  destroy(): void {
    if (this.gcTimerId !== 0) {
      clearInterval(this.gcTimerId);
    }

    this.monitor.destroy();
    this.clearCache();
    this.isInitialized = false;

    LogUtil.info('OptimizationManager destroyed');
  }
}

/**
 * 性能信息接口
 */
interface PerformanceInfo {
  totalMetrics: number;
  averageDuration: string;
  slowOperations: number;
}

/**
 * 图片缓存信息接口
 */
interface ImageCacheInfo {
  count: number;
  memoryUsage: string;
  hitRate: string;
}

/**
 * 性能报告接口
 */
interface PerformanceReport {
  timestamp: number;
  performance: PerformanceInfo;
  imageCache: ImageCacheInfo;
}