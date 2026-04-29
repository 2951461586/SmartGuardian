/**
 * SmartGuardian - Form card preferences storage layer.
 * Handles all preferences CRUD, data merge, and fallback data generation.
 */

import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { LogUtil } from '../utils/LogUtil';
import { FormCardStudentData, FormCardAlertData } from './FormCardDataModels';

const TAG = 'FormCardStorage';

export const FORM_PREFS_NAME: string = 'SmartGuardianFormData';
export const STUDENT_INFO_KEY: string = 'student_info';
export const ALERT_INFO_KEY: string = 'alert_info';
export const CONSISTENCY_KEY: string = 'student_info_consistency';
export const FORM_IDS_KEY: string = 'registered_form_ids';
export const FORM_DIMENSION_PREFIX: string = 'form_dimension_';
export const FORM_NAME_PREFIX: string = 'form_name_';
export const TODAY_FORM_NAME: string = 'TodayGuardianCard';
export const ALERT_FORM_NAME: string = 'AbnormalAlertCard';

export function getRegisteredFormIds(context: common.Context): string[] {
  try {
    const dataPreferences = preferences.getPreferencesSync(context, { name: FORM_PREFS_NAME });
    const value = dataPreferences.getSync(FORM_IDS_KEY, '') as string;
    if (value.length === 0) {
      return [];
    }
    const parts = value.split(',');
    const ids: string[] = [];
    for (let i = 0; i < parts.length; i++) {
      const item = parts[i].trim();
      if (item.length > 0 && ids.indexOf(item) < 0) {
        ids.push(item);
      }
    }
    return ids;
  } catch (error) {
    LogUtil.warn(TAG, `Get registered forms failed: ${String(error)}`);
    return [];
  }
}

export function registerForm(context: common.Context, formId: string, dimension: number, formName?: string): void {
  if (formId.length === 0) {
    return;
  }
  try {
    const dataPreferences = preferences.getPreferencesSync(context, { name: FORM_PREFS_NAME });
    const formIds = getRegisteredFormIds(context);
    if (formIds.indexOf(formId) < 0) {
      formIds.push(formId);
    }
    dataPreferences.putSync(FORM_IDS_KEY, formIds.join(','));
    dataPreferences.putSync(`${FORM_DIMENSION_PREFIX}${formId}`, String(dimension));
    dataPreferences.putSync(`${FORM_NAME_PREFIX}${formId}`, normalizeFormName(formName ? formName : ''));
    dataPreferences.flush();
  } catch (error) {
    LogUtil.warn(TAG, `Register form failed: ${String(error)}`);
  }
}

export function unregisterForm(context: common.Context, formId: string): void {
  if (formId.length === 0) {
    return;
  }
  try {
    const dataPreferences = preferences.getPreferencesSync(context, { name: FORM_PREFS_NAME });
    const formIds = getRegisteredFormIds(context);
    const nextIds: string[] = [];
    for (let i = 0; i < formIds.length; i++) {
      if (formIds[i] !== formId) {
        nextIds.push(formIds[i]);
      }
    }
    dataPreferences.putSync(FORM_IDS_KEY, nextIds.join(','));
    dataPreferences.putSync(`${FORM_DIMENSION_PREFIX}${formId}`, '');
    dataPreferences.putSync(`${FORM_NAME_PREFIX}${formId}`, '');
    dataPreferences.flush();
  } catch (error) {
    LogUtil.warn(TAG, `Unregister form failed: ${String(error)}`);
  }
}

export function getFormDimension(context: common.Context, formId: string, fallbackDimension: number): number {
  try {
    const dataPreferences = preferences.getPreferencesSync(context, { name: FORM_PREFS_NAME });
    const value = dataPreferences.getSync(`${FORM_DIMENSION_PREFIX}${formId}`, '') as string;
    const dimension = Number(value);
    if (!Number.isNaN(dimension) && dimension > 0) {
      return dimension;
    }
  } catch (error) {
    LogUtil.warn(TAG, `Get form dimension failed: ${String(error)}`);
  }
  return fallbackDimension;
}

export function getFormName(context: common.Context, formId: string): string {
  try {
    const dataPreferences = preferences.getPreferencesSync(context, { name: FORM_PREFS_NAME });
    const value = dataPreferences.getSync(`${FORM_NAME_PREFIX}${formId}`, '') as string;
    return normalizeFormName(value);
  } catch (error) {
    LogUtil.warn(TAG, `Get form name failed: ${String(error)}`);
  }
  return TODAY_FORM_NAME;
}

export function normalizeFormName(formName: string): string {
  if (formName === ALERT_FORM_NAME) {
    return ALERT_FORM_NAME;
  }
  return TODAY_FORM_NAME;
}

export function persistCardData(context: common.Context, studentData: FormCardStudentData, alertData: FormCardAlertData, consistencyJson: string): void {
  try {
    const dataPreferences = preferences.getPreferencesSync(context, { name: FORM_PREFS_NAME });
    dataPreferences.putSync(STUDENT_INFO_KEY, JSON.stringify(studentData));
    dataPreferences.putSync(ALERT_INFO_KEY, JSON.stringify(alertData));
    dataPreferences.putSync(CONSISTENCY_KEY, consistencyJson);
    dataPreferences.flush();
  } catch (error) {
    LogUtil.warn(TAG, `Persist form card data failed: ${String(error)}`);
  }
}

