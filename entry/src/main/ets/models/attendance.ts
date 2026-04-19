/**
 * SmartGuardian - Attendance & Homework Models
 * Attendance, homework, feedback, message related types
 * 
 * @description 考勤、作业、反馈、消息相关数据模型
 * @note 包含 OpenAPI 标准字段和 UI 便利字段
 */

/**
 * Attendance record (考勤记录)
 * 
 * @description 学生的签到签退记录
 * @note 包含关联字段，由后端通过JOIN查询返回
 */
export interface AttendanceRecord {
  // ===== OpenAPI 标准字段 =====
  
  /** 考勤记录ID */
  id: number;
  
  /** 学生ID */
  studentId: number;
  
  /** 班次ID */
  sessionId: number;
  
  /** 签到时间 */
  signInTime?: string;
  
  /** 签退时间 */
  signOutTime?: string;
  
  /** 签到方式 (MANUAL, FACE, CARD, QR_CODE) */
  signInMethod?: string;
  
  /** 签退方式 (MANUAL, FACE, CARD, QR_CODE) */
  signOutMethod?: string;
  
  /** 签到地点 (GPS坐标或地点名称) */
  signInLocation?: string;
  
  /** 签退地点 (GPS坐标或地点名称) */
  signOutLocation?: string;
  
  /** 操作人ID (教师或管理员ID) */
  operatorUserId?: number;
  
  /** 操作人姓名 (关联 User.name) */
  operatorName?: string;
  
  /** 异常标记 */
  abnormalFlag?: boolean;
  
  /** 异常类型 (LATE_SIGN_IN, EARLY_SIGN_OUT, ABSENT) */
  abnormalType?: string;
  
  /** 异常描述 */
  abnormalDesc?: string;
  
  /** 创建时间 */
  createdAt?: string;
  
  /** 更新时间 */
  updatedAt?: string;
  
  // ===== UI 便利字段 (后端关联返回) =====
  
  /** 考勤状态 (ABSENT, SIGNED_IN, SIGNED_OUT) */
  status: string;
  
  /** 学生姓名 (关联 Student.name) */
  studentName?: string;
  
  /** 学号 */
  studentNo?: string;
  
  /** 订单ID (关联 Order.id) */
  orderId?: number;
  
  /** 班次编号 (关联 Session.sessionNo) */
  sessionNo?: string;
  
  /** 考勤日期 (源自 Session.sessionDate) */
  attendanceDate?: string;
  
  /** 签到方式 (旧字段，建议使用signInMethod) */
  signMethod?: string;
}

/**
 * Sign in request (签到请求)
 * 
 * @description 学生签到请求参数
 */
export interface SignInRequest {
  /** 学生ID */
  studentId: number;
  
  /** 班次ID */
  sessionId: number;
  
  /** 签到类型 (NORMAL, LATE) */
  signInType?: string;
  
  /** 签到方式 (MANUAL, FACE, CARD, QR_CODE) */
  signMethod?: string;
  
  /** 签到地点 */
  location?: string;
}

/**
 * Sign out request (签退请求)
 * 
 * @description 学生签退请求参数
 */
export interface SignOutRequest {
  /** 学生ID */
  studentId: number;
  
  /** 班次ID */
  sessionId: number;
  
  /** 签退类型 (NORMAL, EARLY) */
  signOutType?: string;
  
  /** 签退方式 (MANUAL, FACE, CARD, QR_CODE) */
  signMethod?: string;
  
  /** 家长ID (接学生的家长) */
  guardianId?: number;
  
  /** 接送人ID */
  pickupUserId?: number;
  
  /** 签退地点 */
  location?: string;
}

/**
 * Leave request (请假申请)
 * 
 * @description 学生请假申请参数
 */
export interface LeaveRequest {
  /** 学生ID */
  studentId: number;
  
  /** 请假日期 */
  leaveDate: string;
  
  /** 请假类型 (SICK, PERSONAL, EMERGENCY) */
  leaveType: string;
  
  /** 请假原因 */
  reason: string;
  
  /** 附件列表 (请假条、病假证明等) */
  attachments?: string[];
}

/**
 * Homework task (作业任务)
 * 
 * @description 学生的作业任务记录
 * @note 包含关联字段，由后端通过JOIN查询返回
 */
export interface HomeworkTask {
  // ===== OpenAPI 标准字段 =====
  
  /** 作业ID */
  id: number;
  
  /** 学生ID */
  studentId: number;
  
  /** 作业日期 */
  taskDate: string;
  
  /** 学科 (语文、数学、英语等) */
  subject?: string;
  
  /** 作业标题 */
  title?: string;
  
  /** 作业内容 */
  content?: string;
  
  /** 来源类型 (MANUAL, SYSTEM, IMPORT) */
  sourceType?: string;
  
  /** 作业状态 (PENDING, IN_PROGRESS, COMPLETED) */
  status: string;
  
  /** 作业编号 */
  taskNo?: string;
  
  /** 班次ID (关联 Session.id) */
  sessionId?: number;
  
  /** 班次编号 (关联 Session.sessionNo) */
  sessionNo?: string;
  
  /** 教师ID (关联 User.id) */
  teacherId?: number;
  
  /** 创建时间 */
  createdAt?: string;
  
