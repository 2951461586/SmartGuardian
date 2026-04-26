const fs = require('fs');
const path = require('path');
const { repoRoot, buildMigrationPlan } = require('./cloud-db-migration-lib');

function main() {
  const outputPath = path.join(repoRoot, 'cloud-functions', 'cloud-db', 'migration-plan.generated.json');
  const plan = buildMigrationPlan();
  fs.writeFileSync(outputPath, `${JSON.stringify(plan, null, 2)}\n`, 'utf8');

  console.log(`Cloud DB migration plan written to ${outputPath}`);
  console.log(`Collections: ${plan.collectionCount}`);
  console.log(`Validation warnings: ${plan.validation.warnings.length}`);

  if (plan.validation.errors.length > 0) {
    console.error('Validation errors:');
    for (let i = 0; i < plan.validation.errors.length; i++) {
      console.error(`- ${plan.validation.errors[i]}`);
    }
    process.exit(1);
  }
}

main();
