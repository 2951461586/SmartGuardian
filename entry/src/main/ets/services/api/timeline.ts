/**
 * SmartGuardian - Timeline API Service
 * Student timeline related APIs
 */

import { get } from '../../utils/request';
import { ApiResponse, PageResponse } from '../../models/common';
import { TimelineItem, TimelineQueryParams } from '../../models/timeline';

/**
 * Timeline API Service
 */
export class TimelineService {
  /**
   * Get student timeline
   */
  static async getStudentTimeline(studentId: number, params?: TimelineQueryParams): Promise<ApiResponse<PageResponse<TimelineItem> | TimelineItem[]>> {
    return get<PageResponse<TimelineItem> | TimelineItem[]>(`/api/v1/timeline/students/${studentId}`, params);
  }
}
