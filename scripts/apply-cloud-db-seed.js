const {
  loadSeedData,
  topologicallySortCollections,
  validateArtifacts
} = require('./cloud-db-migration-lib');
const {
  loadCloudEnv,
  resolveAgcServerCredential,
  inspectJsonFile,
  isClientAgconnectConfig,
  isServerApiClientConfig
} = require('./cloud-env-loader');
const store = require('../cloud-functions/shared/store');
const { isAgcCloudDbEnabled } = require('../cloud-functions/shared/agc');

function hasArg(flag) {
  return process.argv.indexOf(flag) >= 0;
}

async function clearCollection(collectionName) {
  const items = await store.listAsync(collectionName);
  for (let i = 0; i < items.length; i++) {
    await store.removeAsync(collectionName, items[i].id);
  }
  return items.length;
}

async function upsertSeedRows(collectionName, rows, primaryKey) {
  let created = 0;
  let updated = 0;
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const recordId = row[primaryKey];
    const existing = await store.findByIdAsync(collectionName, recordId);
    if (existing) {
      await store.updateAsync(collectionName, recordId, row);
      updated += 1;
    } else {
      await store.insertAsync(collectionName, row);
      created += 1;
    }
  }
  return { created, updated };
}

async function main() {
  const loadedEnvPath = loadCloudEnv();
  const dryRun = hasArg('--dry-run');
  const reset = hasArg('--reset');
  const validation = validateArtifacts();
  const credentialPath = resolveAgcServerCredential();
  const credentialJson = credentialPath.length > 0 ? inspectJsonFile(credentialPath) : null;

  if (validation.errors.length > 0) {
    console.error('Cloud DB artifacts are invalid:');
    for (let i = 0; i < validation.errors.length; i++) {
      console.error(`- ${validation.errors[i]}`);
    }
    process.exit(1);
  }

  const orderedCollections = topologicallySortCollections(validation.schema.collections || []);
  const seedData = loadSeedData();

  if (dryRun || !isAgcCloudDbEnabled()) {
    console.log('Cloud DB seed import preview');
    if (loadedEnvPath.length > 0) {
      console.log(`Loaded environment from: ${loadedEnvPath}`);
    }
    console.log(`AGC enabled: ${isAgcCloudDbEnabled()}`);
    console.log(`Reset mode: ${reset}`);
    for (let i = 0; i < orderedCollections.length; i++) {
      const collection = orderedCollections[i];
      const rows = seedData[collection.name] || [];
      console.log(`- ${collection.name}: ${rows.length} row(s)`);
    }
    if (!dryRun && !isAgcCloudDbEnabled()) {
      console.error('AGC Cloud DB environment is not configured. Set SMARTGUARDIAN_CLOUD_DB_PROVIDER=agc, AGC_CONFIG and AGC_CLOUD_DB_ZONE.');
      process.exit(1);
    }
    return;
  }

  if (!credentialJson) {
    console.error(`AGC credential file could not be parsed: ${credentialPath}`);
    process.exit(1);
  }

  if (isClientAgconnectConfig(credentialJson)) {
    console.error(`AGC credential file is a client config, not a Server SDK credential: ${credentialPath}`);
    console.error('Download agc-apiclient-*.json from AppGallery Connect > Project settings > Server SDK and point PROJECT_CREDENTIAL or AGC_CONFIG to it.');
    process.exit(1);
  }

  if (!isServerApiClientConfig(credentialJson)) {
    console.error(`AGC credential file does not look like a valid Server SDK credential JSON: ${credentialPath}`);
    process.exit(1);
  }

  if (reset) {
    const reverseCollections = orderedCollections.slice().reverse();
    for (let i = 0; i < reverseCollections.length; i++) {
      const removed = await clearCollection(reverseCollections[i].name);
      console.log(`Reset ${reverseCollections[i].name}: removed ${removed} row(s)`);
    }
  }

  let totalCreated = 0;
  let totalUpdated = 0;
  for (let i = 0; i < orderedCollections.length; i++) {
    const collection = orderedCollections[i];
    const rows = seedData[collection.name] || [];
    const result = await upsertSeedRows(collection.name, rows, collection.primaryKey || 'id');
    totalCreated += result.created;
    totalUpdated += result.updated;
    console.log(`Seeded ${collection.name}: created ${result.created}, updated ${result.updated}`);
  }

  console.log(`Cloud DB seed import completed. Created=${totalCreated}, Updated=${totalUpdated}`);
}

main().catch((error) => {
  console.error(error && error.stack ? error.stack : String(error));
  process.exit(1);
}).then(() => {
  process.exit(0);
});
