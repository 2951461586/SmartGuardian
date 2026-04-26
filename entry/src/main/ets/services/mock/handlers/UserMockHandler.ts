import { ApiResponse } from '../../../models/common';
import { UserInfo } from '../../../models/user';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockUsers } from '../mockData';
import { MockSessionState } from '../shared/mockState';
import { getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class UserMockHandler {
  static async getCurrentUser(): Promise<ApiResponse<UserInfo>> {
    return mockResponse(MockSessionState.getCurrentUser());
  }

  static async getUsers(url: string): Promise<ApiResponse<UserInfo[]>> {
    const roleType = getQueryParam(url, 'roleType');
    const users = mockUsers.filter((item: UserInfo) => {
      return roleType.length === 0 || item.roleType === roleType;
    });
    return mockResponse(users);
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.AUTH_ME && method === HttpMethod.GET) {
      return this.getCurrentUser() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.USERS && method === HttpMethod.GET) {
      return this.getUsers(url) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
