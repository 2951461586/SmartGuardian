/**
 * SmartGuardian - AGC Cloud Storage upload orchestration.
 */

import {
  CloudAttachment,
  CloudAttachmentCompleteRequest,
  CloudAttachmentCreateRequest,
  CloudAttachmentUploadPolicy
} from '../models/cloud';
import { CloudStorageAttachmentService } from './api/cloud';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'CloudStorageUploadService';

export class CloudStorageUploadRequest {
  localFileUri: string = '';
  fileName: string = '';
  contentType: string = 'application/octet-stream';
  fileSize: number = 0;
  checksum: string = '';
  studentId: number = 0;
  bizType: string = '';
  bizId: number = 0;
  storageBucket: string = '';
  accessLevel: string = 'PRIVATE';
}

export class CloudStorageSdkUploadRequest {
  localFileUri: string = '';
  storageBucket: string = '';
  storagePath: string = '';
  contentType: string = 'application/octet-stream';
  fileSize: number = 0;
  checksum: string = '';
  attachmentId: number = 0;
}

export class CloudStorageSdkUploadResult {
  success: boolean = false;
  downloadUrl: string = '';
  checksum: string = '';
  bytesTransferred: number = 0;
  errorMessage: string = '';
}

export class CloudStorageUploadResult {
  success: boolean = false;
  status: string = 'NOT_STARTED';
  attachment: CloudAttachment | null = null;
  errorMessage: string = '';
}

export interface CloudStorageUploadAdapter {
  isAvailable(): boolean;
  uploadFile(request: CloudStorageSdkUploadRequest): Promise<CloudStorageSdkUploadResult>;
}

class UnconfiguredCloudStorageUploadAdapter implements CloudStorageUploadAdapter {
  isAvailable(): boolean {
    return false;
  }

  async uploadFile(request: CloudStorageSdkUploadRequest): Promise<CloudStorageSdkUploadResult> {
    const result = new CloudStorageSdkUploadResult();
    result.success = false;
    result.errorMessage = 'AGC Cloud Storage SDK adapter is not configured.';
    return result;
  }
}

export class CloudStorageUploadService {
  private static adapter: CloudStorageUploadAdapter = new UnconfiguredCloudStorageUploadAdapter();

  static registerAdapter(adapter: CloudStorageUploadAdapter): void {
    CloudStorageUploadService.adapter = adapter;
  }

  static resetAdapter(): void {
    CloudStorageUploadService.adapter = new UnconfiguredCloudStorageUploadAdapter();
  }

  static isAvailable(): boolean {
    return CloudStorageUploadService.adapter.isAvailable();
  }

  static async uploadAttachment(request: CloudStorageUploadRequest): Promise<CloudStorageUploadResult> {
    const result = new CloudStorageUploadResult();
    if (!CloudStorageUploadService.adapter.isAvailable()) {
      result.status = 'SDK_NOT_CONFIGURED';
      result.errorMessage = 'AGC Cloud Storage SDK adapter is not configured.';
      return result;
    }

    if (request.localFileUri.length === 0 || request.fileName.length === 0 || request.bizType.length === 0) {
      result.status = 'INVALID_REQUEST';
      result.errorMessage = 'localFileUri, fileName and bizType are required.';
      return result;
    }

    try {
      const createRequest = CloudStorageUploadService.buildCreateRequest(request);
      const createResponse = await CloudStorageAttachmentService.createAttachment(createRequest);
      if (createResponse.code !== 0) {
        result.status = 'REGISTER_FAILED';
        result.errorMessage = createResponse.message;
        return result;
      }

      const attachment = createResponse.data.attachment;
      const policy = createResponse.data.uploadPolicy;
      const sdkRequest = CloudStorageUploadService.buildSdkRequest(request, attachment, policy);
      const sdkResult = await CloudStorageUploadService.adapter.uploadFile(sdkRequest);
      if (!sdkResult.success) {
        result.status = 'UPLOAD_FAILED';
        result.attachment = attachment;
        result.errorMessage = sdkResult.errorMessage;
        return result;
      }

      const completeRequest = new CloudAttachmentCompleteRequest();
      completeRequest.downloadUrl = sdkResult.downloadUrl;
      completeRequest.checksum = sdkResult.checksum.length > 0 ? sdkResult.checksum : request.checksum;

      const completeResponse = await CloudStorageAttachmentService.completeAttachment(attachment.id, completeRequest);
      if (completeResponse.code !== 0) {
        result.status = 'COMPLETE_FAILED';
        result.attachment = attachment;
        result.errorMessage = completeResponse.message;
        return result;
      }

      result.success = true;
      result.status = 'AVAILABLE';
      result.attachment = completeResponse.data;
      return result;
    } catch (error) {
      result.status = 'ERROR';
      result.errorMessage = String(error);
      LogUtil.warn(TAG, `Upload attachment failed: ${result.errorMessage}`);
      return result;
    }
  }

  private static buildCreateRequest(request: CloudStorageUploadRequest): CloudAttachmentCreateRequest {
    const createRequest = new CloudAttachmentCreateRequest();
    createRequest.studentId = request.studentId;
    createRequest.bizType = request.bizType;
    createRequest.bizId = request.bizId;
    createRequest.fileName = request.fileName;
    createRequest.contentType = request.contentType;
    createRequest.fileSize = request.fileSize;
    createRequest.storageBucket = request.storageBucket;
    createRequest.accessLevel = request.accessLevel;
    createRequest.checksum = request.checksum;
    return createRequest;
  }

  private static buildSdkRequest(
    request: CloudStorageUploadRequest,
    attachment: CloudAttachment,
    policy: CloudAttachmentUploadPolicy
  ): CloudStorageSdkUploadRequest {
    const sdkRequest = new CloudStorageSdkUploadRequest();
    sdkRequest.localFileUri = request.localFileUri;
    sdkRequest.storageBucket = attachment.storageBucket.length > 0 ? attachment.storageBucket : request.storageBucket;
    sdkRequest.storagePath = policy.storagePath.length > 0 ? policy.storagePath : attachment.storagePath;
    sdkRequest.contentType = request.contentType;
    sdkRequest.fileSize = request.fileSize;
    sdkRequest.checksum = request.checksum;
    sdkRequest.attachmentId = attachment.id;
    return sdkRequest;
  }
}
