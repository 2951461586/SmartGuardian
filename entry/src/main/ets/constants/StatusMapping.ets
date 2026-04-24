/**
 * SmartGuardian - Status Mapping Constants
 * Unified status text and color mapping
 * 
 * @description 统一状态文案和颜色映射，消除各页面重复的状态处理代码
 * @features
 * - 考勤状态映射
 * - 订单状态映射
 * - 作业状态映射
 * - 班次状态映射
 * - 支付状态映射
 */

/**
 * Status Style Interface
 */
export interface StatusStyle {
  /** 显示文本 */
  text: string;
  /** 文字颜色 */
  textColor: string;
  /** 背景颜色 */
  bgColor: string;
}

/**
 * Status Type Enumeration
 */
export enum StatusType {
  /** 考勤状态 */
  ATTENDANCE = 'ATTENDANCE',
  /** 订单状态 */
  ORDER = 'ORDER',
  /** 作业状态 */
  HOMEWORK = 'HOMEWORK',
  /** 班次状态 */
  SESSION = 'SESSION',
  /** 支付状态 */
  PAYMENT = 'PAYMENT',
  /** 退款状态 */
  REFUND = 'REFUND',
  /** 告警状态 */
  ALERT = 'ALERT'
}

/**
 * Attendance Status Mapping
 * @description 考勤状态映射
 */
export const ATTENDANCE_STATUS_MAP: Record<string, StatusStyle> = {
  'NOT_SIGNED': {
    text: '待签到',
    textColor: '#A9794E',
    bgColor: '#F6F0E9'
  },
  'SIGNED_IN': {
    text: '已签到',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  },
  'IN_PROGRESS': {
    text: '托管中',
    textColor: '#526F95',
    bgColor: '#EEF6F0'
  },
  'SIGNED_OUT': {
    text: '已签退',
    textColor: '#66738A',
    bgColor: '#EEF3FA'
  },
  'ABSENT': {
    text: '缺勤',
    textColor: '#D94B5A',
    bgColor: '#FFF0F1'
  },
  'LATE': {
    text: '迟到',
    textColor: '#A9794E',
    bgColor: '#F6F0E9'
  },
  'LEAVE': {
    text: '请假',
    textColor: '#526F95',
    bgColor: '#EEF6F0'
  }
};

/**
 * Order Status Mapping
 * @description 订单状态映射
 */
export const ORDER_STATUS_MAP: Record<string, StatusStyle> = {
  'PENDING': {
    text: '待审核',
    textColor: '#A9794E',
    bgColor: '#F6F0E9'
  },
  'APPROVED': {
    text: '已审核',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  },
  'REJECTED': {
    text: '已拒绝',
    textColor: '#D94B5A',
    bgColor: '#FFF0F1'
  },
  'CANCELLED': {
    text: '已取消',
    textColor: '#66738A',
    bgColor: '#EEF3FA'
  },
  'COMPLETED': {
    text: '已完成',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  },
  'REFUNDED': {
    text: '已退款',
    textColor: '#66738A',
    bgColor: '#EEF3FA'
  }
};

/**
 * Homework Status Mapping
 * @description 作业状态映射
 */
export const HOMEWORK_STATUS_MAP: Record<string, StatusStyle> = {
  'PENDING': {
    text: '待辅导',
    textColor: '#A9794E',
    bgColor: '#F6F0E9'
  },
  'IN_PROGRESS': {
    text: '辅导中',
    textColor: '#526F95',
    bgColor: '#EEF6F0'
  },
  'COMPLETED': {
    text: '已完成',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  },
  'CONFIRMED': {
    text: '已确认',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  }
};

/**
 * Session Status Mapping
 * @description 班次状态映射
 */
export const SESSION_STATUS_MAP: Record<string, StatusStyle> = {
  'SCHEDULED': {
    text: '待开始',
    textColor: '#A9794E',
    bgColor: '#F6F0E9'
  },
  'IN_PROGRESS': {
    text: '进行中',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  },
  'COMPLETED': {
    text: '已完成',
    textColor: '#66738A',
    bgColor: '#EEF3FA'
  },
  'CANCELLED': {
    text: '已取消',
    textColor: '#D94B5A',
    bgColor: '#FFF0F1'
  }
};

