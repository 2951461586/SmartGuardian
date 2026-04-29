/**
 * SmartGuardian - Services Index
 * Central export point for all API services
 * 
 * @description API 服务统一导出入口
 * @module api
 * @exports
 * - auth: 认证服务
 * - service: 服务、订单、课程相关
 * - attendance: 考勤服务
 * - homework: 作业服务
 * - reports: 报表服务
 * - card: 卡片服务
 * - timeline: 时间线服务
 * - payments: 支付服务
 * - message: 消息服务
 * - alert: 告警服务
 * - refund: 退款服务
 */

// Auth & User services
export * from './auth';

// Service & Order & Session services (merged from service.ts and session.ts)
export * from './service';

// Attendance services
export * from './attendance';

// Homework services
export * from './homework';

// Report services (merged from reports.ts and report.ts)
export * from './reports';

// Card services
export * from './card';

// Timeline services
export * from './timeline';

// Payments services
export * from './payments';

// Message services
export * from './message';

// Alert services
export * from './alert';

// Refund services
export * from './refund';

// Workbench services
export * from './workbench';

// Agent services
export * from './agent';

// Security services
export * from './security';

// Cloud orchestration services
export * from './cloud';
