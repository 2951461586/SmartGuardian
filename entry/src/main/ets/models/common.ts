/**
 * SmartGuardian - Common Models
 * Common types and interfaces used across the application
 */

/**
 * API Response Code Enumeration
 * @description 统一API响应码规范
 */
export enum ApiCode {
  /** 成功 - 标准响应码 */
  SUCCESS = 0,
  /** 成功 - HTTP风格响应码 */
  SUCCESS_HTTP = 200,
  /** 请求参数错误 */
  BAD_REQUEST = 400,
  /** 未授权/登录过期 */
  UNAUTHORIZED = 401,
  /** 无权限 */
  FORBIDDEN = 403,
  /** 资源不存在 */
  NOT_FOUND = 404,
  /** 请求超时 */
  REQUEST_TIMEOUT = 408,
  /** 资源冲突 */
  CONFLICT = 409,
  /** 服务器内部错误 */
  INTERNAL_ERROR = 500,
  /** 网关错误 */
  BAD_GATEWAY = 502,
  /** 服务不可用 */
  SERVICE_UNAVAILABLE = 503,
  /** 网关超时 */
  GATEWAY_TIMEOUT = 504
}

/**
 * API Response Helper
 * @description API响应判断工具类
 */
export class ApiResponseHelper {
  /**
   * 判断响应是否成功
   * @param code 响应码
   * @returns 是否成功
   */
  static isSuccess(code: number): boolean {
    return code === ApiCode.SUCCESS || code === ApiCode.SUCCESS_HTTP;
  }

  /**
   * 判断是否为认证错误
   * @param code 响应码
   * @returns 是否为认证错误
   */
  static isAuthError(code: number): boolean {
    return code === ApiCode.UNAUTHORIZED || code === ApiCode.FORBIDDEN;
  }

  /**
   * 判断是否为客户端错误
   * @param code 响应码
   * @returns 是否为客户端错误
   */
  static isClientError(code: number): boolean {
    return code >= 400 && code < 500;
  }

  /**
   * 判断是否为服务端错误
   * @param code 响应码
   * @returns 是否为服务端错误
   */
  static isServerError(code: number): boolean {
    return code >= 500;
  }

  /**
   * 获取错误类型
   * @param code 响应码
   * @returns 错误类型字符串
   */
  static getErrorType(code: number): string {
    if (this.isSuccess(code)) return 'SUCCESS';
    if (code === ApiCode.UNAUTHORIZED) return 'UNAUTHORIZED';
    if (code === ApiCode.FORBIDDEN) return 'FORBIDDEN';
    if (this.isClientError(code)) return 'CLIENT_ERROR';
    if (this.isServerError(code)) return 'SERVER_ERROR';
    return 'UNKNOWN';
  }
}

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

// ============================================
// Query Parameter Interfaces (查询参数接口)
// ============================================

/**
 * Base Page Query Parameters
 * @description 基础分页查询参数
 */
export interface PageQueryParams {
  /** 页码，从1开始 */
  pageNum?: number;
  /** 每页数量 */
  pageSize?: number;
}

/**
 * Date Range Query Parameters
 * @description 日期范围查询参数
 */
export interface DateRangeParams {
  /** 开始日期 (YYYY-MM-DD) */
  startDate?: string;
  /** 结束日期 (YYYY-MM-DD) */
  endDate?: string;
}

/**
 * Keyword Search Parameters
 * @description 关键字搜索参数
 */
export interface KeywordParams {
  /** 搜索关键字 */
  keyword?: string;
}

/**
 * Status Filter Parameters
 * @description 状态过滤参数
 */
export interface StatusFilterParams {
  /** 状态过滤 */
  status?: string;
}

/**
 * ID Filter Parameters
 * @description ID过滤参数
 */
export interface IdFilterParams {
  /** 关联ID */
  id?: number;
}

/**
 * Student Query Parameters
 * @description 学生查询参数
 */
export interface StudentQueryParams extends PageQueryParams, KeywordParams {
  /** 学生ID */
  studentId?: number;
  /** 年级 */
  grade?: string;
  /** 班级 */
  class?: string;
  /** 是否绑定监护人 */
  hasGuardian?: boolean;
}

/**
 * Order Query Parameters
 * @description 订单查询参数
 */
export interface OrderQueryParams extends PageQueryParams, DateRangeParams {
  /** 订单状态 */
  orderStatus?: string;
  /** 支付状态 */
  payStatus?: string;
  /** 学生ID */
  studentId?: number;
  /** 服务产品ID */
  serviceProductId?: number;
  /** 订单编号 */
  orderNo?: string;
}

