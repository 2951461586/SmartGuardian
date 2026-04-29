/**
 * SmartGuardian - Agent Models
 * Contract types for the SmartGuardian Agent cloud function.
 */

export enum AgentTaskType {
  CHAT = 'CHAT',
  SUMMARY = 'SUMMARY',
  REPORT = 'REPORT',
  NAVIGATION = 'NAVIGATION',
  QA = 'QA'
}

export enum AgentResponseSource {
  LLM = 'LLM',
  LOCAL_RULES = 'LOCAL_RULES'
}

export interface AgentRequestBase {
  message?: string;
  question?: string;
  prompt?: string;
  taskType?: string;
  studentId?: number;
  date?: string;
  contextScope?: string;
}

export interface AgentChatRequest extends AgentRequestBase {
  message: string;
}

export interface AgentSummaryRequest extends AgentRequestBase {
}

export interface AgentReportRequest extends AgentRequestBase {
  reportType?: string;
  startDate?: string;
  endDate?: string;
}

export interface AgentNavigationRequest {
  message: string;
}

export interface AgentAction {
  type: string;
  title: string;
  routeUrl: string;
  moduleCode: string;
  confidence: number;
  reason: string;
}

export interface AgentSummary {
  studentCount: number;
  attendanceTotal: number;
  signedIn: number;
  signedOut: number;
  absent: number;
  late: number;
  abnormal: number;
  homeworkTotal: number;
  homeworkCompleted: number;
  activeAlerts: number;
  unreadMessages: number;
  pendingLeaves: number;
  pendingOrders: number;
}

export interface AgentCitation {
  label: string;
  count: number;
}

export interface AgentResponse {
  agentId: string;
  taskType: string;
  answer: string;
  source: string;
  model: string;
  provider: string;
  generatedAt: string;
  contextDate: string;
  summary: AgentSummary;
  actions: AgentAction[];
  suggestions: string[];
  citations: AgentCitation[];
}
