/**
 * SmartGuardian - Message Store
 * Message state management
 */

import { MessageRecord, MessageType } from '../models/attendance';

/**
 * Message store keys
 */
const MESSAGE_LIST_KEY = 'message_list';
const UNREAD_COUNT_KEY = 'unread_count';
const CURRENT_MESSAGE_KEY = 'current_message';

/**
 * Message state management
 */
export class MessageStore {
  /**
   * Set message list
   */
  static setMessageList(messages: MessageRecord[]): void {
    AppStorage.setOrCreate(MESSAGE_LIST_KEY, messages);
  }

  /**
   * Get message list
   */
  static getMessageList(): MessageRecord[] {
    return AppStorage.get<MessageRecord[]>(MESSAGE_LIST_KEY) ?? [];
  }

  /**
   * Set unread count
   */
  static setUnreadCount(count: number): void {
    AppStorage.setOrCreate(UNREAD_COUNT_KEY, count);
  }

  /**
   * Get unread count
   */
  static getUnreadCount(): number {
    return AppStorage.get<number>(UNREAD_COUNT_KEY) ?? 0;
  }

  /**
   * Increment unread count
   */
  static incrementUnread(): void {
    const count = this.getUnreadCount();
    this.setUnreadCount(count + 1);
  }

  /**
   * Decrement unread count
   */
  static decrementUnread(): void {
    const count = this.getUnreadCount();
    if (count > 0) {
      this.setUnreadCount(count - 1);
    }
  }

  /**
   * Set current message
   */
  static setCurrentMessage(message: MessageRecord): void {
    AppStorage.setOrCreate(CURRENT_MESSAGE_KEY, message);
  }

  /**
   * Get current message
   */
  static getCurrentMessage(): MessageRecord | null {
    return AppStorage.get<MessageRecord>(CURRENT_MESSAGE_KEY) ?? null;
  }

  /**
   * Mark message as read
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
   */
  static getMessagesByType(type: MessageType): MessageRecord[] {
    const messages = this.getMessageList();
    return messages.filter(m => m.msgType === type);
  }

  /**
   * Clear all message data
   */
  static clearAll(): void {
    AppStorage.delete(MESSAGE_LIST_KEY);
    AppStorage.delete(UNREAD_COUNT_KEY);
    AppStorage.delete(CURRENT_MESSAGE_KEY);
  }
}