  /** 更新时间 */
  updatedAt?: string;
  
  // ===== UI 便利字段 (后端关联返回) =====
  
  /** 学生姓名 (关联 Student.name) */
  studentName?: string;
  
  /** 教师姓名 (关联 User.name) */
  teacherName?: string;
  
  /** 附件列表 (图片、文档等) */
  attachments?: string[];
  
  /** 完成时间 */
  completedTime?: string;
}

/**
 * Create homework task request (创建作业任务请求)
 * 
 * @description 教师创建作业任务的请求参数
 */
export interface HomeworkTaskCreateRequest {
  /** 学生ID */
  studentId: number;
  
  /** 作业日期 */
  taskDate: string;
  
  /** 学科 */
  subject: string;
  
  /** 作业标题 */
  title: string;
  
  /** 作业内容 */
  content?: string;
  
  /** 来源类型 */
  sourceType?: string;
  
  /** 班次ID */
  sessionId?: number;
  
  /** 附件列表 */
  attachments?: string[];
}

/**
 * Homework feedback (作业反馈)
 * 
 * @description 教师对学生作业的反馈
 */
export interface HomeworkFeedback {
  /** 反馈ID */
  id: number;
  
  /** 作业任务ID */
  taskId: number;
  
  /** 教师ID */
  teacherId?: number;
  
  /** 教师姓名 (关联 User.name) */
  teacherName?: string;
  
  /** 学生ID */
  studentId?: number;
  
  /** 反馈内容 */
  feedbackContent: string;
  
  /** 表现评价 (EXCELLENT, GOOD, AVERAGE, NEEDS_IMPROVEMENT) */
  performance?: string;
  
  /** 附件列表 */
  attachments?: string[];
  
  /** 反馈状态 (DRAFT, PUBLISHED) */
  status?: string;
  
  /** 家长确认时间 */
  guardianConfirmTime?: string;
  
  /** 家长备注 */
  guardianRemark?: string;
  
  /** 创建时间 */
  createdAt?: string;
  
  /** 更新时间 */
  updatedAt?: string;
}

/**
 * Create homework feedback request (创建作业反馈请求)
 * 
 * @description 教师创建作业反馈的请求参数
 */
export interface HomeworkFeedbackCreateRequest {
  /** 作业任务ID */
  taskId: number;
  
  /** 反馈内容 */
  feedbackContent: string;
  
  /** 表现评价 */
  performance?: string;
  
  /** 附件列表 */
  attachments?: string[];
}

/**
 * Homework confirm request (家长确认作业请求)
 * 
 * @description 家长确认作业的请求参数
 */
export interface HomeworkConfirmRequest {
  /** 确认状态 */
  confirmStatus: 'CONFIRMED' | 'DISPUTED';
  
  /** 家长备注 */
  guardianRemark?: string;
}

/**
 * Message record (消息记录)
 * 
 * @description 用户消息通知记录
 */
export interface MessageRecord {
  /** 消息ID */
  id: number;
  
  /** 发送人ID */
  senderUserId?: number;
  
  /** 发送人姓名 (关联 User.name) */
  senderName?: string;
  
  /** 发送人头像 (关联 User.avatar) */
  senderAvatar?: string;
  
  /** 接收人ID */
  receiverUserId?: number;
  
  /** 接收人姓名 (关联 User.name) */
  receiverName?: string;
  
  /** 会话ID */
  conversationId?: number;
  
  /** 消息类型 (SYSTEM, ATTENDANCE, HOMEWORK, ORDER, CHAT) */
  msgType: 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER' | 'CHAT';
  
  /** 消息内容 */
  content: string;
  
  /** 附件列表 */
  attachments?: string[];
  
  /** 已读状态 */
  readStatus?: boolean;
  
  /** 创建时间 */
  createdAt?: string;
}

/**
 * Send message request (发送消息请求)
 * 
 * @description 发送消息的请求参数
 */
export interface SendMessageRequest {
  /** 接收人ID */
  receiverUserId: number;
  
  /** 消息类型 */
  msgType: 'SYSTEM' | 'ATTENDANCE' | 'HOMEWORK' | 'ORDER' | 'CHAT';
  
  /** 消息内容 */
  content: string;
  
  /** 附件列表 */
  attachments?: string[];
}

/**
 * Student timeline entry (学生动态时间线)
 * 
 * @description 学生的时间线记录，包含各种业务事件
 */
export interface StudentTimeline {
  /** 时间线ID */
  id: number;
  
  /** 学生ID */
  studentId: number;
  
  /** 时间线类型 (ATTENDANCE, HOMEWORK, MESSAGE, ORDER, NOTE) */
  timelineType: 'ATTENDANCE' | 'HOMEWORK' | 'MESSAGE' | 'ORDER' | 'NOTE';
  
  /** 业务ID (关联的业务记录ID) */
  bizId?: number;
  
  /** 标题 */
  title: string;
  
  /** 内容 */
  content: string;
  
  /** 业务日期 */
  bizDate?: string;
  
  /** 时间戳 */
  timestamp: string;
  
  /** 操作人ID */
  operatorUserId?: number;
  
  /** 操作人姓名 (关联 User.name) */
  operatorName?: string;
}
