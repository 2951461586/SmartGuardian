/**
 * SmartGuardian - State Notifier
 * State change notification mechanism
 * 
 * @description 状态变更通知机制，支持订阅者模式
 * @features
 * - 发布订阅模式
 * - 类型安全的状态变更通知
 * - 支持多个监听器
 * - 自动清理机制
 */

/**
 * State change event
 * 
 * @description 状态变更事件接口
 */
export interface StateChangeEvent<T> {
  /** 状态键名 */
  key: string;
  
  /** 旧值 */
  oldValue: T | undefined;
  
  /** 新值 */
  newValue: T;
  
  /** 变更时间戳 */
  timestamp: number;
  
  /** 变更来源 */
  source?: string;
}

/**
 * State change listener
 * 
 * @description 状态变更监听器类型
 */
export type StateChangeListener<T> = (event: StateChangeEvent<T>) => void;

/**
 * Listener subscription
 * 
 * @description 监听器订阅信息
 */
interface ListenerSubscription {
  /** 监听器ID */
  id: number;
  
  /** 状态键名 */
  key: string;
  
  /** 监听器函数 */
  listener: StateChangeListener<unknown>;
  
  /** 是否一次性监听 */
  once: boolean;
}

/**
 * State Notifier
 * 
 * @description 状态变更通知器，实现发布订阅模式
 * @class
 * @example
 * ```typescript
 * // 订阅状态变更
 * const unsubscribe = StateNotifier.subscribe('user_info', (event) => {
 *   console.log('用户信息变更:', event.newValue);
 * });
 * 
 * // 发布状态变更
 * StateNotifier.notify('user_info', oldValue, newValue);
 * 
 * // 取消订阅
 * unsubscribe();
 * ```
 */
export class StateNotifier {
  private static listeners: Map<string, ListenerSubscription[]> = new Map();
  private static nextListenerId: number = 1;
  
  /**
   * Subscribe to state changes
   * 
   * @description 订阅指定键的状态变更
   * @param {string} key - 状态键名
   * @param {StateChangeListener<T>} listener - 监听器函数
   * @param {boolean} once - 是否只监听一次
   * @returns {() => void} 取消订阅函数
   */
  static subscribe<T>(
    key: string,
    listener: StateChangeListener<T>,
    once: boolean = false
  ): () => void {
    const id = this.nextListenerId++;
    const subscription: ListenerSubscription = {
      id,
      key,
      listener: listener as StateChangeListener<unknown>,
      once
    };
    
    if (!this.listeners.has(key)) {
      this.listeners.set(key, []);
    }
    this.listeners.get(key)!.push(subscription);
    
    // 返回取消订阅函数
    return () => {
      this.unsubscribe(key, id);
    };
  }
  
  /**
   * Subscribe once
   * 
   * @description 订阅一次状态变更（触发后自动取消）
   * @param {string} key - 状态键名
   * @param {StateChangeListener<T>} listener - 监听器函数
   * @returns {() => void} 取消订阅函数
   */
  static once<T>(
    key: string,
    listener: StateChangeListener<T>
  ): () => void {
    return this.subscribe(key, listener, true);
  }
  
  /**
   * Notify state change
   * 
   * @description 通知状态变更
   * @param {string} key - 状态键名
   * @param {T | undefined} oldValue - 旧值
   * @param {T} newValue - 新值
   * @param {string} source - 变更来源
   */
  static notify<T>(
    key: string,
    oldValue: T | undefined,
    newValue: T,
    source?: string
  ): void {
    const subscriptions = this.listeners.get(key);
    if (!subscriptions || subscriptions.length === 0) {
      return;
    }
    
    const event: StateChangeEvent<T> = {
      key,
      oldValue,
      newValue,
      timestamp: Date.now(),
      source
    };
    
    // 复制数组以避免在迭代过程中修改
    const toRemove: number[] = [];
    const toCall = [...subscriptions];
    
    for (const sub of toCall) {
      try {
        sub.listener(event as StateChangeEvent<unknown>);
        if (sub.once) {
          toRemove.push(sub.id);
        }
      } catch (error) {
        console.error(`StateNotifier listener error for key "${key}":`, error);
      }
    }
    
    // 移除一次性监听器
    if (toRemove.length > 0) {
      const remaining = subscriptions.filter(s => !toRemove.includes(s.id));
      if (remaining.length === 0) {
        this.listeners.delete(key);
      } else {
        this.listeners.set(key, remaining);
      }
    }
  }
  
  /**
   * Unsubscribe
   * 
   * @description 取消订阅
   * @param {string} key - 状态键名
   * @param {number} id - 监听器ID
   */
  private static unsubscribe(key: string, id: number): void {
    const subscriptions = this.listeners.get(key);
    if (!subscriptions) {
      return;
    }
    
    const remaining = subscriptions.filter(s => s.id !== id);
    if (remaining.length === 0) {
      this.listeners.delete(key);
    } else {
      this.listeners.set(key, remaining);
    }
  }
  
  /**
   * Clear all listeners
   * 
   * @description 清除所有监听器
   */
  static clearAll(): void {
    this.listeners.clear();
  }
  
  /**
   * Clear listeners for key
   * 
   * @description 清除指定键的所有监听器
   * @param {string} key - 状态键名
   */
  static clearForKey(key: string): void {
    this.listeners.delete(key);
  }
  
  /**
   * Get listener count
   * 
   * @description 获取指定键的监听器数量
   * @param {string} key - 状态键名
   * @returns {number} 监听器数量
   */
  static getListenerCount(key: string): number {
    return this.listeners.get(key)?.length ?? 0;
  }
}
