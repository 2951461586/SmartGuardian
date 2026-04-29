const store = require('./store');
const { nowIso } = require('./time');
const {
  buildTodayStatusCardAsync,
  buildAbnormalAlertCardAsync
} = require('./read-models');
const { processPendingNotificationJobsAsync } = require('./push');

function asNumber(value) {
  const numberValue = Number(value || 0);
  return Number.isNaN(numberValue) ? 0 : numberValue;
}

async function emitDomainEventAsync(event) {
  const now = nowIso();
  return store.insertAsync('domain_events', {
    eventType: event.eventType || 'UNKNOWN',
    bizType: event.bizType || '',
    bizId: asNumber(event.bizId),
    studentId: asNumber(event.studentId),
    userId: asNumber(event.userId),
    actorUserId: asNumber(event.actorUserId),
    payload: event.payload || {},
    status: 'PENDING',
    attempts: 0,
    lastError: '',
    processedAt: '',
    createdAt: now,
    updatedAt: now
  });
}

async function getStudentAsync(studentId) {
  if (asNumber(studentId) <= 0) {
    return null;
  }
  return store.findByIdAsync('students', asNumber(studentId));
}

async function getGuardianUserIdsAsync(studentId) {
  const ids = [];
  const student = await getStudentAsync(studentId);
  if (student && asNumber(student.guardianUserId) > 0) {
    ids.push(asNumber(student.guardianUserId));
  }

  const relations = await store.filterAsync('student_guardians', (item) => asNumber(item.studentId) === asNumber(studentId));
  for (let i = 0; i < relations.length; i++) {
    const userId = asNumber(relations[i].userId);
    if (userId > 0 && ids.indexOf(userId) < 0) {
      ids.push(userId);
    }
  }
  return ids;
}

async function getActiveAdminUserIdsAsync() {
  const users = await store.filterAsync('users', (item) => item.status === 'ACTIVE' && item.roleType === 'ADMIN');
  const ids = [];
  for (let i = 0; i < users.length; i++) {
    ids.push(asNumber(users[i].id));
  }
  return ids;
}

function resolveMessage(event) {
  const payload = event.payload || {};
  if (event.eventType === 'ATTENDANCE_SIGNED_IN') {
    return {
      msgType: 'ATTENDANCE',
      title: payload.abnormalFlag ? '学生迟到签到提醒' : '学生已签到',
      content: payload.abnormalFlag ? '学生已完成迟到签到，请关注现场情况。' : '学生已安全到达并完成签到。',
      bizType: 'ATTENDANCE'
    };
  }
  if (event.eventType === 'ATTENDANCE_SIGNED_OUT') {
    return {
      msgType: 'ATTENDANCE',
      title: '学生已签退',
      content: '学生已完成签退，请留意接回状态。',
      bizType: 'ATTENDANCE'
    };
  }
  if (event.eventType === 'LEAVE_SUBMITTED') {
    return {
      msgType: 'LEAVE',
      title: '新的请假申请',
      content: '有新的托管请假申请待处理。',
      bizType: 'LEAVE'
    };
  }
  if (event.eventType === 'HOMEWORK_FEEDBACK_SUBMITTED') {
    return {
      msgType: 'HOMEWORK',
      title: '老师提交了作业反馈',
      content: '请查看孩子今日作业辅导反馈。',
      bizType: 'HOMEWORK'
    };
  }
  if (event.eventType === 'REFUND_CREATED') {
    return {
      msgType: 'REFUND',
      title: '退款申请已提交',
      content: '退款申请已进入审核流程。',
      bizType: 'REFUND'
    };
  }
  return {
    msgType: 'SYSTEM',
    title: '托管状态更新',
    content: '托管业务状态已更新。',
    bizType: event.bizType || 'SYSTEM'
  };
}

async function resolveRecipientsAsync(event) {
  if (event.userId && asNumber(event.userId) > 0) {
    return [asNumber(event.userId)];
  }
  if (event.eventType === 'LEAVE_SUBMITTED') {
    return getActiveAdminUserIdsAsync();
  }
  if (event.studentId && asNumber(event.studentId) > 0) {
    return getGuardianUserIdsAsync(event.studentId);
  }
  return getActiveAdminUserIdsAsync();
}

