/**
 * SmartGuardian - API Endpoints
 * Unified API endpoint constants
 * 
 * @description 统一API端点常量，消除各服务硬编码的URL路径
 * @features
 * - 按模块分组
 * - RESTful风格路径
 * - 易于维护和修改
 */

/**
 * API Version
 */
export const API_VERSION = 'v1';

/**
 * API Base Path
 */
export const API_BASE = `/api/${API_VERSION}`;

/**
 * API Endpoints Class
 * @description API端点常量类
 */
export class ApiEndpoints {
  // ============================================
  // Auth & User (认证与用户)
  // ============================================
  
  /** 认证模块基础路径 */
  static readonly AUTH = `${API_BASE}/auth`;
  /** 用户登录 */
  static readonly AUTH_LOGIN = `${API_BASE}/auth/login`;
  /** 用户登出 */
  static readonly AUTH_LOGOUT = `${API_BASE}/auth/logout`;
  /** 获取当前用户信息 */
  static readonly AUTH_ME = `${API_BASE}/auth/me`;
  /** 刷新Token */
  static readonly AUTH_REFRESH = `${API_BASE}/auth/refresh`;
  static readonly AUTH_SESSION_DEVICE = `${API_BASE}/auth/session-device`;

  /** 用户模块基础路径 */
  static readonly USERS = `${API_BASE}/users`;

  // ============================================
  // Student (学生)
  // ============================================
  
  /** 学生模块基础路径 */
  static readonly STUDENTS = `${API_BASE}/students`;
  /** 兼容 V2 的学生详情模板路径 */
  static readonly STUDENT_DETAIL = `${API_BASE}/students/{id}`;
  /** 兼容 V2 的学生监护人模板路径 */
  static readonly STUDENT_GUARDIANS = `${API_BASE}/students/{studentId}/guardians`;
  
  /**
   * 获取学生详情路径
   * @param studentId 学生ID
   */
  static studentDetail(studentId: number): string {
    return `${API_BASE}/students/${studentId}`;
  }
  
  /**
   * 绑定监护人路径
   * @param studentId 学生ID
   */
  static bindGuardian(studentId: number): string {
    return `${API_BASE}/students/${studentId}/guardians`;
  }

  // ============================================
  // Service Product (服务产品)
  // ============================================
  
  /** 服务产品基础路径 */
  static readonly SERVICE_PRODUCTS = `${API_BASE}/service-products`;
  
  /**
   * 服务产品详情路径
   * @param serviceId 服务ID
   */
  static serviceProductDetail(serviceId: number): string {
    return `${API_BASE}/service-products/${serviceId}`;
  }

  // ============================================
  // Order (订单)
  // ============================================
  
  /** 订单基础路径 */
  static readonly ORDERS = `${API_BASE}/orders`;
  
  /**
   * 订单详情路径
   * @param orderId 订单ID
   */
  static orderDetail(orderId: number): string {
    return `${API_BASE}/orders/${orderId}`;
  }
  
  /**
   * 订单审核路径
   * @param orderId 订单ID
   */
  static orderAudit(orderId: number): string {
    return `${API_BASE}/orders/${orderId}/audit`;
  }
  
  /**
   * 订单退款路径
   * @param orderId 订单ID
   */
  static orderRefund(orderId: number): string {
    return `${API_BASE}/orders/${orderId}/refund`;
  }

  // ============================================
  // Session (班次)
  // ============================================
  
  /** 班次基础路径 */
  static readonly SESSIONS = `${API_BASE}/sessions`;
  /** 今日班次 */
  static readonly SESSIONS_TODAY = `${API_BASE}/sessions/today`;
  
  /**
   * 班次详情路径
   * @param sessionId 班次ID
   */
  static sessionDetail(sessionId: number): string {
    return `${API_BASE}/sessions/${sessionId}`;
  }

  // ============================================
  // Attendance (考勤)
  // ============================================
  
