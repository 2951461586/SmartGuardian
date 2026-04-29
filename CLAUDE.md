# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

- 这是一个 HarmonyOS Stage 模式应用，主模块是 `entry/`。
- 启动链路：`EntryAbility` → `pages/Index` → 登录态分流到 `LoginPage` 或 `MainPage`。
- `MainPage` 按角色切换底部导航与页面栈：家长（22 页面）、教师（8 页面）、管理员（12 页面）三套主界面。
- **当前架构已完全收口到 AGC Serverless**：前端通过 AGC Cloud Functions + Cloud DB 提供所有后端能力，无 Mock/本地后端依赖。
- 后端服务通过华为 AGC（AppGallery Connect）云函数、云存储、云数据库实现，API 密钥配置在 `scripts/` 和 `cloud-functions/.env`。

## 常用命令

- 清理构建：`hvigorw clean`
- 生成 HAP：`hvigorw assembleHap`
- 清理后构建：`hvigorw clean && hvigorw assembleHap`
- 严格分析构建警告：`hvigorw assembleHap --analyze=strict`
- 云函数冒烟测试：`cd cloud-functions && npm run smoke`
- AGC 一致性检查：`.\scripts\check-agc-consistency.ps1`
- 生产就绪检查：`.\scripts\check-production-readiness.ps1`
- 生产闭环验收：`.\scripts\check-production-closure.ps1 -RequireDevice -RunCloudSmoke -RunBuild`
- 卡片一致性检查：`.\scripts\check-form-card-consistency.ps1`
- Legacy 门禁检查：`.\scripts\check-legacy-artifacts.ps1`
- 运行测试：使用 DevEco Studio 的 `entry` 测试任务，测试代码分别在 `entry/src/test/`（本地单测）和 `entry/src/ohosTest/`（设备/模拟器测试）

## 结构要点

### 端侧（entry/）

- `entry/src/main/ets/pages/`：页面层，按 `parent/`、`teacher/`、`admin/`、`common/` 分域组织，共 47 个 @Entry 页面。
- `entry/src/main/ets/components/`：可复用 UI 组件，`components/common/` 是通用组件出口。
- `entry/src/main/ets/services/`：业务服务层，核心子目录：
  - `services/api/`：16 个业务域 API 服务（attendance, auth, card, cloud, homework, message, payments, refund, reports, security, service, timeline, workbench, agent, alert），统一由 `services/api/index.ts` 导出。
  - `services/agc/`：AGC 运行时适配层（`AgcFunctionContracts.ts`、`AgcRequestAdapter.ts`、`AgcRuntimeService.ets`）。
  - `services/agent/`：智慧托管 Agent 框架服务。
  - `services/distributed/`：分布式能力（当前为本地兼容模式）。
  - 根目录服务：`AppInitializationService`、`FormCardSyncService`、`PushTokenProviderService`、`CloudStorageUploadService`、`NotificationEndpointRegistrationService` 等。
- `entry/src/main/ets/stores/`：全局状态管理，基于 `ReactiveStore` / `AppStorage`，包含 `userStore`、`attendanceStore`、`studentStore`、`orderStore`、`messageStore`。
- `entry/src/main/ets/models/`：17 个领域模型文件，统一由 `models/index.ts` 导出。
- `entry/src/main/ets/config/api.config.ts`：API 环境配置，当前唯一环境为 `AGC_SERVERLESS`。
- `entry/src/main/ets/utils/`：请求封装、日期、加密/脱敏、日志、权限、性能优化等工具。
- `entry/src/main/ets/formability/`：卡片/元服务能力实现（`TodayGuardianFormAbility`）。
- `entry/src/main/resources/base/`：资源文件、`profile/main_pages.json`（47 页面注册）、`profile/form_config.json`。

### 云函数（cloud-functions/）

