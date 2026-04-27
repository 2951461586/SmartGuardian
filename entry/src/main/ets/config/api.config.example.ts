/**
 * SmartGuardian - API Configuration Example
 *
 * 生产运行统一走 AGC 云服务。客户端只保留 AGC 环境标识，网关地址由构建或发布配置写入。
 */

export class ApiEnvironment {
  static readonly AGC_SERVERLESS: string = 'AGC_SERVERLESS';
}

export class ApiConfigExample {
  static readonly CURRENT_ENV: string = ApiEnvironment.AGC_SERVERLESS;
}
