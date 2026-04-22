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
  static readonly API_ENV_STORAGE_KEY: string = 'smart_guardian_api_env';
  static readonly API_BASE_URL_STORAGE_KEY: string = 'smart_guardian_api_base_url';

  /**
   * Default environment for fresh installs.
   * Keep mock as the baseline and let runtime config switch to real services.
   */
  static readonly CURRENT_ENV: string = ApiEnvironment.DEV_MOCK;

  /**
   * Default real backend base URL. Can be overridden at runtime.
   */
  static readonly TEST_BASE_URL: string = '';

  static getCurrentEnv(): string {
    return AppStorage.get<string>(ApiConfig.API_ENV_STORAGE_KEY) ?? ApiConfig.CURRENT_ENV;
  }

  static setCurrentEnv(env: string): void {
    AppStorage.setOrCreate(ApiConfig.API_ENV_STORAGE_KEY, env);
  }

  static getConfiguredBaseUrl(): string {
    const runtimeUrl = AppStorage.get<string>(ApiConfig.API_BASE_URL_STORAGE_KEY) ?? ApiConfig.TEST_BASE_URL;
    return ApiConfig.normalizeBaseUrl(runtimeUrl);
  }

  static setConfiguredBaseUrl(url: string): void {
    AppStorage.setOrCreate(ApiConfig.API_BASE_URL_STORAGE_KEY, ApiConfig.normalizeBaseUrl(url));
  }

  static applyRuntimeConfig(env: string, baseUrl?: string): void {
    ApiConfig.setCurrentEnv(env);
    if (baseUrl !== undefined) {
      ApiConfig.setConfiguredBaseUrl(baseUrl);
    }
  }

  static clearRuntimeConfig(): void {
    AppStorage.delete(ApiConfig.API_ENV_STORAGE_KEY);
    AppStorage.delete(ApiConfig.API_BASE_URL_STORAGE_KEY);
  }

  static getEnvironmentLabel(): string {
    return ApiConfig.getCurrentEnv() === ApiEnvironment.TEST_REAL ? 'REAL' : 'MOCK';
  }

  /**
   * Enable mock data mode
   */
  static isMockEnabled(): boolean {
    return ApiConfig.getCurrentEnv() === ApiEnvironment.DEV_MOCK;
  }

  /**
   * API base URL
   */
  static getBaseUrl(): string {
    if (ApiConfig.getCurrentEnv() === ApiEnvironment.TEST_REAL) {
      return ApiConfig.getConfiguredBaseUrl();
    }
    return '';
  }

  private static normalizeBaseUrl(url: string): string {
    return url.trim().replace(/\/+$/, '');
  }

  /**
   * Compatibility fields for legacy wrappers.
   * These remain static defaults; new code should call the methods above.
   */
  static readonly USE_MOCK_DATA: boolean = ApiConfig.CURRENT_ENV === ApiEnvironment.DEV_MOCK;
  static readonly BASE_URL: string = ApiConfig.TEST_BASE_URL;

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
  static readonly CACHE_EXPIRATION: number = 300;
}

/**
 * Mock data switch for each service
 * @status PENDING - Not currently used, reserved for future mock integration
 * @note This class allows fine-grained control over which services use mock data
 */
export class MockSwitch {
  static readonly AUTH_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly STUDENT_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly SERVICE_PRODUCT_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly ORDER_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly SESSION_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly ATTENDANCE_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly HOMEWORK_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly MESSAGE_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly TIMELINE_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly PAYMENT_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly REPORT_SERVICE: boolean = ApiConfig.isMockEnabled();
  static readonly CARD_SERVICE: boolean = ApiConfig.isMockEnabled();
}
