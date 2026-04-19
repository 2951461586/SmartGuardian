/**
 * SmartGuardian - 图片加载优化器(Simplified)
 * 实现图片懒加载、缓存和内存优化
 */

import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { LogUtil } from '../LogUtil';
import { PerformanceMonitor, MetricType } from './PerformanceMonitor';

const TAG = 'ImageLoader';

/**
 * 图片缓存配置
 */
export interface ImageCacheConfig {
  maxSize: number;
  maxMemorySize: number;
  enableDiskCache: boolean;
  diskCachePath?: string;
}

/**
 * 缓存项
 */
interface CacheItem {
  data: image.PixelMap | string;
  size: number;
  timestamp: number;
  hits: number;
}

/**
 * 图片加载选项
 */
export interface ImageLoadOptions {
  width?: number;
  height?: number;
  quality?: number;
  placeholder?: Resource | string;
  errorPlaceholder?: Resource | string;
  enableCache?: boolean;
  priority?: string;
}

/**
 * 图片加载器
 * 提供图片缓存、懒加载、尺寸优化等功能
 */
export class ImageLoader {
  private static instance: ImageLoader;
  private context: common.UIAbilityContext | null = null;
  private memoryCache: Map<string, CacheItem> = new Map();
  private config: ImageCacheConfig = {
    maxSize: 100,
    maxMemorySize: 50 * 1024 * 1024,
    enableDiskCache: true
  };
  private currentMemoryUsage: number = 0;
  private loadingQueue: Map<string, Promise<image.PixelMap | null>> = new Map();
  private monitor: PerformanceMonitor;
  private isInitialized: boolean = false;

  private constructor() {
    this.monitor = PerformanceMonitor.getInstance();
  }

  static getInstance(): ImageLoader {
    if (!ImageLoader.instance) {
      ImageLoader.instance = new ImageLoader();
    }
    return ImageLoader.instance;
  }

  /**
   * 初始化图片加载器
   */
  initialize(context: common.UIAbilityContext, config?: ImageCacheConfig): void {
    this.context = context;
    if (config !== undefined) {
      if (config.maxSize !== undefined) this.config.maxSize = config.maxSize;
      if (config.maxMemorySize !== undefined) this.config.maxMemorySize = config.maxMemorySize;
      if (config.enableDiskCache !== undefined) this.config.enableDiskCache = config.enableDiskCache;
      if (config.diskCachePath !== undefined) this.config.diskCachePath = config.diskCachePath;
    }
    this.isInitialized = true;
    LogUtil.info('ImageLoader initialized');
  }

  /**
   * 加载图片
   */
  async loadImage(url: string, options?: ImageLoadOptions): Promise<image.PixelMap | null> {
    const cacheKey = this.getCacheKey(url, options);

    // 检查缓存
    if (options !== undefined && options.enableCache !== false) {
      const cached = this.getFromCache(cacheKey);
      if (cached !== null && typeof cached !== 'string') {
        LogUtil.debug(`Image loaded from cache: ${url}`);
        return cached;
      }
    }

    // 检查是否正在加载
    const loadingPromise = this.loadingQueue.get(cacheKey);
    if (loadingPromise !== undefined) {
      return await loadingPromise;
    }

    // 开始加载
    const loadPromise = this.performLoadImage(url, cacheKey, options);
    this.loadingQueue.set(cacheKey, loadPromise);

    try {
      const result = await loadPromise;
      return result;
    } finally {
      this.loadingQueue.delete(cacheKey);
    }
  }

