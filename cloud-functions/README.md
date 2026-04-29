# SmartGuardian Cloud Functions

This directory is the AGC Serverless backend workspace for SmartGuardian.

## Structure

- `function-manifest.json`: canonical function inventory
- `cloud-db/collections.json`: collection overview
- `cloud-db/schema.json`: field-level schema, indexes, unique keys, foreign keys
- `cloud-db/seed-data.json`: local development seed data
- `shared/`: shared router, auth, store, AGC runtime helpers
- `<domain>/contract.json`: contract for one function domain
- `<domain>/index.js`: function entry

## Domains

- `auth`
- `user`
- `student`
- `service`
- `order`
- `session`
- `attendance`
- `homework`
- `message`
- `alert`
- `report`
- `refund`
- `timeline`
- `card`
- `payment`
- `workbench`
- `agent`

## Runtime Notes

- External routes stay on `/api/v1/*`
- The frontend request layer dispatches to these domains through AGC headers
- `shared/store.js` now supports dual providers:
  - local seed store by default
  - real AGC Cloud DB when `SMARTGUARDIAN_CLOUD_DB_PROVIDER=agc`
- Route handlers now enforce token auth, role gates and domain-level parameter validation before write operations.

## AGC Cloud DB Environment

```text
SMARTGUARDIAN_CLOUD_DB_PROVIDER=agc
SMARTGUARDIAN_PROJECT_CREDENTIAL_JSON_BASE64=<base64-encoded-server-sdk-agc-apiclient-json>
SMARTGUARDIAN_CLOUD_DB_ZONE=<cloud-db-zone-name>
SMARTGUARDIAN_REGION=CN
```

Notes:

- `SMARTGUARDIAN_CLOUD_DB_ZONE` must match the actual Cloud DB Zone name created in AppGallery Connect. `clouddbzone1` is only a sample value.
- Server-side scripts must use the Server SDK credential JSON downloaded from `Project settings > Server SDK`, usually named `agc-apiclient-*.json`.
- `agconnect-services.json` is a client config for HarmonyOS app runtime and must not be used as the Cloud DB server credential.
- If the AGC console does not show a mounted credential path, encode the Server SDK JSON as base64 and configure `SMARTGUARDIAN_PROJECT_CREDENTIAL_JSON_BASE64`.

Current migration state:

- All domain handlers use async store access and keep the same route contracts when switching from local seed mode to AGC Cloud DB.
- `scripts/generate-cloud-db-migration.js` generates the ordered collection/index/relation migration plan at `cloud-functions/cloud-db/migration-plan.generated.json`.
- `scripts/apply-cloud-db-seed.js` imports or updates seed data into AGC Cloud DB once credentials and zone configuration are present.
- `scripts/cloud-functions-smoke.js` covers auth, role checks, parameter validation and response-body shape across all function domains.

## Contract Sync

These artifacts must stay aligned:

- `entry/src/main/ets/services/agc/AgcFunctionContracts.ts`
- `cloud-functions/function-manifest.json`
- `<domain>/contract.json`
- `docs/03-接口文档/openapi-full.yaml`

## Packaging for AGC Upload

```text
npm run package:agc:layered
```

The layered package task regenerates:

- `dist/agc-cloud-function-layers/smartguardian-nodejs-deps-layer.zip`
- `dist/agc-cloud-functions-layered/smartguardian-*.zip`
- `dist/agc-cloud-functions-layered/deployment-manifest.layered.json`
- `dist/smartguardian-agc-cloud-functions-layered-<yyyyMMdd>.zip`

Upload or refresh the dependency layer first, then upload each `smartguardian-*.zip` package to the matching AGC Cloud Function with entry `index.handler`.

## References

- [AGC Serverless](https://developer.huawei.com/consumer/cn/agconnect/serverless/)
- [AGC Cloud Functions](https://developer.huawei.com/consumer/cn/agconnect/cloud-function/)
- [AGC Cloud DB](https://developer.huawei.com/consumer/cn/agconnect/cloud-base/)
