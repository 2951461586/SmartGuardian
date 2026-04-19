/**
 * SmartGuardian - API Configuration
 * API and Mock data configuration
 */

/**
 * API environment configuration
 */
export class ApiConfig {
  /**
   * Enable mock data mode
   * Set to true when backend API is not ready
   */
  static readonly USE_MOCK_DATA: boolean = true;

  /**
   * API base URL
   */
  static readonly BASE_URL: string = 'https://api.smartguardian.local';

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
 */
export class MockSwitch {
  // Auth & User
  static readonly AUTH_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;
  static readonly STUDENT_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;

  // Service & Order
  static readonly SERVICE_PRODUCT_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;
  static readonly ORDER_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;
  static readonly SESSION_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;

  // Attendance & Homework
  static readonly ATTENDANCE_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;
  static readonly HOMEWORK_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;

  // Communication
  static readonly MESSAGE_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;
  static readonly TIMELINE_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;

  // Payment & Report
  static readonly PAYMENT_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;
  static readonly REPORT_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;

  // Card
  static readonly CARD_SERVICE: boolean = ApiConfig.USE_MOCK_DATA;
}
