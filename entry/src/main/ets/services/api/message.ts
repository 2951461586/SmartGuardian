/**
 * SmartGuardian - Message Service API
 * Message and notification related API calls
 */

import { ApiResponse, PageResponse } from '../../models/common';
import {
  MessageRecord,
  MessageQueryParams,
  MessageStatistics,
  MessageDetail,
  SendMessageParams,
  BatchMarkReadParams
} from '../../models/message';
import { get, post } from '../../utils/request';

/**
 * Message Service
 */
export class MessageService {
  private static BASE_URL = '/api/messages';

  /**
   * Get message list
   */
  static async getMessages(params: MessageQueryParams): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    return get<PageResponse<MessageRecord>>(this.BASE_URL, params);
  }

  /**
   * Get message detail
   */
  static async getMessageDetail(messageId: number): Promise<ApiResponse<MessageDetail>> {
    return get<MessageDetail>(`${this.BASE_URL}/${messageId}`);
  }

  /**
   * Mark message as read
   */
  static async markAsRead(messageId: number): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${messageId}/read`);
  }

  /**
   * Batch mark messages as read
   */
  static async batchMarkAsRead(params: BatchMarkReadParams): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/batch-read`, params);
  }

  /**
   * Mark all messages as read
   */
  static async markAllAsRead(): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/read-all`);
  }

  /**
   * Delete message
   */
  static async deleteMessage(messageId: number): Promise<ApiResponse<void>> {
    return post<void>(`${this.BASE_URL}/${messageId}/delete`);
  }

  /**
   * Get unread count
   */
  static async getUnreadCount(): Promise<ApiResponse<{ count: number }>> {
    return get<{ count: number }>(`${this.BASE_URL}/unread-count`);
  }

  /**
   * Get message statistics
   */
  static async getStatistics(): Promise<ApiResponse<MessageStatistics>> {
    return get<MessageStatistics>(`${this.BASE_URL}/statistics`);
  }

  /**
   * Send message (admin only)
   */
  static async sendMessage(params: SendMessageParams): Promise<ApiResponse<MessageRecord>> {
    return post<MessageRecord>(this.BASE_URL, params);
  }

  /**
   * Get messages by type
   */
  static async getMessagesByType(
    msgType: string,
    pageNum: number = 1,
    pageSize: number = 20
  ): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    return this.getMessages({ msgType, pageNum, pageSize });
  }

  /**
   * Get unread messages
   */
  static async getUnreadMessages(
    pageNum: number = 1,
    pageSize: number = 20
  ): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    return this.getMessages({ readStatus: false, pageNum, pageSize });
  }
}
