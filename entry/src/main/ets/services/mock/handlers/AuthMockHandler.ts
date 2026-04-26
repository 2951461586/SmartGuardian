import { ApiResponse, UserRole } from '../../../models/common';
import { LoginRequest, LoginResponse, UserInfo } from '../../../models/user';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { getMockLoginResponse } from '../mockData';
import { MockSessionState } from '../shared/mockState';
import { mockNotFound, mockResponse } from '../shared/mockUtils';

export class AuthMockHandler {
  static async login(username: string, roleType?: UserRole): Promise<ApiResponse<LoginResponse>> {
    const response = getMockLoginResponse(username, roleType);
    MockSessionState.setCurrentUser(response.userInfo);
    return mockResponse(response);
  }

  static async getCurrentUser(): Promise<ApiResponse<UserInfo>> {
    return mockResponse(MockSessionState.getCurrentUser());
  }

  static async logout(): Promise<ApiResponse<null>> {
    MockSessionState.resetCurrentUser();
    return mockResponse(null);
  }

  static async handleRequest<T>(path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.AUTH_LOGIN && method === HttpMethod.POST) {
      const body = (data ?? {}) as Partial<LoginRequest>;
      return this.login(body.username ?? 'parent_zhang', body.roleType) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.AUTH_ME && method === HttpMethod.GET) {
      return this.getCurrentUser() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.AUTH_LOGOUT && method === HttpMethod.POST) {
      return this.logout() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.AUTH_REFRESH && method === HttpMethod.POST) {
      return mockResponse({ token: 'mock_refresh_token_' + Date.now() }) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
