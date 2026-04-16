/**
 * SmartGuardian - 今日托管服务卡片 FormProvider
 * 用于桌面服务卡片展示当日学生托管摘要信息
 */

import { formBindingData, formProvider } from '@kit.FormKit';
import { wantAgent } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';

/**
 * 今日托管卡片数据
 */
export interface TodayGuardianCardData {
  studentName: string;          // 学生姓名
  className: string;            // 班次名称
  sessionTime: string;          // 托管时段
  status: 'PENDING' | 'SIGNED_IN' | 'IN_PROGRESS' | 'WAITING_PICKUP' | 'SIGNED_OUT';
  statusText: string;           // 状态文字
  signInTime?: string;          // 签到时间
  homeworkProgress?: string;    // 作业进度
  teacherFeedback?: string;     // 教师反馈摘要
}

/**
 * 服务卡片数据提供者
 */
export class TodayGuardianCardProvider {
  private static readonly FORM_NAME = 'TodayGuardianCard';
  private static readonly DIMENSION_2X2 = 1;
  private static readonly DIMENSION_2X4 = 2;
  private static readonly DIMENSION_4X4 = 3;

  /**
   * 构建卡片数据
   */
  static buildCardData(info: TodayGuardianCardData): Record<string, Object> {
    const statusColor = this.getStatusColor(info.status);
    const statusIcon = this.getStatusIcon(info.status);

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

  /**
   * 更新卡片数据
   */
  static updateCard(formId: string, data: TodayGuardianCardData): void {
    try {
      const formData = formBindingData.createFormBindingData(
        this.buildCardData(data)
      );

      // 调用FormAbility更新卡片
      // 注意：实际开发需要通过wantAgent启动FormAbility
      console.info(`Update card ${formId} with data: ${JSON.stringify(data)}`);
    } catch (error) {
      console.error(`Failed to update card: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 触发卡片点击事件
   */
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

      // 实际项目中通过wantAgent拉起主应用
      console.info(`Card click action: ${action}, formId: ${formId}`);
    } catch (error) {
      console.error(`Card click failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取状态对应的颜色
   */
  private static getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'PENDING': '#FF9800',        // 待签到 - 橙色
      'SIGNED_IN': '#4CAF50',      // 已签到 - 绿色
      'IN_PROGRESS': '#2196F3',    // 辅导中 - 蓝色
      'WAITING_PICKUP': '#9C27B0', // 待接回 - 紫色
      'SIGNED_OUT': '#607D8B'      // 已签退 - 灰色
    };
    return colorMap[status] || '#999999';
  }

  /**
   * 获取状态对应的图标(emoji)
   */
  private static getStatusIcon(status: string): string {
    const iconMap: Record<string, string> = {
      'PENDING': '⏰',
      'SIGNED_IN': '✅',
      'IN_PROGRESS': '📚',
      'WAITING_PICKUP': '👋',
      'SIGNED_OUT': '🏠'
    };
    return iconMap[status] || '❓';
  }
}

/**
 * 异常提醒卡片数据
 */
export interface AbnormalAlertCardData {
  abnormalType: 'NOT_SIGNED_IN' | 'LATE' | 'WRONG_CLASS' | 'UNAUTHORIZED_PICKUP' | 'HOMEWORK_NOT_CONFIRMED';
  triggerTime: string;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
  suggestion: string;
  teacherName?: string;
  studentName: string;
}

/**
 * 异常提醒卡片提供者
 */
export class AbnormalAlertCardProvider {
  /**
   * 构建异常提醒卡片数据
   */
  static buildAlertCardData(info: AbnormalAlertCardData): Record<string, Object> {
    const typeText = this.getAbnormalTypeText(info.abnormalType);
    const riskColor = this.getRiskLevelColor(info.riskLevel);
    const riskText = this.getRiskLevelText(info.riskLevel);

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
      'LOW': '#FF9800',
      'MEDIUM': '#FF5722',
      'HIGH': '#F44336'
    };
    return colorMap[level] || '#999999';
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