  /** 考勤基础路径 */
  static readonly ATTENDANCE = `${API_BASE}/attendance`;
  /** 签到 */
  static readonly ATTENDANCE_SIGN_IN = `${API_BASE}/attendance/sign-in`;
  /** 签退 */
  static readonly ATTENDANCE_SIGN_OUT = `${API_BASE}/attendance/sign-out`;
  /** 异常考勤 */
  static readonly ATTENDANCE_ABNORMAL = `${API_BASE}/attendance/abnormal-events`;
  /** 请假 */
  static readonly ATTENDANCE_LEAVE = `${API_BASE}/attendance/leave`;
  /** 考勤统计 */
  static readonly ATTENDANCE_STATS = `${API_BASE}/attendance/statistics`;
  /** 兼容 V2 的请假路径别名 */
  static readonly LEAVE = `${API_BASE}/attendance/leave`;

  /**
   * 取消请假路径
   * @param leaveId 请假记录ID
   */
  static attendanceLeaveCancel(leaveId: number): string {
    return `${API_BASE}/attendance/leave/${leaveId}/cancel`;
  }

  // ============================================
  // Homework (作业)
  // ============================================
  
  /** 作业任务基础路径 */
  static readonly HOMEWORK_TASKS = `${API_BASE}/homework/tasks`;
  /** 作业反馈 */
  static readonly HOMEWORK_FEEDBACK = `${API_BASE}/homework/feedback`;
  
  /**
   * 作业任务详情路径
   * @param taskId 任务ID
   */
  static homeworkTaskDetail(taskId: number): string {
    return `${API_BASE}/homework/tasks/${taskId}`;
  }
  
  /**
   * 作业任务状态更新路径
   * @param taskId 任务ID
   */
  static homeworkTaskStatus(taskId: number): string {
    return `${API_BASE}/homework/tasks/${taskId}/status`;
  }
  
  /**
   * 作业任务反馈列表路径
   * @param taskId 任务ID
   */
  static homeworkTaskFeedbacks(taskId: number): string {
    return `${API_BASE}/homework/tasks/${taskId}/feedbacks`;
  }
  
  /**
   * 作业反馈确认路径
   * @param feedbackId 反馈ID
   */
  static homeworkFeedbackConfirm(feedbackId: number): string {
    return `${API_BASE}/homework/feedback/${feedbackId}/confirm`;
  }

  // ============================================
  // Message (消息)
  // ============================================
  
  /** 消息基础路径 */
  static readonly MESSAGES = `${API_BASE}/messages`;
  /** 未读消息数量 */
  static readonly MESSAGES_UNREAD_COUNT = `${API_BASE}/messages/unread-count`;
  /** 兼容 V2 的未读消息数量别名 */
  static readonly MESSAGES_UNREAD = `${API_BASE}/messages/unread-count`;
  /** 消息统计 */
  static readonly MESSAGES_STATISTICS = `${API_BASE}/messages/statistics`;
  /** 兼容 V2 的消息统计别名 */
  static readonly MESSAGES_STATS = `${API_BASE}/messages/statistics`;
  /** 批量标记已读 */
  static readonly MESSAGES_BATCH_READ = `${API_BASE}/messages/batch-read`;
  /** 全部标记已读 */
  static readonly MESSAGES_READ_ALL = `${API_BASE}/messages/read-all`;
  
  /**
   * 消息详情路径
   * @param messageId 消息ID
   */
  static messageDetail(messageId: number): string {
    return `${API_BASE}/messages/${messageId}`;
  }
  
  /**
   * 消息标记已读路径
   * @param messageId 消息ID
   */
  static messageRead(messageId: number): string {
    return `${API_BASE}/messages/${messageId}/read`;
  }
  
  /**
   * 消息删除路径
   * @param messageId 消息ID
   */
  static messageDelete(messageId: number): string {
    return `${API_BASE}/messages/${messageId}/delete`;
  }

  // ============================================
  // Alert (告警)
  // ============================================
  
