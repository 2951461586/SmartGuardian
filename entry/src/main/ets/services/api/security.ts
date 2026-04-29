/**
 * SmartGuardian - Security Audit API Service
 */

import { get } from '../../utils/request';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { ApiResponse, PageResponse } from '../../models/common';
import {
  SecurityAuditEvent,
  SecurityAuditQueryParams,
  SecurityAuditStatistics
} from '../../models/security';

export class SecurityService {
  static readonly AGC_DOMAIN: string = 'security';
  static readonly AGC_FUNCTION: string = 'smartguardian-security';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.SECURITY;

  static async getAuditEvents(params?: SecurityAuditQueryParams): Promise<ApiResponse<PageResponse<SecurityAuditEvent>>> {
    return get<PageResponse<SecurityAuditEvent>>(ApiEndpoints.SECURITY_AUDIT_EVENTS, params);
  }

  static async getAuditStatistics(params?: SecurityAuditQueryParams): Promise<ApiResponse<SecurityAuditStatistics>> {
    return get<SecurityAuditStatistics>(ApiEndpoints.SECURITY_AUDIT_STATISTICS, params);
  }
}