async function createMessagesAsync(event, recipientIds) {
  const message = resolveMessage(event);
  const now = nowIso();
  for (let i = 0; i < recipientIds.length; i++) {
    await store.insertAsync('messages', {
      userId: recipientIds[i],
      msgType: message.msgType,
      title: message.title,
      content: message.content,
      bizType: message.bizType,
      bizId: asNumber(event.bizId),
      readStatus: false,
      readAt: '',
      createdAt: now,
      updatedAt: now
    });
  }
}

async function getNotificationPreferencesAsync(userId) {
  const rows = await store.filterAsync('user_notification_preferences', (item) => asNumber(item.userId) === asNumber(userId));
  if (rows.length > 0) {
    return rows[0];
  }
  return {
    userId,
    enabled: true,
    quietStartTime: '',
    quietEndTime: '',
    channels: ['PUSH', 'IN_APP']
  };
}

function isQuietNow(preferences) {
  if (!preferences.quietStartTime || !preferences.quietEndTime) {
    return false;
  }
  const now = new Date();
  const hour = now.getHours().toString().padStart(2, '0');
  const minute = now.getMinutes().toString().padStart(2, '0');
  const time = `${hour}:${minute}`;
  if (preferences.quietStartTime <= preferences.quietEndTime) {
    return time >= preferences.quietStartTime && time <= preferences.quietEndTime;
  }
  return time >= preferences.quietStartTime || time <= preferences.quietEndTime;
}

async function createNotificationJobsAsync(event, recipientIds) {
  const message = resolveMessage(event);
  const now = nowIso();
  for (let i = 0; i < recipientIds.length; i++) {
    const userId = recipientIds[i];
    const preferences = await getNotificationPreferencesAsync(userId);
    const muted = preferences.enabled === false || isQuietNow(preferences);
    const sessions = await store.filterAsync('user_sessions', (item) => {
      return asNumber(item.userId) === asNumber(userId) &&
        item.sessionStatus === 'ACTIVE' &&
        item.notificationToken &&
        item.notificationToken.length > 0;
    });

    const job = await store.insertAsync('notification_jobs', {
      eventId: event.id,
      userId,
      title: message.title,
      content: message.content,
      channel: 'PUSH',
      provider: sessions.length > 0 ? (sessions[0].notificationProvider || 'AGC_GATEWAY') : 'NO_ENDPOINT',
      status: muted ? 'SUPPRESSED' : (sessions.length > 0 ? 'PENDING' : 'NO_ENDPOINT'),
      priority: event.eventType.indexOf('ALERT') >= 0 ? 'HIGH' : 'NORMAL',
      payload: {
        eventType: event.eventType,
        bizType: message.bizType,
        bizId: event.bizId,
        studentId: event.studentId
      },
      attempts: 0,
      maxAttempts: 3,
      nextRetryAt: '',
      lastError: muted ? 'muted by notification preference' : '',
      createdAt: now,
      updatedAt: now
    });

    for (let j = 0; j < sessions.length; j++) {
      await store.insertAsync('notification_delivery_receipts', {
        jobId: job.id,
        userId,
        sessionId: sessions[j].id,
        deviceId: sessions[j].deviceId || '',
        provider: sessions[j].notificationProvider || '',
        status: muted ? 'SUPPRESSED' : 'PENDING',
        deliveredAt: '',
        errorMessage: '',
        createdAt: now,
        updatedAt: now
      });
    }
  }
}

async function upsertFormCardAsync(cardType, targetRole, studentId, payload) {
  if (!payload || asNumber(studentId) <= 0) {
    return null;
  }
  const rows = await store.filterAsync('form_cards', (item) => {
    return item.cardType === cardType && item.targetRole === targetRole && asNumber(item.studentId) === asNumber(studentId);
  });
  const now = nowIso();
  if (rows.length > 0) {
    return store.updateAsync('form_cards', rows[0].id, {
      payload,
      updatedAt: now
    });
  }
  return store.insertAsync('form_cards', {
    cardType,
    targetRole,
    studentId: asNumber(studentId),
    payload,
    createdAt: now,
    updatedAt: now
  });
}

async function refreshFormCardsAsync(studentId) {
  if (asNumber(studentId) <= 0) {
    return;
  }
  const todayCard = await buildTodayStatusCardAsync(asNumber(studentId));
  await upsertFormCardAsync('TODAY_STATUS', 'PARENT', studentId, todayCard);
  const abnormalCard = await buildAbnormalAlertCardAsync(asNumber(studentId));
  if (abnormalCard) {
    await upsertFormCardAsync('ABNORMAL_ALERT', 'PARENT', studentId, abnormalCard);
  }
}

