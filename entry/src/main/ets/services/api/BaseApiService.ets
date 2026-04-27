/**
 * SmartGuardian - Base API Service
 * Base class for all API services with unified mock control
 * 
 * @description API服务基类，提供统一的Mock控制和请求方法
 * @features
 * - 统一Mock控制
 * - 统一请求方法
 * - 统一错误处理
 * - 统一响应处理
 */

import { get, post, put, del, HttpResponse } from '../../utils/request';
import { ApiResponse, PageResponse, QueryParamsHelper, PageQueryParams } from '../../models/common';
import { ApiWrapper, ApiCallResult } from '../../utils/ApiWrapper';
import { LogUtil } from '../../utils/LogUtil';

/**
 * Mock Control Interface
 */
export interface MockControl {
  /** 是否启用Mock */
  enabled: boolean;
  /** Mock数据获取函数 */
  getData?: (params?: object) => object;
}

/**
 * Base API Service Class
 * @description API服务基类
 */
export abstract class BaseApiService {
  /** 服务名称（用于日志） */
  protected abstract readonly serviceName: string;
  
  /** Mock控制 */
  protected abstract readonly mockControl: MockControl;

  /**
   * Check if mock is enabled
   * @returns 是否启用Mock
   */
  protected isMockEnabled(): boolean {
    return this.mockControl.enabled;
  }

  /**
   * GET request with mock support
   * @param url 请求URL
   * @param params 查询参数
   * @returns 响应数据
   */
  protected async doGet<T>(url: string, params?: object): Promise<ApiResponse<T>> {
    if (this.isMockEnabled() && this.mockControl.getData) {
      LogUtil.info(this.serviceName, `[MOCK] GET ${url}`);
      return {
        code: 0,
        message: 'success',
        data: this.mockControl.getData(params) as T
      };
    }

    LogUtil.info(this.serviceName, `GET ${url}`);
    return get<T>(url, params);
  }

  /**
   * POST request with mock support
   * @param url 请求URL
   * @param data 请求体
   * @returns 响应数据
   */
  protected async doPost<T>(url: string, data?: object): Promise<ApiResponse<T>> {
    if (this.isMockEnabled() && this.mockControl.getData) {
      LogUtil.info(this.serviceName, `[MOCK] POST ${url}`);
      return {
        code: 0,
        message: 'success',
        data: this.mockControl.getData(data) as T
      };
    }

    LogUtil.info(this.serviceName, `POST ${url}`);
    return post<T>(url, data);
  }

  /**
   * PUT request with mock support
   * @param url 请求URL
   * @param data 请求体
   * @returns 响应数据
   */
  protected async doPut<T>(url: string, data?: object): Promise<ApiResponse<T>> {
    if (this.isMockEnabled() && this.mockControl.getData) {
      LogUtil.info(this.serviceName, `[MOCK] PUT ${url}`);
      return {
        code: 0,
        message: 'success',
        data: this.mockControl.getData(data) as T
      };
    }

    LogUtil.info(this.serviceName, `PUT ${url}`);
    return put<T>(url, data);
  }

  /**
   * DELETE request with mock support
   * @param url 请求URL
   * @returns 响应数据
   */
  protected async doDelete<T>(url: string): Promise<ApiResponse<T>> {
    if (this.isMockEnabled() && this.mockControl.getData) {
      LogUtil.info(this.serviceName, `[MOCK] DELETE ${url}`);
      return {
        code: 0,
        message: 'success',
        data: this.mockControl.getData() as T
      };
    }

    LogUtil.info(this.serviceName, `DELETE ${url}`);
    return del<T>(url);
  }

  /**
   * Get list with pagination
   * @param url 请求URL
   * @param params 查询参数
   * @returns 分页响应数据
   */
  protected async doGetList<T>(
    url: string,
    params?: PageQueryParams
  ): Promise<ApiResponse<PageResponse<T>>> {
    const queryParams = params ? QueryParamsHelper.withDefaultPagination(params) : undefined;
    return this.doGet<PageResponse<T>>(url, queryParams as object);
  }

  /**
   * Wrap API call with error handling
   * @param apiCall API调用函数
   * @returns 包装后的结果
   */
  protected async wrapCall<T>(
    apiCall: () => Promise<ApiResponse<T>>
  ): Promise<ApiCallResult<T>> {
    return ApiWrapper.wrap(apiCall, {
      requestName: this.serviceName,
      showErrorToast: true
    });
  }
}

/**
 * Mock Service Switch
 * @description Mock服务开关控制
 */
export class MockServiceSwitch {
  /** 全局Mock开关 */
  static GLOBAL_ENABLED = false;

  /** 各服务Mock开关 */
  private static serviceSwitches: Map<string, boolean> = new Map();

  /**
   * Set service mock switch
   * @param serviceName 服务名称
   * @param enabled 是否启用
   */
  static setServiceMock(serviceName: string, enabled: boolean): void {
    MockServiceSwitch.serviceSwitches.set(serviceName, enabled);
    LogUtil.info('MockServiceSwitch', `${serviceName} mock: ${enabled}`);
  }

  /**
   * Check if service mock is enabled
   * @param serviceName 服务名称
   * @returns 是否启用Mock
   */
  static isServiceMockEnabled(serviceName: string): boolean {
    // 如果全局关闭，则所有服务Mock都关闭
    if (!MockServiceSwitch.GLOBAL_ENABLED) {
      return false;
    }
    
    // 返回服务级别的开关，默认跟随全局
    return MockServiceSwitch.serviceSwitches.get(serviceName) ?? MockServiceSwitch.GLOBAL_ENABLED;
  }

  /**
   * Enable mock for specific services
   * @param serviceNames 服务名称列表
   */
  static enableServices(...serviceNames: string[]): void {
    serviceNames.forEach((name: string) => {
      MockServiceSwitch.setServiceMock(name, true);
    });
  }

  /**
   * Disable mock for specific services
   * @param serviceNames 服务名称列表
   */
  static disableServices(...serviceNames: string[]): void {
    serviceNames.forEach((name: string) => {
      MockServiceSwitch.setServiceMock(name, false);
    });
  }

  /**
   * Reset all service switches
   */
  static reset(): void {
    MockServiceSwitch.serviceSwitches.clear();
  }
}

/**
 * Service Names Constants
 */
export class ServiceNames {
  static readonly AUTH: string = 'AuthService';
  static readonly USER: string = 'UserService';
  static readonly STUDENT: string = 'StudentService';
  static readonly ORDER: string = 'OrderService';
  static readonly SESSION: string = 'SessionService';
  static readonly ATTENDANCE: string = 'AttendanceService';
  static readonly HOMEWORK: string = 'HomeworkService';
  static readonly MESSAGE: string = 'MessageService';
  static readonly ALERT: string = 'AlertService';
  static readonly REPORT: string = 'ReportService';
  static readonly REFUND: string = 'RefundService';
  static readonly PAYMENT: string = 'PaymentService';
  static readonly CARD: string = 'CardService';
  static readonly WORKBENCH: string = 'WorkbenchService';
}

export type ServiceName = string;
