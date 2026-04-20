/**
 * SmartGuardian - Message API (V2) [BETA]
 * Message API using ApiWrapper
 * 
 * @description 使用 ApiWrapper 的消息 API 服务（实验版本）
 * @beta 此模块为实验版本，尚未启用
 * @status RESERVED - 预留架构，暂未投入使用
 * 
 * @note 当前项目使用 v1 MessageService (../message.ts)，此模块为未来 API 升级预留
 * @see ../message.ts - 当前生产环境消息服务
 */

import { api, ApiResult } from '../../utils/api';
import { MessageRecord, MessageStatistics, SendMessageParams } from '../../models/message';
import { PageResponse } from '../../models/common';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Message API (V2)
 * 
 * @description 消息服务类
 * @class
 */
export class MessageApi {
  /**
   * Get message list
   * 
   * @description 获取消息列表
   * @param {object} params - 查询参数
   * @returns {Promise<ApiResult<PageResponse<MessageRecord>>>} 消息列表结果
   */
  static async getList(params?: {
    pageNum?: number;
    pageSize?: number;
    msgType?: string;
    readStatus?: boolean;
  }): Promise<ApiResult<PageResponse<MessageRecord>>> {
    return api.get<PageResponse<MessageRecord>>(ApiEndpoints.MESSAGES, params, {
      source: 'MessageApi.getList'
    });
  }
  
  /**
   * Get unread count
   * 
   * @description 获取未读消息数量
   * @returns {Promise<ApiResult<number>>} 未读数量结果
   */
  static async getUnreadCount(): Promise<ApiResult<number>> {
    return api.get<number>(ApiEndpoints.MESSAGES_UNREAD, undefined, {
      source: 'MessageApi.getUnreadCount',
      enableCache: true,
      cacheTime: 30 * 1000
    });
  }
  
  /**
   * Get message statistics
   * 
   * @description 获取消息统计
   * @returns {Promise<ApiResult<MessageStatistics>>} 统计结果
   */
  static async getStatistics(): Promise<ApiResult<MessageStatistics>> {
    return api.get<MessageStatistics>(ApiEndpoints.MESSAGES_STATS, undefined, {
      source: 'MessageApi.getStatistics',
      enableCache: true,
      cacheTime: 60 * 1000
    });
  }
  
  /**
   * Mark as read
   * 
   * @description 标记消息为已读
   * @param {number} id - 消息ID
   * @returns {Promise<ApiResult<null>>} 操作结果
   */
  static async markAsRead(id: number): Promise<ApiResult<null>> {
    // 清除缓存
    api.clearCache(ApiEndpoints.MESSAGES_UNREAD);
    return api.post<null>(`${ApiEndpoints.MESSAGES}/${id}/read`, undefined, {
      source: 'MessageApi.markAsRead'
    });
  }
  
  /**
   * Mark all as read
   * 
   * @description 标记所有消息为已读
   * @param {string} msgType - 消息类型（可选）
   * @returns {Promise<ApiResult<null>>} 操作结果
   */
  static async markAllAsRead(msgType?: string): Promise<ApiResult<null>> {
    api.clearCache(ApiEndpoints.MESSAGES_UNREAD);
    return api.post<null>(`${ApiEndpoints.MESSAGES}/read-all`, { msgType }, {
      source: 'MessageApi.markAllAsRead'
    });
  }
  
  /**
   * Delete message
   * 
   * @description 删除消息
   * @param {number} id - 消息ID
   * @returns {Promise<ApiResult<null>>} 操作结果
   */
  static async delete(id: number): Promise<ApiResult<null>> {
    return api.delete<null>(`${ApiEndpoints.MESSAGES}/${id}`, {
      source: 'MessageApi.delete'
    });
  }
  
  /**
   * Send message
   * 
   * @description 发送消息（管理员用）
   * @param {SendMessageParams} data - 消息数据
   * @returns {Promise<ApiResult<MessageRecord>>} 发送结果
   */
  static async send(data: SendMessageParams): Promise<ApiResult<MessageRecord>> {
    return api.post<MessageRecord>(ApiEndpoints.MESSAGES, data, {
      source: 'MessageApi.send'
    });
  }
}
