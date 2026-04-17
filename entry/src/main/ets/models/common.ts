/**
 * SmartGuardian - Common Models
 * Common types and interfaces used across the application
 */

/**
 * API Response wrapper
 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * Page response wrapper
 */
export interface PageResponse<T> {
  list: T[];
  total: number;
  pageNum: number;
  pageSize: number;
}

/**
 * User roles in the system
 */
export enum UserRole {
  PARENT = 'PARENT',       // 家长
  TEACHER = 'TEACHER',     // 教师/看护老师
  ORG_ADMIN = 'ORG_ADMIN', // 机构管理员
  SCHOOL_ADMIN = 'SCHOOL_ADMIN', // 学校管理员
  PLATFORM_ADMIN = 'PLATFORM_ADMIN' // 平台管理员
}

/**
 * Order status
 */
export enum OrderStatus {
  PENDING = 'PENDING',           // 待审核
  APPROVED = 'APPROVED',         // 已审核
  REJECTED = 'REJECTED',         // 已拒绝
  CANCELLED = 'CANCELLED',       // 已取消
  COMPLETED = 'COMPLETED',       // 已完成
  REFUNDED = 'REFUNDED'          // 已退款
}

/**
 * Payment status
 */
export enum PayStatus {
  UNPAID = 'UNPAID',     // 未支付
  PAID = 'PAID',         // 已支付
  REFUNDING = 'REFUNDING', // 退款中
  REFUNDED = 'REFUNDED'  // 已退款
}

/**
 * Attendance status
 */
export enum AttendanceStatus {
  NOT_SIGNED = 'NOT_SIGNED', // 未签到
  SIGNED_IN = 'SIGNED_IN',   // 已签到
  SIGNED_OUT = 'SIGNED_OUT', // 已签退
  ABSENT = 'ABSENT',         // 缺勤
  LATE = 'LATE',             // 迟到
  LEAVE = 'LEAVE'            // 请假
}

/**
 * Homework status
 */
export enum HomeworkStatus {
  PENDING = 'PENDING',         // 待辅导
  IN_PROGRESS = 'IN_PROGRESS', // 辅导中
  COMPLETED = 'COMPLETED',     // 已完成
  CONFIRMED = 'CONFIRMED'      // 家长已确认
}

/**
 * Message type
 */
export enum MessageType {
  SYSTEM = 'SYSTEM',     // 系统通知
  ATTENDANCE = 'ATTENDANCE', // 考勤通知
  HOMEWORK = 'HOMEWORK', // 作业通知
  ORDER = 'ORDER',       // 订单通知
  CHAT = 'CHAT'          // 聊天消息
}

/**
 * Abnormal attendance types
 */
export enum AbnormalType {
  NOT_SIGNED = 'NOT_SIGNED',   // 未签到
  LATE = 'LATE',               // 迟到
  WRONG_SESSION = 'WRONG_SESSION', // 错班签到
  UNAUTHORIZED = 'UNAUTHORIZED', // 非授权人员签到
  DUPLICATE = 'DUPLICATE',     // 重复签到
  LOCATION_MISMATCH = 'LOCATION_MISMATCH' // 位置异常
}

