/**
 * SmartGuardian - Service & Order Models
 * Service product, order, session scheduling related types
 * 
 * @description 包含 OpenAPI 标准字段和 UI 便利字段
 * @note UI 便利字段由后端通过关联查询返回，前端可直接使用
 */

/**
 * Service product (托管服务)
 * 
 * @description 服务产品信息，包含托管服务的基本配置
 * @example 接送服务、课后托管、假期托管等
 */
export interface ServiceProduct {
  // ===== OpenAPI 标准字段 =====
  
  /** 服务ID */
  id: number;
  
  /** 服务名称 */
  serviceName: string;
  
  /** 服务类型 (PICKUP, AFTER_SCHOOL, HOLIDAY, etc.) */
  serviceType: string;
  
  /** 服务价格 (单位: 元/月) */
  price: number;
  
  /** 服务容量 (最大学生数) */
  capacity?: number;
  
  /** 服务状态 (ACTIVE, INACTIVE, FULL) */
  status: string;
  
  /** 服务描述 */
  description?: string;
  
  /** 计费单位 (MONTH, SESSION, etc.) */
  unit?: string;
  
  /** 适用年级范围 (如: "1-3年级") */
  gradeRange?: string;
  
  /** 最大学生数 (等同于capacity) */
  maxStudents?: number;
  
  /** 当前学生数 */
  currentStudents?: number;
  
  /** 服务开始日期 */
  serviceStartDate?: string;
  
  /** 服务结束日期 */
  serviceEndDate?: string;
  
  /** 签到开始时间 (如: "07:30") */
  signInStartTime?: string;
  
  /** 签到结束时间 (如: "08:30") */
  signInEndTime?: string;
  
  /** 签退开始时间 (如: "16:30") */
  signOutStartTime?: string;
  
  /** 签退结束时间 (如: "18:30") */
  signOutEndTime?: string;
  
  /** 所属机构ID */
  orgId?: number;
  
  /** 所属机构名称 */
  orgName?: string;
  
  /** 创建时间 */
  createdAt?: string;
  
  /** 更新时间 */
  updatedAt?: string;
  
  // ===== UI 便利字段 (兼容旧代码) =====
  
  /** 服务名称 (serviceName的别名) */
  name?: string;
  
  /** 服务分类 (源自serviceType的中文显示) */
  category?: string;
  
  /** 开始时间 (signInStartTime的别名) */
  startTime?: string;
  
  /** 结束时间 (signOutEndTime的别名) */
  endTime?: string;
}

/**
 * Create service product request
 * 
 * @description 创建托管服务的请求参数
 */
export interface ServiceProductCreateRequest {
  /** 服务名称 */
  serviceName: string;
  
  /** 服务类型 */
  serviceType: string;
  
  /** 服务描述 */
  description?: string;
  
  /** 服务价格 (单位: 元) */
  price: number;
  
  /** 计费单位 */
  unit?: string;
  
  /** 适用年级范围 */
  gradeRange?: string;
  
  /** 最大学生数 */
  maxStudents?: number;
  
  /** 服务容量 (等同于maxStudents) */
  capacity?: number;
  
  /** 服务开始日期 */
  serviceStartDate?: string;
  
  /** 服务结束日期 */
  serviceEndDate?: string;
  
  /** 签到开始时间 */
  signInStartTime?: string;
  
  /** 签到结束时间 */
  signInEndTime?: string;
  
  /** 签退开始时间 */
  signOutStartTime?: string;
  
  /** 签退结束时间 */
  signOutEndTime?: string;
}

/**
 * Order (托管订单)
 * 
 * @description 托管服务订单，记录学生购买服务的信息
 * @note 包含关联字段，由后端通过JOIN查询返回
 */
export interface Order {
  // ===== OpenAPI 标准字段 =====
  
  /** 订单ID */
  id: number;
  
  /** 订单编号 */
  orderNo: string;
  
  /** 学生ID */
  studentId: number;
  
  /** 服务产品ID */
  serviceProductId: number;
  
  /** 订单状态 (PENDING, APPROVED, REJECTED, CANCELLED) */
  orderStatus: string;
  
  /** 订单金额 (单位: 元) */
  amount: number;
  
  /** 已支付金额 (单位: 元) */
  paidAmount: number;
  
  /** 支付状态 (UNPAID, PARTIAL, PAID) */
  payStatus: string;
  
  /** 审核状态 (PENDING, APPROVED, REJECTED) */
  auditStatus?: string;
  
  /** 服务开始日期 */
  startDate?: string;
  
  /** 服务结束日期 */
  endDate?: string;
  
  /** 订单总金额 (等同于amount) */
  totalAmount?: number;
  
  /** 优惠金额 (单位: 元) */
  discountAmount?: number;
  
  /** 实际金额 (totalAmount - discountAmount) */
  actualAmount?: number;
  
