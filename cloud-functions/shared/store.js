const fs = require('fs');
const path = require('path');
const { getCollectionSchema } = require('./schema');
const { badRequest, conflict, notFound } = require('./errors');
const {
  isAgcCloudDbEnabled,
  getCollection,
  normalizeRecord,
  normalizeRecords,
  toGenericObject
} = require('./agc');

function loadSeedData() {
  const seedPath = path.join(__dirname, '..', 'cloud-db', 'seed-data.json');
  try {
    return JSON.parse(fs.readFileSync(seedPath, 'utf8'));
  } catch (error) {
    return {};
  }
}

const state = JSON.parse(JSON.stringify(loadSeedData()));

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function ensureCollection(name) {
  if (!state[name]) {
    state[name] = [];
  }
  return state[name];
}

function list(collectionName) {
  return clone(ensureCollection(collectionName));
}

function nextId(collectionName) {
  const collection = ensureCollection(collectionName);
  let maxId = 0;
  for (let i = 0; i < collection.length; i++) {
    const currentId = Number(collection[i].id || 0);
    if (currentId > maxId) {
      maxId = currentId;
    }
  }
  return maxId + 1;
}

function findById(collectionName, id) {
  const collection = ensureCollection(collectionName);
  for (let i = 0; i < collection.length; i++) {
    if (Number(collection[i].id) === Number(id)) {
      return clone(collection[i]);
    }
  }
  return null;
}

function filter(collectionName, predicate) {
  const collection = ensureCollection(collectionName);
  return clone(collection.filter(predicate));
}

function requireById(collectionName, id) {
  const entity = findById(collectionName, id);
  if (!entity) {
    throw notFound(`${collectionName} record ${id} not found`);
  }
  return entity;
}

function validateType(value, type) {
  if (type === 'array') {
    return Array.isArray(value);
  }
  if (type === 'object') {
    return value !== null && typeof value === 'object' && !Array.isArray(value);
  }
  return typeof value === type;
}

function validateRecord(collectionName, record, currentId) {
  const schema = getCollectionSchema(collectionName);
  const fields = schema.fields || {};
  const required = schema.required || [];

  for (let i = 0; i < required.length; i++) {
    const fieldName = required[i];
    const value = record[fieldName];
    if (value === undefined || value === null || value === '') {
      throw badRequest(`${collectionName}.${fieldName} is required`);
    }
  }

  const fieldNames = Object.keys(fields);
  for (let i = 0; i < fieldNames.length; i++) {
    const fieldName = fieldNames[i];
    if (record[fieldName] === undefined || record[fieldName] === null || record[fieldName] === '') {
      continue;
    }

    const descriptor = fields[fieldName];
    if (descriptor.type && !validateType(record[fieldName], descriptor.type)) {
      throw badRequest(`${collectionName}.${fieldName} must be ${descriptor.type}`);
    }
    if (descriptor.enum && descriptor.enum.indexOf(record[fieldName]) < 0) {
      throw badRequest(`${collectionName}.${fieldName} is invalid`);
    }
  }

  const uniqueConstraints = schema.unique || [];
  for (let i = 0; i < uniqueConstraints.length; i++) {
    const fieldGroup = uniqueConstraints[i];
    const matches = ensureCollection(collectionName).filter((candidate) => {
      if (currentId && Number(candidate.id) === Number(currentId)) {
        return false;
      }
      for (let j = 0; j < fieldGroup.length; j++) {
        const key = fieldGroup[j];
        if (candidate[key] !== record[key]) {
          return false;
        }
      }
      return true;
    });
    if (matches.length > 0) {
      throw conflict(`${collectionName} unique constraint failed: ${fieldGroup.join(',')}`);
    }
  }

  const foreignKeys = schema.foreignKeys || [];
  for (let i = 0; i < foreignKeys.length; i++) {
    const relation = foreignKeys[i];
    const value = record[relation.field];
    if (value === undefined || value === null || value === 0 || value === '') {
      continue;
    }
    const related = findById(relation.collection, value);
    if (!related) {
      throw badRequest(`${collectionName}.${relation.field} references missing ${relation.collection}.${relation.refField}`);
    }
  }
}

async function validateRecordAsync(collectionName, record, currentId) {
  const schema = getCollectionSchema(collectionName);
  const fields = schema.fields || {};
  const required = schema.required || [];

  for (let i = 0; i < required.length; i++) {
    const fieldName = required[i];
    const value = record[fieldName];
    if (value === undefined || value === null || value === '') {
      throw badRequest(`${collectionName}.${fieldName} is required`);
    }
  }

  const fieldNames = Object.keys(fields);
  for (let i = 0; i < fieldNames.length; i++) {
    const fieldName = fieldNames[i];
    if (record[fieldName] === undefined || record[fieldName] === null || record[fieldName] === '') {
      continue;
    }

    const descriptor = fields[fieldName];
    if (descriptor.type && !validateType(record[fieldName], descriptor.type)) {
      throw badRequest(`${collectionName}.${fieldName} must be ${descriptor.type}`);
    }
    if (descriptor.enum && descriptor.enum.indexOf(record[fieldName]) < 0) {
      throw badRequest(`${collectionName}.${fieldName} is invalid`);
    }
  }

  const uniqueConstraints = schema.unique || [];
  const allRecords = await listAsync(collectionName);
  for (let i = 0; i < uniqueConstraints.length; i++) {
    const fieldGroup = uniqueConstraints[i];
    const matches = allRecords.filter((candidate) => {
      if (currentId && Number(candidate.id) === Number(currentId)) {
        return false;
      }
      for (let j = 0; j < fieldGroup.length; j++) {
        const key = fieldGroup[j];
        if (candidate[key] !== record[key]) {
          return false;
        }
      }
      return true;
    });
    if (matches.length > 0) {
      throw conflict(`${collectionName} unique constraint failed: ${fieldGroup.join(',')}`);
    }
  }

  const foreignKeys = schema.foreignKeys || [];
  for (let i = 0; i < foreignKeys.length; i++) {
    const relation = foreignKeys[i];
    const value = record[relation.field];
    if (value === undefined || value === null || value === 0 || value === '') {
      continue;
    }
    const related = await findByIdAsync(relation.collection, value);
    if (!related) {
      throw badRequest(`${collectionName}.${relation.field} references missing ${relation.collection}.${relation.refField}`);
    }
  }
}

