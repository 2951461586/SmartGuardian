const crypto = require('crypto');
const https = require('https');
const querystring = require('querystring');
const {
  loadCloudEnv,
  resolveAgcConnectPrivateKeyCredential,
  inspectJsonFile,
  isConnectApiPrivateKeyConfig
} = require('./cloud-env-loader');

function base64UrlEncode(input) {
  return Buffer.from(input)
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

function signJwtPayload(unsignedToken, privateKey, algorithm) {
  if (algorithm === 'PS256') {
    const signature = crypto.sign('sha256', Buffer.from(unsignedToken), {
      key: privateKey,
      padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
      saltLength: crypto.constants.RSA_PSS_SALTLEN_DIGEST
    });
    return base64UrlEncode(signature);
  }

  const signer = crypto.createSign('RSA-SHA256');
  signer.update(unsignedToken);
  signer.end();
  return base64UrlEncode(signer.sign(privateKey));
}

function createAssertion(credential, options) {
  const now = Math.floor(Date.now() / 1000);
  const algorithm = options.algorithm || 'RS256';
  const expiresIn = options.expiresIn || 3600;
  const header = {
    alg: algorithm,
    typ: 'JWT',
    kid: credential.key_id
  };
  const payload = {
    iss: credential.sub_account,
    sub: credential.sub_account,
    aud: credential.token_uri,
    iat: now,
    exp: now + expiresIn
  };
  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const unsignedToken = `${encodedHeader}.${encodedPayload}`;
  const signature = signJwtPayload(unsignedToken, credential.private_key, algorithm);
  return `${unsignedToken}.${signature}`;
}

function requestAccessToken(credential, assertion) {
  const body = querystring.stringify({
    grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    assertion
  });
  const tokenUrl = new URL(credential.token_uri);
  const requestOptions = {
    method: 'POST',
    hostname: tokenUrl.hostname,
    path: `${tokenUrl.pathname}${tokenUrl.search}`,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(body)
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(requestOptions, (res) => {
      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => {
        const responseBody = Buffer.concat(chunks).toString('utf8');
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            resolve(JSON.parse(responseBody));
          } catch (error) {
            reject(new Error('AGC token response is not valid JSON'));
          }
          return;
        }
        reject(new Error(`AGC token request failed: HTTP ${res.statusCode} ${responseBody}`));
      });
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

function mask(value) {
  if (!value || value.length <= 8) {
    return '***';
  }
  return `${value.substring(0, 4)}***${value.substring(value.length - 4)}`;
}

function loadCredentialFromArgs(args) {
  const keyIndex = args.indexOf('--key');
  if (keyIndex >= 0 && args.length > keyIndex + 1) {
    const filePath = args[keyIndex + 1];
    return {
      filePath,
      credential: inspectJsonFile(filePath)
    };
  }

  loadCloudEnv();
  const filePath = resolveAgcConnectPrivateKeyCredential();
  return {
    filePath,
    credential: filePath.length > 0 ? inspectJsonFile(filePath) : null
  };
}

async function main() {
  const args = process.argv.slice(2);
  const loaded = loadCredentialFromArgs(args);
  if (!loaded.filePath || loaded.filePath.length === 0) {
    throw new Error('AGC Connect private key file is missing. Set AGC_CONNECT_PRIVATE_KEY_FILE or pass --key <file>.');
  }
  if (!isConnectApiPrivateKeyConfig(loaded.credential)) {
    throw new Error('AGC Connect private key file is invalid. Required fields: key_id, private_key, sub_account, token_uri.');
  }

  const algorithm = process.env.AGC_CONNECT_JWT_ALG || 'RS256';
  const assertion = createAssertion(loaded.credential, { algorithm });

  console.log('AGC Connect private key credential is valid.');
  console.log(`  file: ${loaded.filePath}`);
  console.log(`  key_id: ${mask(loaded.credential.key_id)}`);
  console.log(`  sub_account: ${loaded.credential.sub_account}`);
  console.log(`  token_uri: ${loaded.credential.token_uri}`);
  console.log(`  jwt_alg: ${algorithm}`);

  if (args.indexOf('--token') < 0) {
    console.log('Token request skipped. Pass --token to request an access token.');
    return;
  }

  const tokenResponse = await requestAccessToken(loaded.credential, assertion);
  console.log('AGC Connect access token acquired.');
  console.log(`  token_type: ${tokenResponse.token_type || ''}`);
  console.log(`  expires_in: ${tokenResponse.expires_in || ''}`);
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
}

module.exports = {
  createAssertion,
  requestAccessToken
};
