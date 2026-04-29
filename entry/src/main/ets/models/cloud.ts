/**
 * SmartGuardian - Cloud orchestration models
 */

export interface DomainEventRecord {
  id: number;
  eventType: string;
  bizType: string;
  bizId: number;
  studentId: number;
  userId: number;
  actorUserId: number;
  status: string;
  attempts: number;
  lastError: string;
  processedAt: string;
  createdAt: string;
  updatedAt: string;
}

export interface EventTriggerConfig {
  triggerEndpoint: string;
  consumerSecretConfigured: boolean;
  recommendedHeader: string;
}

export interface NotificationJob {
  id: number;
  eventId: number;
  userId: number;
  title: string;
  content: string;
  channel: string;
  provider: string;
  status: string;
  priority: string;
  attempts: number;
  maxAttempts: number;
  nextRetryAt: string;
  lastError: string;
  createdAt: string;
  updatedAt: string;
}

export interface NotificationDeliveryConfig {
  deliveryMode: string;
  huaweiPushConfigured: boolean;
  realDeliveryReady: boolean;
  tokenUrl: string;
  sendUrl: string;
  appIdConfigured: boolean;
  clientIdConfigured: boolean;
  clientSecretConfigured: boolean;
}

export interface NotificationDeliveryReceipt {
  id: number;
  jobId: number;
  userId: number;
  sessionId: number;
  deviceId: string;
  provider: string;
  status: string;
  deliveredAt: string;
  errorMessage: string;
  createdAt: string;
  updatedAt: string;
}

export interface NotificationPreference {
  id?: number;
  userId: number;
  enabled: boolean;
  quietStartTime: string;
  quietEndTime: string;
  channels: string[];
  createdAt?: string;
  updatedAt?: string;
}

export interface CloudAttachment {
  id: number;
  ownerUserId: number;
  studentId: number;
  bizType: string;
  bizId: number;
  fileName: string;
  contentType: string;
  fileSize: number;
  storageProvider: string;
  storageBucket: string;
  storagePath: string;
  accessLevel: string;
  status: string;
  downloadUrl: string;
  checksum: string;
  createdAt: string;
  updatedAt: string;
}

export class CloudAttachmentCreateRequest {
  studentId: number = 0;
  bizType: string = '';
  bizId: number = 0;
  fileName: string = '';
  contentType: string = 'application/octet-stream';
  fileSize: number = 0;
  storageBucket: string = '';
  accessLevel: string = 'PRIVATE';
  checksum: string = '';
}

export class CloudAttachmentCompleteRequest {
  downloadUrl: string = '';
  checksum: string = '';
}

export interface CloudAttachmentUploadPolicy {
  provider: string;
  storagePath: string;
  method: string;
  expiresIn: number;
}

export interface CloudStorageConfig {
  provider: string;
  defaultBucketConfigured: boolean;
  uploadMethod: string;
  metadataCollection: string;
}

export interface CloudAttachmentCreateResponse {
  attachment: CloudAttachment;
  uploadPolicy: CloudAttachmentUploadPolicy;
}
