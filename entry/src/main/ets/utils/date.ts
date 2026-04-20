/**
 * SmartGuardian - Date Utilities
 * Export date formatting functions
 */

import { DateUtils } from './dateUtils';

// Re-export DateUtils class
export { DateUtils };

// Convenience functions for direct import
export const formatDate = DateUtils.formatDate;
export const formatTime = DateUtils.formatTime;
export const formatDateTime = DateUtils.formatDateTime;
export const formatDateCN = DateUtils.formatDateCN;
export const getRelativeTime = DateUtils.getRelativeTime;
export const isToday = DateUtils.isToday;
export const isYesterday = DateUtils.isYesterday;
export const isTomorrow = DateUtils.isTomorrow;