  /** 告警基础路径 */
  static readonly ALERTS = `${API_BASE}/alerts`;
  /** 活跃告警数量 */
  static readonly ALERTS_ACTIVE_COUNT = `${API_BASE}/alerts/active-count`;
  /** 告警统计 */
  static readonly ALERTS_STATISTICS = `${API_BASE}/alerts/statistics`;
  
  /**
   * 告警详情路径
   * @param alertId 告警ID
   */
  static alertDetail(alertId: number): string {
    return `${API_BASE}/alerts/${alertId}`;
  }
  
  /**
   * 告警确认路径
   * @param alertId 告警ID
   */
  static alertAcknowledge(alertId: number): string {
    return `${API_BASE}/alerts/${alertId}/acknowledge`;
  }
  
  /**
   * 告警解决路径
   * @param alertId 告警ID
   */
  static alertResolve(alertId: number): string {
    return `${API_BASE}/alerts/${alertId}/resolve`;
  }
  
  /**
   * 告警忽略路径
   * @param alertId 告警ID
   */
  static alertDismiss(alertId: number): string {
    return `${API_BASE}/alerts/${alertId}/dismiss`;
  }

  // ============================================
  // Timeline (时间线)
  // ============================================
  
  /** 时间线基础路径 */
  static readonly TIMELINE = `${API_BASE}/timeline`;
  
  /**
   * 学生时间线路径
   * @param studentId 学生ID
   */
  static studentTimeline(studentId: number): string {
    return `${API_BASE}/timeline/students/${studentId}`;
  }

  // ============================================
  // Payment (支付)
  // ============================================
  
  /** 支付基础路径 */
  static readonly PAYMENTS = `${API_BASE}/payments`;
  /** 支付回调 */
  static readonly PAYMENTS_CALLBACK = `${API_BASE}/payments/callback`;

  // ============================================
  // Refund (退款)
  // ============================================
  
  /** 退款基础路径 */
  static readonly REFUNDS = `${API_BASE}/refunds`;
  /** 退款统计 */
  static readonly REFUNDS_STATISTICS = `${API_BASE}/refunds/statistics`;
  /** 退款金额计算 */
  static readonly REFUNDS_CALCULATE = `${API_BASE}/refunds/calculate`;
  
  /**
   * 退款详情路径
   * @param refundId 退款ID
   */
  static refundDetail(refundId: number): string {
    return `${API_BASE}/refunds/${refundId}`;
  }
  
  /**
   * 退款取消路径
   * @param refundId 退款ID
   */
  static refundCancel(refundId: number): string {
    return `${API_BASE}/refunds/${refundId}/cancel`;
  }
  
  /**
   * 订单退款列表路径
   * @param orderId 订单ID
   */
  static refundsByOrder(orderId: number): string {
    return `${API_BASE}/refunds/order/${orderId}`;
  }

  // ============================================
  // Report (报表)
  // ============================================
  
  /** 报表基础路径 */
  static readonly REPORTS = `${API_BASE}/reports`;
  /** 考勤报表 */
  static readonly REPORTS_ATTENDANCE = `${API_BASE}/reports/attendance`;
  /** 财务报表 */
  static readonly REPORTS_FINANCE = `${API_BASE}/reports/finance`;
  /** 教师绩效 */
  static readonly REPORTS_PERFORMANCE = `${API_BASE}/reports/performance`;
  /** 每日考勤统计 */
  static readonly REPORTS_ATTENDANCE_DAILY = `${API_BASE}/reports/attendance/daily`;
  /** 学生考勤汇总 */
  static readonly REPORTS_ATTENDANCE_STUDENTS = `${API_BASE}/reports/attendance/students`;
  /** 每日营收统计 */
  static readonly REPORTS_FINANCE_DAILY = `${API_BASE}/reports/finance/daily`;
  /** 服务产品营收 */
  static readonly REPORTS_FINANCE_PRODUCTS = `${API_BASE}/reports/finance/products`;

  // ============================================
  // Card (卡片)
  // ============================================
  
