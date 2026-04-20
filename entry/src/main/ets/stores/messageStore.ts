/**
 * SmartGuardian - Message Store
 * Message state management with reactive support
 * 
 * @description 消息状态管理 Store，负责消息数据和未读数量的全局状态管理
 * @features
 * - 消息列表缓存管理
 * - 未读数量实时追踪
 * - 消息已读标记
 * - 按类型筛选消息
 * - 响应式状态变更通知
 * - 持久化支持
 */

import { MessageRecord } from '../models/message';
import { ReactiveStore, StateChangeListener } from './core';

/**
 * Message store keys
 * 
 * @description AppStorage 存储键名常量
 */
const MESSAGE_LIST_KEY = 'message_list';
const UNREAD_COUNT_KEY = 'unread_count';
const CURRENT_MESSAGE_KEY = 'current_message';
const MESSAGE_FILTER_KEY = 'message_filter';

/**
 * Message filter type
 * 
 * @description 消息筛选类型
 */
export type MessageTab = 'ALL' | 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER';

/**
 * Message filter
 * 
 * @description 消息筛选条件接口
 */
export interface MessageFilter {
  /** 消息类型 */
  type?: MessageTab;
  
  /** 是否已读 */
  readStatus?: boolean;
  
  /** 开始日期 */
  startDate?: string;
  
  /** 结束日期 */
  endDate?: string;
}

/**
 * Message state management with reactive support
 * 
 * @description 消息状态管理类，提供消息数据的增删改查操作
 * @class
 * @example
 * ```typescript
 * // 设置消息列表
 * MessageStore.setMessageList(messages);
 * 
 * // 监听未读数量变更
 * MessageStore.onUnreadCountChange((event) => {
 *   console.log('未读数量:', event.newValue);
 * });
 * 
 * // 标记消息为已读
 * MessageStore.markMessageAsRead(messageId);
 * ```
 */
export class MessageStore extends ReactiveStore {
  // 初始化 Store 配置
  static {
    this.initOptions({
      name: 'MessageStore',
      persistent: false // 消息列表不持久化，但未读数量可以持久化
    });
  }
  
  /**
   * Set message list
   * 
   * @description 设置消息列表到全局状态
   * @param {MessageRecord[]} messages - 消息列表数组
   */
  static setMessageList(messages: MessageRecord[]): void {
    this.setValue(MESSAGE_LIST_KEY, messages);
  }
  
  /**
   * Get message list
   * 
   * @description 从全局状态获取消息列表
   * @returns {MessageRecord[]} 消息列表数组，如果为空则返回空数组
   */
  static getMessageList(): MessageRecord[] {
    return this.getValue<MessageRecord[]>(MESSAGE_LIST_KEY) ?? [];
  }
  
  /**
   * Set unread count
   * 
   * @description 设置未读消息数量（持久化）
   * @param {number} count - 未读数量
   */
  static setUnreadCount(count: number): void {
    this.setValue(UNREAD_COUNT_KEY, count, { persist: true });
  }
  
  /**
   * Get unread count
   * 
   * @description 获取未读消息数量
   * @returns {number} 未读消息数量，如果未设置则返回 0
   */
  static getUnreadCount(): number {
    return this.getValue<number>(UNREAD_COUNT_KEY) ?? 0;
  }
  
  /**
   * Increment unread count
   * 
   * @description 增加未读消息数量（收到新消息时调用）
   */
  static incrementUnread(): void {
    const count = this.getUnreadCount();
    this.setUnreadCount(count + 1);
  }
  
  /**
   * Decrement unread count
   * 
   * @description 减少未读消息数量（标记已读时调用）
   */
  static decrementUnread(): void {
    const count = this.getUnreadCount();
    if (count > 0) {
      this.setUnreadCount(count - 1);
    }
  }
  
  /**
   * Set current message
   * 
   * @description 设置当前选中的消息（用于消息详情页）
   * @param {MessageRecord} message - 消息对象
   */
  static setCurrentMessage(message: MessageRecord): void {
    this.setValue(CURRENT_MESSAGE_KEY, message);
  }
  
