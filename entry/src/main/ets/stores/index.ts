/**
 * SmartGuardian - Stores Module
 * Export all state management stores
 * 
 * @description 统一导出所有状态管理 Store
 */

// Core utilities
export * from './core';

// Stores
export { UserStore, UserPreferences } from './userStore';
export { MessageStore, MessageTab, MessageFilter } from './messageStore';
export { OrderStore, OrderStatusType, OrderFilter } from './orderStore';
export { AttendanceStore, ATTENDANCE_STATUS, AttendanceStats } from './attendanceStore';
export { StudentStore, StudentSearchParams } from './studentStore';
