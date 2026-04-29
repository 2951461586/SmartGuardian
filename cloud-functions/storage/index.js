const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { nowIso } = require('../shared/time');
const { badRequest, notFound } = require('../shared/errors');

function buildStoragePath(body, id) {
  const bizType = body.bizType || 'general';
  const bizId = Number(body.bizId || 0);
  const fileName = body.fileName || `attachment-${id}`;
  return `smartguardian/${bizType}/${bizId}/${id}-${fileName}`;
}

function getDefaultStorageBucket() {
  return process.env.SMARTGUARDIAN_STORAGE_BUCKET || process.env.AGC_CLOUD_STORAGE_BUCKET || '';
}

function getStorageConfig() {
  const defaultBucket = getDefaultStorageBucket();
  return {
    provider: 'AGC_CLOUD_STORAGE',
    defaultBucketConfigured: defaultBucket.length > 0,
    uploadMethod: 'CLIENT_SDK_UPLOAD',
    metadataCollection: 'cloud_attachments'
  };
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/storage/config',
    roles: ['ADMIN'],
    handler: async () => {
      return ok(getStorageConfig());
    }
  },
  {
    method: 'POST',
    path: '/api/v1/storage/attachments',
    handler: async ({ body, auth }) => {
      if (!body.fileName || !body.bizType) {
        throw badRequest('fileName and bizType are required');
      }
      const now = nowIso();
      const id = await store.nextIdAsync('cloud_attachments');
      const storagePath = buildStoragePath(body, id);
      const attachment = await store.insertAsync('cloud_attachments', {
        id,
        ownerUserId: auth.user.id,
        studentId: Number(body.studentId || 0),
        bizType: body.bizType,
        bizId: Number(body.bizId || 0),
        fileName: body.fileName,
        contentType: body.contentType || 'application/octet-stream',
        fileSize: Number(body.fileSize || 0),
        storageProvider: 'AGC_CLOUD_STORAGE',
        storageBucket: body.storageBucket || getDefaultStorageBucket(),
        storagePath,
        accessLevel: body.accessLevel || 'PRIVATE',
        status: 'PENDING_UPLOAD',
        downloadUrl: '',
        checksum: body.checksum || '',
        createdAt: now,
        updatedAt: now
      });
      return ok({
        attachment,
        uploadPolicy: {
          provider: 'AGC_CLOUD_STORAGE',
          storagePath,
          method: 'CLIENT_SDK_UPLOAD',
          expiresIn: 900
        }
      }, 'attachment registered');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/storage/attachments/:attachmentId/complete',
    handler: async ({ params, body, auth }) => {
      const attachment = await store.findByIdAsync('cloud_attachments', Number(params.attachmentId));
      if (!attachment || Number(attachment.ownerUserId) !== Number(auth.user.id)) {
        throw notFound('Attachment not found');
      }
      const updated = await store.updateAsync('cloud_attachments', attachment.id, {
        status: 'AVAILABLE',
        downloadUrl: body.downloadUrl || attachment.downloadUrl || '',
        checksum: body.checksum || attachment.checksum || '',
        updatedAt: nowIso()
      });
      return ok(updated, 'attachment upload completed');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/storage/attachments',
    handler: async ({ query, auth }) => {
      const rows = await store.filterAsync('cloud_attachments', (item) => {
        if (Number(item.ownerUserId) !== Number(auth.user.id) && auth.user.roleType !== 'ADMIN') {
          return false;
        }
        if (query.bizType && item.bizType !== query.bizType) {
          return false;
        }
        if (query.bizId && Number(item.bizId || 0) !== Number(query.bizId)) {
          return false;
        }
        return true;
      });
      const pageResult = store.paginate(rows, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
