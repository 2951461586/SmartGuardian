/**
 * SmartGuardian - Models Index
 * Central export point for all model types
 */

// Common types
export * from './common';

// User related
export * from './user';

// Service and order related
export * from './service';

// Attendance related (exclude homework types that conflict with homework.ts)
export {
  AttendanceRecord,
  SignInRequest,
  SignOutRequest,
  LeaveRequest,
  MessageRecord,
  SendMessageRequest,
  StudentTimeline
} from './attendance';

// Homework specific models (complete definitions with enums)
export * from './homework';

// Timeline related
export * from './timeline';

// Payment related
export * from './payment';

// Alert related
export * from './alert';

// Message related
export * from './message';

// Refund related
export * from './refund';

// Report models
export * from './report';

// Card models
export * from './card';
