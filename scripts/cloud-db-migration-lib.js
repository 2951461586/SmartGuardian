const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const schemaPath = path.join(repoRoot, 'cloud-functions', 'cloud-db', 'schema.json');
const collectionsPath = path.join(repoRoot, 'cloud-functions', 'cloud-db', 'collections.json');
const seedDataPath = path.join(repoRoot, 'cloud-functions', 'cloud-db', 'seed-data.json');

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function loadSchema() {
  return readJson(schemaPath);
}

function loadCollections() {
  return readJson(collectionsPath);
}

function loadSeedData() {
  return readJson(seedDataPath);
}

function toMap(items) {
  const map = {};
  for (let i = 0; i < items.length; i++) {
    map[items[i].name] = items[i];
  }
  return map;
}

function topologicallySortCollections(schemaCollections) {
  const collectionMap = toMap(schemaCollections);
  const indegree = {};
  const adjacency = {};
  const queue = [];
  const sorted = [];

  for (let i = 0; i < schemaCollections.length; i++) {
    const collection = schemaCollections[i];
    indegree[collection.name] = 0;
    adjacency[collection.name] = [];
  }

  for (let i = 0; i < schemaCollections.length; i++) {
    const collection = schemaCollections[i];
    const foreignKeys = collection.foreignKeys || [];
    for (let j = 0; j < foreignKeys.length; j++) {
      const dependency = foreignKeys[j].collection;
      if (!collectionMap[dependency]) {
        continue;
      }
      indegree[collection.name] += 1;
      adjacency[dependency].push(collection.name);
    }
  }

  const names = Object.keys(indegree).sort();
  for (let i = 0; i < names.length; i++) {
    if (indegree[names[i]] === 0) {
      queue.push(names[i]);
    }
  }

  while (queue.length > 0) {
    const current = queue.shift();
    sorted.push(collectionMap[current]);
    const nextNames = adjacency[current];
    for (let i = 0; i < nextNames.length; i++) {
      indegree[nextNames[i]] -= 1;
      if (indegree[nextNames[i]] === 0) {
        queue.push(nextNames[i]);
        queue.sort();
      }
    }
  }

  if (sorted.length !== schemaCollections.length) {
    throw new Error('Cloud DB schema has circular foreign-key dependencies');
  }

  return sorted;
}

function validateArtifacts() {
  const schema = loadSchema();
  const collections = loadCollections();
  const seedData = loadSeedData();
  const schemaCollections = schema.collections || [];
  const overviewCollections = collections.collections || [];
  const schemaMap = toMap(schemaCollections);
  const overviewMap = toMap(overviewCollections);
  const errors = [];
  const warnings = [];

  const schemaNames = Object.keys(schemaMap).sort();
  const overviewNames = Object.keys(overviewMap).sort();
  const seedNames = Object.keys(seedData).sort();

  for (let i = 0; i < schemaNames.length; i++) {
    const name = schemaNames[i];
    if (!overviewMap[name]) {
      errors.push(`collections.json missing collection '${name}'`);
    }
  }

  for (let i = 0; i < overviewNames.length; i++) {
    const name = overviewNames[i];
    if (!schemaMap[name]) {
      errors.push(`schema.json missing collection '${name}'`);
    }
  }

  for (let i = 0; i < schemaNames.length; i++) {
    const name = schemaNames[i];
    const schemaCollection = schemaMap[name];
    const overviewCollection = overviewMap[name];
    const fields = schemaCollection.fields || {};
    const schemaIndexes = schemaCollection.indexes || [];
    const overviewIndexes = overviewCollection ? (overviewCollection.indexes || []) : [];
    const fieldNames = Object.keys(fields);

    for (let j = 0; j < overviewIndexes.length; j++) {
      if (fieldNames.indexOf(overviewIndexes[j]) < 0) {
        errors.push(`collections.json index '${name}.${overviewIndexes[j]}' is not defined in schema fields`);
      }
    }

    for (let j = 0; j < schemaIndexes.length; j++) {
      if (overviewIndexes.indexOf(schemaIndexes[j]) < 0) {
        warnings.push(`collections.json does not describe schema index '${name}.${schemaIndexes[j]}'`);
      }
    }

    const foreignKeys = schemaCollection.foreignKeys || [];
    for (let j = 0; j < foreignKeys.length; j++) {
      const relation = foreignKeys[j];
      if (fieldNames.indexOf(relation.field) < 0) {
        errors.push(`schema.json foreign key '${name}.${relation.field}' is missing source field`);
      }
      if (!schemaMap[relation.collection]) {
        errors.push(`schema.json foreign key '${name}.${relation.field}' references missing collection '${relation.collection}'`);
        continue;
      }
      const refFields = Object.keys(schemaMap[relation.collection].fields || {});
      if (refFields.indexOf(relation.refField) < 0) {
        errors.push(`schema.json foreign key '${name}.${relation.field}' references missing field '${relation.collection}.${relation.refField}'`);
      }
    }
  }

  for (let i = 0; i < seedNames.length; i++) {
    if (!schemaMap[seedNames[i]]) {
      warnings.push(`seed-data.json contains collection '${seedNames[i]}' that is not declared in schema.json`);
    }
  }

  return {
    schema,
    collections,
    seedData,
    errors,
    warnings
  };
}

function buildMigrationPlan() {
  const validation = validateArtifacts();
  const schemaCollections = validation.schema.collections || [];
  const orderedCollections = topologicallySortCollections(schemaCollections);
  const planCollections = [];

  for (let i = 0; i < orderedCollections.length; i++) {
    const collection = orderedCollections[i];
    const overview = (validation.collections.collections || []).find((item) => item.name === collection.name);
    const foreignKeys = collection.foreignKeys || [];
    const seedRows = validation.seedData[collection.name] || [];
    planCollections.push({
      name: collection.name,
      primaryKey: collection.primaryKey || 'id',
      description: overview ? overview.description : '',
      dependencies: foreignKeys.map((item) => item.collection),
      indexes: collection.indexes || [],
      unique: collection.unique || [],
      foreignKeys,
      requiredFields: collection.required || [],
      seedCount: seedRows.length
    });
  }

  return {
    generatedAt: new Date().toISOString(),
    database: validation.schema.database,
    collectionCount: planCollections.length,
    collections: planCollections,
    manualSteps: [
      'Export and import AGC Cloud DB object types from AppGallery Connect Console before first remote seed.',
      'Ensure indexes and relationships in Console match cloud-functions/cloud-db/schema.json.',
      'Set SMARTGUARDIAN_CLOUD_DB_PROVIDER=agc, AGC_CONFIG and AGC_CLOUD_DB_ZONE before running the seed import script.'
    ],
    validation: {
      errors: validation.errors,
      warnings: validation.warnings
    }
  };
}

module.exports = {
  repoRoot,
  schemaPath,
  collectionsPath,
  seedDataPath,
  loadSchema,
  loadCollections,
  loadSeedData,
  topologicallySortCollections,
  validateArtifacts,
  buildMigrationPlan
};
