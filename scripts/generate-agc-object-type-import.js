const fs = require('fs');
const path = require('path');

const projectRoot = path.resolve(__dirname, '..');
const schemaPath = path.join(projectRoot, 'cloud-functions', 'cloud-db', 'schema.json');
const outputPath = path.join(projectRoot, 'cloud-functions', 'cloud-db', 'agc-object-types.importable.generated.json');

function parseArgs() {
  const args = process.argv.slice(2);
  let objectTypeName = '';
  let customOutputPath = '';

  for (let i = 0; i < args.length; i++) {
    const value = args[i];
    if (value.indexOf('--object=') === 0) {
      objectTypeName = value.slice('--object='.length);
      continue;
    }
    if (value.indexOf('--output=') === 0) {
      customOutputPath = value.slice('--output='.length);
    }
  }

  return {
    objectTypeName,
    customOutputPath
  };
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function isMoneyLikeField(fieldName) {
  return /amount|price|fee|cost|discount|paid|income|balance|unitPrice/i.test(fieldName);
}

function isLongTextField(fieldName, descriptor) {
  if (descriptor.type === 'array' || descriptor.type === 'object') {
    return true;
  }
  return /content|description|remark|reason|bio|notes|address|payload|attachments/i.test(fieldName);
}

function mapFieldType(fieldName, descriptor) {
  if (descriptor.type === 'boolean') {
    return 'Boolean';
  }
  if (descriptor.type === 'number') {
    if (isMoneyLikeField(fieldName)) {
      return 'Double';
    }
    return 'Integer';
  }
  if (descriptor.type === 'string') {
    if (isLongTextField(fieldName, descriptor)) {
      return 'Text';
    }
    return 'String';
  }
  if (descriptor.type === 'array' || descriptor.type === 'object') {
    return 'Text';
  }
  return 'String';
}

function buildDefaultValue(fieldName, descriptor) {
  if (descriptor.type === 'boolean') {
    return false;
  }

  if (descriptor.type === 'number') {
    if (isMoneyLikeField(fieldName)) {
      return 0;
    }
    return 0;
  }

  if (descriptor.type === 'array') {
    return '[]';
  }

  if (descriptor.type === 'object') {
    return '{}';
  }

  return '';
}

function buildFieldList(collection) {
  const fieldNames = Object.keys(collection.fields || {});
  const requiredFields = collection.required || [];
  const result = [];

  for (let i = 0; i < fieldNames.length; i++) {
    const fieldName = fieldNames[i];
    const descriptor = collection.fields[fieldName];
    const isPrimaryKey = fieldName === collection.primaryKey;
    const field = {
      fieldName,
      notNull: requiredFields.indexOf(fieldName) >= 0,
      isNeedEncrypt: false,
      belongPrimaryKey: isPrimaryKey,
      fieldType: mapFieldType(fieldName, descriptor)
    };

    if (!isPrimaryKey) {
      field.defaultValue = buildDefaultValue(fieldName, descriptor);
    }

    result.push({
      ...field
    });
  }

  return result;
}

function buildIndexes(collection) {
  const indexes = collection.indexes || [];
  const uniqueGroups = collection.unique || [];
  const result = [];
  let indexCounter = 1;

  for (let i = 0; i < indexes.length; i++) {
    const fieldName = indexes[i];
    result.push({
      indexName: `index${indexCounter}`,
      indexList: [fieldName]
    });
    indexCounter += 1;
  }

  for (let i = 0; i < uniqueGroups.length; i++) {
    const group = uniqueGroups[i];
    result.push({
      indexName: `index${indexCounter}`,
      indexList: group
    });
    indexCounter += 1;
  }

  return result;
}

function buildPermissions(collection) {
  return {
    objectTypeName: collection.name,
    permissions: [
      {
        role: 'Administrator',
        rights: ['Read', 'Upsert', 'Delete']
      }
    ]
  };
}

function buildTemplatePermissions(collection) {
  return {
    objectTypeName: collection.name,
    permissions: [
      {
        role: 'World',
        rights: ['Read']
      },
      {
        role: 'Authenticated',
        rights: ['Read', 'Upsert']
      },
      {
        role: 'Creator',
        rights: ['Read', 'Upsert', 'Delete']
      },
      {
        role: 'Administrator',
        rights: ['Read', 'Upsert', 'Delete']
      }
    ]
  };
}

function buildObjectType(collection) {
  return {
    objectTypeName: collection.name,
    indexes: buildIndexes(collection),
    fields: buildFieldList(collection)
  };
}

function main() {
  const args = parseArgs();
  const schema = readJson(schemaPath);
  const objectTypes = [];
  const strictPermissions = [];
  const templatePermissions = [];
  const allCollections = schema.collections || [];
  const selectedCollections = args.objectTypeName.length > 0
    ? allCollections.filter((collection) => collection.name === args.objectTypeName)
    : allCollections;

  if (selectedCollections.length === 0) {
    throw new Error(`Object type not found in schema: ${args.objectTypeName}`);
  }

  for (let i = 0; i < selectedCollections.length; i++) {
    const collection = selectedCollections[i];
    objectTypes.push(buildObjectType(collection));
    strictPermissions.push(buildPermissions(collection));
    templatePermissions.push(buildTemplatePermissions(collection));
  }

  const payload = {
    permissions: templatePermissions,
    objectTypes
  };
  const strictPayload = {
    permissions: strictPermissions,
    objectTypes
  };

  const resolvedOutputPath = args.customOutputPath.length > 0
    ? path.resolve(projectRoot, args.customOutputPath)
    : outputPath;
  const resolvedStrictOutputPath = args.objectTypeName.length > 0
    ? path.join(projectRoot, 'cloud-functions', 'cloud-db', `agc-object-types.importable.${args.objectTypeName}.strict-admin.generated.json`)
    : path.join(projectRoot, 'cloud-functions', 'cloud-db', 'agc-object-types.importable.strict-admin.generated.json');
  const resolvedTemplateAliasPath = args.objectTypeName.length > 0
    ? ''
    : path.join(projectRoot, 'cloud-functions', 'cloud-db', 'agc-object-types.importable.template-rights.generated.json');

  fs.writeFileSync(resolvedOutputPath, JSON.stringify(payload, null, 2) + '\n', 'utf8');
  fs.writeFileSync(resolvedStrictOutputPath, JSON.stringify(strictPayload, null, 2) + '\n', 'utf8');
  if (resolvedTemplateAliasPath.length > 0) {
    fs.writeFileSync(resolvedTemplateAliasPath, JSON.stringify(payload, null, 2) + '\n', 'utf8');
  }
  console.log(`Generated ${resolvedOutputPath}`);
}

main();
