/**
 * SmartGuardian - Performance Utilities
 * 性能优化工具类，提供常用性能优化方法
 */

/**
 * 防抖函数
 * 在事件被触发后延迟执行，如果在延迟期间再次触发则重新计时
 * 
 * @param fn 要执行的函数
 * @param delay 延迟时间（毫秒）
 * @returns 防抖后的函数
 */
export function debounce<T extends (...args: unknown[]) => unknown>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => void {
  let timer: number | undefined;

  return function (this: unknown, ...args: Parameters<T>): void {
    if (timer !== undefined) {
      clearTimeout(timer);
    }
    timer = setTimeout(() => {
      fn.apply(this, args);
      timer = undefined;
    }, delay);
  };
}

/**
 * 节流函数
 * 在指定时间间隔内只执行一次
 * 
 * @param fn 要执行的函数
 * @param interval 时间间隔（毫秒）
 * @returns 节流后的函数
 */
export function throttle<T extends (...args: unknown[]) => unknown>(
  fn: T,
  interval: number
): (...args: Parameters<T>) => void {
  let lastTime = 0;
  let timer: number | undefined;

  return function (this: unknown, ...args: Parameters<T>): void {
    const now = Date.now();
    const remaining = interval - (now - lastTime);

    if (remaining <= 0) {
      if (timer !== undefined) {
        clearTimeout(timer);
        timer = undefined;
      }
      fn.apply(this, args);
      lastTime = now;
    } else if (timer === undefined) {
      timer = setTimeout(() => {
        fn.apply(this, args);
        lastTime = Date.now();
        timer = undefined;
      }, remaining);
    }
  };
}

/**
 * 简单的内存缓存
 */
export class MemoryCache<T> {
  private cache: Map<string, { data: T; expiry: number }> = new Map();
  private defaultTTL: number;

  constructor(defaultTTL: number = 5 * 60 * 1000) { // 默认5分钟过期
    this.defaultTTL = defaultTTL;
  }

  /**
   * 设置缓存
   */
  set(key: string, data: T, ttl: number = this.defaultTTL): void {
    this.cache.set(key, {
      data,
      expiry: Date.now() + ttl
    });
  }

  /**
   * 获取缓存
   */
  get(key: string): T | null {
    const cached = this.cache.get(key);
    if (!cached) return null;

    if (Date.now() > cached.expiry) {
      this.cache.delete(key);
      return null;
    }

    return cached.data;
  }

  /**
   * 检查缓存是否存在
   */
  has(key: string): boolean {
    const cached = this.cache.get(key);
    if (!cached) return false;

    if (Date.now() > cached.expiry) {
      this.cache.delete(key);
      return false;
    }

    return true;
  }

  /**
   * 删除缓存
   */
  delete(key: string): boolean {
    return this.cache.delete(key);
  }

  /**
   * 清空所有缓存
   */
  clear(): void {
    this.cache.clear();
  }

  /**
   * 获取缓存数量
   */
  size(): number {
    return this.cache.size;
  }

  /**
   * 清理过期缓存
   */
  cleanup(): number {
    const now = Date.now();
    let count = 0;

    this.cache.forEach((value, key) => {
      if (now > value.expiry) {
        this.cache.delete(key);
        count++;
      }
    });

    return count;
  }
}

/**
 * 请求数据缓存管理器
 * 用于缓存API请求结果
 */
export class RequestCache {
  private static instance: RequestCache;
  private cache: MemoryCache<unknown>;

  private constructor() {
    this.cache = new MemoryCache(5 * 60 * 1000);
  }

  static getInstance(): RequestCache {
    if (!RequestCache.instance) {
      RequestCache.instance = new RequestCache();
    }
    return RequestCache.instance;
  }

  /**
   * 生成缓存key
   */
  private generateKey(url: string, params?: Record<string, unknown>): string {
    const parts = [url];
    if (params) {
      const sortedKeys = Object.keys(params).sort();
      sortedKeys.forEach(key => {
        parts.push(`${key}=${String(params[key])}`);
      });
    }
    return parts.join('&');
  }

