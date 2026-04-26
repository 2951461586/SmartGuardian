const fs = require('fs');
const path = require('path');

const projectRoot = path.resolve(__dirname, '..');
const schemaPath = path.join(projectRoot, 'cloud-functions', 'cloud-db', 'schema.json');
const outputPath = path.join(projectRoot, 'cloud-functions', 'cloud-db', 'agc-object-types.generated.json');

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function isMoneyLikeField(fieldName) {
  return /amount|price|fee|cost|discount|paid|income|balance/i.test(fieldName);
}

function isCountLikeField(fieldName) {
  return /count|capacity|quantity|id|no$/i.test(fieldName);
}

function mapFieldType(fieldName, descriptor) {
  if (descriptor.type === 'string') {
    return {
      sourceType: 'string',
      agcRecommendedType: 'String',
      storageMode: 'native'
    };
  }

  if (descriptor.type === 'boolean') {
    return {
      sourceType: 'boolean',
      agcRecommendedType: 'Boolean',
      storageMode: 'native'
    };
  }

  if (descriptor.type === 'number') {
    if (isMoneyLikeField(fieldName)) {
      return {
        sourceType: 'number',
        agcRecommendedType: 'Double',
        storageMode: 'native',
        note: 'Money-like numeric field. Prefer Double in AGC Cloud DB.'
      };
    }

    if (isCountLikeField(fieldName)) {
      return {
        sourceType: 'number',
        agcRecommendedType: 'Integer',
        storageMode: 'native',
        note: 'Identifier or count-like numeric field. Prefer Integer in AGC Cloud DB.'
      };
    }

    return {
      sourceType: 'number',
      agcRecommendedType: 'Integer',
      alternativeTypes: ['Double'],
      storageMode: 'native',
      note: 'Defaulted to Integer. Switch to Double if this field needs decimals.'
    };
  }

  if (descriptor.type === 'array') {
    return {
      sourceType: 'array',
      agcRecommendedType: 'String',
      storageMode: 'json-string',
      note: 'Serialize arrays with JSON.stringify before writing to Cloud DB.'
    };
  }

  if (descriptor.type === 'object') {
    return {
      sourceType: 'object',
      agcRecommendedType: 'String',
      storageMode: 'json-string',
      note: 'Serialize objects with JSON.stringify before writing to Cloud DB.'
    };
  }

  return {
    sourceType: descriptor.type,
    agcRecommendedType: 'String',
    storageMode: 'manual-review',
    note: 'Unknown source type. Review manually before creating Cloud DB object type.'
  };
}

function buildObjectType(collection) {
  const fieldNames = Object.keys(collection.fields || {});
  const requiredFields = collection.required || [];
  const indexes = collection.indexes || [];
  const uniqueGroups = collection.unique || [];
  const foreignKeys = collection.foreignKeys || [];

  const fields = [];
  for (let i = 0; i < fieldNames.length; i++) {
    const fieldName = fieldNames[i];
    const descriptor = collection.fields[fieldName];
    const typeInfo = mapFieldType(fieldName, descriptor);
    const uniqueWith = [];

    for (let j = 0; j < uniqueGroups.length; j++) {
      const group = uniqueGroups[j];
      if (group.indexOf(fieldName) >= 0) {
        uniqueWith.push(group);
      }
    }

    let relation = null;
    for (let j = 0; j < foreignKeys.length; j++) {
      if (foreignKeys[j].field === fieldName) {
        relation = {
          collection: foreignKeys[j].collection,
          refField: foreignKeys[j].refField
        };
        break;
      }
    }

    fields.push({
      name: fieldName,
      primaryKey: fieldName === collection.primaryKey,
      required: requiredFields.indexOf(fieldName) >= 0,
      indexed: indexes.indexOf(fieldName) >= 0,
      enumValues: descriptor.enum || [],
      uniqueGroups: uniqueWith,
      relation,
      ...typeInfo
    });
  }

  return {
    name: collection.name,
    primaryKey: collection.primaryKey || 'id',
    indexes,
    uniqueGroups,
    foreignKeys,
    defaultPermissions: {
      everyone: {
        query: false,
        upsert: false,
        delete: false
      },
      authenticatedUsers: {
        query: false,
        upsert: false,
        delete: false
      },
      dataCreator: {
        query: false,
        upsert: false,
        delete: false
      },
      administrator: {
        query: true,
        upsert: true,
        delete: true
      }
    },
    fields
  };
}

function main() {
  const schema = readJson(schemaPath);
  const objectTypes = [];
  for (let i = 0; i < (schema.collections || []).length; i++) {
    objectTypes.push(buildObjectType(schema.collections[i]));
  }

  const payload = {
    generatedAt: new Date().toISOString(),
    sourceSchema: 'cloud-functions/cloud-db/schema.json',
    database: schema.database || 'smartguardian-cloud-db',
    zoneHint: 'ClouddbDev',
    usage: [
      'This file is a generated reference for creating AGC Cloud DB object types in AppGallery Connect Console.',
      'Huawei official docs confirm Cloud DB object types are created and managed in Console. This file is not presented as an official import payload format.',
      'Fields marked storageMode=json-string should be created as String and written with JSON.stringify / read with JSON.parse.',
      'defaultPermissions assumes the app accesses Cloud DB only through Cloud Functions and Server SDK. Keep client roles closed unless you intentionally expose direct Cloud DB access.'
    ],
    objectTypeCount: objectTypes.length,
    objectTypes
  };

  fs.writeFileSync(outputPath, JSON.stringify(payload, null, 2) + '\n', 'utf8');
  console.log(`Generated ${outputPath}`);
}

main();
