const https = require('https');
const store = require('./store');
const { nowIso } = require('./time');

function asNumber(value) {
  const numberValue = Number(value || 0);
  return Number.isNaN(numberValue) ? 0 : numberValue;
}

function isPushConfigured() {
  return !!process.env.HUAWEI_PUSH_APP_ID &&
    !!process.env.HUAWEI_PUSH_CLIENT_ID &&
    !!process.env.HUAWEI_PUSH_CLIENT_SECRET;
}

function getDeliveryMode() {
  return process.env.SMARTGUARDIAN_PUSH_DELIVERY_MODE || 'auto';
}

function getPushDeliveryConfig() {
  const appId = process.env.HUAWEI_PUSH_APP_ID || '';
  const clientId = process.env.HUAWEI_PUSH_CLIENT_ID || '';
  const clientSecret = process.env.HUAWEI_PUSH_CLIENT_SECRET || '';
  const deliveryMode = getDeliveryMode();
  return {
    deliveryMode,
    huaweiPushConfigured: isPushConfigured(),
    realDeliveryReady: deliveryMode === 'real' && isPushConfigured(),
    tokenUrl: process.env.HUAWEI_PUSH_TOKEN_URL || 'https://oauth-login.cloud.huawei.com/oauth2/v3/token',
    sendUrl: process.env.HUAWEI_PUSH_SEND_URL || (appId.length > 0 ? `https://push-api.cloud.huawei.com/v1/${appId}/messages:send` : ''),
    appIdConfigured: appId.length > 0,
    clientIdConfigured: clientId.length > 0,
    clientSecretConfigured: clientSecret.length > 0
  };
}

function requestJsonAsync(url, options, body) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const request = https.request({
      hostname: parsed.hostname,
      path: `${parsed.pathname}${parsed.search}`,
      method: options.method || 'POST',
      headers: options.headers || {}
    }, (response) => {
      let raw = '';
      response.on('data', (chunk) => {
        raw += chunk.toString('utf8');
      });
      response.on('end', () => {
        let data = {};
        if (raw.length > 0) {
          try {
            data = JSON.parse(raw);
          } catch (error) {
            data = { raw };
          }
        }
        resolve({
          statusCode: response.statusCode || 0,
          data
        });
      });
    });
    request.on('error', reject);
    if (body) {
      request.write(body);
    }
    request.end();
  });
}

async function getHuaweiAccessTokenAsync() {
  const tokenUrl = process.env.HUAWEI_PUSH_TOKEN_URL || 'https://oauth-login.cloud.huawei.com/oauth2/v3/token';
  const body = new URLSearchParams({
    grant_type: 'client_credentials',
    client_id: process.env.HUAWEI_PUSH_CLIENT_ID || '',
    client_secret: process.env.HUAWEI_PUSH_CLIENT_SECRET || ''
  }).toString();
  const response = await requestJsonAsync(tokenUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  }, body);
  if (response.statusCode < 200 || response.statusCode >= 300 || !response.data.access_token) {
    throw new Error(`Huawei Push token request failed: ${response.statusCode} ${JSON.stringify(response.data)}`);
  }
  return response.data.access_token;
}

function buildHuaweiPushBody(job, token) {
  return JSON.stringify({
    validate_only: false,
    message: {
      token: [token],
      notification: {
        title: job.title || '',
        body: job.content || ''
      },
      data: JSON.stringify(job.payload || {})
    }
  });
}

