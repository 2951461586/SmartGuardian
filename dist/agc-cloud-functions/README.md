# SmartGuardian AGC Cloud Functions Layered Packages

Upload or refresh the dependency layer first:

- smartguardian-nodejs-deps-layer.zip

Then upload each smartguardian-*.zip package as the matching AGC Cloud Function.
Use entry: index.handler
Use trigger type: HTTP
Use method: POST

Common environment variables are listed in deployment-manifest.layered.json.
Do not put Server SDK private credentials or LLM API keys inside ZIP files.
