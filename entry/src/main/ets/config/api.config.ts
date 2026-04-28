/**
 * SmartGuardian - API Configuration
 * API configuration
 */

import { StorageKeys } from '../constants/app.constants';

/**
 * API environment identifiers
 */
export class ApiEnvironment {
  static readonly AGC_SERVERLESS: string = 'AGC_SERVERLESS';
}

/**
 * API environment configuration
 */
export class ApiConfig {
  static readonly API_ENV_STORAGE_KEY: string = StorageKeys.API_ENV;
  static readonly API_BASE_URL_STORAGE_KEY: string = StorageKeys.API_BASE_URL;
  static readonly API_CONFIG_VERSION_STORAGE_KEY: string = StorageKeys.API_CONFIG_VERSION;
  private static readonly API_CONFIG_VERSION: number = 9;
  private static readonly AGC_GATEWAY_BASE_URL: string = '';
  private static readonly AGC_AUTH_FUNCTION_TRIGGER_URL: string = 'smartguardian-auth-$latest';

  /**
   * Default environment for fresh installs.
   * Production traffic is routed through AGC.
   */
  static readonly CURRENT_ENV: string = ApiEnvironment.AGC_SERVERLESS;

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

  static getFunctionTriggerUrl(functionName: string): string {
    ApiConfig.ensureRuntimeConfigReady();
    const storageKey = ApiConfig.getFunctionTriggerUrlStorageKey(functionName);
    const runtimeUrl = AppStorage.get<string>(storageKey);
    if (runtimeUrl !== undefined && runtimeUrl !== null && runtimeUrl.length > 0) {
      return ApiConfig.normalizeBaseUrl(runtimeUrl);
    }
    if (functionName === 'smartguardian-auth') {
      return ApiConfig.normalizeBaseUrl(ApiConfig.AGC_AUTH_FUNCTION_TRIGGER_URL);
    }
    if (functionName.indexOf('smartguardian-') === 0) {
      return ApiConfig.normalizeBaseUrl(`${functionName}-$latest`);
    }
    return '';
  }

  static setFunctionTriggerUrl(functionName: string, url: string): void {
    AppStorage.setOrCreate(ApiConfig.getFunctionTriggerUrlStorageKey(functionName), ApiConfig.normalizeBaseUrl(url));
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
    return '云服务';
  }

  static isAgcEnabled(): boolean {
    return true;
  }

  /**
   * API base URL
   */
  static getBaseUrl(): string {
    return ApiConfig.getConfiguredBaseUrl();
  }

  static describeRuntimeConfig(): string {
    const baseUrl = ApiConfig.getConfiguredBaseUrl() || '(未配置)';
    return `env=${ApiEnvironment.AGC_SERVERLESS}, label=${ApiConfig.getEnvironmentLabel()}, baseUrl=${baseUrl}`;
  }

  static ensureRuntimeConfigReady(): void {
    const storedVersion = AppStorage.get<number>(ApiConfig.API_CONFIG_VERSION_STORAGE_KEY) ?? 0;
    const storedEnv = AppStorage.get<string>(ApiConfig.API_ENV_STORAGE_KEY);
    const storedBaseUrl = AppStorage.get<string>(ApiConfig.API_BASE_URL_STORAGE_KEY);

    let nextEnv = ApiConfig.normalizeEnv(storedEnv);
    let nextBaseUrl = storedBaseUrl ? ApiConfig.normalizeBaseUrl(storedBaseUrl) : ApiConfig.getDefaultAgcGatewayBaseUrl();

    nextEnv = ApiEnvironment.AGC_SERVERLESS;

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

  private static getDefaultAgcGatewayBaseUrl(): string {
    return ApiConfig.normalizeBaseUrl(ApiConfig.AGC_GATEWAY_BASE_URL);
  }

  private static getFunctionTriggerUrlStorageKey(functionName: string): string {
    return `${StorageKeys.AGC_FUNCTION_TRIGGER_URL_PREFIX}${functionName}`;
  }

  private static normalizeEnv(env?: string | null): string {
    if (env === ApiEnvironment.AGC_SERVERLESS) {
      return env;
    }
    return ApiConfig.CURRENT_ENV;
  }

  /**
   * Request timeout in milliseconds
   */
  static readonly TIMEOUT: number = 30000;

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

