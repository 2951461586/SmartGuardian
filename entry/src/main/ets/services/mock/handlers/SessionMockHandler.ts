import { ApiResponse } from '../../../models/common';
import { SessionSchedule, SessionWithStudents } from '../../../models/service';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockSessionStudents, mockSessions } from '../mockData';
import { extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class SessionMockHandler {
  static async getSessions(params?: {
    sessionDate?: string;
    teacherUserId?: number;
  }): Promise<ApiResponse<SessionSchedule[]>> {
    let sessions = mockSessions;
    if (params?.sessionDate) {
      sessions = sessions.filter((item: SessionSchedule) => item.sessionDate === params.sessionDate);
    }
    if (params?.teacherUserId) {
      sessions = sessions.filter((item: SessionSchedule) => item.teacherUserId === params.teacherUserId);
    }
    return mockResponse(sessions);
  }

  static async createSession(data: object): Promise<ApiResponse<SessionSchedule>> {
    const body = data as Record<string, string | number>;
    return mockResponse({
      id: Date.now(),
      sessionDate: String(body.sessionDate ?? new Date().toISOString().split('T')[0]),
      startTime: String(body.startTime ?? '16:30:00'),
      endTime: String(body.endTime ?? '18:30:00'),
      teacherUserId: Number(body.teacherUserId) || 2,
      capacity: Number(body.capacity) || 40,
      currentCount: 0,
      sessionNo: 'SES' + Date.now(),
      serviceProductId: Number(body.serviceProductId) || 1,
      maxCapacity: Number(body.maxCapacity) || 40,
      location: String(body.location ?? '托管教室A'),
      status: 'SCHEDULED',
      teacherId: Number(body.teacherUserId) || 2,
      teacherName: '王老师'
    });
  }

  static async updateSession(sessionId: number, data: object): Promise<ApiResponse<SessionSchedule>> {
    const detail = mockSessions.find((item: SessionSchedule) => item.id === sessionId);
    if (!detail) {
      return mockNotFound<SessionSchedule>('Session not found');
    }
    const body = data as Record<string, string | number>;
    return mockResponse({
      ...detail,
      sessionDate: String(body.sessionDate ?? detail.sessionDate),
      startTime: String(body.startTime ?? detail.startTime),
      endTime: String(body.endTime ?? detail.endTime),
      teacherUserId: Number(body.teacherUserId) || detail.teacherUserId,
      capacity: Number(body.capacity) || detail.capacity,
      maxCapacity: Number(body.maxCapacity) || detail.maxCapacity,
      location: String(body.location ?? detail.location),
      status: String(body.status ?? detail.status),
      currentCount: detail.currentCount
    });
  }

  static async getSessionWithStudents(sessionId: number): Promise<ApiResponse<SessionWithStudents>> {
    const session = mockSessions.find((item: SessionSchedule) => item.id === sessionId);
    if (!session) {
      return mockNotFound<SessionWithStudents>('Session not found');
    }
    return mockResponse({
      ...session,
      students: mockSessionStudents
    });
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.SESSIONS && method === HttpMethod.GET) {
      return this.getSessions({
        sessionDate: getQueryParam(url, 'sessionDate') || undefined,
        teacherUserId: Number(getQueryParam(url, 'teacherUserId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.SESSIONS && method === HttpMethod.POST) {
      return this.createSession(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.SESSIONS_TODAY && method === HttpMethod.GET) {
      return this.getSessions() as Promise<HttpResponse<T>>;
    }
    if (path === `${ApiEndpoints.SESSIONS}/generate` && method === HttpMethod.POST) {
      return mockResponse(mockSessions) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/students') > -1 && method === HttpMethod.GET) {
      return this.getSessionWithStudents(extractId(path, ApiEndpoints.SESSIONS + '/')) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.SESSIONS + '/') === 0 && method === HttpMethod.GET) {
      return this.getSessionWithStudents(extractId(path, ApiEndpoints.SESSIONS + '/')) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.SESSIONS + '/') === 0 && method === HttpMethod.POST) {
      return this.updateSession(extractId(path, ApiEndpoints.SESSIONS + '/'), data ?? {}) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