/**
 * Attendance Query Parameters
 * @description 考勤查询参数
 */
export interface AttendanceQueryParams extends PageQueryParams, DateRangeParams {
  /** 学生ID */
  studentId?: number;
  /** 班次ID */
  sessionId?: number;
  /** 考勤状态 */
  attendanceStatus?: string;
  /** 是否异常 */
  isAbnormal?: boolean;
}

/**
 * Session Query Parameters
 * @description 班次查询参数
 */
export interface SessionQueryParams extends PageQueryParams, DateRangeParams {
  /** 班次状态 */
  sessionStatus?: string;
  /** 教师/看护人ID */
  teacherId?: number;
  /** 服务产品ID */
  serviceProductId?: number;
  /** 班次日期 */
  sessionDate?: string;
}

/**
 * Homework Query Parameters
 * @description 作业查询参数
 */
export interface HomeworkQueryParams extends PageQueryParams, DateRangeParams {
  /** 学生ID */
  studentId?: number;
  /** 作业状态 */
  homeworkStatus?: string;
  /** 科目 */
  subject?: string;
  /** 班次ID */
  sessionId?: number;
}

/**
 * Message Query Parameters
 * @description 消息查询参数
 */
export interface MessageQueryParams extends PageQueryParams {
  /** 消息类型 */
  msgType?: string;
  /** 是否已读 */
  readStatus?: boolean;
  /** 发送者ID */
  senderId?: number;
  /** 接收者ID */
  receiverId?: number;
}

/**
 * Alert Query Parameters
 * @description 告警查询参数
 */
export interface AlertQueryParams extends PageQueryParams, DateRangeParams {
  /** 告警类型 */
  alertType?: string;
  /** 告警状态 */
  alertStatus?: string;
  /** 学生ID */
  studentId?: number;
  /** 严重程度 */
  severity?: string;
}

/**
 * Report Query Parameters
 * @description 报表查询参数
 */
export interface ReportQueryParams extends DateRangeParams {
  /** 分组维度: day/week/month */
  groupBy?: string;
  /** 学生ID（可选，用于学生维度报表） */
  studentId?: number;
  /** 教师ID（可选，用于教师绩效报表） */
  teacherId?: number;
  /** 服务产品ID（可选） */
  serviceProductId?: number;
}

/**
 * Refund Query Parameters
 * @description 退款查询参数
 */
export interface RefundQueryParams extends PageQueryParams, DateRangeParams {
  /** 退款状态 */
  refundStatus?: string;
  /** 订单ID */
  orderId?: number;
  /** 学生ID */
  studentId?: number;
}

/**
 * Query Params Helper
 * @description 查询参数工具类
 */
export class QueryParamsHelper {
  /** 默认页码 */
  static readonly DEFAULT_PAGE_NUM = 1;
  /** 默认每页数量 */
  static readonly DEFAULT_PAGE_SIZE = 20;

  /**
   * Apply default pagination
   * @param params 查询参数
   * @returns 带默认值的参数
   */
  static withDefaultPagination<T extends PageQueryParams>(params: T): T {
    return {
      ...params,
      pageNum: params.pageNum ?? QueryParamsHelper.DEFAULT_PAGE_NUM,
      pageSize: params.pageSize ?? QueryParamsHelper.DEFAULT_PAGE_SIZE
    };
  }

  /**
   * Build query string from params
   * @param params 查询参数
   * @returns URL查询字符串
   */
  static buildQueryString(params: Record<string, unknown>): string {
    const queryParts: string[] = [];
    
    Object.keys(params).forEach((key: string) => {
      const value = params[key];
      if (value !== undefined && value !== null && value !== '') {
        queryParts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
      }
    });

    return queryParts.length > 0 ? `?${queryParts.join('&')}` : '';
  }

  /**
   * Clean empty params
   * @param params 查询参数
   * @returns 清理后的参数
   */
  static cleanEmptyParams<T extends Record<string, unknown>>(params: T): Partial<T> {
    const result: Partial<T> = {};
    
    Object.keys(params).forEach((key: string) => {
      const value = params[key];
      if (value !== undefined && value !== null && value !== '') {
        result[key as keyof T] = value as T[keyof T];
      }
    });

    return result;
  }
}

/**
 * User roles in the system
 */
export enum UserRole {
  PARENT = 'PARENT',       // 家长
  TEACHER = 'TEACHER',     // 教师/看护老师
  ADMIN = 'ADMIN',         // 管理员
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

