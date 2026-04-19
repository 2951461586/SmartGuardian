/**
 * SmartGuardian - 今日托管服务卡片 FormExtensionAbility
 * 提供桌面卡片服务能力
 */

import { FormExtensionAbility, formBindingData, formProvider } from '@kit.FormKit';
import { wantAgent, Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'TodayGuardianFormAbility';

/**
 * 卡片数据存储Key
 */
const FORM_DATA_KEY = 'form_data';
const STUDENT_INFO_KEY = 'student_info';

export default class TodayGuardianFormAbility extends FormExtensionAbility {
  
  /**
   * 创建卡片时调用
   */
  onAddForm(want: Want): formBindingData.FormBindingData {
    LogUtil.info('onAddForm called');
    
    const formId = want.parameters?.['ohos.extra.param.key.form_identity'] as string;
    const formName = want.parameters?.['ohos.extra.param.key.form_name'] as string;
    const dimension = want.parameters?.['ohos.extra.param.key.form_dimension'] as number;
    
    LogUtil.info(`Form created - ID: ${formId}, Name: ${formName}, Dimension: ${dimension}`);
    
    // 获取存储的学生数据
    const studentData = this.getStoredStudentData();
    
    // 根据卡片尺寸返回不同的数据
    const formData = this.buildFormDataByDimension(dimension, studentData);
    
    return formBindingData.createFormBindingData(formData);
  }
  
  /**
   * 更新卡片时调用
   */
  onUpdateForm(formId: string): void {
    LogUtil.info(`onUpdateForm called - FormId: ${formId}`);
    
    // 获取最新数据
    const studentData = this.getStoredStudentData();
    
    // 构建更新数据
    const formData = this.buildFormDataByDimension(2, studentData);
    
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
  
  /**
   * 卡片事件处理
   */
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
  
  /**
   * 移除卡片时调用
   */
  onRemoveForm(formId: string): void {
    LogUtil.info(`onRemoveForm - FormId: ${formId}`);
    
    // 清理相关数据
    this.clearFormData(formId);
  }
  
  /**
   * 获取存储的学生数据
   */
  private getStoredStudentData(): StudentData {
    try {
      const studentData: StudentData = {
        studentName: '张小明',
        className: '三年级1班',
        sessionTime: '15:30-18:00',
        status: 'SIGNED_IN',
        statusText: '已签到',
        signInTime: '15:32',
        homeworkProgress: '2/3',
        teacherFeedback: '作业完成良好'
      };
      return studentData;
    } catch (error) {
      LogUtil.error('Get stored data failed:', String(error));
      const emptyData: StudentData = {};
      return emptyData;
    }
  }
  
  /**
   * 根据尺寸构建卡片数据
   */
  private buildFormDataByDimension(dimension: number, data: StudentData): FormData {
    const formData: FormData = {
      updateTime: this.formatTime(new Date()),
      formId: dimension
    };
    
    switch (dimension) {
      case 1:
        formData.studentName = data.studentName !== undefined ? String(data.studentName) : '未知学生';
        formData.status = data.statusText !== undefined ? String(data.statusText) : '未知状态';
        formData.statusColor = this.getStatusColor(data.status !== undefined ? String(data.status) : '');
        break;
        
      case 2:
        formData.studentName = data.studentName !== undefined ? String(data.studentName) : '';
        formData.className = data.className !== undefined ? String(data.className) : '';
        formData.sessionTime = data.sessionTime !== undefined ? String(data.sessionTime) : '';
        formData.status = data.statusText !== undefined ? String(data.statusText) : '';
        formData.signInTime = data.signInTime !== undefined ? String(data.signInTime) : '';
        formData.homeworkProgress = data.homeworkProgress !== undefined ? String(data.homeworkProgress) : '';
        formData.teacherFeedback = data.teacherFeedback !== undefined ? String(data.teacherFeedback) : '';
        formData.statusColor = this.getStatusColor(data.status !== undefined ? String(data.status) : '');
        formData.statusIcon = this.getStatusIcon(data.status !== undefined ? String(data.status) : '');
        break;
        
      case 3:
        formData.studentName = data.studentName !== undefined ? String(data.studentName) : '';
        formData.className = data.className !== undefined ? String(data.className) : '';
        formData.sessionTime = data.sessionTime !== undefined ? String(data.sessionTime) : '';
        formData.status = data.statusText !== undefined ? String(data.statusText) : '';
        formData.signInTime = data.signInTime !== undefined ? String(data.signInTime) : '';
        formData.homeworkProgress = data.homeworkProgress !== undefined ? String(data.homeworkProgress) : '';
        formData.teacherFeedback = data.teacherFeedback !== undefined ? String(data.teacherFeedback) : '';
        formData.statusColor = this.getStatusColor(data.status !== undefined ? String(data.status) : '');
        formData.statusIcon = this.getStatusIcon(data.status !== undefined ? String(data.status) : '');
        formData.showDetail = true;
        break;
        
      default:
        break;
    }
    
    return formData;
  }
  
  /**
   * 打开主应用
   */
  private openMainApp(page: string): void {
    try {
      LogUtil.info(`Opening main app to page: ${page}`);
    } catch (error) {
      LogUtil.error('Open app failed:', String(error));
    }
  }
  
  /**
   * 处理快速签到
   */
  private async handleQuickSignIn(formId: string): Promise<void> {
    LogUtil.info(`Handling quick sign in for form: ${formId}`);
    
    try {
      // 更新卡片显示
      this.onUpdateForm(formId);
    } catch (error) {
      LogUtil.error('Handle quick sign in failed:', String(error));
    }
  }
  
  /**
   * 清理卡片数据
   */
  private clearFormData(formId: string): void {
    LogUtil.info(`Clearing data for form: ${formId}`);
  }
  
  /**
   * 获取状态颜色
   */
  private getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'PENDING': '#FF9800',
      'SIGNED_IN': '#4CAF50',
      'IN_PROGRESS': '#2196F3',
      'WAITING_PICKUP': '#9C27B0',
      'SIGNED_OUT': '#607D8B'
    };
    return colorMap[status] || '#999999';
  }
  
  /**
   * 获取状态图标
   */
  private getStatusIcon(status: string): string {
    const iconMap: Record<string, string> = {
      'PENDING': '⏰',
      'SIGNED_IN': '✅',
      'IN_PROGRESS': '📚',
      'WAITING_PICKUP': '👋',
      'SIGNED_OUT': '🏠'
    };
    return iconMap[status] || '❓';
  }
  
  /**
   * 格式化时间
   */
  private formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}

/**
 * 卡片表单数据接口
 */
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

/**
 * 表单事件接口
 */
interface FormEvent {
  action: string;
  data?: string;
}

/**
 * 学生数据接口
 */
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