  /**
   * Get current message
   * 
   * @description 获取当前选中的消息
   * @returns {MessageRecord | null} 当前消息对象，如果未设置则返回 null
   */
  static getCurrentMessage(): MessageRecord | null {
    return this.getValue<MessageRecord>(CURRENT_MESSAGE_KEY) ?? null;
  }
  
  /**
   * Set message filter
   * 
   * @description 设置消息筛选条件
   * @param {MessageFilter} filter - 筛选条件对象
   */
  static setMessageFilter(filter: MessageFilter): void {
    this.setValue(MESSAGE_FILTER_KEY, filter);
  }
  
  /**
   * Get message filter
   * 
   * @description 获取当前的消息筛选条件
   * @returns {MessageFilter} 筛选条件对象
   */
  static getMessageFilter(): MessageFilter {
    return this.getValue<MessageFilter>(MESSAGE_FILTER_KEY) ?? {};
  }
  
  /**
   * Mark message as read
   * 
   * @description 将指定消息标记为已读，并更新未读数量
   * @param {number} messageId - 消息 ID
   */
  static markMessageAsRead(messageId: number): void {
    const messages = this.getMessageList();
    const message = messages.find(m => m.id === messageId);
    if (message && !message.readStatus) {
      message.readStatus = true;
      this.setMessageList(messages);
      this.decrementUnread();
    }
  }
  
  /**
   * Add new message
   * 
   * @description 添加新消息到列表顶部
   * @param {MessageRecord} message - 新消息对象
   */
  static addMessage(message: MessageRecord): void {
    const messages = this.getMessageList();
    this.setMessageList([message, ...messages]);
    if (!message.readStatus) {
      this.incrementUnread();
    }
  }
  
  /**
   * Remove message
   * 
   * @description 从列表中移除消息
   * @param {number} messageId - 消息 ID
   */
  static removeMessage(messageId: number): void {
    const messages = this.getMessageList();
    const message = messages.find(m => m.id === messageId);
    const filtered = messages.filter(m => m.id !== messageId);
    this.setMessageList(filtered);
    if (message && !message.readStatus) {
      this.decrementUnread();
    }
  }
  
  /**
   * Find message by ID
   * 
   * @description 根据 ID 查找消息
   * @param {number} messageId - 消息 ID
   * @returns {MessageRecord | undefined} 找到的消息
   */
  static findMessageById(messageId: number): MessageRecord | undefined {
    return this.getMessageList().find(m => m.id === messageId);
  }
  
  /**
   * Get messages by type
   * 
   * @description 按类型获取消息列表
   * @param {string} type - 消息类型
   * @returns {MessageRecord[]} 筛选后的消息列表
   */
  static getMessagesByType(type: string): MessageRecord[] {
    if (type === 'ALL') {
      return this.getMessageList();
    }
    return this.getMessageList().filter(m => m.msgType === type);
  }
  
  /**
   * Clear all messages
   * 
   * @description 清空所有消息
   */
  static clearMessages(): void {
    this.setMessageList([]);
    this.setUnreadCount(0);
  }
  
  // ============ 响应式订阅方法 ============
  
  /**
   * Subscribe to message list changes
   * 
   * @description 订阅消息列表变更
   * @param {StateChangeListener<MessageRecord[]>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onMessageListChange(listener: StateChangeListener<MessageRecord[]>): () => void {
    return this.subscribe<MessageRecord[]>(MESSAGE_LIST_KEY, listener);
  }
  
  /**
   * Subscribe to unread count changes
   * 
   * @description 订阅未读数量变更
   * @param {StateChangeListener<number>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onUnreadCountChange(listener: StateChangeListener<number>): () => void {
    return this.subscribe<number>(UNREAD_COUNT_KEY, listener);
  }
  
  /**
   * Subscribe to current message changes
   * 
   * @description 订阅当前消息变更
   * @param {StateChangeListener<MessageRecord>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onCurrentMessageChange(listener: StateChangeListener<MessageRecord>): () => void {
    return this.subscribe<MessageRecord>(CURRENT_MESSAGE_KEY, listener);
  }
}
