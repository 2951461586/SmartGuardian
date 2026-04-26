import { ApiResponse, PageResponse } from '../../../models/common';
import { MessageDetail, MessageRecord, MessageStatistics } from '../../../models/message';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockMessageDetails, mockMessageStatistics, mockMessages } from '../mockData';
import { createPageResponse, extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class MessageMockHandler {
  static async getMessages(params?: {
    pageNum?: number;
    pageSize?: number;
  }): Promise<ApiResponse<PageResponse<MessageRecord>>> {
    return mockResponse(createPageResponse(mockMessages, params?.pageNum ?? 1, params?.pageSize ?? 20));
  }

  static async getMessageDetail(messageId: number): Promise<ApiResponse<MessageDetail>> {
    const detail = mockMessageDetails.find((item: MessageDetail) => item.id === messageId);
    if (!detail) {
      return mockNotFound<MessageDetail>('Message not found');
    }
    return mockResponse(detail);
  }

  static async getUnreadCount(): Promise<ApiResponse<{ count: number }>> {
    return mockResponse({ count: mockMessageStatistics.unread });
  }

  static async getMessageStatistics(): Promise<ApiResponse<MessageStatistics>> {
    return mockResponse(mockMessageStatistics);
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.MESSAGES && method === HttpMethod.GET) {
      return this.getMessages({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        readStatus: false,
        ...(data as Record<string, string | number | boolean>)
      } as MessageRecord) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES_UNREAD_COUNT && method === HttpMethod.GET) {
      return this.getUnreadCount() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES_STATISTICS && method === HttpMethod.GET) {
      return this.getMessageStatistics() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES_BATCH_READ && method === HttpMethod.POST) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.MESSAGES_READ_ALL && method === HttpMethod.POST) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/read') > -1 && method === HttpMethod.POST) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/delete') > -1 && method === HttpMethod.POST) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    const messageId = extractId(path, ApiEndpoints.MESSAGES + '/');
    if (messageId > 0 && method === HttpMethod.GET) {
      return this.getMessageDetail(messageId) as Promise<HttpResponse<T>>;
    }
    if (messageId > 0 && method === HttpMethod.DELETE) {
      return mockResponse<void>(undefined) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
