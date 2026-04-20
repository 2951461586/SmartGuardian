/**
 * SmartGuardian - Timeline API Service
 * Student timeline related APIs
 * 
 * @description 时间线 API 服务，提供学生成长轨迹和活动时间线功能
 * @module timeline
 */

import { get } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';
import { TimelineItem, TimelineQueryParams } from '../../models/timeline';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

/**
 * Timeline API Service
 * 
 * @description 时间线服务类，提供学生活动时间线相关功能
 * @class
 */
export class TimelineService {
  /**
   * Get student timeline
   * 
   * @description 获取学生活动时间线数据
   * @param studentId 学生ID
   * @param params 查询参数（分页、时间范围等）
   * @returns 时间线数据响应（支持分页或数组形式）
   */
  static async getStudentTimeline(studentId: number, params?: TimelineQueryParams): Promise<ApiResponse<PageResponse<TimelineItem> | TimelineItem[]>> {
    return get<PageResponse<TimelineItem> | TimelineItem[]>(ApiEndpoints.studentTimeline(studentId), params);
  }
}
