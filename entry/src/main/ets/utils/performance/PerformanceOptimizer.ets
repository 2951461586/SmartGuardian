/**
 * SmartGuardian - 性能优化管理器(Simplified)
 * 综合管理应用性能优化策略
 */

import { common } from '@kit.AbilityKit';
import { LogUtil } from '../LogUtil';
import { PerformanceMonitor, MetricType } from './PerformanceMonitor';

const TAG = 'PerformanceOptimizer';

/**
 * 性能优化管理器
 */
export class PerformanceOptimizer {
  private static instance: PerformanceOptimizer;
  private monitor: PerformanceMonitor = PerformanceMonitor.getInstance();
  private isInitialized: boolean = false;

  private constructor() {}

  static getInstance(): PerformanceOptimizer {
    if (!PerformanceOptimizer.instance) {
      PerformanceOptimizer.instance = new PerformanceOptimizer();
    }
    return PerformanceOptimizer.instance;
  }

  /**
   * 初始化
   */
  initialize(): void {
    if (this.isInitialized) {
      return;
    }

    LogUtil.info('PerformanceOptimizer initialized');
    this.isInitialized = true;
  }

  /**
   * 监控页面加载性能
   */
  trackPageLoad(pageName: string, startTime: number): void {
    const duration = Date.now() - startTime;
    
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
  trackApiRequest(apiName: string, duration: number, success: boolean): void {
    this.monitor.recordMetric({
      type: MetricType.API_REQUEST,
      name: `api_${apiName}`,
      duration: duration,
      timestamp: Date.now()
    });

    if (duration > 2000) {
      LogUtil.warn(`Slow API request: ${apiName} took ${duration}ms`);
    }
  }

  /**
   * 获取性能报告
   */
  getPerformanceReport(): string {
    const stats = this.monitor.getStats();
    return `Performance - Metrics: ${stats.totalMetrics}, Avg: ${stats.averageDuration.toFixed(2)}ms`;
  }

  /**
   * 销毁
   */
  destroy(): void {
    this.monitor.destroy();
    this.isInitialized = false;
    LogUtil.info('PerformanceOptimizer destroyed');
  }
}