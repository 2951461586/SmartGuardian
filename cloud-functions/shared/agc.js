const path = require('path');
const { getCollectionSchema } = require('./schema');
const {
  loadCloudEnv,
  resolveAgcServerCredential,
  inspectJsonFile,
  isClientAgconnectConfig,
  isConnectApiPrivateKeyConfig
} = require('../../scripts/cloud-env-loader');

let cachedCloudInstance = null;
let cachedDatabase = null;
let cachedCloudServer = null;
loadCloudEnv();

function getCloudServer() {
  if (cachedCloudServer) {
    return cachedCloudServer;
  }
  cachedCloudServer = require('@hw-agconnect/cloud-server');
  return cachedCloudServer;
}

function isAgcCloudDbEnabled() {
  return process.env.SMARTGUARDIAN_CLOUD_DB_PROVIDER === 'agc'
    && !!resolveCloudDbZone()
    && resolveCredentialPath().length > 0;
}

function resolveCredentialPath() {
  return resolveAgcServerCredential();
}

function resolveRegion() {
  const regionKey = (process.env.SMARTGUARDIAN_REGION || process.env.AGC_REGION || 'CN').toUpperCase();
  const Region = getCloudServer().Region;
  if (regionKey === 'RU') {
    return Region.REGION_RU;
  }
  if (regionKey === 'SG') {
    return Region.REGION_SG;
  }
  if (regionKey === 'DE') {
    return Region.REGION_DE;
  }
  return Region.REGION_CN;
}

function resolveCloudDbZone() {
  return process.env.SMARTGUARDIAN_CLOUD_DB_ZONE || process.env.AGC_CLOUD_DB_ZONE || '';
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
  if (isConnectApiPrivateKeyConfig(credentialJson)) {
    throw new Error('AGC Cloud Server SDK 1.0.5 does not support Service Account private-key JSON for Cloud DB. Use the Server SDK credential JSON (agc-apiclient) for now.');
  }

  const instanceName = 'smartguardian-cloud-functions';
  const cloud = getCloudServer().cloud;
  cachedCloudInstance = cloud.createInstance(path.resolve(credentialPath), instanceName, resolveRegion());
  return cachedCloudInstance;
}

function getDatabase() {
  if (cachedDatabase) {
    return cachedDatabase;
  }

  cachedDatabase = getCloudInstance().database({
    zoneName: resolveCloudDbZone(),
    traceId: process.env.SMARTGUARDIAN_TRACE_ID || process.env.AGC_TRACE_ID || ''
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
  const CloudDBZoneGenericObject = getCloudServer().CloudDBZoneGenericObject;
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
