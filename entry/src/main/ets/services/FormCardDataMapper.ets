/**
 * SmartGuardian - Form card data mapping and formatting utilities.
 * Converts API card models to form binding payloads.
 */

import { TodayStatusCard, AbnormalAlertCard } from '../models/card';
import { FormCardStudentData, FormCardAlertData, FormCardBindingPayload } from './FormCardDataModels';
import { ALERT_FORM_NAME, getFallbackAlertData } from './FormCardStorage';

export function mapTodayStatus(card: TodayStatusCard): FormCardStudentData {
  const data = new FormCardStudentData();
  data.studentId = card.studentId;
  data.studentName = card.studentName;
  data.className = card.sessionInfo && card.sessionInfo.location ? card.sessionInfo.location : '';
  data.sessionTime = card.sessionTime ? card.sessionTime : buildSessionTime(card);
  data.status = card.attendanceStatus;
  data.statusText = getStatusText(card.attendanceStatus);
  data.signInTime = formatCardTime(card.signInTime ? card.signInTime : '');
  data.homeworkProgress = buildHomeworkProgress(card);
  data.teacherFeedback = card.teacherFeedback ? card.teacherFeedback : (card.latestDynamic ? card.latestDynamic : '');
  return data;
}

export function mapAbnormalAlert(card: AbnormalAlertCard | null, fallbackStudentName: string): FormCardAlertData {
  if (!card) {
    const fallbackData = getFallbackAlertData();
    fallbackData.studentName = fallbackStudentName.length > 0 ? fallbackStudentName : fallbackData.studentName;
    fallbackData.dataFreshness = 'ONLINE';
    return fallbackData;
  }

  const data = new FormCardAlertData();
  data.studentId = card.studentId;
  data.studentName = card.studentName;
  data.abnormalType = card.alertTitle.length > 0 ? card.alertTitle : getAlertTypeText(card.alertType);
  data.triggerTime = formatCardTime(card.alertTime);
  data.riskLevel = getRiskLevelText(card.alertLevel);
  data.riskColor = getRiskColor(card.alertLevel);
  data.suggestion = card.alertContent.length > 0 ? card.alertContent : '请及时联系老师确认';
  data.teacherName = '';
  return data;
}

export function buildFormDataByDimension(dimension: number, data: FormCardStudentData): FormCardBindingPayload {
  const formData = new FormCardBindingPayload();
  formData.updateTime = formatTime(new Date());
  formData.formId = dimension;
  formData.dataFreshness = data.dataFreshness;
  formData.localSyncedAt = data.localSyncedAt;

  if (dimension === 1) {
    formData.studentName = data.studentName.length > 0 ? data.studentName : '未知学生';
    formData.status = data.statusText.length > 0 ? data.statusText : '未知状态';
    formData.statusColor = getStatusColor(data.status);
    formData.statusIcon = getStatusIcon(data.status);
    return formData;
  }

  formData.studentName = data.studentName;
  formData.className = data.className;
  formData.sessionTime = data.sessionTime;
  formData.status = data.statusText;
  formData.signInTime = data.signInTime;
  formData.homeworkProgress = data.homeworkProgress;
  formData.teacherFeedback = data.teacherFeedback;
  formData.statusColor = getStatusColor(data.status);
  formData.statusIcon = getStatusIcon(data.status);
  if (dimension === 3) {
    formData.showDetail = true;
  }
  return formData;
}

export function buildAlertFormDataByDimension(dimension: number, data: FormCardAlertData): FormCardBindingPayload {
  const formData = new FormCardBindingPayload();
  formData.updateTime = formatTime(new Date());
  formData.formId = dimension;
  formData.dataFreshness = data.dataFreshness;
  formData.localSyncedAt = data.localSyncedAt;
  formData.studentName = data.studentName;
  formData.abnormalType = data.abnormalType;
  formData.triggerTime = data.triggerTime;
  formData.riskLevel = data.riskLevel;
  formData.riskColor = data.riskColor;
  formData.suggestion = data.suggestion;
  formData.teacherName = data.teacherName;
  return formData;
}

function buildSessionTime(card: TodayStatusCard): string {
  if (card.sessionInfo) {
    return `${card.sessionInfo.startTime}-${card.sessionInfo.endTime}`;
  }
  return '';
}

function buildHomeworkProgress(card: TodayStatusCard): string {
  const total = card.homeworkCount ? card.homeworkCount : 0;
  const completed = card.completedHomework ? card.completedHomework : 0;
  if (total <= 0) {
    return '0/0';
  }
  return `${completed}/${total}`;
}

function formatCardTime(value: string): string {
  if (value.length >= 16 && value.indexOf('T') > 0) {
    return value.slice(11, 16);
  }
  return value;
}

function formatTime(date: Date): string {
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  return `${hours}:${minutes}`;
}

function getStatusText(status: string): string {
  switch (status) {
    case 'SIGNED_IN':
      return '已签到';
    case 'SIGNED_OUT':
      return '已签退';
    case 'ABSENT':
      return '缺勤';
    case 'LEAVE':
      return '请假';
    case 'IN_PROGRESS':
      return '托管中';
    default:
      return '待签到';
  }
}

function getAlertTypeText(alertType: string): string {
  switch (alertType) {
    case 'ATTENDANCE':
      return '考勤异常';
    case 'HOMEWORK':
      return '作业异常';
    case 'HEALTH':
      return '健康提醒';
    case 'PAYMENT':
      return '缴费提醒';
    default:
      return '异常提醒';
  }
}

function getRiskLevelText(alertLevel: string): string {
  switch (alertLevel) {
    case 'ERROR':
      return '高';
    case 'WARNING':
      return '中';
    default:
      return '低';
  }
}

function getRiskColor(alertLevel: string): string {
  switch (alertLevel) {
    case 'ERROR':
      return '#D92D20';
    case 'WARNING':
      return '#F59E42';
    default:
      return '#2F7DF6';
  }
}

function getStatusColor(status: string): string {
  const colorMap: Record<string, string> = {
    'PENDING': '#F59E42',
    'NOT_SIGNED': '#F59E42',
    'SIGNED_IN': '#2DBE7E',
    'IN_PROGRESS': '#2F7DF6',
    'WAITING_PICKUP': '#526A83',
    'SIGNED_OUT': '#667085',
    'ABSENT': '#D92D20',
    'LEAVE': '#526A83'
  };
  return colorMap[status] || '#98A2B3';
}

function getStatusIcon(status: string): string {
  const iconMap: Record<string, string> = {
    'PENDING': '待签',
    'NOT_SIGNED': '待签',
    'SIGNED_IN': '已签',
    'IN_PROGRESS': '辅导',
    'WAITING_PICKUP': '待接',
    'SIGNED_OUT': '离托',
    'ABSENT': '缺勤',
    'LEAVE': '请假'
  };
  return iconMap[status] || '状态';
}
