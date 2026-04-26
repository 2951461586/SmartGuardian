import { ApiResponse, PageResponse } from '../../../models/common';
import { ServiceProduct } from '../../../models/service';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockServiceProducts } from '../mockData';
import { createPageResponse, extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class ServiceMockHandler {
  static async getServiceProducts(params?: {
    pageNum?: number;
    pageSize?: number;
    status?: string;
    serviceType?: string;
  }): Promise<ApiResponse<PageResponse<ServiceProduct>>> {
    let products = mockServiceProducts;
    if (params?.status) {
      products = products.filter((item: ServiceProduct) => item.status === params.status);
    }
    if (params?.serviceType) {
      products = products.filter((item: ServiceProduct) => item.serviceType === params.serviceType);
    }
    return mockResponse(createPageResponse(products, params?.pageNum ?? 1, params?.pageSize ?? 20));
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.SERVICE_PRODUCTS && method === HttpMethod.GET) {
      return this.getServiceProducts({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 20,
        status: getQueryParam(url, 'status') || undefined,
        serviceType: getQueryParam(url, 'serviceType') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.SERVICE_PRODUCTS && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        ...(data as Record<string, string | number>)
      } as ServiceProduct) as Promise<HttpResponse<T>>;
    }
    const serviceId = extractId(path, ApiEndpoints.SERVICE_PRODUCTS + '/');
    if (serviceId > 0 && method === HttpMethod.GET) {
      const detail = mockServiceProducts.find((item: ServiceProduct) => item.id === serviceId);
      if (detail) {
        return mockResponse(detail) as Promise<HttpResponse<T>>;
      }
    }
    if (serviceId > 0 && method === HttpMethod.PUT) {
      const detail = mockServiceProducts.find((item: ServiceProduct) => item.id === serviceId);
      if (detail) {
        return mockResponse({
          ...detail,
          ...(data as Record<string, string | number>)
        }) as Promise<HttpResponse<T>>;
      }
    }
    return mockNotFound<T>();
  }
}
