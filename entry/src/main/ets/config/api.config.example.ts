/**
 * SmartGuardian - API Configuration Example
 *
 * Production runtime is AGC Serverless only. The client keeps a single
 * AGC environment flag. Function trigger identifiers are provided by build
 * or release configuration; API Gateway URL is optional for gateway-based
 * deployments.
 */

export class ApiEnvironment {
  static readonly AGC_SERVERLESS: string = 'AGC_SERVERLESS';
}

export class ApiConfigExample {
  static readonly CURRENT_ENV: string = ApiEnvironment.AGC_SERVERLESS;
  static readonly AGC_GATEWAY_BASE_URL: string = 'https://your-agc-api-gateway.example.com';
  static readonly AGC_AUTH_FUNCTION_TRIGGER_URL: string = 'smartguardian-auth-$latest';
}
