/**
 * SmartGuardian - Timeline Models
 * Timeline related request and response types
 */

/**
 * Timeline item
 * Compatible with OpenAPI Timeline schema and current page usage.
 */
export interface TimelineItem {
  id: number;
  studentId: number;
  timelineType: 'ATTENDANCE' | 'HOMEWORK' | 'MESSAGE' | 'ORDER' | 'NOTE';
  bizId?: number;
  title: string;
  content: string;
  bizDate?: string;
  timestamp: string;
  operatorUserId?: number;
  operatorName?: string;
}

/**
 * Timeline query params
 */
export interface TimelineQueryParams {
  bizDate?: string;
  pageNum?: number;
  pageSize?: number;
  timelineType?: string;
}

/**
 * Student timeline entry (alias for TimelineItem)
 * 
 * @description 学生动态时间线，兼容旧代码
 */
export type StudentTimeline = TimelineItem;
