const fs = require('fs');
const https = require('https');
const path = require('path');
const {
  loadCloudEnv,
  resolveAgcConnectPrivateKeyCredential,
  inspectJsonFile,
  isConnectApiPrivateKeyConfig
} = require('./cloud-env-loader');
const {
  createAssertion,
  requestAccessToken,
  requestClientCredentialsAccessToken
} = require('./agc-connect-api-client');

function mask(value) {
  if (!value || value.length <= 8) {
    return '***';
  }
  return `${value.substring(0, 4)}***${value.substring(value.length - 4)}`;
}

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    return null;
  }
}

function resolveProjectRoot() {
  return path.resolve(__dirname, '..');
}

function resolveAgcClientConfig() {
  return readJson(path.join(resolveProjectRoot(), 'entry', 'src', 'main', 'resources', 'rawfile', 'agconnect-services.json'));
}

function resolveServerCredential() {
  const candidates = [
    process.env.SMARTGUARDIAN_PROJECT_CREDENTIAL || '',
    process.env.SMARTGUARDIAN_CREDENTIAL_PATH || '',
    process.env.PROJECT_CREDENTIAL || '',
    process.env.AGC_CONFIG || ''
  ];
  for (let i = 0; i < candidates.length; i++) {
    const candidate = candidates[i];
    if (candidate && fs.existsSync(candidate)) {
      return readJson(candidate);
    }
  }
  return null;
}

function firstEnvValue(keys) {
  for (let i = 0; i < keys.length; i++) {
    const value = process.env[keys[i]] || '';
    if (value.length > 0) {
      return value;
    }
  }
  return '';
}

function resolveConnectApiClient(serverCredential) {
  const explicitClientId = firstEnvValue([
    'AGC_CONNECT_CLIENT_ID',
    'AGC_API_CLIENT_ID',
    'HUAWEI_APPGALLERY_CONNECT_CLIENT_ID'
  ]);
  const explicitClientSecret = firstEnvValue([
    'AGC_CONNECT_CLIENT_SECRET',
    'AGC_API_CLIENT_SECRET',
    'HUAWEI_APPGALLERY_CONNECT_CLIENT_SECRET'
  ]);
  if (explicitClientId.length > 0 || explicitClientSecret.length > 0) {
    return {
      clientId: explicitClientId,
      clientSecret: explicitClientSecret,
      source: 'env'
    };
  }

  if (serverCredential && typeof serverCredential.client_id === 'string' && typeof serverCredential.client_secret === 'string') {
    return {
      clientId: serverCredential.client_id,
      clientSecret: serverCredential.client_secret,
      source: 'project_credential'
    };
  }

  return {
    clientId: '',
    clientSecret: '',
    source: 'none'
  };
}

function httpRequest(method, url, token, clientId) {
  const target = new URL(url);
  const headers = {
    Authorization: `Bearer ${token}`,
    Accept: 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'SmartGuardian-AGC-Discovery/1.0'
  };
  if (clientId && clientId.length > 0) {
    headers.client_id = clientId;
  }

  const options = {
    method,
    hostname: target.hostname,
    path: `${target.pathname}${target.search}`,
    headers
  };

  return new Promise((resolve) => {
    const req = https.request(options, (res) => {
      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => {
        const body = Buffer.concat(chunks).toString('utf8');
        resolve({
          statusCode: res.statusCode || 0,
          headers: res.headers,
          body
        });
      });
    });
    req.on('error', (error) => {
      resolve({
        statusCode: 0,
        headers: {},
        body: error.message
      });
    });
    req.setTimeout(20000, () => {
      req.destroy(new Error('request timeout'));
    });
    req.end();
  });
}

function summarizeBody(body) {
  if (!body) {
    return '';
  }
  const text = String(body).replace(/\s+/g, ' ').trim();
  if (text.length <= 280) {
    return text;
  }
  return `${text.substring(0, 280)}...`;
}

function tryParseJson(body) {
  try {
    return JSON.parse(body);
  } catch (error) {
    return null;
  }
}

function getArraySize(value) {
  if (Array.isArray(value)) {
    return value.length;
  }
  if (value && Array.isArray(value.data)) {
    return value.data.length;
  }
  if (value && Array.isArray(value.apps)) {
    return value.apps.length;
  }
  if (value && Array.isArray(value.functions)) {
    return value.functions.length;
  }
  if (value && Array.isArray(value.layers)) {
    return value.layers.length;
  }
  if (value && value.data && Array.isArray(value.data.list)) {
    return value.data.list.length;
  }
  if (value && Array.isArray(value.result)) {
    return value.result.length;
  }
  return -1;
}

