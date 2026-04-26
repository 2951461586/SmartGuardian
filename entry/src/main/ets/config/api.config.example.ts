/**
 * SmartGuardian - API Configuration Example
 *
 * 使用说明：
 * 1. 演示/本地走 Mock：CURRENT_ENV = ApiEnvironment.DEV_MOCK
 * 2. 真实 AGC 网关：CURRENT_ENV = ApiEnvironment.AGC_SERVERLESS，并在运行时配置网关地址
 * 3. 旧 Spring Boot backend/ 已退役，不再保留旧后端联调入口
 */

export class ApiEnvironment {
  static readonly DEV_MOCK: string = 'DEV_MOCK';
  static readonly AGC_SERVERLESS: string = 'AGC_SERVERLESS';
}

export class ApiConfigExample {
  static readonly CURRENT_ENV: string = ApiEnvironment.DEV_MOCK;
}
