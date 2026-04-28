/**
 * SmartGuardian - Today Guardian FormProvider
 */

import { formBindingData } from '@kit.FormKit';
import { wantAgent } from '@kit.AbilityKit';

export interface TodayGuardianCardData {
  studentName: string;
  className: string;
  sessionTime: string;
  status: 'PENDING' | 'SIGNED_IN' | 'IN_PROGRESS' | 'WAITING_PICKUP' | 'SIGNED_OUT';
  statusText: string;
  signInTime?: string;
  homeworkProgress?: string;
  teacherFeedback?: string;
}

export class TodayGuardianCardProvider {
  private static readonly FORM_NAME = 'TodayGuardianCard';
  private static readonly DIMENSION_2X2 = 1;
  private static readonly DIMENSION_2X4 = 2;
  private static readonly DIMENSION_4X4 = 3;

  static buildCardData(info: TodayGuardianCardData): Record<string, Object> {
    const statusColor = TodayGuardianCardProvider.getStatusColor(info.status);
    const statusIcon = TodayGuardianCardProvider.getStatusIcon(info.status);

    return {
      studentName: info.studentName,
      className: info.className,
      sessionTime: info.sessionTime,
      status: info.statusText,
      statusColor: statusColor,
      statusIcon: statusIcon,
      signInTime: info.signInTime || '--:--',
      homeworkProgress: info.homeworkProgress || '暂无',
      teacherFeedback: info.teacherFeedback || '暂无反馈',
      updateTime: new Date().toLocaleString()
    };
  }

  static updateCard(formId: string, data: TodayGuardianCardData): void {
    try {
      const formData = formBindingData.createFormBindingData(
        TodayGuardianCardProvider.buildCardData(data)
      );
      console.info(`Update card ${formId} with data: ${JSON.stringify(formData)}`);
    } catch (error) {
      console.error(`Failed to update card: ${JSON.stringify(error)}`);
    }
  }

  static onCardClick(formId: string, action: string): void {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: 'com.smartguardian.app',
            abilityName: 'EntryAbility',
            parameters: {
              'page': action,
              'formId': formId
            }
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };

      console.info(`Card click action: ${action}, formId: ${formId}, agent: ${JSON.stringify(wantAgentInfo)}`);
    } catch (error) {
      console.error(`Card click failed: ${JSON.stringify(error)}`);
    }
  }

  private static getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'PENDING': '#F59E42',
      'SIGNED_IN': '#2DBE7E',
      'IN_PROGRESS': '#2F7DF6',
      'WAITING_PICKUP': '#526A83',
      'SIGNED_OUT': '#667085'
    };
    return colorMap[status] || '#98A2B3';
  }

  private static getStatusIcon(status: string): string {
    const iconMap: Record<string, string> = {
      'PENDING': '待签',
      'SIGNED_IN': '已签',
      'IN_PROGRESS': '辅导',
      'WAITING_PICKUP': '待接',
      'SIGNED_OUT': '离托'
    };
    return iconMap[status] || '状态';
  }
}

export interface AbnormalAlertCardData {
  abnormalType: 'NOT_SIGNED_IN' | 'LATE' | 'WRONG_CLASS' | 'UNAUTHORIZED_PICKUP' | 'HOMEWORK_NOT_CONFIRMED';
  triggerTime: string;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
  suggestion: string;
  teacherName?: string;
  studentName: string;
}

export class AbnormalAlertCardProvider {
  static buildAlertCardData(info: AbnormalAlertCardData): Record<string, Object> {
    const typeText = AbnormalAlertCardProvider.getAbnormalTypeText(info.abnormalType);
    const riskColor = AbnormalAlertCardProvider.getRiskLevelColor(info.riskLevel);
    const riskText = AbnormalAlertCardProvider.getRiskLevelText(info.riskLevel);

    return {
      abnormalType: typeText,
      triggerTime: info.triggerTime,
      riskLevel: riskText,
      riskColor: riskColor,
      suggestion: info.suggestion,
      studentName: info.studentName,
      teacherName: info.teacherName || '未知教师',
      updateTime: new Date().toLocaleString()
    };
  }

  private static getAbnormalTypeText(type: string): string {
    const typeMap: Record<string, string> = {
      'NOT_SIGNED_IN': '未签到',
      'LATE': '迟到',
      'WRONG_CLASS': '错班签到',
      'UNAUTHORIZED_PICKUP': '未授权接走',
      'HOMEWORK_NOT_CONFIRMED': '作业未确认'
    };
    return typeMap[type] || '异常';
  }

  private static getRiskLevelColor(level: string): string {
    const colorMap: Record<string, string> = {
      'LOW': '#F59E42',
      'MEDIUM': '#FF5722',
      'HIGH': '#D92D20'
    };
    return colorMap[level] || '#98A2B3';
  }

  private static getRiskLevelText(level: string): string {
    const textMap: Record<string, string> = {
      'LOW': '低',
      'MEDIUM': '中',
      'HIGH': '高'
    };
    return textMap[level] || '未知';
  }
}