async function sendHuaweiPushAsync(job, token) {
  const appId = process.env.HUAWEI_PUSH_APP_ID || '';
  const sendUrl = process.env.HUAWEI_PUSH_SEND_URL || `https://push-api.cloud.huawei.com/v1/${appId}/messages:send`;
  const accessToken = await getHuaweiAccessTokenAsync();
  const response = await requestJsonAsync(sendUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`
    }
  }, buildHuaweiPushBody(job, token));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw new Error(`Huawei Push send failed: ${response.statusCode} ${JSON.stringify(response.data)}`);
  }
  if (response.data && response.data.code && String(response.data.code) !== '80000000') {
    throw new Error(`Huawei Push rejected: ${JSON.stringify(response.data)}`);
  }
  return response.data;
}

async function sendNotificationAsync(job, session) {
  const provider = session.notificationProvider || job.provider || '';
  const token = session.notificationToken || '';
  if (token.length === 0) {
    return {
      success: false,
      simulated: false,
      errorMessage: 'notification token is empty'
    };
  }

  const mode = getDeliveryMode();
  const shouldUseHuaweiPush = provider === 'PUSH_KIT' && isPushConfigured() && mode !== 'simulated';
  if (!shouldUseHuaweiPush) {
    if (mode === 'real' && provider === 'PUSH_KIT') {
      return {
        success: false,
        simulated: false,
        errorMessage: 'Huawei Push credentials are not configured'
      };
    }
    return {
      success: true,
      simulated: true,
      errorMessage: ''
    };
  }

  try {
    await sendHuaweiPushAsync(job, token);
    return {
      success: true,
      simulated: false,
      errorMessage: ''
    };
  } catch (error) {
    return {
      success: false,
      simulated: false,
      errorMessage: String(error)
    };
  }
}

async function getJobSessionsAsync(job) {
  return store.filterAsync('user_sessions', (item) => {
    return asNumber(item.userId) === asNumber(job.userId) &&
      item.sessionStatus === 'ACTIVE' &&
      item.notificationToken &&
      item.notificationToken.length > 0;
  });
}

async function ensureReceiptsAsync(job, sessions) {
  const receipts = await store.filterAsync('notification_delivery_receipts', (item) => asNumber(item.jobId) === asNumber(job.id));
  const created = [];
  for (let i = 0; i < sessions.length; i++) {
    let exists = false;
    for (let j = 0; j < receipts.length; j++) {
      if (asNumber(receipts[j].sessionId) === asNumber(sessions[i].id)) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      created.push(await store.insertAsync('notification_delivery_receipts', {
        jobId: job.id,
        userId: job.userId,
        sessionId: sessions[i].id,
        deviceId: sessions[i].deviceId || '',
        provider: sessions[i].notificationProvider || job.provider || '',
        status: 'PENDING',
        deliveredAt: '',
        errorMessage: '',
        createdAt: nowIso(),
        updatedAt: nowIso()
      }));
    }
  }
  return receipts.concat(created);
}

function shouldProcessJob(job) {
  if (job.status !== 'PENDING' && job.status !== 'FAILED') {
    return false;
  }
  if (job.nextRetryAt && String(job.nextRetryAt).length > 0) {
    return String(job.nextRetryAt) <= nowIso();
  }
  return true;
}

function nextRetryAt(attempts) {
  const delaySeconds = Math.min(300, Math.pow(2, Math.max(0, attempts - 1)) * 30);
  return new Date(Date.now() + delaySeconds * 1000).toISOString();
}

async function processNotificationJobAsync(job) {
  const now = nowIso();
  const attempts = asNumber(job.attempts) + 1;
  const sessions = await getJobSessionsAsync(job);
  if (sessions.length === 0) {
    return store.updateAsync('notification_jobs', job.id, {
      status: 'NO_ENDPOINT',
      attempts,
      lastError: 'no active notification endpoint',
      updatedAt: now
    });
  }

  await ensureReceiptsAsync(job, sessions);
  let successCount = 0;
  let lastError = '';
  for (let i = 0; i < sessions.length; i++) {
    const sendResult = await sendNotificationAsync(job, sessions[i]);
    const receiptRows = await store.filterAsync('notification_delivery_receipts', (item) => {
      return asNumber(item.jobId) === asNumber(job.id) && asNumber(item.sessionId) === asNumber(sessions[i].id);
    });
    const receiptStatus = sendResult.success ? 'SENT' : 'FAILED';
    const deliveredAt = sendResult.success ? nowIso() : '';
    const errorMessage = sendResult.simulated ? 'simulated delivery' : sendResult.errorMessage;
    if (sendResult.success) {
      successCount += 1;
    } else {
      lastError = sendResult.errorMessage;
    }
    for (let j = 0; j < receiptRows.length; j++) {
      await store.updateAsync('notification_delivery_receipts', receiptRows[j].id, {
        provider: sessions[i].notificationProvider || job.provider || '',
        status: receiptStatus,
        deliveredAt,
        errorMessage,
        updatedAt: nowIso()
      });
    }
  }

  if (successCount > 0) {
    return store.updateAsync('notification_jobs', job.id, {
      status: 'SENT',
      attempts,
      nextRetryAt: '',
      lastError,
      updatedAt: nowIso()
    });
  }

  const maxAttempts = asNumber(job.maxAttempts || 3);
  return store.updateAsync('notification_jobs', job.id, {
    status: attempts >= maxAttempts ? 'FAILED' : 'PENDING',
    attempts,
    nextRetryAt: attempts >= maxAttempts ? '' : nextRetryAt(attempts),
    lastError: lastError || 'notification delivery failed',
    updatedAt: nowIso()
  });
}

async function processPendingNotificationJobsAsync(limit) {
  const max = Number(limit || 20);
  const jobs = await store.filterAsync('notification_jobs', shouldProcessJob);
  jobs.sort((left, right) => String(left.createdAt || '').localeCompare(String(right.createdAt || '')));
  const results = [];
  for (let i = 0; i < jobs.length && i < max; i++) {
    results.push(await processNotificationJobAsync(jobs[i]));
  }
  return results;
}

module.exports = {
  getPushDeliveryConfig,
  isPushConfigured,
  processNotificationJobAsync,
  processPendingNotificationJobsAsync,
  sendNotificationAsync
};
