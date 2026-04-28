const fs = require('fs');
const os = require('os');
const path = require('path');

function stripQuotes(value) {
  if (value.length >= 2) {
    const first = value.charAt(0);
    const last = value.charAt(value.length - 1);
    if ((first === '"' && last === '"') || (first === '\'' && last === '\'')) {
      return value.substring(1, value.length - 1);
    }
  }
  return value;
}

function parseEnvFile(content) {
  const parsed = {};
  const lines = content.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line.length === 0 || line.charAt(0) === '#') {
      continue;
    }
    const separatorIndex = line.indexOf('=');
    if (separatorIndex < 1) {
      continue;
    }
    const key = line.substring(0, separatorIndex).trim();
    const value = stripQuotes(line.substring(separatorIndex + 1).trim());
    parsed[key] = value;
  }
  return parsed;
}

function resolveProjectRoot() {
  return path.resolve(__dirname, '..');
}

function writeCredentialContent(content, fileName) {
  if (!content || content.length === 0) {
    return '';
  }

  try {
    JSON.parse(content);
  } catch (error) {
    return '';
  }

  const credentialDir = path.join(os.tmpdir(), 'smartguardian-agc');
  if (!fs.existsSync(credentialDir)) {
    fs.mkdirSync(credentialDir, { recursive: true });
  }

  const credentialPath = path.join(credentialDir, fileName);
  fs.writeFileSync(credentialPath, content, { encoding: 'utf8', mode: 0o600 });
  return credentialPath;
}

function decodeBase64Credential(value) {
  if (!value || value.length === 0) {
    return '';
  }

  try {
    return Buffer.from(value, 'base64').toString('utf8');
  } catch (error) {
    return '';
  }
}

function loadCloudEnv() {
  const projectRoot = resolveProjectRoot();
  const envFiles = [
    path.join(projectRoot, 'cloud-functions', '.env'),
    path.join(projectRoot, '.env')
  ];

  for (let i = 0; i < envFiles.length; i++) {
    const envPath = envFiles[i];
    if (!fs.existsSync(envPath)) {
      continue;
    }

    const parsed = parseEnvFile(fs.readFileSync(envPath, 'utf8'));
    const keys = Object.keys(parsed);
    for (let j = 0; j < keys.length; j++) {
      const key = keys[j];
      if (!process.env[key] || process.env[key].length === 0) {
        process.env[key] = parsed[key];
      }
    }
    return envPath;
  }

  return '';
}

function resolveAgcServerCredential() {
  const credentialJsonBase64 = process.env.SMARTGUARDIAN_PROJECT_CREDENTIAL_JSON_BASE64 || '';
  const credentialJson = process.env.SMARTGUARDIAN_PROJECT_CREDENTIAL_JSON || '';
  const decodedCredentialJson = decodeBase64Credential(credentialJsonBase64);
  const materializedCredential = writeCredentialContent(
    decodedCredentialJson || credentialJson,
    'project-credential.json'
  );

  if (materializedCredential.length > 0) {
    return materializedCredential;
  }

  const candidates = [
    process.env.SMARTGUARDIAN_PROJECT_CREDENTIAL || '',
    process.env.SMARTGUARDIAN_CREDENTIAL_PATH || '',
    process.env.PROJECT_CREDENTIAL || '',
    process.env.AGC_CONFIG || ''
  ];

  for (let i = 0; i < candidates.length; i++) {
    const candidate = candidates[i];
    if (!candidate || candidate.length === 0) {
      continue;
    }

    const resolved = path.resolve(candidate);
    if (fs.existsSync(resolved)) {
      return resolved;
    }
  }

  return '';
}

function inspectJsonFile(filePath) {
  try {
    const raw = fs.readFileSync(filePath, 'utf8');
    const json = JSON.parse(raw);
    return json;
  } catch (error) {
    return null;
  }
}

function isClientAgconnectConfig(json) {
  return !!json
    && typeof json.client === 'object'
    && json.client !== null
    && typeof json.client.app_id === 'string';
}

function isServerApiClientConfig(json) {
  return !!json
    && typeof json.client_id === 'string'
    && typeof json.client_secret === 'string'
    && typeof json.project_id === 'string';
}

function resolveAgcConnectPrivateKeyCredential() {
  const candidates = [
    process.env.AGC_CONNECT_PRIVATE_KEY_FILE || '',
    process.env.AGC_CONNECT_PRIVATE_KEY || ''
  ];

  for (let i = 0; i < candidates.length; i++) {
    const candidate = candidates[i];
    if (!candidate || candidate.length === 0) {
      continue;
    }

    const resolved = path.resolve(candidate);
    if (fs.existsSync(resolved)) {
      return resolved;
    }
  }

  return '';
}

function isConnectApiPrivateKeyConfig(json) {
  return !!json
    && typeof json.key_id === 'string'
    && typeof json.private_key === 'string'
    && typeof json.sub_account === 'string'
    && typeof json.token_uri === 'string';
}

module.exports = {
  loadCloudEnv,
  resolveAgcServerCredential,
  resolveAgcConnectPrivateKeyCredential,
  inspectJsonFile,
  isClientAgconnectConfig,
  isServerApiClientConfig,
  isConnectApiPrivateKeyConfig
};
