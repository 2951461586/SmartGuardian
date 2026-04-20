# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

- 这是一个 HarmonyOS Stage 模式应用，主模块是 `entry/`。
- 启动链路：`EntryAbility` → `pages/Index` → 登录态分流到 `LoginPage` 或 `MainPage`。
- `MainPage` 按角色切换底部导航与页面栈：家长、教师、管理员三套主界面。
- 当前数据层以 `services/api/*` + `services/mock/*` + `utils/request.ts` 组成；默认环境是 Mock，切到真实后端由 `entry/src/main/ets/config/api.config.ts` 控制。

## 常用命令

- 清理构建：`hvigorw clean`
- 生成 HAP：`hvigorw assembleHap`
- 清理后构建：`hvigorw clean && hvigorw assembleHap`
- 严格分析构建警告：`hvigorw assembleHap --analyze=strict`
- 运行测试：使用 DevEco Studio 的 `entry` 测试任务，测试代码分别在 `entry/src/test/`（本地单测）和 `entry/src/ohosTest/`（设备/模拟器测试）
- 跑单个测试：在对应测试文件里保留/只启用目标 `it(...)`，再从 DevEco Studio 只运行该测试用例或测试套件

## 结构要点

- `entry/src/main/ets/pages/`：页面层，按 `parent/`、`teacher/`、`admin/`、`common/` 分域组织。
- `entry/src/main/ets/components/`：可复用 UI 组件，`components/common/` 是通用组件出口。
- `entry/src/main/ets/services/`：业务服务层；`services/api/index.ts` 是统一导出入口，`services/mock/mockService.ts` 提供 Mock 数据。
- `entry/src/main/ets/stores/`：全局状态管理，基于 `ReactiveStore` / `AppStorage`，`stores/index.ts` 统一导出。
- `entry/src/main/ets/models/`：领域模型与响应类型，`models/index.ts` 统一导出。
- `entry/src/main/ets/utils/`：请求封装、日期、加密/脱敏、日志、权限、性能优化等工具。
- `entry/src/main/ets/formability/`：卡片/元服务能力实现。
- `entry/src/main/resources/base/`：`color.json`、`float.json`、`string.json`、`profile/main_pages.json`、`profile/form_config.json` 等资源与页面注册。
- `docs/`：正式交付文档、接口说明、历史优化记录；优先参考这里理解业务与约束。

## 关键实现脉络

- 网络请求统一走 `utils/request.ts`，它负责鉴权头、Mock 切换、401 回跳登录页。
- `services/api/BaseApiService.ets` 为各业务服务提供 GET/POST/PUT/DELETE、分页和统一包装。
- `stores/core/ReactiveStore.ts` 封装了可持久化状态、通知与订阅，`UserStore` 是全局登录态核心。
- `AppInitializationService` 在应用启动时串联性能优化、通知、分布式能力与同步服务。
- 卡片通过 `TodayGuardianFormAbility` 和 `formability/pages/*` 提供。

## 约束

- 现有实现默认偏 Mock 联调；切真实后端前先确认 `ApiConfig.CURRENT_ENV` 和 `TEST_BASE_URL`。
- 页面注册以 `entry/src/main/resources/base/profile/main_pages.json` 为准。
- 代码里大量使用资源引用 `$r(...)` 和 `AppStorage`，改动时注意保持资源名和状态键一致。
