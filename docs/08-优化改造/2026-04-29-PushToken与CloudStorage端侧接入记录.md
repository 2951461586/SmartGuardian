# 2026-04-29 Push Token 与 Cloud Storage 端侧接入记录

## 本批目标

在云端已经具备 `notification_jobs`、`cloud_attachments`、`user_sessions` 的基础上，先把端侧真实 SDK 的替换口落到工程内：

1. Push Kit token provider：把真实 Push token 获取与会话设备注册解耦。
2. Cloud Storage upload service：把附件登记、SDK 上传、上传完成回写串成一个端侧编排服务。

## 已落地

### Push token provider

- 新增 `entry/src/main/ets/services/PushTokenProviderService.ets`。
- 支持三层来源：
  - 业务注册的 `PushTokenSource`，后续真 Push Kit SDK adapter 接这里。
  - `AppStorage` 中已持久化的 Push Kit token。
  - 当前 AGC gateway token fallback。
- `HarmonyPushEndpointService` 已切换为异步读取 `PushTokenProviderService`。
- `NotificationEndpointRegistrationService` 已改为等待真实 provider 后再调用 `/api/v1/auth/session-device`。
- 新增 `StorageKeys.PUSH_KIT_TOKEN`、`PUSH_KIT_DEVICE_ID`、`PUSH_KIT_TOKEN_UPDATED_AT`、`PUSH_KIT_PROVIDER_MESSAGE`。

### Cloud Storage upload service

- 新增 `entry/src/main/ets/services/CloudStorageUploadService.ets`。
- 新增 `CloudStorageUploadAdapter` 注入点，后续 AGC Cloud Storage SDK adapter 只需要实现：
  - `isAvailable()`
  - `uploadFile(request)`
- `uploadAttachment()` 已串联：
  - `POST /api/v1/storage/attachments`
  - 端侧 SDK 上传
  - `POST /api/v1/storage/attachments/{attachmentId}/complete`
- `models/cloud.ts` 补齐 `CloudAttachmentCreateRequest`、`CloudAttachmentCompleteRequest`、`CloudAttachmentUploadPolicy`、`CloudAttachmentCreateResponse`。
- `CloudStorageAttachmentService` 已改为强类型请求/响应。

### 云端 Push 发送网关

- 新增 `cloud-functions/shared/push.js`。
- `domain_events` 消费后不再直接把通知任务标记为 `SENT`，而是调用 `processPendingNotificationJobsAsync()`。
- `notification_jobs` 处理逻辑已具备：
  - 从 `user_sessions` 读取当前用户活跃设备和 token。
  - 按 `notification_delivery_receipts` 逐设备记录发送结果。
  - 支持失败重试、`nextRetryAt` 退避、超过 `maxAttempts` 后保留 `FAILED`。
  - 无设备端点时落 `NO_ENDPOINT`。
- 新增管理员补偿入口 `POST /api/v1/notifications/jobs/process`。
- 当前默认 `SMARTGUARDIAN_PUSH_DELIVERY_MODE=auto`：
  - 未配置华为 Push 凭据时走模拟送达，保持本地 smoke 可跑。
  - 配置 `HUAWEI_PUSH_APP_ID`、`HUAWEI_PUSH_CLIENT_ID`、`HUAWEI_PUSH_CLIENT_SECRET` 且设备 provider 为 `PUSH_KIT` 时走华为 Push HTTPS 发送。
  - 设置 `SMARTGUARDIAN_PUSH_DELIVERY_MODE=real` 后，`PUSH_KIT` 缺少凭据会直接失败，适合生产验收。

### outbox 异步消费

- `attendance`、`homework`、`refund` 域已经从 `emitAndProcessDomainEventAsync()` 切换为 `emitDomainEventAsync()`。
- 业务请求只负责写 `domain_events`，不再同步派生消息、时间线、通知任务、告警和卡片缓存。
- `POST /api/v1/events/process` 保留为管理员手动补偿入口。
- 新增 `POST /api/v1/events/trigger`，用于 AGC 定时触发器或外部调度器调用。
- `events/trigger` 支持 `SMARTGUARDIAN_EVENT_CONSUMER_SECRET`：
  - 未配置时本地 smoke 可直接调用。
  - 配置后必须传 `x-smartguardian-event-secret` header 或 body.secret。
- `card` 域读取 `form_cards` 时增加旧缓存结构校验，缺少 `studentId/studentName/attendanceStatus` 会自动重建并回填，避免历史 seed 缓存污染线上响应。

## 当前边界

- 当前仓库还没有安装 Push Kit 独立 SDK 或 AGC Cloud Storage 端侧 SDK 包，因此没有直接写未验证的 `import`，避免 ArkTS 编译失败。
- 真机接入时只需要补两个薄 adapter：
  - Push：调用官方 Push Kit API 获取 token，然后 `PushTokenProviderService.persistPushKitToken()` 或注册 `PushTokenSource`。
  - Storage：调用官方 Cloud Storage SDK 上传 `localFileUri -> storagePath`，返回 `downloadUrl/checksum`。
- 云端 Push 真实发送需要在部署环境中配置华为 Push 服务端凭据，不能提交到仓库。
- 生产环境建议配置 `SMARTGUARDIAN_EVENT_CONSUMER_SECRET`，并由 AGC 定时触发器周期调用 `/api/v1/events/trigger`。

## 验证

- `.\hvigorw.bat assembleHap`：通过。
- `npm run smoke`：通过。
- `.\scripts\check-agc-consistency.ps1`：通过。
