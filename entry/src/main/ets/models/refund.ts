/**
 * SmartGuardian - Refund Models
 * Refund process related types
 */

/**
 * Refund status
 */
export enum RefundStatus {
  PENDING = 'PENDING',           // 待审核
  APPROVED = 'APPROVED',         // 已批准
  REJECTED = 'REJECTED',         // 已拒绝
  PROCESSING = 'PROCESSING',     // 退款中
  COMPLETED = 'COMPLETED',       // 已完成
  CANCELLED = 'CANCELLED'        // 已取消
}

/**
 * Refund reason type
 */
export enum RefundReasonType {
  STUDENT_TRANSFER = 'STUDENT_TRANSFER',     // 学生转学
  SERVICE_QUALITY = 'SERVICE_QUALITY',       // 服务质量
  SCHEDULE_CHANGE = 'SCHEDULE_CHANGE',       // 时间变动
  PERSONAL_REASON = 'PERSONAL_REASON',       // 个人原因
  OTHER = 'OTHER'                            // 其他
}

/**
 * Refund record
 */
export interface RefundRecord {
  id: number;
  orderNo: string;
  orderId: number;
  studentId: number;
  studentName: string;
  serviceProductId: number;
  serviceName: string;
  refundAmount: number;
  reason: string;
  reasonType: string;
  description?: string;
  status: string;
  appliedAt: string;
  reviewedBy?: number;
  reviewedAt?: string;
  reviewRemark?: string;
  processedAt?: string;
  completedAt?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * Create refund application params
 */
export interface CreateRefundParams {
  orderId: number;
  refundAmount: number;
  reasonType: string;
  reason: string;
  description?: string;
}

/**
 * Refund query params
 */
export interface RefundQueryParams {
  orderId?: number;
  studentId?: number;
  status?: string;
  pageNum?: number;
  pageSize?: number;
}

/**
 * Refund statistics
 */
export interface RefundStatistics {
  total: number;
  pending: number;
  processing: number;
  completed: number;
  totalAmount: number;
}

/**
 * Cancel refund params
 */
export interface CancelRefundParams {
  refundId: number;
  reason?: string;
}