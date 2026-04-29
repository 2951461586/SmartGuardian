/**
 * SmartGuardian - Form card cloud consistency sync service.
 * Orchestrates cloud sync, delegates storage to FormCardStorage and mapping to FormCardDataMapper.
 */

import { common } from '@kit.AbilityKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { CardService } from './api/card';
import { getToken } from '../utils/request';
import { LogUtil } from '../utils/LogUtil';
import { FormCardStudentData, FormCardAlertData, FormCardSyncResult, FormCardBindingPayload } from './FormCardDataModels';
import {
  registerForm,
  unregisterForm,
  getRegisteredFormIds,
  getFormDimension,
  getFormName,
  persistCardData,
  getStoredStudentData,
  getStoredAlertData,
  ALERT_FORM_NAME
} from './FormCardStorage';
import {
  mapTodayStatus,
  mapAbnormalAlert,
  buildFormDataByDimension,
  buildAlertFormDataByDimension
} from './FormCardDataMapper';

const TAG = 'FormCardSyncService';

export { FormCardStudentData, FormCardAlertData, FormCardSyncResult, FormCardBindingPayload } from './FormCardDataModels';
export {
  registerForm,
  unregisterForm,
  getRegisteredFormIds,
  getFormDimension,
  getFormName,
  getStoredStudentData,
  getStoredAlertData
} from './FormCardStorage';
export {
  buildFormDataByDimension,
  buildAlertFormDataByDimension
} from './FormCardDataMapper';

export class FormCardSyncService {
  static readonly PREFERENCES_NAME: string = 'SmartGuardianFormData';
  static readonly STUDENT_INFO_KEY: string = 'student_info';
  static readonly ALERT_INFO_KEY: string = 'alert_info';
  static readonly CONSISTENCY_KEY: string = 'student_info_consistency';
  static readonly FORM_IDS_KEY: string = 'registered_form_ids';
  static readonly FORM_DIMENSION_PREFIX: string = 'form_dimension_';
  static readonly FORM_NAME_PREFIX: string = 'form_name_';
  static readonly TODAY_FORM_NAME: string = 'TodayGuardianCard';
  static readonly ALERT_FORM_NAME: string = 'AbnormalAlertCard';

  static registerForm(context: common.Context, formId: string, dimension: number, formName?: string): void {
    registerForm(context, formId, dimension, formName);
  }

  static unregisterForm(context: common.Context, formId: string): void {
    unregisterForm(context, formId);
  }

  static getRegisteredFormIds(context: common.Context): string[] {
    return getRegisteredFormIds(context);
  }

  static getFormDimension(context: common.Context, formId: string, fallbackDimension: number): number {
    return getFormDimension(context, formId, fallbackDimension);
  }

  static getFormName(context: common.Context, formId: string): string {
    return getFormName(context, formId);
  }

  static async syncTodayStatus(context: common.Context, studentId?: number): Promise<FormCardSyncResult> {
    const result = new FormCardSyncResult();
    const token = getToken();
    if (!token || token.length === 0) {
      result.message = 'User token is not ready.';
      return result;
    }

    try {
      const cardResponse = await CardService.getTodayStatus(studentId);
      if (cardResponse.code !== 0) {
        result.message = cardResponse.message;
        return result;
      }

      const alertResponse = await CardService.getAbnormalAlert(studentId);
      const consistencyResponse = await CardService.getConsistency(studentId, true);
      const studentData = mapTodayStatus(cardResponse.data);
      const alertData = mapAbnormalAlert(alertResponse.code === 0 ? alertResponse.data : null, studentData.studentName);
      studentData.dataFreshness = consistencyResponse.code === 0 && consistencyResponse.data.consistent ? 'ONLINE' : 'ONLINE_UNVERIFIED';
      studentData.cloudCheckedAt = consistencyResponse.code === 0 ? consistencyResponse.data.checkedAt : '';
      studentData.localSyncedAt = new Date().toISOString();
      alertData.dataFreshness = studentData.dataFreshness;
      alertData.cloudCheckedAt = studentData.cloudCheckedAt;
      alertData.localSyncedAt = studentData.localSyncedAt;

      persistCardData(context, studentData, alertData, consistencyResponse.code === 0 ? JSON.stringify(consistencyResponse.data) : '');
      result.updatedForms = await updateRegisteredForms(context, studentData, alertData);
      result.success = true;
      result.consistent = consistencyResponse.code === 0 && consistencyResponse.data.consistent;
      result.localSyncedAt = studentData.localSyncedAt;
      result.message = result.consistent ? 'Form card data is consistent.' : 'Form card data synced but consistency check is not fully green.';
      return result;
    } catch (error) {
      result.message = String(error);
      LogUtil.warn(TAG, `Sync today status failed: ${result.message}`);
      return result;
    }
  }

  static getStoredStudentData(context: common.Context): FormCardStudentData {
    return getStoredStudentData(context);
  }

  static getStoredAlertData(context: common.Context): FormCardAlertData {
    return getStoredAlertData(context);
  }

  static buildFormDataByDimension(dimension: number, data: FormCardStudentData): FormCardBindingPayload {
    return buildFormDataByDimension(dimension, data);
  }

  static buildAlertFormDataByDimension(dimension: number, data: FormCardAlertData): FormCardBindingPayload {
    return buildAlertFormDataByDimension(dimension, data);
  }
}

async function updateRegisteredForms(context: common.Context, studentData: FormCardStudentData, alertData: FormCardAlertData): Promise<number> {
  const formIds = getRegisteredFormIds(context);
  let updated = 0;
  for (let i = 0; i < formIds.length; i++) {
    try {
      const formName = getFormName(context, formIds[i]);
      const dimension = getFormDimension(context, formIds[i], 2);
      const formData = formName === ALERT_FORM_NAME
        ? buildAlertFormDataByDimension(dimension, alertData)
        : buildFormDataByDimension(dimension, studentData);
      const bindingData = formBindingData.createFormBindingData(formData);
      await formProvider.updateForm(formIds[i], bindingData);
      updated += 1;
    } catch (error) {
      LogUtil.warn(TAG, `Update registered form failed: ${String(error)}`);
    }
  }
  return updated;
}