function insert(collectionName, record) {
  const schema = getCollectionSchema(collectionName);
  const created = clone(record);
  if (created[schema.primaryKey] === undefined) {
    created[schema.primaryKey] = nextId(collectionName);
  }
  validateRecord(collectionName, created, null);
  ensureCollection(collectionName).push(created);
  return clone(created);
}

function update(collectionName, id, patch) {
  const collection = ensureCollection(collectionName);
  let index = -1;
  for (let i = 0; i < collection.length; i++) {
    if (Number(collection[i].id) === Number(id)) {
      index = i;
      break;
    }
  }
  if (index < 0) {
    throw notFound(`${collectionName} record ${id} not found`);
  }

  const updated = {
    ...collection[index],
    ...clone(patch)
  };
  validateRecord(collectionName, updated, id);
  collection[index] = updated;
  return clone(updated);
}

function remove(collectionName, id) {
  const collection = ensureCollection(collectionName);
  const index = collection.findIndex((item) => Number(item.id) === Number(id));
  if (index < 0) {
    throw notFound(`${collectionName} record ${id} not found`);
  }
  const removed = collection[index];
  collection.splice(index, 1);
  return clone(removed);
}

function paginate(items, pageNum, pageSize) {
  const resolvedPageNum = Number(pageNum || 1);
  const resolvedPageSize = Number(pageSize || 20);
  const start = (resolvedPageNum - 1) * resolvedPageSize;
  const end = start + resolvedPageSize;
  return {
    list: items.slice(start, end),
    total: items.length,
    pageNum: resolvedPageNum,
    pageSize: resolvedPageSize
  };
}

async function listAsync(collectionName) {
  if (!isAgcCloudDbEnabled()) {
    return list(collectionName);
  }
  const collection = getCollection(collectionName);
  const records = await collection.query().get();
  return normalizeRecords(records);
}

async function nextIdAsync(collectionName) {
  if (!isAgcCloudDbEnabled()) {
    return nextId(collectionName);
  }
  const records = await listAsync(collectionName);
  let maxId = 0;
  for (let i = 0; i < records.length; i++) {
    const currentId = Number(records[i].id || 0);
    if (currentId > maxId) {
      maxId = currentId;
    }
  }
  return maxId + 1;
}

async function findByIdAsync(collectionName, id) {
  if (!isAgcCloudDbEnabled()) {
    return findById(collectionName, id);
  }
  const collection = getCollection(collectionName);
  const records = await collection.query().equalTo('id', Number(id)).limit(1).get();
  if (!records || records.length === 0) {
    return null;
  }
  return normalizeRecord(records[0]);
}

async function filterAsync(collectionName, predicate) {
  const records = await listAsync(collectionName);
  return clone(records.filter(predicate));
}

async function requireByIdAsync(collectionName, id) {
  const entity = await findByIdAsync(collectionName, id);
  if (!entity) {
    throw notFound(`${collectionName} record ${id} not found`);
  }
  return entity;
}

async function insertAsync(collectionName, record) {
  if (!isAgcCloudDbEnabled()) {
    return insert(collectionName, record);
  }
  const schema = getCollectionSchema(collectionName);
  const created = clone(record);
  if (created[schema.primaryKey] === undefined) {
    created[schema.primaryKey] = await nextIdAsync(collectionName);
  }
  await validateRecordAsync(collectionName, created, null);
  const collection = getCollection(collectionName);
  const result = await collection.insert(toGenericObject(collectionName, created));
  if (Number(result) < 1) {
    throw conflict(`${collectionName} insert failed`);
  }
  return requireByIdAsync(collectionName, created[schema.primaryKey]);
}

async function updateAsync(collectionName, id, patch) {
  if (!isAgcCloudDbEnabled()) {
    return update(collectionName, id, patch);
  }
  const current = await requireByIdAsync(collectionName, id);
  const updated = {
    ...current,
    ...clone(patch)
  };
  await validateRecordAsync(collectionName, updated, id);
  const collection = getCollection(collectionName);
  const result = await collection.upsert(toGenericObject(collectionName, updated));
  if (Number(result) < 1) {
    throw conflict(`${collectionName} update failed`);
  }
  return requireByIdAsync(collectionName, id);
}

async function removeAsync(collectionName, id) {
  if (!isAgcCloudDbEnabled()) {
    return remove(collectionName, id);
  }
  const current = await requireByIdAsync(collectionName, id);
  const collection = getCollection(collectionName);
  const result = await collection.delete(toGenericObject(collectionName, current));
  if (Number(result) < 1) {
    throw conflict(`${collectionName} delete failed`);
  }
  return current;
}

module.exports = {
  list,
  filter,
  findById,
  requireById,
  insert,
  update,
  remove,
  paginate,
  nextId,
  clone,
  listAsync,
  filterAsync,
  findByIdAsync,
  requireByIdAsync,
  insertAsync,
  updateAsync,
  removeAsync,
  nextIdAsync
};
