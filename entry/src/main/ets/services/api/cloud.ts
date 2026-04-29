/**
 * SmartGuardian - Cloud orchestration API services
 */

import { get, post, put } from '../../utils/request';
import { ApiEndpoints } from '../../constants/ApiEndpoints';
import { ApiResponse, PageResponse } from '../../models/common';
import {
  CloudAttachment,
  CloudAttachmentCompleteRequest,
  CloudAttachmentCreateRequest,
  CloudAttachmentCreateResponse,
  CloudStorageConfig,
  DomainEventRecord,
  EventTriggerConfig,
  NotificationDeliveryConfig,
  NotificationDeliveryReceipt,
  NotificationJob,
  NotificationPreference
} from '../../models/cloud';

export class EventService {
  static readonly AGC_DOMAIN: string = 'event';
  static readonly AGC_FUNCTION: string = 'smartguardian-event';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.EVENTS;

  static async getOutbox(params?: object): Promise<ApiResponse<PageResponse<DomainEventRecord>>> {
    return get<PageResponse<DomainEventRecord>>(ApiEndpoints.EVENTS_OUTBOX, params);
  }

  static async processPending(limit?: number): Promise<ApiResponse<object>> {
    return post<object>(ApiEndpoints.EVENTS_PROCESS, { limit: limit ? limit : 20 });
  }

  static async getTriggerConfig(): Promise<ApiResponse<EventTriggerConfig>> {
    return get<EventTriggerConfig>(ApiEndpoints.EVENTS_TRIGGER_CONFIG);
  }

  static async triggerConsumer(limit?: number): Promise<ApiResponse<object>> {
    return post<object>(ApiEndpoints.EVENTS_TRIGGER, { limit: limit ? limit : 20 }, { needAuth: false });
  }
}

export class NotificationCloudService {
  static readonly AGC_DOMAIN: string = 'notification';
  static readonly AGC_FUNCTION: string = 'smartguardian-notification';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.NOTIFICATIONS;

  static async getJobs(params?: object): Promise<ApiResponse<PageResponse<NotificationJob>>> {
    return get<PageResponse<NotificationJob>>(ApiEndpoints.NOTIFICATION_JOBS, params);
  }

  static async getDeliveryConfig(): Promise<ApiResponse<NotificationDeliveryConfig>> {
    return get<NotificationDeliveryConfig>(ApiEndpoints.NOTIFICATION_DELIVERY_CONFIG);
  }

  static async getReceipts(params?: object): Promise<ApiResponse<PageResponse<NotificationDeliveryReceipt>>> {
    return get<PageResponse<NotificationDeliveryReceipt>>(ApiEndpoints.NOTIFICATION_RECEIPTS, params);
  }

  static async getPreferences(): Promise<ApiResponse<NotificationPreference>> {
    return get<NotificationPreference>(ApiEndpoints.NOTIFICATION_PREFERENCES);
  }

  static async updatePreferences(data: NotificationPreference): Promise<ApiResponse<NotificationPreference>> {
    return put<NotificationPreference>(ApiEndpoints.NOTIFICATION_PREFERENCES, data);
  }

  static async retryJob(jobId: number): Promise<ApiResponse<NotificationJob>> {
    return post<NotificationJob>(ApiEndpoints.notificationJobRetry(jobId), {});
  }

  static async processJobs(limit?: number): Promise<ApiResponse<object>> {
    return post<object>(ApiEndpoints.NOTIFICATION_JOBS_PROCESS, { limit: limit ? limit : 20 });
  }
}

export class CloudStorageAttachmentService {
  static readonly AGC_DOMAIN: string = 'storage';
  static readonly AGC_FUNCTION: string = 'smartguardian-storage';
  static readonly AGC_ROUTE_SCOPE: string = ApiEndpoints.STORAGE;

  static async createAttachment(data: CloudAttachmentCreateRequest): Promise<ApiResponse<CloudAttachmentCreateResponse>> {
    return post<CloudAttachmentCreateResponse>(ApiEndpoints.STORAGE_ATTACHMENTS, data);
  }

  static async getConfig(): Promise<ApiResponse<CloudStorageConfig>> {
    return get<CloudStorageConfig>(ApiEndpoints.STORAGE_CONFIG);
  }

  static async completeAttachment(attachmentId: number, data: CloudAttachmentCompleteRequest): Promise<ApiResponse<CloudAttachment>> {
    return post<CloudAttachment>(ApiEndpoints.storageAttachmentComplete(attachmentId), data);
  }

  static async getAttachments(params?: object): Promise<ApiResponse<PageResponse<CloudAttachment>>> {
    return get<PageResponse<CloudAttachment>>(ApiEndpoints.STORAGE_ATTACHMENTS, params);
  }
}
