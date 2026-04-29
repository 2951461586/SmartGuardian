/**
 * SmartGuardian - Today Guardian FormExtensionAbility
 */

import { FormExtensionAbility, formBindingData, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { LogUtil } from '../utils/LogUtil';
import { FormCardSyncService } from '../services/FormCardSyncService';

const TAG = 'TodayGuardianFormAbility';
const STUDENT_INFO_KEY = 'student_info';

export default class TodayGuardianFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    LogUtil.info('onAddForm called');

    const formId = want.parameters?.['ohos.extra.param.key.form_identity'] as string;
    const formName = want.parameters?.['ohos.extra.param.key.form_name'] as string;
    const dimension = want.parameters?.['ohos.extra.param.key.form_dimension'] as number;
    LogUtil.info(`Form created - ID: ${formId}, Name: ${formName}, Dimension: ${dimension}`);

    FormCardSyncService.registerForm(this.context, formId, dimension, formName);
    const formData = formName === 'AbnormalAlertCard'
      ? FormCardSyncService.buildAlertFormDataByDimension(dimension, FormCardSyncService.getStoredAlertData(this.context))
      : FormCardSyncService.buildFormDataByDimension(dimension, FormCardSyncService.getStoredStudentData(this.context));
    return formBindingData.createFormBindingData(formData);
  }

  onUpdateForm(formId: string): void {
    LogUtil.info(`onUpdateForm called - FormId: ${formId}`);
    const dimension = FormCardSyncService.getFormDimension(this.context, formId, 2);
    const formName = FormCardSyncService.getFormName(this.context, formId);
    const formData = formName === 'AbnormalAlertCard'
      ? FormCardSyncService.buildAlertFormDataByDimension(dimension, FormCardSyncService.getStoredAlertData(this.context))
      : FormCardSyncService.buildFormDataByDimension(dimension, FormCardSyncService.getStoredStudentData(this.context));

    try {
      const bindingData = formBindingData.createFormBindingData(formData);
      formProvider.updateForm(formId, bindingData).then(() => {
        LogUtil.info(`Form ${formId} updated successfully`);
      }).catch((error: Error) => {
        LogUtil.error(`Failed to update form ${formId}: ${error.message}`);
      });
    } catch (error) {
      LogUtil.error('Update form error:', String(error));
    }
  }

  onFormEvent(formId: string, message: string): void {
    LogUtil.info(`onFormEvent - FormId: ${formId}, Message: ${message}`);

    try {
      const eventObj: FormEvent = JSON.parse(message) as FormEvent;
      const action: string = eventObj.action;

      switch (action) {
        case 'refresh':
          this.onUpdateForm(formId);
          break;
        case 'viewDetail':
          this.openMainApp('detail');
          break;
        case 'quickSignIn':
          this.handleQuickSignIn(formId);
          break;
        default:
          LogUtil.warn(`Unknown action: ${action}`);
      }
    } catch (error) {
      LogUtil.error('Parse event message failed:', String(error));
    }
  }

  onRemoveForm(formId: string): void {
    LogUtil.info(`onRemoveForm - FormId: ${formId}`);
    FormCardSyncService.unregisterForm(this.context, formId);
    this.clearFormData(formId);
  }

  private getStoredStudentData(): StudentData {
    const fallbackData: StudentData = {
      studentName: '张小明',
      className: '三年级 1 班',
      sessionTime: '15:30-18:00',
      status: 'SIGNED_IN',
      statusText: '已签到',
      signInTime: '15:32',
      homeworkProgress: '2/3',
      teacherFeedback: '作业完成良好'
    };

    try {
      const dataPreferences = preferences.getPreferencesSync(this.context, {
        name: 'SmartGuardianFormData'
      });
      const storedValue = dataPreferences.getSync(STUDENT_INFO_KEY, '') as string;
      if (typeof storedValue === 'string' && storedValue.length > 0) {
        const parsedData = JSON.parse(storedValue) as StudentData;
        const mergedData: StudentData = {
          studentName: parsedData.studentName ?? fallbackData.studentName,
          className: parsedData.className ?? fallbackData.className,
          sessionTime: parsedData.sessionTime ?? fallbackData.sessionTime,
          status: parsedData.status ?? fallbackData.status,
          statusText: parsedData.statusText ?? fallbackData.statusText,
          signInTime: parsedData.signInTime ?? fallbackData.signInTime,
          homeworkProgress: parsedData.homeworkProgress ?? fallbackData.homeworkProgress,
          teacherFeedback: parsedData.teacherFeedback ?? fallbackData.teacherFeedback
        };
        return mergedData;
      }
    } catch (error) {
      LogUtil.error('Get stored data failed:', String(error));
    }

    return fallbackData;
  }

  private buildFormDataByDimension(dimension: number, data: StudentData): FormData {
    const formData: FormData = {
      updateTime: this.formatTime(new Date()),
      formId: dimension
    };

    if (dimension === 1) {
      formData.studentName = data.studentName !== undefined ? String(data.studentName) : '未知学生';
      formData.status = data.statusText !== undefined ? String(data.statusText) : '未知状态';
      formData.statusColor = this.getStatusColor(data.status !== undefined ? String(data.status) : '');
      formData.statusIcon = this.getStatusIcon(data.status !== undefined ? String(data.status) : '');
      return formData;
    }

    formData.studentName = data.studentName !== undefined ? String(data.studentName) : '';
    formData.className = data.className !== undefined ? String(data.className) : '';
    formData.sessionTime = data.sessionTime !== undefined ? String(data.sessionTime) : '';
    formData.status = data.statusText !== undefined ? String(data.statusText) : '';
    formData.signInTime = data.signInTime !== undefined ? String(data.signInTime) : '';
    formData.homeworkProgress = data.homeworkProgress !== undefined ? String(data.homeworkProgress) : '';
    formData.teacherFeedback = data.teacherFeedback !== undefined ? String(data.teacherFeedback) : '';
    formData.statusColor = this.getStatusColor(data.status !== undefined ? String(data.status) : '');
    formData.statusIcon = this.getStatusIcon(data.status !== undefined ? String(data.status) : '');
    if (dimension === 3) {
      formData.showDetail = true;
    }
    return formData;
  }

  private openMainApp(page: string): void {
    try {
      LogUtil.info(`Opening main app to page: ${page}`);
    } catch (error) {
      LogUtil.error('Open app failed:', String(error));
    }
  }

  private async handleQuickSignIn(formId: string): Promise<void> {
    LogUtil.info(`Handling quick sign in for form: ${formId}`);

    try {
      this.onUpdateForm(formId);
    } catch (error) {
      LogUtil.error('Handle quick sign in failed:', String(error));
    }
  }

  private clearFormData(formId: string): void {
    LogUtil.info(`Clearing data for form: ${formId}`);
  }

  private getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'PENDING': '#F59E42',
      'SIGNED_IN': '#2DBE7E',
      'IN_PROGRESS': '#2F7DF6',
      'WAITING_PICKUP': '#526A83',
      'SIGNED_OUT': '#667085'
    };
    return colorMap[status] || '#98A2B3';
  }

  private getStatusIcon(status: string): string {
    const iconMap: Record<string, string> = {
      'PENDING': '待签',
      'SIGNED_IN': '已签',
      'IN_PROGRESS': '辅导',
      'WAITING_PICKUP': '待接',
      'SIGNED_OUT': '离托'
    };
    return iconMap[status] || '状态';
  }

  private formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}

interface FormData {
  updateTime: string;
  formId: number;
  studentName?: string;
  className?: string;
  sessionTime?: string;
  status?: string;
  statusColor?: string;
  statusIcon?: string;
  signInTime?: string;
  homeworkProgress?: string;
  teacherFeedback?: string;
  showDetail?: boolean;
}

interface FormEvent {
  action: string;
  data?: string;
}

interface StudentData {
  studentName?: string;
  className?: string;
  sessionTime?: string;
  status?: string;
  statusText?: string;
  signInTime?: string;
  homeworkProgress?: string;
  teacherFeedback?: string;
}
