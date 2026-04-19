/**
 * SmartGuardian - Log Utility
 * Centralized logging utility for debugging and error tracking
 */

export class LogUtil {
  private static readonly TAG: string = 'SmartGuardian';
  
  /**
   * Debug log
   */
  static debug(message: string, ...args: string[]): void {
    console.debug(`[${LogUtil.TAG}] ${message}`, ...args);
  }
  
  /**
   * Info log
   */
  static info(message: string, ...args: string[]): void {
    console.info(`[${LogUtil.TAG}] ${message}`, ...args);
  }
  
  /**
   * Warning log
   */
  static warn(message: string, ...args: string[]): void {
    console.warn(`[${LogUtil.TAG}] ${message}`, ...args);
  }
  
  /**
   * Error log
   */
  static error(message: string, ...args: string[]): void {
    console.error(`[${LogUtil.TAG}] ${message}`, ...args);
  }
  
  /**
   * Verbose log
   */
  static verbose(message: string, ...args: string[]): void {
    console.log(`[${LogUtil.TAG}] ${message}`, ...args);
  }
  
  /**
   * Log with tag
   */
  static logWithTag(tag: string, message: string, ...args: string[]): void {
    console.log(`[${tag}] ${message}`, ...args);
  }
}

export default LogUtil;