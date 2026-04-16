/**
 * SmartGuardian - 日期时间工具类
 * 提供常用的日期格式化、计算和比较功能
 */

/**
 * 日期时间工具类
 */
export class DateUtils {
  /**
   * 格式化日期为 YYYY-MM-DD
   */
  static formatDate(date: Date | string | number): string {
    const d = this.parseDate(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 格式化时间为 HH:mm:ss
   */
  static formatTime(date: Date | string | number): string {
    const d = this.parseDate(date);
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');
    const seconds = String(d.getSeconds()).padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  }

  /**
   * 格式化日期时间为 YYYY-MM-DD HH:mm:ss
   */
  static formatDateTime(date: Date | string | number): string {
    return `${this.formatDate(date)} ${this.formatTime(date)}`;
  }

  /**
   * 格式化日期为中文格式
   */
  static formatDateCN(date: Date | string | number): string {
    const d = this.parseDate(date);
    const year = d.getFullYear();
    const month = d.getMonth() + 1;
    const day = d.getDate();
    return `${year}年${month}月${day}日`;
  }

  /**
   * 获取相对时间描述
   */
  static getRelativeTime(date: Date | string | number): string {
    const d = this.parseDate(date);
    const now = new Date();
    const diff = now.getTime() - d.getTime();

    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (seconds < 60) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;

    return this.formatDate(date);
  }

  /**
   * 判断是否为今天
   */
  static isToday(date: Date | string | number): boolean {
    const d = this.parseDate(date);
    const today = new Date();
    return d.getFullYear() === today.getFullYear() &&
      d.getMonth() === today.getMonth() &&
      d.getDate() === today.getDate();
  }

  /**
   * 判断是否为昨天
   */
  static isYesterday(date: Date | string | number): boolean {
    const d = this.parseDate(date);
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    return d.getFullYear() === yesterday.getFullYear() &&
      d.getMonth() === yesterday.getMonth() &&
      d.getDate() === yesterday.getDate();
  }

  /**
   * 判断是否为明天
   */
  static isTomorrow(date: Date | string | number): boolean {
    const d = this.parseDate(date);
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return d.getFullYear() === tomorrow.getFullYear() &&
      d.getMonth() === tomorrow.getMonth() &&
      d.getDate() === tomorrow.getDate();
  }

  /**
   * 获取一天的开始时间
   */
  static getStartOfDay(date: Date | string | number): Date {
    const d = this.parseDate(date);
    d.setHours(0, 0, 0, 0);
    return d;
  }

  /**
   * 获取一天的结束时间
   */
  static getEndOfDay(date: Date | string | number): Date {
    const d = this.parseDate(date);
    d.setHours(23, 59, 59, 999);
    return d;
  }

  /**
   * 获取本周开始日期(周一)
   */
  static getStartOfWeek(date: Date | string | number): Date {
    const d = this.parseDate(date);
    const day = d.getDay();
    const diff = day === 0 ? -6 : 1 - day;
    d.setDate(d.getDate() + diff);
    return this.getStartOfDay(d);
  }

  /**
   * 获取本月开始日期
   */
  static getStartOfMonth(date: Date | string | number): Date {
    const d = this.parseDate(date);
    return new Date(d.getFullYear(), d.getMonth(), 1);
  }

  /**
   * 计算两个日期之间的天数差
   */
  static daysBetween(start: Date | string | number, end: Date | string | number): number {
    const startDate = this.getStartOfDay(start);
    const endDate = this.getStartOfDay(end);
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime());
    return Math.floor(diffTime / (1000 * 60 * 60 * 24));
  }

  /**
   * 判断是否在时间范围内
   */
  static isInRange(
    date: Date | string | number,
    start: Date | string | number,
    end: Date | string | number
  ): boolean {
    const d = this.parseDate(date).getTime();
    const startTime = this.parseDate(start).getTime();
    const endTime = this.parseDate(end).getTime();
    return d >= startTime && d <= endTime;
  }

  /**
   * 解析日期
   */
  private static parseDate(date: Date | string | number): Date {
    if (date instanceof Date) return date;
    if (typeof date === 'number') return new Date(date);
    return new Date(date);
  }

  /**
   * 获取当前学期的开始和结束日期
   * 假设学期为2月-7月(春季)和9月-1月(秋季)
   */
  static getCurrentSemester(): { startDate: Date; endDate: Date } {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;

    let startDate: Date;
    let endDate: Date;

    if (month >= 2 && month <= 7) {
      // 春季学期: 2月1日 - 7月31日
      startDate = new Date(year, 1, 1);
      endDate = new Date(year, 6, 31);
    } else if (month >= 8 && month <= 12) {
      // 秋季学期: 9月1日 - 次年1月31日
      startDate = new Date(year, 8, 1);
      endDate = new Date(year + 1, 0, 31);
    } else {
      // 1月属于秋季学期
      startDate = new Date(year - 1, 8, 1);
      endDate = new Date(year, 0, 31);
    }

    return { startDate, endDate };
  }

  /**
   * 格式化托管时段
   */
  static formatSessionTime(startHour: number, endHour: number): string {
    const formatHour = (h: number) => `${h.toString().padStart(2, '0')}:00`;
    return `${formatHour(startHour)} - ${formatHour(endHour)}`;
  }

  /**
   * 判断是否在托管时间段内
   */
  static isInSessionTime(
    currentTime: Date,
    sessionStartHour: number,
    sessionEndHour: number
  ): boolean {
    const hour = currentTime.getHours();
    return hour >= sessionStartHour && hour < sessionEndHour;
  }
}

/**
 * 年级工具类
 */
export class GradeUtils {
  // 年级映射
  static readonly GRADE_MAP: Record<number, string> = {
    1: '一年级',
    2: '二年级',
    3: '三年级',
    4: '四年级',
    5: '五年级',
    6: '六年级',
    7: '七年级',
    8: '八年级',
    9: '九年级',
    10: '高一',
    11: '高二',
    12: '高三'
  };

  /**
   * 获取年级名称
   */
  static getGradeName(grade: number): string {
    return this.GRADE_MAP[grade] || `年级${grade}`;
  }

  /**
   * 判断是否为小学
   */
  static isPrimarySchool(grade: number): boolean {
    return grade >= 1 && grade <= 6;
  }

  /**
   * 判断是否为初中
   */
  static isMiddleSchool(grade: number): boolean {
    return grade >= 7 && grade <= 9;
  }

  /**
   * 判断是否为高中
   */
  static isHighSchool(grade: number): boolean {
    return grade >= 10 && grade <= 12;
  }

  /**
   * 获取学段名称
   */
  static getSchoolSection(grade: number): string {
    if (this.isPrimarySchool(grade)) return '小学';
    if (this.isMiddleSchool(grade)) return '初中';
    if (this.isHighSchool(grade)) return '高中';
    return '未知';
  }
}