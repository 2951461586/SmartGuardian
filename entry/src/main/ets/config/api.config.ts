/**
 * SmartGuardian - API Configuration
 * API and Mock data configuration
 */

import { StorageKeys } from '../constants/app.constants';

/**
 * API environment identifiers
 */
export class ApiEnvironment {
  static readonly DEV_MOCK: string = 'DEV_MOCK';
  static readonly AGC_SERVERLESS: string = 'AGC_SERVERLESS';
}

/**
 * API environment configuration
 */
export class ApiConfig {
  static readonly API_ENV_STORAGE_KEY: string = StorageKeys.API_ENV;
  static readonly API_BASE_URL_STORAGE_KEY: string = StorageKeys.API_BASE_URL;
  static readonly API_CONFIG_VERSION_STORAGE_KEY: string = StorageKeys.API_CONFIG_VERSION;
  private static readonly API_CONFIG_VERSION: number = 6;

  /**
   * Default environment for fresh installs.
   * Keep mock as the baseline and let runtime config switch to real services.
   */
  static readonly CURRENT_ENV: string = ApiEnvironment.DEV_MOCK;

  static getCurrentEnv(): string {
    ApiConfig.ensureRuntimeConfigReady();
    return AppStorage.get<string>(ApiConfig.API_ENV_STORAGE_KEY) ?? ApiConfig.CURRENT_ENV;
  }

  static setCurrentEnv(env: string): void {
    AppStorage.setOrCreate(ApiConfig.API_ENV_STORAGE_KEY, env);
  }

  static getConfiguredBaseUrl(): string {
    ApiConfig.ensureRuntimeConfigReady();
    const runtimeUrl = AppStorage.get<string>(ApiConfig.API_BASE_URL_STORAGE_KEY);
    if (runtimeUrl !== undefined && runtimeUrl !== null) {
      return ApiConfig.normalizeBaseUrl(runtimeUrl);
    }
    const currentEnv = ApiConfig.normalizeEnv(AppStorage.get<string>(ApiConfig.API_ENV_STORAGE_KEY));
    if (currentEnv === ApiEnvironment.AGC_SERVERLESS) {
      return runtimeUrl ? ApiConfig.normalizeBaseUrl(runtimeUrl) : '';
    }
    return '';
  }

  static setConfiguredBaseUrl(url: string): void {
    AppStorage.setOrCreate(ApiConfig.API_BASE_URL_STORAGE_KEY, ApiConfig.normalizeBaseUrl(url));
  }

  static applyRuntimeConfig(env: string, baseUrl?: string): void {
    ApiConfig.setCurrentEnv(env);
    if (baseUrl !== undefined) {
      ApiConfig.setConfiguredBaseUrl(baseUrl);
    } else if (env === ApiEnvironment.AGC_SERVERLESS) {
      AppStorage.delete(ApiConfig.API_BASE_URL_STORAGE_KEY);
    }
  }

  static clearRuntimeConfig(): void {
    AppStorage.delete(ApiConfig.API_ENV_STORAGE_KEY);
    AppStorage.delete(ApiConfig.API_BASE_URL_STORAGE_KEY);
    AppStorage.delete(ApiConfig.API_CONFIG_VERSION_STORAGE_KEY);
  }

  static getEnvironmentLabel(): string {
    const env = ApiConfig.getCurrentEnv();
    if (env === ApiEnvironment.AGC_SERVERLESS) {
      return 'AGC Serverless';
    }
    return 'Mock Demo';
  }
  /**
   * Enable mock data mode
   */
  static isMockEnabled(): boolean {
    return ApiConfig.getCurrentEnv() === ApiEnvironment.DEV_MOCK;
  }

  static isAgcEnabled(): boolean {
    return ApiConfig.getCurrentEnv() === ApiEnvironment.AGC_SERVERLESS;
  }

  /**
   * API base URL
   */
  static getBaseUrl(): string {
    const env = ApiConfig.getCurrentEnv();
    if (env === ApiEnvironment.AGC_SERVERLESS) {
      return ApiConfig.getConfiguredBaseUrl();
    }
    return '';
  }

  static describeRuntimeConfig(): string {
    const env = ApiConfig.getCurrentEnv();
    const baseUrl = env === ApiEnvironment.DEV_MOCK
      ? '(mock mode)'
      : (ApiConfig.getConfiguredBaseUrl() || '(unset)');
    return `env=${env}, label=${ApiConfig.getEnvironmentLabel()}, mock=${ApiConfig.isMockEnabled()}, baseUrl=${baseUrl}`;
  }

  static ensureRuntimeConfigReady(): void {
    const storedVersion = AppStorage.get<number>(ApiConfig.API_CONFIG_VERSION_STORAGE_KEY) ?? 0;
    const storedEnv = AppStorage.get<string>(ApiConfig.API_ENV_STORAGE_KEY);
    const storedBaseUrl = AppStorage.get<string>(ApiConfig.API_BASE_URL_STORAGE_KEY);

    let nextEnv = ApiConfig.normalizeEnv(storedEnv);
    let nextBaseUrl = storedBaseUrl ? ApiConfig.normalizeBaseUrl(storedBaseUrl) : '';

    if (nextEnv === ApiEnvironment.AGC_SERVERLESS) {
      if (!nextBaseUrl) {
        nextBaseUrl = '';
      }
    } else {
      nextBaseUrl = '';
    }

    if (storedVersion < ApiConfig.API_CONFIG_VERSION) {
      AppStorage.setOrCreate(ApiConfig.API_ENV_STORAGE_KEY, nextEnv);
      AppStorage.setOrCreate(ApiConfig.API_BASE_URL_STORAGE_KEY, nextBaseUrl);
      AppStorage.setOrCreate(ApiConfig.API_CONFIG_VERSION_STORAGE_KEY, ApiConfig.API_CONFIG_VERSION);
      return;
    }

    if (storedEnv !== nextEnv) {
      AppStorage.setOrCreate(ApiConfig.API_ENV_STORAGE_KEY, nextEnv);
    }
    if (storedBaseUrl !== nextBaseUrl) {
      AppStorage.setOrCreate(ApiConfig.API_BASE_URL_STORAGE_KEY, nextBaseUrl);
    }
  }

  private static normalizeBaseUrl(url: string): string {
    return url.trim().replace(/\/+$/, '');
  }

  private static normalizeEnv(env?: string | null): string {
    if (env === ApiEnvironment.DEV_MOCK ||
      env === ApiEnvironment.AGC_SERVERLESS) {
      return env;
    }
    return ApiConfig.CURRENT_ENV;
  }

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

