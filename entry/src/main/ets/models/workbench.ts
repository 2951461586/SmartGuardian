/**
 * SmartGuardian - Workbench Models
 * Role-aware product capability manifest for parent, teacher and organization portals.
 */

export interface WorkbenchVisual {
  primary: string;
  light: string;
  surface: string;
  componentTone: string;
  slogan: string;
}

export interface WorkbenchSummary {
  title: string;
  description: string;
  metrics: string[];
}

export interface WorkbenchFlow {
  code: string;
  name: string;
  description: string;
}

export interface WorkbenchModule {
  code: string;
  name: string;
  route: string;
  enabled: boolean;
}

export interface WorkbenchIntegration {
  apiBase: string;
  auth: string;
  mockDefault: boolean;
  acceptance: string[];
}

export interface WorkbenchManifest {
  roleType: string;
  version: string;
  visual: WorkbenchVisual;
  summary: WorkbenchSummary;
  primaryFlows: WorkbenchFlow[];
  modules: WorkbenchModule[];
  integration: WorkbenchIntegration;
}
