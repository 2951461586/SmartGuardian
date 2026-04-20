/**
 * SmartGuardian - API Configuration
 * API and Mock data configuration
 */

/**
 * API environment identifiers
 */
export class ApiEnvironment {
  static readonly DEV_MOCK: string = 'DEV_MOCK';
  static readonly TEST_REAL: string = 'TEST_REAL';
}

/**
 * API environment configuration
 */
export class ApiConfig {
  /**
   * 当前环境。
   * DEV_MOCK: 本地开发/界面联调，全部走 Mock。
   * TEST_REAL: 测试环境联调，全部走真实后端。
   */
  static readonly CURRENT_ENV: string = ApiEnvironment.DEV_MOCK;

  /**
   * 测试环境后端地址。
   *
   * @description 请替换为实际联调地址，例如 http://192.168.1.100:8080
   */
  static readonly TEST_BASE_URL: string = '';

  /**
   * Enable mock data mode
   */
  static isMockEnabled(): boolean {
    return ApiConfig.CURRENT_ENV === ApiEnvironment.DEV_MOCK;
  }

  /**
   * API base URL
   */
  static getBaseUrl(): string {
    if (ApiConfig.CURRENT_ENV === ApiEnvironment.TEST_REAL) {
      return ApiConfig.TEST_BASE_URL;
    }
    return '';
  }

  /**
   * 兼容旧版 ApiWrapper 的 Mock 开关字段
   */
  static readonly USE_MOCK_DATA: boolean = ApiConfig.isMockEnabled();

  /**
   * 兼容旧版 ApiWrapper 的基础地址字段
   */
  static readonly BASE_URL: string = ApiConfig.getBaseUrl();

  /**
   * Request timeout in milliseconds
   */
  static readonly TIMEOUT: number = 30000;

  /**
   * Mock data delay in milliseconds (simulate network latency)
   */
  static readonly MOCK_DELAY: number = 300;

  /**
   * API version
   */
  static readonly API_VERSION: string = 'v1';

  /**
   * Enable request logging
   */
  static readonly ENABLE_LOGGING: boolean = true;

  /**
   * Enable response caching
   */
  static readonly ENABLE_CACHE: boolean = true;

  /**
   * Cache expiration time in seconds
   */
  static readonly CACHE_EXPIRATION: number = 300; // 5 minutes
}

/**
 * Mock data switch for each service
 * @status PENDING - Not currently used, reserved for future mock integration
 * @note This class allows fine-grained control over which services use mock data
 */
export class MockSwitch {
  // Auth & User
  static readonly AUTH_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly STUDENT_SERVICE: boolean = ApiConfig.isMockEnabled();

  // Service & Order
  static readonly SERVICE_PRODUCT_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly ORDER_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly SESSION_SERVICE: boolean = ApiConfig.isMockEnabled();

  // Attendance & Homework
  static readonly ATTENDANCE_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly HOMEWORK_SERVICE: boolean = ApiConfig.isMockEnabled();

  // Communication
  static readonly MESSAGE_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly TIMELINE_SERVICE: boolean = ApiConfig.isMockEnabled();

  // Payment & Report
  static readonly PAYMENT_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly REPORT_SERVICE: boolean = ApiConfig.isMockEnabled();

  // Card
  static readonly CARD_SERVICE: boolean = ApiConfig.isMockEnabled();
}