  /** 支付时间 */
  payTime?: string;
  
  /** 审核时间 */
  auditTime?: string;
  
  /** 审核人ID */
  auditUserId?: number;
  
  /** 审核备注 */
  auditRemark?: string;
  
  /** 创建时间 */
  createdAt?: string;
  
  /** 更新时间 */
  updatedAt?: string;
  
  // ===== UI 便利字段 (后端关联返回) =====
  
  /** 学生姓名 (关联 Student.name) */
  studentName?: string;
  
  /** 家长用户ID */
  guardianUserId?: number;
  
  /** 家长姓名 (关联 User.name) */
  guardianName?: string;
  
  /** 服务产品名称 (关联 ServiceProduct.serviceName) */
  serviceProductName?: string;
}

/**
 * Create order request
 * 
 * @description 创建订单的请求参数
 */
export interface OrderCreateRequest {
  /** 学生ID */
  studentId: number;
  
  /** 服务产品ID */
  serviceProductId: number;
  
  /** 服务开始日期 */
  startDate: string;
  
  /** 服务结束日期 */
  endDate: string;
  
  /** 订单总金额 */
  totalAmount?: number;
  
  /** 优惠金额 */
  discountAmount?: number;
}

/**
 * Order audit request
 * 
 * @description 审核订单的请求参数
 */
export interface OrderAuditRequest {
  /** 审核状态 */
  auditStatus: 'APPROVED' | 'REJECTED';
  
  /** 审核备注 */
  auditRemark?: string;
}

/**
 * Order refund request
 * 
 * @description 订单退费请求参数
 */
export interface OrderRefundRequest {
  /** 退费金额 (单位: 元) */
  refundAmount: number;
  
  /** 退费原因 */
  refundReason: string;
}

/**
 * Session schedule (班次排课)
 * 
 * @description 托管班次信息，包含时间、教师、容量等
 * @note 包含关联字段，由后端通过JOIN查询返回
 */
export interface SessionSchedule {
  // ===== OpenAPI 标准字段 =====
  
  /** 班次ID */
  id: number;
  
  /** 班次日期 (yyyy-MM-dd) */
  sessionDate: string;
  
  /** 开始时间 (HH:mm) */
  startTime: string;
  
  /** 结束时间 (HH:mm) */
  endTime: string;
  
  /** 教师用户ID */
  teacherUserId?: number;
  
  /** 班次容量 */
  capacity?: number;
  
  /** 当前学生数 */
  currentCount: number;
  
  /** 班次编号 */
  sessionNo?: string;
  
  /** 服务产品ID */
  serviceProductId?: number;
  
  /** 最大容量 (等同于capacity) */
  maxCapacity?: number;
  
  /** 班次地点 */
  location?: string;
  
  /** 班次状态 (SCHEDULED, ONGOING, ENDED, CANCELLED) */
  status?: string;
  
  /** 创建时间 */
  createdAt?: string;
  
  /** 更新时间 */
  updatedAt?: string;
  
  // ===== UI 便利字段 (后端关联返回) =====
  
  /** 服务产品名称 (关联 ServiceProduct.serviceName) */
  serviceProductName?: string;
  
  /** 教师ID (等同于teacherUserId) */
  teacherId?: number;
  
  /** 教师姓名 (关联 User.name) */
  teacherName?: string;
}

/**
 * Auto-schedule request
 * 
 * @description 自动排课请求参数
 */
export interface AutoScheduleRequest {
  /** 服务产品ID */
  serviceProductId: number;
  
  /** 开始日期 */
  startDate: string;
  
  /** 结束日期 */
  endDate: string;
  
  /** 上课日 (0-6, 0=周日) */
  weekdays: number[];
  
  /** 开始时间 (HH:mm) */
  startTime: string;
  
  /** 结束时间 (HH:mm) */
  endTime: string;
  
  /** 教师ID列表 */
  teacherIds: number[];
  
  /** 最大容量 */
  maxCapacity: number;
  
  /** 上课地点 */
  location?: string;
}

/**
 * Student in session
 * 
 * @description 班次中的学生信息，包含考勤状态
 */
export interface SessionStudent {
  /** 学生ID */
  studentId: number;
  
  /** 学生姓名 (关联 Student.name) */
  studentName: string;
  
  /** 学号 */
  studentNo: string;
  
  /** 考勤状态 (NOT_SIGNED, SIGNED_IN, SIGNED_OUT) */
  attendanceStatus: string;
  
  /** 签到时间 */
  signInTime?: string;
  
  /** 签退时间 */
  signOutTime?: string;
}

/**
 * Session with student list
 * 
 * @description 班次详情，包含学生列表
 */
export interface SessionWithStudents extends SessionSchedule {
  /** 学生列表 */
  students: SessionStudent[];
}
