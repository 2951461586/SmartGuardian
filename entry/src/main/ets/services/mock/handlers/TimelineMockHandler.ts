import { ApiResponse } from '../../../models/common';
import { TimelineItem } from '../../../models/timeline';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockTimeline } from '../mockData';
import { extractId, mockNotFound, mockResponse } from '../shared/mockUtils';

export class TimelineMockHandler {
  static async getTimeline(studentId: number): Promise<ApiResponse<TimelineItem[]>> {
    const timeline = mockTimeline.filter((item: TimelineItem) => item.studentId === studentId);
    return mockResponse(timeline);
  }

  static async handleRequest<T>(path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path.indexOf(`${ApiEndpoints.TIMELINE}/students/`) === 0 && method === HttpMethod.GET) {
      return this.getTimeline(extractId(path, `${ApiEndpoints.TIMELINE}/students/`)) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