export function getStoredStudentData(context: common.Context): FormCardStudentData {
  const fallbackData = getFallbackStudentData();
  try {
    const dataPreferences = preferences.getPreferencesSync(context, { name: FORM_PREFS_NAME });
    const storedValue = dataPreferences.getSync(STUDENT_INFO_KEY, '') as string;
    if (storedValue.length > 0) {
      const parsedData = JSON.parse(storedValue) as FormCardStudentData;
      return mergeStudentData(parsedData, fallbackData);
    }
  } catch (error) {
    LogUtil.error('Get stored form card data failed:', String(error));
  }
  return fallbackData;
}

export function getStoredAlertData(context: common.Context): FormCardAlertData {
  const fallbackData = getFallbackAlertData();
  try {
    const dataPreferences = preferences.getPreferencesSync(context, { name: FORM_PREFS_NAME });
    const storedValue = dataPreferences.getSync(ALERT_INFO_KEY, '') as string;
    if (storedValue.length > 0) {
      const parsedData = JSON.parse(storedValue) as FormCardAlertData;
      return mergeAlertData(parsedData, fallbackData);
    }
  } catch (error) {
    LogUtil.error('Get stored alert card data failed:', String(error));
  }
  return fallbackData;
}

export function getFallbackStudentData(): FormCardStudentData {
  const data = new FormCardStudentData();
  data.studentName = '张小明';
  data.className = '三年级 1 班';
  data.sessionTime = '15:30-18:00';
  data.status = 'SIGNED_IN';
  data.statusText = '已签到';
  data.signInTime = '15:32';
  data.homeworkProgress = '2/3';
  data.teacherFeedback = '作业完成良好';
  data.dataFreshness = 'FALLBACK';
  return data;
}

export function getFallbackAlertData(): FormCardAlertData {
  const data = new FormCardAlertData();
  data.studentName = '张小明';
  data.abnormalType = '暂无异常';
  data.triggerTime = '--:--';
  data.riskLevel = '低';
  data.riskColor = '#2DBE7E';
  data.suggestion = '今日无异常提醒';
  data.teacherName = '';
  data.dataFreshness = 'FALLBACK';
  return data;
}

function mergeStudentData(parsedData: FormCardStudentData, fallbackData: FormCardStudentData): FormCardStudentData {
  const data = new FormCardStudentData();
  data.studentId = parsedData.studentId > 0 ? parsedData.studentId : fallbackData.studentId;
  data.studentName = parsedData.studentName ? parsedData.studentName : fallbackData.studentName;
  data.className = parsedData.className ? parsedData.className : fallbackData.className;
  data.sessionTime = parsedData.sessionTime ? parsedData.sessionTime : fallbackData.sessionTime;
  data.status = parsedData.status ? parsedData.status : fallbackData.status;
  data.statusText = parsedData.statusText ? parsedData.statusText : fallbackData.statusText;
  data.signInTime = parsedData.signInTime ? parsedData.signInTime : fallbackData.signInTime;
  data.homeworkProgress = parsedData.homeworkProgress ? parsedData.homeworkProgress : fallbackData.homeworkProgress;
  data.teacherFeedback = parsedData.teacherFeedback ? parsedData.teacherFeedback : fallbackData.teacherFeedback;
  data.dataFreshness = parsedData.dataFreshness ? parsedData.dataFreshness : fallbackData.dataFreshness;
  data.cloudCheckedAt = parsedData.cloudCheckedAt ? parsedData.cloudCheckedAt : '';
  data.localSyncedAt = parsedData.localSyncedAt ? parsedData.localSyncedAt : '';
  return data;
}

function mergeAlertData(parsedData: FormCardAlertData, fallbackData: FormCardAlertData): FormCardAlertData {
  const data = new FormCardAlertData();
  data.studentId = parsedData.studentId > 0 ? parsedData.studentId : fallbackData.studentId;
  data.studentName = parsedData.studentName ? parsedData.studentName : fallbackData.studentName;
  data.abnormalType = parsedData.abnormalType ? parsedData.abnormalType : fallbackData.abnormalType;
  data.triggerTime = parsedData.triggerTime ? parsedData.triggerTime : fallbackData.triggerTime;
  data.riskLevel = parsedData.riskLevel ? parsedData.riskLevel : fallbackData.riskLevel;
  data.riskColor = parsedData.riskColor ? parsedData.riskColor : fallbackData.riskColor;
  data.suggestion = parsedData.suggestion ? parsedData.suggestion : fallbackData.suggestion;
  data.teacherName = parsedData.teacherName ? parsedData.teacherName : fallbackData.teacherName;
  data.dataFreshness = parsedData.dataFreshness ? parsedData.dataFreshness : fallbackData.dataFreshness;
  data.cloudCheckedAt = parsedData.cloudCheckedAt ? parsedData.cloudCheckedAt : '';
  data.localSyncedAt = parsedData.localSyncedAt ? parsedData.localSyncedAt : '';
  return data;
}