- 共 21 个函数域，统一由 `function-manifest.json` 和分域 `contract.json` 约束：
  - **核心业务**：`auth`、`user`、`student`、`service`、`order`、`session`、`attendance`、`homework`、`message`、`alert`、`report`、`refund`、`timeline`、`card`、`payment`、`workbench`
  - **云端编排**：`event`（事件 outbox）、`notification`（通知推送编排）、`storage`（Cloud Storage 附件）
  - **安全与智能**：`security`（审计事件）、`agent`（AI 问答/总结/导航）
- `cloud-functions/shared/`：共享模块（`router.js`、`store.js`、`auth.js`、`events.js`、`push.js`、`audit.js`）。
- `cloud-functions/cloud-db/`：Cloud DB schema、collections（38 个集合）、seed 数据。
- 云函数使用 CommonJS 模块系统，依赖 `@hw-agconnect/cloud-server`。

### 脚本（scripts/）

- 验收门禁：`check-agc-consistency.ps1`、`check-production-readiness.ps1`、`check-production-closure.ps1`、`check-form-card-consistency.ps1`、`check-legacy-artifacts.ps1`、`check-ui-governance.ps1`
- 冒烟测试：`cloud-functions-smoke.js`（覆盖 21 个函数域）
- 部署工具：`package-agc-cloud-functions.ps1`、`cloud-env-loader.js`
- 数据迁移：`apply-cloud-db-seed.js`、`cloud-db-migration-lib.js`

## 关键实现脉络

- 网络请求统一走 `utils/request.ts`，通过 AGC Cloud Functions 触发 URL 路由请求，401 自动回跳登录页。
- `services/agc/AgcFunctionContracts.ts` 是前端唯一 AGC 路由契约，定义所有云函数触发 URL。
- `services/agc/AgcRequestAdapter.ts` 封装 AGC 云函数调用协议。
- `stores/core/ReactiveStore.ts` 封装可持久化状态、通知与订阅，`UserStore` 是全局登录态核心。
- `AppInitializationService` 在应用启动时串联性能优化、通知、分布式能力、卡片同步与推送注册。
- 事件驱动架构：业务操作投递领域事件（`domain_events`）→ 事件消费统一派生消息、时间线、卡片缓存、告警、通知任务。
- 卡片通过 `TodayGuardianFormAbility` + `FormCardSyncService` 实现云端缓存与端侧刷新闭环。
- Push 通知通过 `PushTokenProviderService` + `HarmonyPushEndpointService` + 云端 `shared/push.js` 实现端云协同。
- Agent 能力通过 `SmartGuardianAgentFrameworkService` 接入，支持本地规则与 OpenAI-compatible LLM fallback。

## 约束

- **当前架构已完全 AGC-only**，不存在 Mock 环境。`ApiConfig.CURRENT_ENV` 固定为 `AGC_SERVERLESS`。
- 页面注册以 `entry/src/main/resources/base/profile/main_pages.json` 为准（47 页面）。
- 代码里大量使用资源引用 `$r(...)` 和 `AppStorage`，改动时注意保持资源名和状态键一致。
- ArkTS 不支持 TypeScript 的解构赋值、`any`/`unknown` 类型、`as const`、索引访问类型等，详见 `AGENTS.md` 中的完整语法约束列表。
- AGC 生产验收需要配置：Push 服务端凭据、事件 trigger secret、Storage bucket。当前本机未配置这些变量。
- 真机能力（Push Kit token、Cloud Storage SDK 上传、分布式软总线、桌面卡片刷新）必须在设备/控制台环境验收。
- LLM 能力通过 `SMARTGUARDIAN_LLM_*` 环境变量配置，未配置时走本地规则回答。

## 文档索引

- 顶层设计：`docs/01-顶层设计/`
- 接口文档：`docs/03-接口文档/`（OpenAPI: `openapi-full.yaml`）
- 测试文档：`docs/05-测试文档/`
- 部署运维：`docs/06-部署与运维/`
- 优化改造记录：`docs/08-优化改造/`（含 2026-04-25 至 2026-04-29 全部执行记录）
