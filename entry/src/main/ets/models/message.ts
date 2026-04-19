/**
 * SmartGuardian - Message Models
 * Message and notification related types
 */

import { MessageType } from './common';

/**
 * Message record
 */
export interface MessageRecord {
  id: number;
  userId: number;
  msgType: string;
  title: string;
  content: string;
  bizType?: string;
  bizId?: number;
  readStatus: boolean;
  readAt?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * Message query params
 */
export interface MessageQueryParams {
  msgType?: string;
  readStatus?: boolean;
  pageNum?: number;
  pageSize?: number;
}

/**
 * Message statistics
 */
export interface MessageStatistics {
  total: number;
  unread: number;
  byType: Record<string, number>;
}

/**
 * Message detail with related business info
 */
export interface MessageDetail extends MessageRecord {
  relatedInfo?: {
    studentName?: string;
    actionText?: string;
    actionUrl?: string;
  };
}

/**
 * Send message params
 */
export interface SendMessageParams {
  userId: number;
  msgType: string;
  title: string;
  content: string;
  bizType?: string;
  bizId?: number;
  pushNow?: boolean;
}

/**
 * Batch mark read params
 */
export interface BatchMarkReadParams {
  messageIds: number[];
  msgType?: string;
}
