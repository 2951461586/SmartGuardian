/**
 * SmartGuardian Agent runtime constants.
 */

import { ApiEndpoints } from '../../constants/ApiEndpoints';

export class SmartGuardianAgentConfig {
  static readonly AGENT_ID: string = 'smartguardian-student-custody-agent';
  static readonly AGC_DOMAIN: string = 'agent';
  static readonly AGC_FUNCTION: string = 'smartguardian-agent';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.AGENT;
}
