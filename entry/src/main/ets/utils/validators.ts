/**
 * SmartGuardian - Validators
 * Common validation utilities
 */

/**
 * Validation result
 */
export interface ValidationResult {
  isValid: boolean;
  message?: string;
}

/**
 * Validator utilities
 */
export class Validator {
  /**
   * Validate phone number
   */
  static validatePhone(phone: string): ValidationResult {
    if (!phone) {
      return { isValid: false, message: '手机号不能为空' };
    }
    const phoneReg = /^1[3-9]\d{9}$/;
    if (!phoneReg.test(phone)) {
      return { isValid: false, message: '请输入正确的手机号' };
    }
    return { isValid: true };
  }

  /**
   * Validate password
   */
  static validatePassword(password: string): ValidationResult {
    if (!password) {
      return { isValid: false, message: '密码不能为空' };
    }
    if (password.length < 6) {
      return { isValid: false, message: '密码长度不能少于6位' };
    }
    if (password.length > 20) {
      return { isValid: false, message: '密码长度不能超过20位' };
    }
    return { isValid: true };
  }

  /**
   * Validate username
   */
  static validateUsername(username: string): ValidationResult {
    if (!username) {
      return { isValid: false, message: '用户名不能为空' };
    }
    if (username.length < 3) {
      return { isValid: false, message: '用户名长度不能少于3位' };
    }
    if (username.length > 20) {
      return { isValid: false, message: '用户名长度不能超过20位' };
    }
    const usernameReg = /^[a-zA-Z0-9_]+$/;
    if (!usernameReg.test(username)) {
      return { isValid: false, message: '用户名只能包含字母、数字和下划线' };
    }
    return { isValid: true };
  }

  /**
   * Validate student number
   */
  static validateStudentNo(studentNo: string): ValidationResult {
    if (!studentNo) {
      return { isValid: false, message: '学号不能为空' };
    }
    const studentNoReg = /^[A-Z]\d{8}$/;
    if (!studentNoReg.test(studentNo)) {
      return { isValid: false, message: '学号格式不正确' };
    }
    return { isValid: true };
  }

  /**
   * Validate email
   */
  static validateEmail(email: string): ValidationResult {
    if (!email) {
      return { isValid: false, message: '邮箱不能为空' };
    }
    const emailReg = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailReg.test(email)) {
      return { isValid: false, message: '请输入正确的邮箱地址' };
    }
    return { isValid: true };
  }

  /**
   * Validate ID card number
   */
  static validateIdCard(idCard: string): ValidationResult {
    if (!idCard) {
      return { isValid: false, message: '身份证号不能为空' };
    }
    const idCardReg = /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/;
    if (!idCardReg.test(idCard)) {
      return { isValid: false, message: '身份证号格式不正确' };
    }
    return { isValid: true };
  }

  /**
   * Validate required field
   */
  static validateRequired(value: string | undefined | null, fieldName: string): ValidationResult {
    if (!value || value.trim() === '') {
      return { isValid: false, message: `${fieldName}不能为空` };
    }
    return { isValid: true };
  }

  /**
   * Validate length range
   */
  static validateLength(value: string, min: number, max: number, fieldName: string): ValidationResult {
    if (!value) {
      return { isValid: false, message: `${fieldName}不能为空` };
    }
    if (value.length < min) {
      return { isValid: false, message: `${fieldName}长度不能少于${min}个字符` };
    }
    if (value.length > max) {
      return { isValid: false, message: `${fieldName}长度不能超过${max}个字符` };
    }
    return { isValid: true };
  }

  /**
   * Validate number range
   */
  static validateNumberRange(value: number, min: number, max: number, fieldName: string): ValidationResult {
    if (value === undefined || value === null) {
      return { isValid: false, message: `${fieldName}不能为空` };
    }
    if (value < min) {
      return { isValid: false, message: `${fieldName}不能小于${min}` };
    }
    if (value > max) {
      return { isValid: false, message: `${fieldName}不能大于${max}` };
    }
    return { isValid: true };
  }

  /**
   * Validate date format
   */
  static validateDate(date: string): ValidationResult {
    if (!date) {
      return { isValid: false, message: '日期不能为空' };
    }
    const dateReg = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateReg.test(date)) {
      return { isValid: false, message: '日期格式不正确' };
    }
    return { isValid: true };
  }

  /**
   * Validate date range
   */
  static validateDateRange(startDate: string, endDate: string): ValidationResult {
    const startResult = this.validateDate(startDate);
    if (!startResult.isValid) {
      return startResult;
    }

    const endResult = this.validateDate(endDate);
    if (!endResult.isValid) {
      return endResult;
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start > end) {
      return { isValid: false, message: '开始日期不能晚于结束日期' };
    }

    return { isValid: true };
  }
}
