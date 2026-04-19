/**
 * SmartGuardian - Alert Models
 * Alert and warning related types
 */

/**
 * Alert severity level
 */
export enum AlertSeverity {
  LOW = 'LOW',           // 低
  MEDIUM = 'MEDIUM',     // 中
  HIGH = 'HIGH',         // 高
  CRITICAL = 'CRITICAL'  // 紧急
}

/**
 * Alert type
 */
export enum AlertType {
  ATTENDANCE_ANOMALY = 'ATTENDANCE_ANOMALY',   // 考勤异常
  SAFETY_CONCERN = 'SAFETY_CONCERN',           // 安全隐患
  ACADEMIC_PERFORMANCE = 'ACADEMIC_PERFORMANCE', // 学业表现
  BEHAVIORAL_ISSUE = 'BEHAVIORAL_ISSUE',       // 行为问题
  FEE_DUE = 'FEE_DUE',                         // 费用到期
  SYSTEM = 'SYSTEM'                            // 系统提醒
}

/**
 * Alert status
 */
export enum AlertStatus {
  ACTIVE = 'ACTIVE',       // 活动中
  ACKNOWLEDGED = 'ACKNOWLEDGED', // 已确认
  RESOLVED = 'RESOLVED',   // 已解决
  DISMISSED = 'DISMISSED'  // 已忽略
}

/**
 * Alert record
 */
export interface AlertRecord {
  id: number;
  studentId: number;
  studentName: string;
  alertType: string;
  severity: string;
  title: string;
  description: string;
  suggestedAction?: string;
  status: string;
  acknowledgedBy?: number;
  acknowledgedAt?: string;
  resolvedBy?: number;
  resolvedAt?: string;
  resolution?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * Alert query params
 */
export interface AlertQueryParams {
  studentId?: number;
  alertType?: string;
  severity?: string;
  status?: string;
  startDate?: string;
  endDate?: string;
  pageNum?: number;
  pageSize?: number;
}

/**
 * Alert statistics
 */
export interface AlertStatistics {
  total: number;
  active: number;
  acknowledged: number;
  resolved: number;
  byType: Record<string, number>;
  bySeverity: Record<string, number>;
}

/**
 * Acknowledge alert params
 */
export interface AcknowledgeAlertParams {
  alertId: number;
  note?: string;
}

/**
 * Resolve alert params
 */
export interface ResolveAlertParams {
  alertId: number;
  resolution: string;
}