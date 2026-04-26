/**
 * SmartGuardian - Mock Service
 * Unified route entry for split mock domain handlers.
 */

import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { RequestOptions, HttpResponse } from '../../utils/request';
import { AlertMockHandler } from './handlers/AlertMockHandler';
import { AttendanceMockHandler } from './handlers/AttendanceMockHandler';
import { AuthMockHandler } from './handlers/AuthMockHandler';
import { CardMockHandler } from './handlers/CardMockHandler';
import { HomeworkMockHandler } from './handlers/HomeworkMockHandler';
import { MessageMockHandler } from './handlers/MessageMockHandler';
import { OrderMockHandler } from './handlers/OrderMockHandler';
import { PaymentMockHandler } from './handlers/PaymentMockHandler';
import { RefundMockHandler } from './handlers/RefundMockHandler';
import { ReportMockHandler } from './handlers/ReportMockHandler';
import { ServiceMockHandler } from './handlers/ServiceMockHandler';
import { SessionMockHandler } from './handlers/SessionMockHandler';
import { StudentMockHandler } from './handlers/StudentMockHandler';
import { TimelineMockHandler } from './handlers/TimelineMockHandler';
import { UserMockHandler } from './handlers/UserMockHandler';
import { WorkbenchMockHandler } from './handlers/WorkbenchMockHandler';
import { getPath, mockNotFound } from './shared/mockUtils';

export class MockService {
  static async handleMockRequest<T>(options: RequestOptions): Promise<HttpResponse<T>> {
    const url = options.url;
    const path = getPath(url);
    const method = options.method;
    const data = options.data;

    if (path.indexOf(ApiEndpoints.ALERTS) === 0) {
      return AlertMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.ORDERS) === 0) {
      return OrderMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.PAYMENTS) === 0) {
      return PaymentMockHandler.handleRequest<T>(path, method, data);
    }
    if (path.indexOf(ApiEndpoints.SERVICE_PRODUCTS) === 0) {
      return ServiceMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.SESSIONS) === 0) {
      return SessionMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.AUTH) === 0) {
      return AuthMockHandler.handleRequest<T>(path, method, data);
    }
    if (path.indexOf(ApiEndpoints.USERS) === 0) {
      return UserMockHandler.handleRequest<T>(url, path, method);
    }
    if (path.indexOf(ApiEndpoints.STUDENTS) === 0) {
      return StudentMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.ATTENDANCE) === 0) {
      return AttendanceMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.HOMEWORK_TASKS) === 0 || path.indexOf(ApiEndpoints.HOMEWORK_FEEDBACK) === 0) {
      return HomeworkMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.MESSAGES) === 0) {
      return MessageMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.TIMELINE) === 0) {
      return TimelineMockHandler.handleRequest<T>(path, method);
    }
    if (path.indexOf(ApiEndpoints.CARDS) === 0) {
      return CardMockHandler.handleRequest<T>(path, method);
    }
    if (path.indexOf(ApiEndpoints.REFUNDS) === 0) {
      return RefundMockHandler.handleRequest<T>(url, path, method, data);
    }
    if (path.indexOf(ApiEndpoints.REPORTS) === 0) {
      return ReportMockHandler.handleRequest<T>(path, method);
    }
    if (path.indexOf(ApiEndpoints.WORKBENCH) === 0) {
      return WorkbenchMockHandler.handleRequest<T>(path, method);
    }

    return mockNotFound<T>();
  }
}
