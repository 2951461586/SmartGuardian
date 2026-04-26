/**
 * SmartGuardian - Workbench API Service
 * Role-aware manifest used to keep the frontend shell aligned with backend capabilities.
 */

import { get } from '../../utils/request';
import { ApiResponse } from '../../models/common';
import { WorkbenchManifest } from '../../models/workbench';
import { ApiEndpoints } from '../../constants/ApiEndpoints';

export class WorkbenchService {
  static readonly AGC_DOMAIN: string = 'workbench';
  static readonly AGC_FUNCTION: string = 'smartguardian-workbench';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.WORKBENCH;

  static async getManifest(): Promise<ApiResponse<WorkbenchManifest>> {
    return get<WorkbenchManifest>(ApiEndpoints.WORKBENCH_MANIFEST);
  }
}
