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
 * Leave record (请假记录)
 *
 * @description 学生请假记录
 */
export interface LeaveRecord extends LeaveRequest {
  /** 请假记录ID */
  id: number;

  /** 请假状态 (PENDING, APPROVED, REJECTED, CANCELLED) */
  status: string;

  /** 审核人ID */
  reviewerId?: number;

  /** 审核人姓名 */
  reviewerName?: string;

  /** 审核备注 */
  reviewRemark?: string;

  /** 审核时间 */
  reviewedAt?: string;

  /** 创建时间 */
  createdAt?: string;

  /** 更新时间 */
  updatedAt?: string;
}

/**
 * Attendance statistics (考勤统计)
 *
 * @description 考勤与请假汇总，用于首页、报表和管理端筛选概览。
 */
export interface AttendanceStatistics {
  /** 考勤记录总数 */
  total: number;

  /** 已签到数量 */
  signedIn: number;

  /** 已签退数量 */
  signedOut: number;

  /** 未签到/缺勤数量 */
  absent: number;

  /** 迟到数量 */
  late: number;

  /** 异常考勤数量 */
  abnormal: number;

  /** 待审核请假数量 */
  leavePending: number;
}