async function createTimelineAsync(event) {
  if (asNumber(event.studentId) <= 0) {
    return;
  }
  const existing = await store.filterAsync('student_timelines', (item) => {
    return item.timelineType === event.bizType && asNumber(item.bizId) === asNumber(event.bizId);
  });
  if (existing.length > 0) {
    return;
  }
  const message = resolveMessage(event);
  const now = nowIso();
  await store.insertAsync('student_timelines', {
    studentId: asNumber(event.studentId),
    timelineType: event.bizType === 'ATTENDANCE' || event.bizType === 'HOMEWORK' || event.bizType === 'MESSAGE' || event.bizType === 'ORDER' ? event.bizType : 'NOTE',
    bizId: asNumber(event.bizId),
    title: message.title,
    content: message.content,
    bizDate: now.slice(0, 10),
    timestamp: now,
    operatorUserId: asNumber(event.actorUserId),
    operatorName: '',
    createdAt: now,
    updatedAt: now
  });
}

async function createAlertForAbnormalAttendanceAsync(event) {
  const payload = event.payload || {};
  if (event.eventType !== 'ATTENDANCE_SIGNED_IN' || payload.abnormalFlag !== true || asNumber(event.studentId) <= 0) {
    return;
  }
  const existing = await store.filterAsync('alerts', (item) => {
    return item.alertType === 'ATTENDANCE_ANOMALY' && asNumber(item.bizId) === asNumber(event.bizId);
  });
  if (existing.length > 0) {
    return;
  }
  const student = await getStudentAsync(event.studentId);
  const now = nowIso();
  await store.insertAsync('alerts', {
    studentId: asNumber(event.studentId),
    studentName: student ? student.name : '',
    alertType: 'ATTENDANCE_ANOMALY',
    bizId: asNumber(event.bizId),
    severity: 'MEDIUM',
    title: '迟到签到提醒',
    description: '学生发生迟到签到，请老师和家长关注。',
    suggestedAction: '核对到达时间并在必要时联系家长。',
    status: 'ACTIVE',
    acknowledgedBy: 0,
    acknowledgedAt: '',
    resolvedBy: 0,
    resolvedAt: '',
    resolution: '',
    createdAt: now,
    updatedAt: now
  });
}

async function processDomainEventAsync(event) {
  const recipientIds = await resolveRecipientsAsync(event);
  await createAlertForAbnormalAttendanceAsync(event);
  await createMessagesAsync(event, recipientIds);
  await createNotificationJobsAsync(event, recipientIds);
  await createTimelineAsync(event);
  await refreshFormCardsAsync(event.studentId);
  await processPendingNotificationJobsAsync(20);
}

async function processPendingEventsAsync(limit) {
  const max = Number(limit || 20);
  const pending = await store.filterAsync('domain_events', (item) => item.status === 'PENDING' || item.status === 'FAILED');
  pending.sort((left, right) => String(left.createdAt).localeCompare(String(right.createdAt)));
  const results = [];
  for (let i = 0; i < pending.length && i < max; i++) {
    const event = pending[i];
    try {
      await store.updateAsync('domain_events', event.id, {
        status: 'PROCESSING',
        attempts: asNumber(event.attempts) + 1,
        updatedAt: nowIso()
      });
      await processDomainEventAsync(event);
      const updated = await store.updateAsync('domain_events', event.id, {
        status: 'PROCESSED',
        processedAt: nowIso(),
        lastError: '',
        updatedAt: nowIso()
      });
      results.push(updated);
    } catch (error) {
      const updated = await store.updateAsync('domain_events', event.id, {
        status: 'FAILED',
        lastError: String(error),
        updatedAt: nowIso()
      });
      results.push(updated);
    }
  }
  return results;
}

async function emitAndProcessDomainEventAsync(event) {
  const created = await emitDomainEventAsync(event);
  await processPendingEventsAsync(20);
  return created;
}

module.exports = {
  emitDomainEventAsync,
  emitAndProcessDomainEventAsync,
  processPendingEventsAsync,
  refreshFormCardsAsync
};
