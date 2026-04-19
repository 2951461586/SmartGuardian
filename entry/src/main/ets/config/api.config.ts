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
   * 
   * @status PENDING - Mock system is implemented but not yet integrated into request.ts
   * @usage To enable mock:
   *   1. Set USE_MOCK_DATA = true
   *   2. Add mock interceptor in request.ts (see example below)
   *   3. Import MockService in request interceptor
   * 
   * @example Mock integration in request.ts
   * ```typescript
   * import { ApiConfig } from '../config/api.config';
   * import { MockService } from '../services/mock/mockService';
   * 
   * async function httpRequest<T>(options: RequestOptions): Promise<HttpResponse<T>> {
   *   if (ApiConfig.USE_MOCK_DATA) {
   *     return MockService.handleMockRequest(options);
   *   }
   *   // ... real API call
   * }
   * ```
   */
  static readonly USE_MOCK_DATA: boolean = false;  // ⚠️ Changed to false - backend API is ready

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
 * @status PENDING - Not currently used, reserved for future mock integration
 * @note This class allows fine-grained control over which services use mock data
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
