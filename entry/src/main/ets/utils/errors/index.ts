/**
 * SmartGuardian - Error Module
 * Export all error types and handlers
 */

export {
  ErrorCode,
  ErrorCategory,
  ErrorContext,
  AppError,
  NetworkError,
  AuthError,
  BusinessError,
  DataError,
  ErrorFactory
} from './AppError';

export {
  ErrorHandler,
  ErrorHandlerOptions,
  ErrorHandlerCallback,
  safeExecute
} from './ErrorHandler';
