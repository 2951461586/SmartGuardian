import { ApiEndpoints, API_BASE } from '../../../constants/ApiEndpoints';
import { AbnormalAlertCard, TodayStatusCard } from '../../../models/card';
import { ApiResponse } from '../../../models/common';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockAbnormalAlerts, mockTodayStatusCard } from '../mockData';
import { mockNotFound, mockResponse } from '../shared/mockUtils';

export class CardMockHandler {
  static async getTodayStatus(): Promise<ApiResponse<TodayStatusCard>> {
    return mockResponse(mockTodayStatusCard);
  }

  static async getAbnormalAlerts(): Promise<ApiResponse<AbnormalAlertCard | null>> {
    return mockResponse(mockAbnormalAlerts[0] ?? null);
  }

  static async handleRequest<T>(path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.CARDS_TODAY_STATUS && method === HttpMethod.GET) {
      return this.getTodayStatus() as Promise<HttpResponse<T>>;
    }
    if ((path === ApiEndpoints.CARDS_ABNORMAL_ALERT || path === `${API_BASE}/cards/alerts`) && method === HttpMethod.GET) {
      return this.getAbnormalAlerts() as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
