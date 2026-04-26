import { ApiResponse, PageResponse } from '../../../models/common';
import { AlertRecord, AlertStatistics } from '../../../models/alert';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockAlertStatistics, mockAlerts } from '../mockData';
import { createPageResponse, extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class AlertMockHandler {
  static async getAlerts(params?: {
    studentId?: number;
    alertType?: string;
    severity?: string;
    status?: string;
    pageNum?: number;
    pageSize?: number;
  }): Promise<ApiResponse<PageResponse<AlertRecord>>> {
    let alerts = mockAlerts;
    if (params?.status) {
      alerts = alerts.filter((item: AlertRecord) => item.status === params.status);
    }
    if (params?.severity) {
      alerts = alerts.filter((item: AlertRecord) => item.severity === params.severity);
    }
    if (params?.alertType) {
      alerts = alerts.filter((item: AlertRecord) => item.alertType === params.alertType);
    }
    if (params?.studentId) {
      alerts = alerts.filter((item: AlertRecord) => item.studentId === params.studentId);
    }
    return mockResponse(createPageResponse(alerts, params?.pageNum ?? 1, params?.pageSize ?? 20));
  }

  static async getAlertStatistics(): Promise<ApiResponse<AlertStatistics>> {
    return mockResponse(mockAlertStatistics);
  }

  static async getActiveCount(): Promise<ApiResponse<{ count: number }>> {
    return mockResponse({ count: mockAlerts.filter((item: AlertRecord) => item.status === 'ACTIVE').length });
  }

  static async acknowledgeAlert(): Promise<ApiResponse<void>> {
    return mockResponse<void>(undefined);
  }

  static async resolveAlert(): Promise<ApiResponse<void>> {
    return mockResponse<void>(undefined);
  }

  static async dismissAlert(): Promise<ApiResponse<void>> {
    return mockResponse<void>(undefined);
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.ALERTS && method === HttpMethod.GET) {
      return this.getAlerts({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20,
        status: getQueryParam(url, 'status') || undefined,
        severity: getQueryParam(url, 'severity') || undefined,
        alertType: getQueryParam(url, 'alertType') || undefined,
        studentId: Number(getQueryParam(url, 'studentId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ALERTS_ACTIVE_COUNT && method === HttpMethod.GET) {
      return this.getActiveCount() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ALERTS_STATISTICS && method === HttpMethod.GET) {
      return this.getAlertStatistics() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/acknowledge') > -1 && method === HttpMethod.POST) {
      return this.acknowledgeAlert() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/resolve') > -1 && method === HttpMethod.POST) {
      return this.resolveAlert() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/dismiss') > -1 && method === HttpMethod.POST) {
      return this.dismissAlert() as Promise<HttpResponse<T>>;
    }
    const alertId = extractId(path, ApiEndpoints.ALERTS + '/');
    if (alertId > 0 && method === HttpMethod.GET) {
      const detail = mockAlerts.find((item: AlertRecord) => item.id === alertId);
      if (detail) {
        return mockResponse(detail) as Promise<HttpResponse<T>>;
      }
    }
    return mockNotFound<T>();
  }
}
