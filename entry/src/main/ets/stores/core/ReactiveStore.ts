/**
 * SmartGuardian - Reactive Store
 * Base class for reactive state management
 * 
 * @description 响应式状态管理基类，支持持久化和变更通知
 * @features
 * - 自动状态变更通知
 * - 可选持久化支持
 * - 类型安全的状态管理
 * - 响应式更新支持
 */

import { StateNotifier, StateChangeListener, StateChangeEvent } from './StateNotifier';
import { PersistentStateManager, PersistOptions } from './PersistentStateManager';

/**
 * Store options
 * 
 * @description Store 配置选项
 */
export interface StoreOptions {
  /** Store 名称（用于调试和日志） */
  name: string;
  
  /** 是否启用持久化 */
  persistent?: boolean;
  
  /** 默认过期时间（毫秒） */
  defaultExpiresIn?: number;
}

/**
 * Reactive Store Base Class
 * 
 * @description 响应式状态管理基类
 * @class
 * @example
 * ```typescript
 * class UserStore extends ReactiveStore {
 *   private static readonly USER_KEY = 'user_info';
 *   
 *   static setUserInfo(userInfo: UserInfo): void {
 *     this.setValue(this.USER_KEY, userInfo, { persist: true });
 *   }
 *   
 *   static getUserInfo(): UserInfo | null {
 *     return this.getValue<UserInfo>(this.USER_KEY) ?? null;
 *   }
 *   
 *   static onUserInfoChange(listener: StateChangeListener<UserInfo>): () => void {
 *     return this.subscribe(this.USER_KEY, listener);
 *   }
 * }
 * ```
 */
export abstract class ReactiveStore {
  protected static options: StoreOptions = {
    name: 'ReactiveStore',
    persistent: false
  };
  
  /**
   * Initialize store
   * 
   * @description 初始化 Store 配置
   * @param {StoreOptions} options - Store 配置选项
   */
  protected static initOptions(options: StoreOptions): void {
    this.options = { ...this.options, ...options };
  }
  
  /**
   * Set value
   * 
   * @description 设置状态值，自动触发变更通知
   * @param {string} key - 状态键名
   * @param {T} value - 状态值
   * @param {PersistOptions} options - 持久化选项
   */
  protected static setValue<T>(
    key: string,
    value: T,
    options?: PersistOptions
  ): void {
    const oldValue = this.getValue<T>(key);
    
    // 确定是否持久化
    const shouldPersist = options?.persist ?? this.options.persistent;
    
    if (shouldPersist) {
      PersistentStateManager.set(key, value, {
        persist: true,
        expiresIn: options?.expiresIn ?? this.options.defaultExpiresIn
      });
    } else {
      AppStorage.setOrCreate<T>(key, value);
    }
    
    // 触发变更通知
    StateNotifier.notify(key, oldValue, value, this.options.name);
  }
  
  /**
   * Get value
   * 
   * @description 获取状态值
   * @param {string} key - 状态键名
   * @param {T} defaultValue - 默认值
   * @returns {T | undefined} 状态值
   */
  protected static getValue<T>(key: string, defaultValue?: T): T | undefined {
    // 优先从持久化存储获取
    if (this.options.persistent) {
      const value = PersistentStateManager.get<T>(key, defaultValue);
      if (value !== undefined) {
        return value;
      }
    }
    
    // 回退到 AppStorage
    return AppStorage.get<T>(key) ?? defaultValue;
  }
  
  /**
   * Delete value
   * 
   * @description 删除状态值
   * @param {string} key - 状态键名
   */
  protected static deleteValue(key: string): void {
    const oldValue = this.getValue(key);
    
    if (this.options.persistent) {
      PersistentStateManager.remove(key);
    } else {
      AppStorage.delete(key);
    }
    
    // 触发变更通知（新值为 undefined）
    StateNotifier.notify(key, oldValue, undefined, this.options.name);
  }
  
  /**
   * Check if has value
   * 
   * @description 检查是否存在状态值
   * @param {string} key - 状态键名
   * @returns {boolean} 是否存在
   */
  protected static hasValue(key: string): boolean {
    if (this.options.persistent) {
      return PersistentStateManager.has(key);
    }
    return AppStorage.has(key);
  }
  
  /**
   * Subscribe to state changes
   * 
   * @description 订阅状态变更
   * @param {string} key - 状态键名
   * @param {StateChangeListener<T>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  protected static subscribe<T>(
    key: string,
    listener: StateChangeListener<T>
  ): () => void {
    return StateNotifier.subscribe<T>(key, listener);
  }
  
  /**
   * Subscribe once
   * 
   * @description 订阅一次状态变更
   * @param {string} key - 状态键名
   * @param {StateChangeListener<T>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  protected static subscribeOnce<T>(
    key: string,
    listener: StateChangeListener<T>
  ): () => void {
    return StateNotifier.once<T>(key, listener);
  }
  
  /**
   * Update value with function
   * 
   * @description 使用函数更新状态值
   * @param {string} key - 状态键名
   * @param {(current: T | undefined) => T} updater - 更新函数
   * @param {PersistOptions} options - 持久化选项
   */
  protected static updateValue<T>(
    key: string,
    updater: (current: T | undefined) => T,
    options?: PersistOptions
  ): void {
    const currentValue = this.getValue<T>(key);
    const newValue = updater(currentValue);
    this.setValue(key, newValue, options);
  }
  
  /**
   * Get state change event stream
   * 
   * @description 获取状态变更事件流（用于调试或日志）
   * @param {string} key - 状态键名
   * @returns {StateChangeEvent<T>[]} 最近的事件列表
   */
  protected static getRecentEvents<T>(key: string): StateChangeEvent<T>[] {
    // 这个方法可以扩展来存储最近的事件历史
    // 目前返回空数组，可以后续实现
    return [];
  }
}

/**
 * Create reactive property decorator helper
 * 
 * @description 创建响应式属性的辅助函数
 * @param {string} key - 状态键名
 * @param {T} defaultValue - 默认值
 * @param {PersistOptions} options - 持久化选项
 * @returns {Object} getter 和 setter
 */
export function createReactiveProperty<T>(
  key: string,
  defaultValue?: T,
  options?: PersistOptions
): {
  get: () => T | undefined;
  set: (value: T) => void;
  subscribe: (listener: StateChangeListener<T>) => () => void;
} {
  return {
    get: () => {
      if (options?.persist) {
        return PersistentStateManager.get<T>(key, defaultValue);
      }
      return AppStorage.get<T>(key) ?? defaultValue;
    },
    set: (value: T) => {
      const oldValue = AppStorage.get<T>(key);
      
      if (options?.persist) {
        PersistentStateManager.set(key, value, options);
      } else {
        AppStorage.setOrCreate<T>(key, value);
      }
      
      StateNotifier.notify(key, oldValue, value);
    },
    subscribe: (listener: StateChangeListener<T>) => {
      return StateNotifier.subscribe<T>(key, listener);
    }
  };
}
