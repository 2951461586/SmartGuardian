/**
 * SmartGuardian - Message Store
 * Message state management
 * 
 * @description 消息状态管理 Store，负责消息数据和未读数量的全局状态管理
 * @features
 * - 消息列表缓存管理
 * - 未读数量实时追踪
 * - 消息已读标记
 * - 按类型筛选消息
 */

import { MessageRecord } from '../models/message';

/**
 * Message store keys
 * 
 * @description AppStorage 存储键名常量
 */
const MESSAGE_LIST_KEY = 'message_list';
const UNREAD_COUNT_KEY = 'unread_count';
const CURRENT_MESSAGE_KEY = 'current_message';

/**
 * Message state management
 * 
 * @description 消息状态管理类，提供消息数据的增删改查操作
 * @class
 * @example
 * ```typescript
 * // 设置消息列表
 * MessageStore.setMessageList(messages);
 * 
 * // 获取未读数量
 * const unreadCount = MessageStore.getUnreadCount();
 * 
 * // 标记消息为已读
 * MessageStore.markMessageAsRead(messageId);
 * ```
 */
export class MessageStore {
  /**
   * Set message list
   * 
   * @description 设置消息列表到全局状态
   * @param {MessageRecord[]} messages - 消息列表数组
   * @returns {void}
   * @example
   * ```typescript
   * const messages = await MessageService.getMessages();
   * MessageStore.setMessageList(messages.data);
   * ```
   */
  static setMessageList(messages: MessageRecord[]): void {
    AppStorage.setOrCreate(MESSAGE_LIST_KEY, messages);
  }

  /**
   * Get message list
   * 
   * @description 从全局状态获取消息列表
   * @returns {MessageRecord[]} 消息列表数组，如果为空则返回空数组
   * @example
   * ```typescript
   * const messages = MessageStore.getMessageList();
   * console.log('消息数量:', messages.length);
   * ```
   */
  static getMessageList(): MessageRecord[] {
    return AppStorage.get<MessageRecord[]>(MESSAGE_LIST_KEY) ?? [];
  }

  /**
   * Set unread count
   * 
   * @description 设置未读消息数量
   * @param {number} count - 未读数量
   * @returns {void}
   * @example
   * ```typescript
   * MessageStore.setUnreadCount(5);
   * ```
   */
  static setUnreadCount(count: number): void {
    AppStorage.setOrCreate(UNREAD_COUNT_KEY, count);
  }

  /**
   * Get unread count
   * 
   * @description 获取未读消息数量
   * @returns {number} 未读消息数量，如果未设置则返回 0
   * @example
   * ```typescript
   * const unreadCount = MessageStore.getUnreadCount();
   * console.log('未读消息:', unreadCount);
   * ```
   */
  static getUnreadCount(): number {
    return AppStorage.get<number>(UNREAD_COUNT_KEY) ?? 0;
  }

  /**
   * Increment unread count
   * 
   * @description 增加未读消息数量（收到新消息时调用）
   * @returns {void}
   * @example
   * ```typescript
   * // 收到新消息
   * MessageStore.incrementUnread();
   * ```
   */
  static incrementUnread(): void {
    const count = this.getUnreadCount();
    this.setUnreadCount(count + 1);
  }

  /**
   * Decrement unread count
   * 
   * @description 减少未读消息数量（标记已读时调用）
   * @returns {void}
   * @example
   * ```typescript
   * MessageStore.decrementUnread();
   * ```
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
   * @returns {void}
   * @example
   * ```typescript
   * MessageStore.setCurrentMessage(message);
   * router.pushUrl({ url: '/pages/parent/ParentMessageDetailPage' });
   * ```
   */
  static setCurrentMessage(message: MessageRecord): void {
    AppStorage.setOrCreate(CURRENT_MESSAGE_KEY, message);
  }

  /**
   * Get current message
   * 
   * @description 获取当前选中的消息
   * @returns {MessageRecord | null} 当前消息对象，如果未设置则返回 null
   * @example
   * ```typescript
   * const currentMessage = MessageStore.getCurrentMessage();
   * if (currentMessage) {
   *   console.log('当前消息:', currentMessage.content);
   * }
   * ```
   */
  static getCurrentMessage(): MessageRecord | null {
    return AppStorage.get<MessageRecord>(CURRENT_MESSAGE_KEY) ?? null;
  }

  /**
   * Mark message as read
   * 
   * @description 将指定消息标记为已读，并更新未读数量
   * @param {number} messageId - 消息 ID
   * @returns {void}
   * @example
   * ```typescript
   * MessageStore.markMessageAsRead(123);
   * ```
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
   * @returns {void}
   * @example
   * ```typescript
   * const newMessage = { id: 1, content: '新消息', ... };
   * MessageStore.addMessage(newMessage);
   * ```
   */
  static addMessage(message: MessageRecord): void {
    const messages = this.getMessageList();
    messages.unshift(message);
    this.setMessageList(messages);
    if (!message.readStatus) {
      this.incrementUnread();
    }
  }

  /**
   * Get messages by type
   * 
   * @description 按消息类型筛选消息列表
   * @param {string} type - 消息类型 (SYSTEM, ATTENDANCE, HOMEWORK, ORDER, CHAT)
   * @returns {MessageRecord[]} 符合类型的消息列表
   * @example
   * ```typescript
   * const systemMessages = MessageStore.getMessagesByType('SYSTEM');
   * console.log('系统消息数量:', systemMessages.length);
   * ```
   */
  static getMessagesByType(type: string): MessageRecord[] {
    const messages = this.getMessageList();
    return messages.filter(m => m.msgType === type);
  }

  /**
   * Clear all message data
   * 
   * @description 清除所有消息相关数据（用于退出登录）
   * @returns {void}
   * @example
   * ```typescript
   * // 用户退出登录时调用
   * MessageStore.clearAll();
   * ```
   */
  static clearAll(): void {
    AppStorage.delete(MESSAGE_LIST_KEY);
    AppStorage.delete(UNREAD_COUNT_KEY);
    AppStorage.delete(CURRENT_MESSAGE_KEY);
  }
}
