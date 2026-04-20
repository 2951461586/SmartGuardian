/**
 * SmartGuardian - API Configuration Example
 *
 * 使用说明：
 * 1. 开发/演示环境：CURRENT_ENV = ApiEnvironment.DEV_MOCK
 * 2. 联调/测试环境：CURRENT_ENV = ApiEnvironment.TEST_REAL
 * 3. 联调时填写 TEST_BASE_URL
 */

export class ApiEnvironment {
  static readonly DEV_MOCK: string = 'DEV_MOCK';
  static readonly TEST_REAL: string = 'TEST_REAL';
}

export class ApiConfigExample {
  static readonly CURRENT_ENV: string = ApiEnvironment.TEST_REAL;
  static readonly TEST_BASE_URL: string = 'http://192.168.1.100:8080';
}