  /**
   * 执行图片加载
   */
  private async performLoadImage(
    url: string,
    cacheKey: string,
    options?: ImageLoadOptions
  ): Promise<image.PixelMap | null> {
    const startTime = Date.now();
    try {
      // 判断URL类型
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return await this.loadFromNetwork(url, cacheKey, options);
      } else if (url.startsWith('resource://')) {
        return await this.loadFromResource(url, options);
      } else {
        return await this.loadFromLocal(url, cacheKey, options);
      }
    } catch (error) {
      const duration = Date.now() - startTime;
      this.monitor.recordMetric({
        type: MetricType.DATA_PROCESSING,
        name: `load_image_${url}`,
        duration: duration,
        timestamp: Date.now()
      });
      
      LogUtil.error(`Failed to load image: ${url}`, String(error));
      return null;
    }
  }

  /**
   * 从网络加载图片
   */
  private async loadFromNetwork(
    url: string,
    cacheKey: string,
    options?: ImageLoadOptions
  ): Promise<image.PixelMap | null> {
    // 注意：HarmonyOS需要使用@ohos.net.http模块替代fetch
    LogUtil.warn(`Network loading not implemented for: ${url}`);
    return null;
  }

  /**
   * 从资源加载图片
   */
  private async loadFromResource(url: string, options?: ImageLoadOptions): Promise<image.PixelMap | null> {
    try {
      LogUtil.debug(`Loading from resource: ${url}`);
      return null;
    } catch (error) {
      LogUtil.error('Failed to load from resource:', String(error));
      return null;
    }
  }

  /**
   * 从本地文件加载图片
   */
  private async loadFromLocal(
    path: string,
    cacheKey: string,
    options?: ImageLoadOptions
  ): Promise<image.PixelMap | null> {
    try {
      const imageSource = image.createImageSource(path);
      
      const decodingOptions: image.DecodingOptions = {
        editable: true,
        desiredSize: options && options.width && options.height ? 
          { width: options.width, height: options.height } : undefined,
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      };

      const pixelMap = await imageSource.createPixelMap(decodingOptions);

      // 存入缓存
      if (options?.enableCache !== false) {
        const size = options?.width && options?.height ? options.width * options.height * 4 : 0;
        this.putToCache(cacheKey, pixelMap, size);
      }

      return pixelMap;
    } catch (error) {
      LogUtil.error('Failed to load from local:', String(error));
      return null;
    }
  }

  /**
   * 从缓存获取
   */
  private getFromCache(key: string): image.PixelMap | string | null {
    const item = this.memoryCache.get(key);
    if (item) {
      item.hits++;
      item.timestamp = Date.now();
      return item.data;
    }
    return null;
  }

  /**
   * 存入缓存
   */
  private putToCache(key: string, data: image.PixelMap, size: number): void {
    // 检查是否需要清理缓存
    if (this.currentMemoryUsage + size > this.config.maxMemorySize) {
      this.evictCache();
    }

    // 检查数量限制
    if (this.memoryCache.size >= this.config.maxSize) {
      this.evictLRU();
    }

    this.memoryCache.set(key, {
      data: data,
      size: size,
      timestamp: Date.now(),
      hits: 0
    });

    this.currentMemoryUsage += size;
  }

  /**
   * 清理缓存
   */
  private evictCache(): void {
    const keys = Array.from(this.memoryCache.keys());
    const deleteCount = Math.floor(keys.length / 2);

    for (let i = 0; i < deleteCount; i++) {
      const key = keys[i];
      const item = this.memoryCache.get(key);
      if (item) {
        this.currentMemoryUsage -= item.size;
      }
      this.memoryCache.delete(key);
    }

    LogUtil.info(`Evicted ${deleteCount} items from cache`);
  }

  /**
   * LRU清理
   */
  private evictLRU(): void {
    let minHits = Infinity;
    let lruKey = '';

    this.memoryCache.forEach((item, key) => {
      if (item.hits < minHits) {
        minHits = item.hits;
        lruKey = key;
      }
    });

    if (lruKey) {
      const item = this.memoryCache.get(lruKey);
      if (item) {
        this.currentMemoryUsage -= item.size;
      }
      this.memoryCache.delete(lruKey);
    }
  }

  /**
   * 生成缓存键
   */
  private getCacheKey(url: string, options?: ImageLoadOptions): string {
    const parts: string[] = [url];
    if (options?.width) parts.push(`w${options.width}`);
    if (options?.height) parts.push(`h${options.height}`);
    if (options?.quality) parts.push(`q${options.quality}`);
    return parts.join('_');
  }

  /**
   * 清空缓存
   */
  clearCache(): void {
    this.memoryCache.clear();
    this.currentMemoryUsage = 0;
    LogUtil.info('Image cache cleared');
  }

  /**
   * 缓存统计结果
   */
  getCacheStats(): CacheStats {
    let totalHits = 0;
    this.memoryCache.forEach((item: CacheItem) => {
      totalHits += item.hits;
    });

    const stats: CacheStats = {
      count: this.memoryCache.size,
      memoryUsage: this.currentMemoryUsage,
      hitRate: this.memoryCache.size > 0 ? totalHits / this.memoryCache.size : 0
    };
    return stats;
  }
}

/**
 * 缓存统计接口
 */
interface CacheStats {
  count: number;
  memoryUsage: number;
  hitRate: number;
}