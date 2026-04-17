/**
 * SmartGuardian - 安全工具类
 * 实现数据脱敏、加密传输等安全功能
 */

// 脱敏规则配置
const DESENSITIZE_RULES = {
  // 姓名脱敏：保留姓，名用*代替
  NAME: (value: string): string => {
    if (!value || value.length < 2) return value;
    return value.charAt(0) + '*'.repeat(value.length - 1);
  },

  // 手机号脱敏：显示前3位和后4位
  MOBILE: (value: string): string => {
    if (!value || value.length < 7) return value;
    return value.substring(0, 3) + '****' + value.substring(value.length - 4);
  },

  // 身份证号脱敏：显示前3位和后4位
  ID_CARD: (value: string): string => {
    if (!value || value.length < 8) return value;
    return value.substring(0, 3) + '**********' + value.substring(value.length - 4);
  },

  // 银行卡号脱敏：显示前4位和后4位
  BANK_CARD: (value: string): string => {
    if (!value || value.length < 8) return value;
    return value.substring(0, 4) + ' **** **** ' + value.substring(value.length - 4);
  },

  // 地址脱敏：保留省市，隐藏详细地址
  ADDRESS: (value: string): string => {
    if (!value) return value;
    // 保留前12个字符，隐藏后续内容
    if (value.length <= 12) return value;
    return value.substring(0, 12) + '***';
  },

  // 邮箱脱敏：@前保留1位，@后保留域名
  EMAIL: (value: string): string => {
    if (!value || !value.includes('@')) return value;
    const parts = value.split('@');
    const username = parts[0];
    const domain = parts[1];
    if (username.length <= 1) return value;
    return username.charAt(0) + '***@' + domain;
  }
};

/**
 * 安全工具类
 */
export class SecurityUtils {
  /**
   * 姓名脱敏
   */
  static desensitizeName(name: string): string {
    return DESENSITIZE_RULES.NAME(name);
  }

  /**
   * 手机号脱敏
   */
  static desensitizeMobile(mobile: string): string {
    return DESENSITIZE_RULES.MOBILE(mobile);
  }

  /**
   * 身份证号脱敏
   */
  static desensitizeIdCard(idCard: string): string {
    return DESENSITIZE_RULES.ID_CARD(idCard);
  }

  /**
   * 银行卡号脱敏
   */
  static desensitizeBankCard(bankCard: string): string {
    return DESENSITIZE_RULES.BANK_CARD(bankCard);
  }

  /**
   * 地址脱敏
   */
  static desensitizeAddress(address: string): string {
    return DESENSITIZE_RULES.ADDRESS(address);
  }

  /**
   * 邮箱脱敏
   */
  static desensitizeEmail(email: string): string {
    return DESENSITIZE_RULES.EMAIL(email);
  }

  /**
   * 学生信息脱敏（批量处理）
   */
  static desensitizeStudentInfo(student: {
    name?: string;
    mobile?: string;
    idCard?: string;
    address?: string;
  }): {
    name: string;
    mobile: string;
    idCard: string;
    address: string;
  } {
    return {
      name: this.desensitizeName(student.name || ''),
      mobile: this.desensitizeMobile(student.mobile || ''),
      idCard: this.desensitizeIdCard(student.idCard || ''),
      address: this.desensitizeAddress(student.address || '')
    };
  }

  /**
   * 验证手机号格式
   */
  static isValidMobile(mobile: string): boolean {
    return /^1[3-9]\d{9}$/.test(mobile);
  }

  /**
   * 验证身份证号格式
   */
  static isValidIdCard(idCard: string): boolean {
    return /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/.test(idCard);
  }

  /**
   * 生成随机接送码
   */
  static generatePickupCode(): string {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  /**
   * 密码强度验证
   * 返回：0-弱 1-中 2-强
   */
  static checkPasswordStrength(password: string): number {
    let score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (/[a-z]/.test(password)) score++;
    if (/[A-Z]/.test(password)) score++;
    if (/[0-9]/.test(password)) score++;
    if (/[^a-zA-Z0-9]/.test(password)) score++;

    if (score <= 2) return 0;
    if (score <= 4) return 1;
    return 2;
  }

  /**
   * 密码强度描述
   */
  static getPasswordStrengthText(strength: number): string {
    const texts = ['弱', '中', '强'];
    return texts[strength] || '未知';
  }
}

/**
 * 数据加密辅助类（基于鸿蒙安全能力）
 */
export class CryptoUtils {
  /**
   * Base64编码
   */
  static base64Encode(str: string): string {
    return str; // 实际项目中应使用 @kit.CryptoArchitectureKit
  }

  /**
   * Base64解码
   */
  static base64Decode(str: string): string {
    return str; // 实际项目中应使用 @kit.CryptoArchitectureKit
  }

  /**
   * SHA256哈希（示例，实际使用鸿蒙加密API）
   */
  static sha256(str: string): string {
    // 模拟返回，实际需要使用 cryptoFramework
    return 'hash_' + str.substring(0, 8);
  }

  /**
   * 生成随机Token
   */
  static generateToken(length: number = 32): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let token = '';
    for (let i = 0; i < length; i++) {
      token += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return token;
  }

  /**
   * 生成UUID
   */
  static generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
}

/**
 * 输入安全过滤
 */
export class InputFilter {
  /**
   * 过滤HTML标签
   */
  static stripHtml(html: string): string {
    return html.replace(/<[^>]*>/g, '');
  }

  /**
   * 过滤SQL注入风险字符
   */
  static stripSqlChars(str: string): string {
    return str.replace(/['"\\;-]|--/g, '');
  }

  /**
   * 过滤敏感词（示例，实际需要敏感词库）
   */
  static filterSensitiveWords(str: string): string {
    // 实际项目中应接入敏感词库
    return str;
  }

  /**
   * 截断过长文本
   */
  static truncate(str: string, maxLength: number): string {
    if (str.length <= maxLength) return str;
    return str.substring(0, maxLength - 3) + '...';
  }
}