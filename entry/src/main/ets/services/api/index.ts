/**
 * SmartGuardian - Services Index
 * Central export point for all API services
 */

// Auth & User services
export * from './auth';

// Service & Order & Session services (merged from service.ts and session.ts)
export * from './service';

// Attendance & Homework services
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