  /** 卡片基础路径 */
  static readonly CARDS = `${API_BASE}/cards`;
  /** 今日状态卡片 */
  static readonly CARDS_TODAY_STATUS = `${API_BASE}/cards/today-status`;
  /** 异常告警卡片 */
  static readonly CARDS_ABNORMAL_ALERT = `${API_BASE}/cards/abnormal-alert`;
  /** 卡片缓存一致性验收 */
  static readonly CARDS_CONSISTENCY = `${API_BASE}/cards/consistency`;
  /** 主动刷新卡片缓存 */
  static readonly CARDS_REFRESH = `${API_BASE}/cards/refresh`;

  // ============================================
  // Workbench (三端工作台)
  // ============================================

  /** 工作台基础路径 */
  static readonly WORKBENCH = `${API_BASE}/workbench`;
  /** 当前角色工作台能力清单 */
  static readonly WORKBENCH_MANIFEST = `${API_BASE}/workbench/manifest`;

  // ============================================
  // Agent (智慧托管 Agent)
  // ============================================

  /** 智慧托管 Agent 基础路径 */
  static readonly AGENT = `${API_BASE}/agent`;
  /** Agent 对话问答 */
  static readonly AGENT_CHAT = `${API_BASE}/agent/chat`;
  /** Agent 托管总结 */
  static readonly AGENT_SUMMARY = `${API_BASE}/agent/summary`;
  /** Agent 汇报生成 */
  static readonly AGENT_REPORT = `${API_BASE}/agent/report`;
  /** Agent 导航解析 */
  static readonly AGENT_NAVIGATION = `${API_BASE}/agent/navigation`;

  // ============================================
  // Security (安全审计)
  // ============================================

  /** 安全治理基础路径 */
  static readonly SECURITY = `${API_BASE}/security`;
  /** 安全审计事件 */
  static readonly SECURITY_AUDIT_EVENTS = `${API_BASE}/security/audit-events`;
  /** 安全审计统计 */
  static readonly SECURITY_AUDIT_STATISTICS = `${API_BASE}/security/audit-events/statistics`;

  // ============================================
  // Event / Notification / Storage (云端编排)
  // ============================================

  /** 事件中心基础路径 */
  static readonly EVENTS = `${API_BASE}/events`;
  /** 事件 outbox */
  static readonly EVENTS_OUTBOX = `${API_BASE}/events/outbox`;
  /** 处理待消费事件 */
  static readonly EVENTS_PROCESS = `${API_BASE}/events/process`;
  static readonly EVENTS_TRIGGER_CONFIG = `${API_BASE}/events/trigger-config`;
  static readonly EVENTS_TRIGGER = `${API_BASE}/events/trigger`;

  /** 通知编排基础路径 */
  static readonly NOTIFICATIONS = `${API_BASE}/notifications`;
  /** 通知真实送达配置 */
  static readonly NOTIFICATION_DELIVERY_CONFIG = `${API_BASE}/notifications/delivery-config`;
  /** 通知任务 */
  static readonly NOTIFICATION_JOBS = `${API_BASE}/notifications/jobs`;
  static readonly NOTIFICATION_JOBS_PROCESS = `${API_BASE}/notifications/jobs/process`;
  /** 通知送达回执 */
  static readonly NOTIFICATION_RECEIPTS = `${API_BASE}/notifications/receipts`;
  /** 当前用户通知偏好 */
  static readonly NOTIFICATION_PREFERENCES = `${API_BASE}/notifications/preferences`;

  /** 云存储附件基础路径 */
  static readonly STORAGE = `${API_BASE}/storage`;
  /** 云存储配置 */
  static readonly STORAGE_CONFIG = `${API_BASE}/storage/config`;
  /** 附件元数据 */
  static readonly STORAGE_ATTACHMENTS = `${API_BASE}/storage/attachments`;

  static notificationJobRetry(jobId: number): string {
    return `${API_BASE}/notifications/jobs/${jobId}/retry`;
  }

  static storageAttachmentComplete(attachmentId: number): string {
    return `${API_BASE}/storage/attachments/${attachmentId}/complete`;
  }
}
