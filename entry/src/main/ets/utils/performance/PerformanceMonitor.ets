/**
 * SmartGuardian - 性能监控工具(Simplified)
 * 用于监控应用运行时性能指标
 */

import { LogUtil } from '../LogUtil';

const TAG = 'PerformanceMonitor';

/**
 * 性能指标类型
 */
export enum MetricType {
  PAGE_LOAD = 'PAGE_LOAD',
  API_REQUEST = 'API_REQUEST',
  COMPONENT_RENDER = 'COMPONENT_RENDER',
  DATA_PROCESSING = 'DATA_PROCESSING'
}

/**
 * 性能指标数据
 */
export interface PerformanceMetric {
  type: MetricType;
  name: string;
  duration: number;
  timestamp: number;
}

/**
 * 性能统计数据
 */
export interface PerformanceStats {
  totalMetrics: number;
  averageDuration: number;
  maxDuration: number;
  minDuration: number;
  slowOperations: number;
}

/**
 * 监控配置接口
 */
export interface MonitorConfig {
  enableLogging: boolean;
  enableReporting: boolean;
  slowThreshold: number;
}

/**
 * 性能监控器(Simplified)
 */
export class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private metrics: PerformanceMetric[] = [];
  private slowThreshold: number = 1000;
  private startTimes: Map<string, number> = new Map();
  private config: MonitorConfig = {
    enableLogging: true,
    enableReporting: false,
    slowThreshold: 1000
  };
  private isInitialized: boolean = false;

  private constructor() {}

  static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  /**
   * 初始化监控器
   */
  initialize(config: MonitorConfig): void {
    this.config = config;
    this.slowThreshold = config.slowThreshold;
    this.isInitialized = true;
    LogUtil.info('PerformanceMonitor initialized');
  }

  /**
   * 开始计时
   */
  startTimer(name: string): void {
    this.startTimes.set(name, Date.now());
  }

  /**
   * 结束计时
   */
  endTimer(name: string, type: MetricType): number {
    const startTime = this.startTimes.get(name);
    if (!startTime) {
      return 0;
    }

    const duration = Date.now() - startTime;
    this.startTimes.delete(name);

    this.recordMetric({
      type: type,
      name: name,
      duration: duration,
      timestamp: Date.now()
    });

    return duration;
  }

  /**
   * 异步测量工具方法
   */
  async measureAsync<T>(name: string, type: MetricType, operation: () => Promise<T>): Promise<T> {
    this.startTimer(name);
    try {
      const result = await operation();
      this.endTimer(name, type);
      return result;
    } catch (error) {
      this.endTimer(name, type);
      throw new Error(String(error));
    }
  }

  /**
   * 记录性能指标
   */
  recordMetric(metric: PerformanceMetric): void {
    this.metrics.push(metric);

    if (metric.duration > this.slowThreshold) {
      LogUtil.warn(`Slow operation: ${metric.name} took ${metric.duration}ms`);
    }

    if (this.metrics.length > 1000) {
      this.metrics.shift();
    }
  }

  /**
   * 获取慢操作列表
   */
  getSlowOperations(limit: number = 10): PerformanceMetric[] {
    const slowOps = this.metrics
      .filter(m => m.duration > this.slowThreshold)
      .sort((a, b) => b.duration - a.duration)
      .slice(0, limit);
    return slowOps;
  }

  /**
   * 获取统计数据
   */
  getStats(): PerformanceStats {
    if (this.metrics.length === 0) {
      return {
        totalMetrics: 0,
        averageDuration: 0,
        maxDuration: 0,
        minDuration: 0,
        slowOperations: 0
      };
    }

    let total = 0;
    let max = 0;
    let min = Infinity;
    let slowCount = 0;

    for (const metric of this.metrics) {
      total += metric.duration;
      if (metric.duration > max) max = metric.duration;
      if (metric.duration < min) min = metric.duration;
      if (metric.duration > this.slowThreshold) slowCount++;
    }

    return {
      totalMetrics: this.metrics.length,
      averageDuration: total / this.metrics.length,
      maxDuration: max,
      minDuration: min,
      slowOperations: slowCount
    };
  }

  /**
   * 清除指标
   */
  clearMetrics(): void {
    this.metrics = [];
    this.startTimes.clear();
  }

  /**
   * 销毁
   */
  destroy(): void {
    this.clearMetrics();
    this.isInitialized = false;
  }
}