function buildCandidates(projectId, appId, packageName) {
  const host = 'https://connect-api.cloud.huawei.com';
  const encodedPackage = encodeURIComponent(packageName || '');
  const encodedProject = encodeURIComponent(projectId || '');
  const encodedApp = encodeURIComponent(appId || '');

  return [
    {
      group: 'publish',
      label: 'appid-list by HarmonyOS packageName',
      method: 'GET',
      url: `${host}/api/publish/v2/appid-list?packageName=${encodedPackage}&packageTypes=7`
    },
    {
      group: 'publish',
      label: 'appid-list by packageName',
      method: 'GET',
      url: `${host}/api/publish/v2/appid-list?packageName=${encodedPackage}`
    },
    {
      group: 'publish',
      label: 'app info by appId',
      method: 'GET',
      url: `${host}/api/publish/v2/app-info?appId=${encodedApp}`
    },
    {
      group: 'publish',
      label: 'app info by appid',
      method: 'GET',
      url: `${host}/api/publish/v2/app-info?appid=${encodedApp}`
    },
    {
      group: 'project',
      label: 'project apps',
      method: 'GET',
      url: `${host}/api/agc/v1/projects/${encodedProject}/apps`
    },
    {
      group: 'project',
      label: 'project detail',
      method: 'GET',
      url: `${host}/api/agc/v1/projects/${encodedProject}`
    },
    {
      group: 'cloud-functions',
      label: 'functions v1',
      method: 'GET',
      url: `${host}/api/agc/cloudfunctions/v1/projects/${encodedProject}/functions`
    },
    {
      group: 'cloud-functions',
      label: 'functions v2',
      method: 'GET',
      url: `${host}/api/agc/cloudfunctions/v2/projects/${encodedProject}/functions`
    },
    {
      group: 'cloud-functions',
      label: 'serverless functions',
      method: 'GET',
      url: `${host}/api/agc/serverless/v1/projects/${encodedProject}/functions`
    },
    {
      group: 'cloud-functions',
      label: 'function list',
      method: 'GET',
      url: `${host}/api/cloudfunctions/v1/projects/${encodedProject}/functions`
    },
    {
      group: 'layers',
      label: 'layers v1',
      method: 'GET',
      url: `${host}/api/agc/cloudfunctions/v1/projects/${encodedProject}/layers`
    },
    {
      group: 'layers',
      label: 'layers v2',
      method: 'GET',
      url: `${host}/api/agc/cloudfunctions/v2/projects/${encodedProject}/layers`
    },
    {
      group: 'layers',
      label: 'serverless layers',
      method: 'GET',
      url: `${host}/api/agc/serverless/v1/projects/${encodedProject}/layers`
    }
  ];
}

async function main() {
  loadCloudEnv();
  const privateKeyFile = resolveAgcConnectPrivateKeyCredential();
  const privateCredential = privateKeyFile ? inspectJsonFile(privateKeyFile) : null;
  const clientConfig = resolveAgcClientConfig() || {};
  const serverCredential = resolveServerCredential() || {};
  const connectApiClient = resolveConnectApiClient(serverCredential);
  const hasClientCredentials = connectApiClient.clientId.length > 0 && connectApiClient.clientSecret.length > 0;

  let tokenResponse = null;
  let tokenClientId = connectApiClient.clientId;
  let tokenSource = 'client_credentials';
  if (hasClientCredentials) {
    tokenResponse = await requestClientCredentialsAccessToken(connectApiClient.clientId, connectApiClient.clientSecret);
  } else {
    if (!isConnectApiPrivateKeyConfig(privateCredential)) {
      throw new Error('AGC Connect credentials are missing. Set AGC_CONNECT_CLIENT_ID/AGC_CONNECT_CLIENT_SECRET for Publishing API, or AGC_CONNECT_PRIVATE_KEY_FILE for JWT probing.');
    }
    const assertion = createAssertion(privateCredential, {
      algorithm: process.env.AGC_CONNECT_JWT_ALG || 'RS256'
    });
    tokenResponse = await requestAccessToken(privateCredential, assertion);
    tokenClientId = privateCredential.key_id;
    tokenSource = 'jwt_private_key';
  }
  if (hasClientCredentials && connectApiClient.source === 'project_credential') {
    tokenSource = 'client_credentials_project_credential';
  }
  const accessToken = tokenResponse.access_token || '';
  if (!accessToken) {
    throw new Error('AGC Connect access token response did not include access_token.');
  }

  const appId = clientConfig.client ? clientConfig.client.app_id || '' : '';
  const packageName = clientConfig.client ? clientConfig.client.package_name || '' : '';
  const privateProjectId = privateCredential && privateCredential.project_id ? privateCredential.project_id : '';
  const projectId = serverCredential.project_id || privateProjectId || '';

  console.log('AGC Connect discovery context');
  console.log(`  token_source: ${tokenSource}`);
  console.log(`  client_id: ${mask(tokenClientId)}`);
  if (privateKeyFile.length > 0 && isConnectApiPrivateKeyConfig(privateCredential)) {
    console.log(`  private_key_file: ${privateKeyFile}`);
    console.log(`  key_id: ${mask(privateCredential.key_id)}`);
    console.log(`  sub_account: ${privateCredential.sub_account}`);
  }
  console.log(`  project_id: ${mask(projectId)}`);
  console.log(`  app_id: ${mask(appId)}`);
  console.log(`  package_name: ${packageName}`);
  console.log('');

  const candidates = buildCandidates(projectId, appId, packageName);
  const opened = [];
  for (let i = 0; i < candidates.length; i++) {
    const candidate = candidates[i];
    const response = await httpRequest(candidate.method, candidate.url, accessToken, tokenClientId);
    const json = tryParseJson(response.body);
    const size = getArraySize(json);
    const statusText = response.statusCode >= 200 && response.statusCode < 300 ? 'OPEN' : 'BLOCKED';
    console.log(`[${statusText}] ${candidate.group} :: ${candidate.label}`);
    console.log(`  ${candidate.method} ${candidate.url.replace(projectId, mask(projectId)).replace(appId, mask(appId))}`);
    console.log(`  status: ${response.statusCode}`);
    if (size >= 0) {
      console.log(`  resource_count: ${size}`);
    }
    const summary = summarizeBody(response.body);
    if (summary.length > 0) {
      console.log(`  body: ${summary}`);
    }
    console.log('');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      opened.push(candidate);
    }
  }

  console.log('Discovery summary');
  console.log(`  endpoints_checked: ${candidates.length}`);
  console.log(`  endpoints_open: ${opened.length}`);
  if (opened.length > 0) {
    console.log(`  open_groups: ${Array.from(new Set(opened.map((item) => item.group))).join(', ')}`);
  } else {
    console.log('  open_groups: none');
  }
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error && error.stack ? error.stack : String(error));
    process.exit(1);
  });
}
