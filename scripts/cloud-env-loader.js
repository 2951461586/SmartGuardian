const fs = require('fs');
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
  const candidates = [
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

module.exports = {
  loadCloudEnv,
  resolveAgcServerCredential,
  inspectJsonFile,
  isClientAgconnectConfig,
  isServerApiClientConfig
};
