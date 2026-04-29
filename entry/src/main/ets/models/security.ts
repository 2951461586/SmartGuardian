/**
 * SmartGuardian - Security Audit Models
 */

export interface SecurityAuditEvent {
  id: number;
  eventType: string;
  domain: string;
  functionName: string;
  routePath: string;
  requestPath: string;
  method: string;
  userId: number;
  roleType: string;
  resourceId: string;
  statusCode: number;
  success: boolean;
  requestId: string;
  message: string;
  createdAt: string;
}

export interface SecurityAuditQueryParams {
  domain?: string;
  eventType?: string;
  roleType?: string;
  userId?: number;
  success?: boolean;
  startTime?: string;
  endTime?: string;
  pageNum?: number;
  pageSize?: number;
}

export interface SecurityAuditBucket {
  key: string;
  count: number;
}

export interface SecurityAuditStatistics {
  total: number;
  successCount: number;
  failureCount: number;
  byDomain: SecurityAuditBucket[];
  byEventType: SecurityAuditBucket[];
  byRoleType: SecurityAuditBucket[];
}
