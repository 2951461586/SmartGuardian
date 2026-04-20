/**
 * SmartGuardian - Persistent State Manager
 * State persistence support using PersistentStorage
 * 
 * @description 状态持久化管理器，支持跨应用生命周期的状态持久化
 * @features
 * - 基于 PersistentStorage 的持久化
 * - 支持类型安全的存取
 * - 自动序列化/反序列化
 * - 支持过期时间设置
 */

/**
 * Persist options
 * 
 * @description 持久化选项接口
 */
export interface PersistOptions {
  /** 是否持久化，默认 true */
  persist?: boolean;
  
  /** 过期时间（毫秒），0 表示永不过期 */
  expiresIn?: number;
  
  /** 默认值 */
  defaultValue?: unknown;
}

/**
 * Persisted item metadata
 * 
 * @description 持久化项元数据
 */
interface PersistedItemMetadata {
  /** 创建时间戳 */
  createdAt: number;
  
  /** 过期时间戳 */
  expiresAt?: number;
  
  /** 数据类型 */
  type: string;
}

/**
 * Persistent State Manager
 * 
 * @description 持久化状态管理器
 * @class
 * @example
 * ```typescript
 * // 设置持久化状态
 * PersistentStateManager.set('user_preferences', preferences, {
 *   expiresIn: 7 * 24 * 60 * 60 * 1000 // 7天
 * });
 * 
 * // 获取持久化状态
 * const preferences = PersistentStateManager.get<UserPreferences>('user_preferences');
 * 
 * // 检查是否过期
 * if (PersistentStateManager.isExpired('user_preferences')) {
 *   // 重新加载
 * }
 * ```
 */
export class PersistentStateManager {
  private static readonly METADATA_PREFIX = '__meta__';
  private static initializedKeys: Set<string> = new Set();
  
  /**
   * Initialize persistent key
   * 
   * @description 初始化持久化键（必须在应用启动时调用）
   * @param {string} key - 键名
   * @param {T} defaultValue - 默认值
   */
  static initKey<T>(key: string, defaultValue: T): void {
    if (!this.initializedKeys.has(key)) {
      PersistentStorage.persistProp<T>(key, defaultValue);
      this.initializedKeys.add(key);
    }
  }
  
  /**
   * Initialize multiple keys
   * 
   * @description 批量初始化持久化键
   * @param {Array<{key: string, defaultValue: unknown}>} keys - 键配置数组
   */
  static initKeys(keys: Array<{ key: string; defaultValue: unknown }>): void {
    keys.forEach(({ key, defaultValue }) => {
      this.initKey(key, defaultValue);
    });
  }
  
  /**
   * Set persistent value
   * 
   * @description 设置持久化值
   * @param {string} key - 键名
   * @param {T} value - 值
   * @param {PersistOptions} options - 持久化选项
   */
  static set<T>(key: string, value: T, options?: PersistOptions): void {
    const shouldPersist = options?.persist !== false;
    
    if (shouldPersist) {
      // 确保键已初始化
      if (!this.initializedKeys.has(key)) {
        PersistentStorage.persistProp<T>(key, value);
        this.initializedKeys.add(key);
      } else {
        // 更新值
        AppStorage.setOrCreate<T>(key, value);
      }
      
      // 存储元数据
      const metadataKey = this.METADATA_PREFIX + key;
      const metadata: PersistedItemMetadata = {
        createdAt: Date.now(),
        expiresAt: options?.expiresIn ? Date.now() + options.expiresIn : undefined,
        type: typeof value
      };
      
      if (!this.initializedKeys.has(metadataKey)) {
        PersistentStorage.persistProp<PersistedItemMetadata>(metadataKey, metadata);
        this.initializedKeys.add(metadataKey);
      } else {
        AppStorage.setOrCreate<PersistedItemMetadata>(metadataKey, metadata);
      }
    } else {
      // 不持久化，只存到 AppStorage
      AppStorage.setOrCreate<T>(key, value);
    }
  }
  
  /**
   * Get persistent value
   * 
   * @description 获取持久化值
   * @param {string} key - 键名
   * @param {T} defaultValue - 默认值
   * @returns {T | undefined} 值
   */
  static get<T>(key: string, defaultValue?: T): T | undefined {
    // 检查是否过期
    if (this.isExpired(key)) {
      this.remove(key);
      return defaultValue;
    }
    
    // 从 AppStorage 获取（PersistentStorage 会同步到 AppStorage）
    return AppStorage.get<T>(key) ?? defaultValue;
  }
  
  /**
   * Check if key exists
   * 
   * @description 检查键是否存在
   * @param {string} key - 键名
   * @returns {boolean} 是否存在
   */
  static has(key: string): boolean {
    return AppStorage.has(key);
  }
  
  /**
   * Remove persistent value
   * 
   * @description 移除持久化值
   * @param {string} key - 键名
   */
  static remove(key: string): void {
    AppStorage.delete(key);
    AppStorage.delete(this.METADATA_PREFIX + key);
    this.initializedKeys.delete(key);
    this.initializedKeys.delete(this.METADATA_PREFIX + key);
  }
  
  /**
   * Check if value is expired
   * 
   * @description 检查值是否过期
   * @param {string} key - 键名
   * @returns {boolean} 是否过期
   */
  static isExpired(key: string): boolean {
    const metadataKey = this.METADATA_PREFIX + key;
    const metadata = AppStorage.get<PersistedItemMetadata>(metadataKey);
    
    if (!metadata || !metadata.expiresAt) {
      return false;
    }
    
    return Date.now() > metadata.expiresAt;
  }
  
  /**
   * Get remaining time
   * 
   * @description 获取剩余有效时间（毫秒）
   * @param {string} key - 键名
   * @returns {number} 剩余时间，-1 表示永不过期，-2 表示已过期或不存在
   */
  static getRemainingTime(key: string): number {
    const metadataKey = this.METADATA_PREFIX + key;
    const metadata = AppStorage.get<PersistedItemMetadata>(metadataKey);
    
    if (!metadata) {
      return -2;
    }
    
    if (!metadata.expiresAt) {
      return -1;
    }
    
    const remaining = metadata.expiresAt - Date.now();
    return remaining > 0 ? remaining : -2;
  }
  
  /**
   * Extend expiration
   * 
   * @description 延长过期时间
   * @param {string} key - 键名
   * @param {number} extendBy - 延长时间（毫秒）
   * @returns {boolean} 是否成功
   */
  static extendExpiration(key: string, extendBy: number): boolean {
    const metadataKey = this.METADATA_PREFIX + key;
    const metadata = AppStorage.get<PersistedItemMetadata>(metadataKey);
    
    if (!metadata) {
      return false;
    }
    
    if (metadata.expiresAt) {
      metadata.expiresAt += extendBy;
      AppStorage.setOrCreate<PersistedItemMetadata>(metadataKey, metadata);
    }
    
    return true;
  }
  
  /**
   * Get metadata
   * 
   * @description 获取持久化项的元数据
   * @param {string} key - 键名
   * @returns {PersistedItemMetadata | undefined} 元数据
   */
  static getMetadata(key: string): PersistedItemMetadata | undefined {
    return AppStorage.get<PersistedItemMetadata>(this.METADATA_PREFIX + key);
  }
  
  /**
   * Clear all initialized keys
   * 
   * @description 清除所有已初始化的键（用于登出时清理）
   */
  static clearAll(): void {
    this.initializedKeys.forEach(key => {
      AppStorage.delete(key);
    });
    this.initializedKeys.clear();
  }
}
