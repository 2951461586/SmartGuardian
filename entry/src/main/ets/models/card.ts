/**
 * SmartGuardian - Card Models
 * Widget card data models
 */

/**
 * Today status card data
 */
export interface TodayStatusCard {
  date: string;
  studentId: number;
  studentName: string;
  sessionInfo?: SessionCardInfo;
  attendanceStatus: 'NOT_SIGNED' | 'SIGNED_IN' | 'SIGNED_OUT' | 'ABSENT' | 'LEAVE';
  signInTime?: string;
  signOutTime?: string;
  homeworkStatus?: 'PENDING' | 'IN_PROGRESS' | 'COMPLETED';
  homeworkCount?: number;
  completedHomework?: number;
  messages?: number;
  // Convenience properties for UI display
  sessionName?: string;
  sessionTime?: string;
  status?: 'NOT_SIGNED' | 'SIGNED_IN' | 'IN_PROGRESS' | 'SIGNED_OUT';
  latestDynamic?: string;
  homeworkProgress?: number;
  teacherFeedback?: string;
}

/**
 * Session card info
 */
export interface SessionCardInfo {
  sessionId: number;
  sessionNo: string;
  sessionDate: string;
  startTime: string;
  endTime: string;
  teacherName?: string;
  location?: string;
}

/**
 * Abnormal alert card data
 */
export interface AbnormalAlertCard {
  alertId: number;
  studentId: number;
  studentName: string;
  alertType: 'ATTENDANCE' | 'HOMEWORK' | 'HEALTH' | 'PAYMENT' | 'OTHER';
  alertLevel: 'INFO' | 'WARNING' | 'ERROR';
  alertTitle: string;
  alertContent: string;
  alertTime: string;
  isRead: boolean;
  relatedData?: Record<string, object>;
}

/**
 * Card update request
 */
export interface CardUpdateRequest {
  cardId: string;
  cardType: 'TODAY_STATUS' | 'ABNORMAL_ALERT';
  formId: string;
}

/**
 * Card data response
 */
export interface CardDataResponse {
  cardType: string;
  updateTime: string;
  data: TodayStatusCard | AbnormalAlertCard;
}

export interface FormCardConsistencyItem {
  consistent: boolean;
  cacheUpdatedAt: string;
  cachedPayload?: TodayStatusCard | AbnormalAlertCard | null;
  freshPayload?: TodayStatusCard | AbnormalAlertCard | null;
}

export interface FormCardConsistencyReport {
  studentId: number;
  checkedAt: string;
  consistent: boolean;
  todayStatus: FormCardConsistencyItem;
  abnormalAlert: FormCardConsistencyItem;
}