/**
 * Payment Status Mapping
 * @description 支付状态映射
 */
export const PAYMENT_STATUS_MAP: Record<string, StatusStyle> = {
  'UNPAID': {
    text: '未支付',
    textColor: '#A9794E',
    bgColor: '#F6F0E9'
  },
  'PAID': {
    text: '已支付',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  },
  'REFUNDING': {
    text: '退款中',
    textColor: '#526F95',
    bgColor: '#EEF6F0'
  },
  'REFUNDED': {
    text: '已退款',
    textColor: '#66738A',
    bgColor: '#EEF3FA'
  }
};

/**
 * Refund Status Mapping
 * @description 退款状态映射
 */
export const REFUND_STATUS_MAP: Record<string, StatusStyle> = {
  'PENDING': {
    text: '待处理',
    textColor: '#A9794E',
    bgColor: '#F6F0E9'
  },
  'PROCESSING': {
    text: '处理中',
    textColor: '#526F95',
    bgColor: '#EEF6F0'
  },
  'SUCCESS': {
    text: '退款成功',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  },
  'FAILED': {
    text: '退款失败',
    textColor: '#D94B5A',
    bgColor: '#FFF0F1'
  },
  'CANCELLED': {
    text: '已取消',
    textColor: '#66738A',
    bgColor: '#EEF3FA'
  }
};

/**
 * Alert Status Mapping
 * @description 告警状态映射
 */
export const ALERT_STATUS_MAP: Record<string, StatusStyle> = {
  'ACTIVE': {
    text: '待处理',
    textColor: '#D94B5A',
    bgColor: '#FFF0F1'
  },
  'ACKNOWLEDGED': {
    text: '已确认',
    textColor: '#A9794E',
    bgColor: '#F6F0E9'
  },
  'RESOLVED': {
    text: '已解决',
    textColor: '#5D8267',
    bgColor: '#EEF6F0'
  },
  'DISMISSED': {
    text: '已忽略',
    textColor: '#66738A',
    bgColor: '#EEF3FA'
  }
};

/**
 * Status Mapping Helper
 * @description 状态映射工具类
 */
export class StatusMappingHelper {
  /**
   * Get status style by type and value
   * @param type 状态类型
   * @param value 状态值
   * @returns 状态样式，未找到返回默认样式
   */
  static getStatusStyle(type: StatusType, value: string): StatusStyle {
    let map: Record<string, StatusStyle>;

    switch (type) {
      case StatusType.ATTENDANCE:
        map = ATTENDANCE_STATUS_MAP;
        break;
      case StatusType.ORDER:
        map = ORDER_STATUS_MAP;
        break;
      case StatusType.HOMEWORK:
        map = HOMEWORK_STATUS_MAP;
        break;
      case StatusType.SESSION:
        map = SESSION_STATUS_MAP;
        break;
      case StatusType.PAYMENT:
        map = PAYMENT_STATUS_MAP;
        break;
      case StatusType.REFUND:
        map = REFUND_STATUS_MAP;
        break;
      case StatusType.ALERT:
        map = ALERT_STATUS_MAP;
        break;
      default:
        return StatusMappingHelper.getDefaultStyle(value);
    }

    return map[value] || StatusMappingHelper.getDefaultStyle(value);
  }

  /**
   * Get default status style
   * @param value 状态值
   * @returns 默认状态样式
   */
  static getDefaultStyle(value: string): StatusStyle {
    return {
      text: value,
      textColor: '#66738A',
      bgColor: '#EEF3FA'
    };
  }

  /**
   * Get status text only
   * @param type 状态类型
   * @param value 状态值
   * @returns 状态文本
   */
  static getStatusText(type: StatusType, value: string): string {
    return StatusMappingHelper.getStatusStyle(type, value).text;
  }

  /**
   * Get status color only
   * @param type 状态类型
   * @param value 状态值
   * @returns 文字颜色
   */
  static getStatusColor(type: StatusType, value: string): string {
    return StatusMappingHelper.getStatusStyle(type, value).textColor;
  }

  /**
   * Get status background color only
   * @param type 状态类型
   * @param value 状态值
   * @returns 背景颜色
   */
  static getStatusBgColor(type: StatusType, value: string): string {
    return StatusMappingHelper.getStatusStyle(type, value).bgColor;
  }
}

