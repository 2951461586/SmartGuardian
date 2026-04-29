/**
 * SmartGuardian - Form card data model classes.
 * Shared between FormCardSyncService, FormCardStorage, and form abilities.
 */

export class FormCardStudentData {
  studentId: number = 0;
  studentName: string = '';
  className: string = '';
  sessionTime: string = '';
  status: string = '';
  statusText: string = '';
  signInTime: string = '';
  homeworkProgress: string = '';
  teacherFeedback: string = '';
  dataFreshness: string = 'FALLBACK';
  cloudCheckedAt: string = '';
  localSyncedAt: string = '';
}

export class FormCardAlertData {
  studentId: number = 0;
  studentName: string = '';
  abnormalType: string = '';
  triggerTime: string = '';
  riskLevel: string = '';
  riskColor: string = '';
  suggestion: string = '';
  teacherName: string = '';
  dataFreshness: string = 'FALLBACK';
  cloudCheckedAt: string = '';
  localSyncedAt: string = '';
}

export class FormCardSyncResult {
  success: boolean = false;
  consistent: boolean = false;
  updatedForms: number = 0;
  message: string = '';
  localSyncedAt: string = '';
}

export class FormCardBindingPayload {
  updateTime: string = '';
  formId: number = 2;
  dataFreshness: string = '';
  localSyncedAt: string = '';
  studentName: string = '';
  className: string = '';
  sessionTime: string = '';
  status: string = '';
  statusColor: string = '';
  statusIcon: string = '';
  signInTime: string = '';
  homeworkProgress: string = '';
  teacherFeedback: string = '';
  showDetail: boolean = false;
  abnormalType: string = '';
  triggerTime: string = '';
  riskLevel: string = '';
  riskColor: string = '';
  suggestion: string = '';
  teacherName: string = '';
}
