const path = require('path');
const { cloud, Region, CloudDBZoneGenericObject } = require('@hw-agconnect/cloud-server');
const { getCollectionSchema } = require('./schema');
const {
  loadCloudEnv,
  resolveAgcServerCredential,
  inspectJsonFile,
  isClientAgconnectConfig
} = require('../../scripts/cloud-env-loader');

const REGION_MAP = {
  CN: Region.REGION_CN,
  RU: Region.REGION_RU,
  SG: Region.REGION_SG,
  DE: Region.REGION_DE
};

let cachedCloudInstance = null;
let cachedDatabase = null;
loadCloudEnv();

function isAgcCloudDbEnabled() {
  return process.env.SMARTGUARDIAN_CLOUD_DB_PROVIDER === 'agc'
    && !!process.env.AGC_CLOUD_DB_ZONE
    && resolveCredentialPath().length > 0;
}

function resolveCredentialPath() {
  return resolveAgcServerCredential();
}

function resolveRegion() {
  const regionKey = (process.env.AGC_REGION || 'CN').toUpperCase();
  return REGION_MAP[regionKey] || Region.REGION_CN;
}

function getCloudInstance() {
  if (cachedCloudInstance) {
    return cachedCloudInstance;
  }

  const credentialPath = resolveCredentialPath();
  if (!credentialPath) {
    throw new Error('AGC credential path is missing');
  }
  const credentialJson = inspectJsonFile(credentialPath);
  if (isClientAgconnectConfig(credentialJson)) {
    throw new Error('AGC credential must be a Server SDK credential JSON (agc-apiclient), not agconnect-services.json');
  }

  const instanceName = 'smartguardian-cloud-functions';
  cachedCloudInstance = cloud.createInstance(path.resolve(credentialPath), instanceName, resolveRegion());
  return cachedCloudInstance;
}

function getDatabase() {
  if (cachedDatabase) {
    return cachedDatabase;
  }

  cachedDatabase = getCloudInstance().database({
    zoneName: process.env.AGC_CLOUD_DB_ZONE,
    traceId: process.env.AGC_TRACE_ID || ''
  });
  return cachedDatabase;
}

function getCollection(collectionName) {
  return getDatabase().collection(collectionName);
}

function normalizeRecord(record) {
  if (!record) {
    return null;
  }
  if (typeof record.getObject === 'function') {
    return record.getObject();
  }
  if (record.fieldMap && typeof record.fieldMap.entries === 'function') {
    const value = {};
    for (const entry of record.fieldMap.entries()) {
      value[entry[0]] = entry[1];
    }
    return value;
  }
  return record;
}

function normalizeRecords(records) {
  return records.map((record) => normalizeRecord(record));
}

function toGenericObject(collectionName, record) {
  const schema = getCollectionSchema(collectionName);
  const primaryKey = schema.primaryKey || 'id';
  const genericObject = CloudDBZoneGenericObject.build(collectionName);
  const keys = Object.keys(record);
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (record[key] === undefined) {
      continue;
    }
    genericObject.addFieldValue(key, record[key], key === primaryKey);
  }
  return genericObject;
}

module.exports = {
  isAgcCloudDbEnabled,
  getCollection,
  normalizeRecord,
  normalizeRecords,
  toGenericObject
};
