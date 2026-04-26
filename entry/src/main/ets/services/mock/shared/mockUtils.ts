import { ApiResponse, PageResponse } from '../../../models/common';
import { ApiConfig } from '../../../config/api.config';
import { HttpResponse } from '../../../utils/request';

export async function delay(ms: number): Promise<void> {
  return new Promise((resolve: Function): void => {
    setTimeout((): void => resolve(), ms);
  });
}

export async function mockResponse<T>(data: T): Promise<ApiResponse<T>> {
  if (ApiConfig.ENABLE_LOGGING) {
    console.info('[Mock] Returning mock data');
  }
  await delay(ApiConfig.MOCK_DELAY);
  return {
    code: 0,
    message: 'success',
    data: data
  };
}

export function getQueryParam(url: string, key: string): string {
  const queryIndex = url.indexOf('?');
  if (queryIndex < 0) {
    return '';
  }
  const queryString = url.substring(queryIndex + 1);
  const pairs = queryString.split('&');
  for (let i = 0; i < pairs.length; i++) {
    const pair = pairs[i];
    const equalsIndex = pair.indexOf('=');
    if (equalsIndex < 0) {
      continue;
    }
    const paramKey = decodeURIComponent(pair.substring(0, equalsIndex));
    if (paramKey === key) {
      return decodeURIComponent(pair.substring(equalsIndex + 1));
    }
  }
  return '';
}

export function getPath(url: string): string {
  const queryIndex = url.indexOf('?');
  if (queryIndex < 0) {
    return url;
  }
  return url.substring(0, queryIndex);
}

export function createPageResponse<T>(list: T[], pageNum: number, pageSize: number): PageResponse<T> {
  return {
    list: list,
    total: list.length,
    pageNum: pageNum,
    pageSize: pageSize
  };
}

export function extractId(path: string, prefix: string): number {
  if (path.indexOf(prefix) !== 0) {
    return 0;
  }
  const suffix = path.substring(prefix.length);
  const firstSegment = suffix.split('/')[0];
  if (!firstSegment) {
    return 0;
  }
  const parsed = Number(firstSegment);
  return Number.isFinite(parsed) ? parsed : 0;
}

export function mockNotFound<T>(message: string = 'Mock route not found'): HttpResponse<T> {
  return {
    code: 404,
    message,
    data: null as T
  };
}
