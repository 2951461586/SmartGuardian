/**
 * SmartGuardian - Agent API Service
 * LLM-backed custody assistant APIs.
 */

import { post } from '../../utils/request';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { ApiResponse } from '../../models/common';
import {
  AgentChatRequest,
  AgentNavigationRequest,
  AgentReportRequest,
  AgentResponse,
  AgentSummaryRequest
} from '../../models/agent';

export class AgentService {
  static readonly AGC_DOMAIN: string = 'agent';
  static readonly AGC_FUNCTION: string = 'smartguardian-agent';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.AGENT;

  static async chat(data: AgentChatRequest): Promise<ApiResponse<AgentResponse>> {
    const payload: AgentChatRequest = {
      message: data.message,
      taskType: data.taskType,
      studentId: data.studentId,
      date: data.date,
      contextScope: data.contextScope
    };
    return post<AgentResponse>(ApiEndpoints.AGENT_CHAT, payload);
  }

  static async summarize(data?: AgentSummaryRequest): Promise<ApiResponse<AgentResponse>> {
    const payload: AgentSummaryRequest = data ? {
      message: data.message,
      question: data.question,
      prompt: data.prompt,
      taskType: data.taskType,
      studentId: data.studentId,
      date: data.date,
      contextScope: data.contextScope
    } : {};
    return post<AgentResponse>(ApiEndpoints.AGENT_SUMMARY, payload);
  }

  static async report(data?: AgentReportRequest): Promise<ApiResponse<AgentResponse>> {
    const payload: AgentReportRequest = data ? {
      message: data.message,
      question: data.question,
      prompt: data.prompt,
      taskType: data.taskType,
      studentId: data.studentId,
      date: data.date,
      contextScope: data.contextScope,
      reportType: data.reportType,
      startDate: data.startDate,
      endDate: data.endDate
    } : {};
    return post<AgentResponse>(ApiEndpoints.AGENT_REPORT, payload);
  }

  static async navigate(data: AgentNavigationRequest): Promise<ApiResponse<AgentResponse>> {
    const payload: AgentNavigationRequest = {
      message: data.message
    };
    return post<AgentResponse>(ApiEndpoints.AGENT_NAVIGATION, payload);
  }
}