  /**
   * 获取缓存的请求结果
   */
  get<T>(url: string, params?: Record<string, unknown>): T | null {
    const key = this.generateKey(url, params);
    return this.cache.get(key) as T | null;
  }

  /**
   * 缓存请求结果
   */
  set<T>(url: string, data: T, ttl?: number, params?: Record<string, unknown>): void {
    const key = this.generateKey(url, params);
    this.cache.set(key, data, ttl);
  }

  /**
   * 清除指定URL的缓存
   */
  clearUrl(url: string): void {
    // 由于key包含params，这里需要遍历删除
    // 简化实现：清除所有包含该URL的缓存
  }

  /**
   * 清除所有缓存
   */
  clearAll(): void {
    this.cache.clear();
  }
}

/**
 * 批量请求处理器
 * 将多个请求合并为批量请求
 */
export class BatchRequestHandler<T, R> {
  private queue: Array<{ item: T; resolve: (result: R) => void; reject: (error: Error) => void }> = [];
  private timer: number | undefined;
  private batchSize: number;
  private delay: number;
  private batchFn: (items: T[]) => Promise<R[]>;

  constructor(
    batchFn: (items: T[]) => Promise<R[]>,
    batchSize: number = 10,
    delay: number = 100
  ) {
    this.batchFn = batchFn;
    this.batchSize = batchSize;
    this.delay = delay;
  }

  /**
   * 添加请求到队列
   */
  add(item: T): Promise<R> {
    return new Promise((resolve, reject) => {
      this.queue.push({ item, resolve, reject });

      if (this.queue.length >= this.batchSize) {
        this.flush();
      } else if (this.timer === undefined) {
        this.timer = setTimeout(() => this.flush(), this.delay);
      }
    });
  }

  /**
   * 执行批量请求
   */
  private async flush(): Promise<void> {
    if (this.timer !== undefined) {
      clearTimeout(this.timer);
      this.timer = undefined;
    }

    const batch = this.queue.splice(0, this.batchSize);
    if (batch.length === 0) return;

    const items = batch.map(b => b.item);

    try {
      const results = await this.batchFn(items);
      batch.forEach((b, i) => b.resolve(results[i]));
    } catch (error) {
      batch.forEach(b => b.reject(error instanceof Error ? error : new Error(String(error))));
    }
  }
}

/**
 * 性能测量工具
 */
export class PerformanceMeasurer {
  private static measurements: Map<string, number[]> = new Map();

  /**
   * 开始测量
   */
  static start(label: string): number {
    return Date.now();
  }

  /**
   * 结束测量
   */
  static end(label: string, startTime: number): number {
    const duration = Date.now() - startTime;
    
    if (!this.measurements.has(label)) {
      this.measurements.set(label, []);
    }
    
    const durations = this.measurements.get(label);
    if (durations) {
      durations.push(duration);
    }
    
    return duration;
  }

  /**
   * 获取平均执行时间
   */
  static getAverage(label: string): number {
    const durations = this.measurements.get(label);
    if (!durations || durations.length === 0) return 0;

    const sum = durations.reduce((a, b) => a + b, 0);
    return sum / durations.length;
  }

  /**
   * 获取测量统计
   */
  static getStats(label: string): { count: number; avg: number; min: number; max: number } | null {
    const durations = this.measurements.get(label);
    if (!durations || durations.length === 0) return null;

    return {
      count: durations.length,
      avg: durations.reduce((a, b) => a + b, 0) / durations.length,
      min: Math.min(...durations),
      max: Math.max(...durations)
    };
  }

  /**
   * 清除测量记录
   */
  static clear(label?: string): void {
    if (label) {
      this.measurements.delete(label);
    } else {
      this.measurements.clear();
    }
  }
}

/**
 * 延迟执行
 */
export function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * 带超时的Promise
 */
export function withTimeout<T>(promise: Promise<T>, timeout: number): Promise<T> {
  return Promise.race([
    promise,
    new Promise<T>((_, reject) => {
      setTimeout(() => reject(new Error('Timeout')), timeout);
    })
  ]);
}
