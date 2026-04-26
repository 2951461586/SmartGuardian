/**
 * SmartGuardian - Message Service API
 * Message and notification related API calls
 * 
 * @description 消息服务 API，提供消息通知、已读标记和消息管理功能
 * @features
 * - 消息列表查询
 * - 消息详情获取
 * - 消息已读标记
 * - 消息统计数据
 * - 管理员发送消息
 */

import { ApiResponse, PageResponse } from '../../models/common';
import {
  MessageRecord,
  MessageQueryParams,
  MessageStatistics,
  MessageUnreadCount,
  MessageDetail,
  SendMessageParams,
  BatchMarkReadParams
} from '../../models/message';
import { get, post } from '../../utils/request';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Message Service
 * 
 * @description 消息服务类，提供消息通知和管理功能
 * @class
 */
export class MessageService {
  static readonly AGC_DOMAIN: string = 'message';
  static readonly AGC_FUNCTION: string = 'smartguardian-message';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.MESSAGES;

  /**
   * Get message list
   * 
   * @description 分页获取消息列表，支持按类型、已读状态筛选
   * @param params 查询参数
   * @returns 分页消息响应
   */
  static async getMessages(params: MessageQueryParams): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    return get<PageResponse<MessageRecord>>(ApiEndpoints.MESSAGES, params);
  }

  /**
   * Get message detail
   * 
   * @description 获取消息详情
   * @param messageId 消息ID
   * @returns 消息详情响应
   */
  static async getMessageDetail(messageId: number): Promise<ApiResponse<MessageDetail>> {
    return get<MessageDetail>(ApiEndpoints.messageDetail(messageId));
  }

  /**
   * Mark message as read
   * 
   * @description 标记单条消息为已读
   * @param messageId 消息ID
   * @returns 操作响应
   */
  static async markAsRead(messageId: number): Promise<ApiResponse<MessageRecord>> {
    return post<MessageRecord>(ApiEndpoints.messageRead(messageId));
  }

  /**
   * Batch mark messages as read
   * 
   * @description 批量标记消息为已读
   * @param params 批量标记参数（消息ID列表）
   * @returns 操作响应
   */
  static async batchMarkAsRead(params: BatchMarkReadParams): Promise<ApiResponse<void>> {
    return post<void>(ApiEndpoints.MESSAGES_BATCH_READ, params);
  }

  /**
   * Mark all messages as read
   * 
   * @description 标记所有消息为已读
   * @returns 操作响应
   */
  static async markAllAsRead(): Promise<ApiResponse<void>> {
    return post<void>(ApiEndpoints.MESSAGES_READ_ALL);
  }

  /**
   * Delete message
   * 
   * @description 删除指定消息
   * @param messageId 消息ID
   * @returns 操作响应
   */
  static async deleteMessage(messageId: number): Promise<ApiResponse<void>> {
    return post<void>(ApiEndpoints.messageDelete(messageId));
  }

  /**
   * Get unread count
   * 
   * @description 获取未读消息数量
   * @returns 未读数量响应
   */
  static async getUnreadCount(): Promise<ApiResponse<MessageUnreadCount>> {
    return get<MessageUnreadCount>(ApiEndpoints.MESSAGES_UNREAD_COUNT);
  }

  /**
   * Get message statistics
   * 
   * @description 获取消息统计数据（按类型统计未读数量）
   * @returns 统计数据响应
   */
  static async getStatistics(): Promise<ApiResponse<MessageStatistics>> {
    return get<MessageStatistics>(ApiEndpoints.MESSAGES_STATISTICS);
  }

  /**
   * Send message (admin only)
   * 
   * @description 发送消息（仅管理员权限可用）
   * @param params 发送参数
   * @returns 发送成功的消息响应
   */
  static async sendMessage(params: SendMessageParams): Promise<ApiResponse<MessageRecord>> {
    return post<MessageRecord>(ApiEndpoints.MESSAGES, params);
  }

  /**
   * Get messages by type
   * 
   * @description 按消息类型获取消息列表（封装方法）
   * @param msgType 消息类型
   * @param pageNum 页码，默认 1
   * @param pageSize 每页数量，默认 20
   * @returns 分页消息响应
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
   * 
   * @description 获取未读消息列表（封装方法）
   * @param pageNum 页码，默认 1
   * @param pageSize 每页数量，默认 20
   * @returns 分页消息响应
   */
  static async getUnreadMessages(
    pageNum: number = 1,
    pageSize: number = 20
  ): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    return this.getMessages({ readStatus: false, pageNum, pageSize });
  }
}
