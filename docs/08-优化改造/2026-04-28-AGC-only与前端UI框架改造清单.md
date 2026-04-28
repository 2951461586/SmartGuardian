# 2026-04-28 AGC-only 与前端 UI 框架改造清单

## 当前判断

- 当前主线已经是 HarmonyOS Stage + ArkTS + AGC Serverless + Cloud Functions + Cloud DB。
- 本地 `backend/`、`@ohos/hamock`、Mock 环境和 Spring Boot/MySQL 入口不再属于生产运行链路，需要通过脚本门禁阻止回流。
- 三端首页应围绕 WorkbenchManifest 承载导航、首页模块入口和后端能力清单，页面层只负责状态装配和导航动作。
- 前端 UI 要统一为低饱和、轻量层级、官方组件优先的 HarmonyOS 风格，减少 emoji 式图标、高饱和色块和泛 AI 插画。

## 大颗粒可执行改造清单

1. **AGC-only 运行收口**
   - 删除本地 `backend/` 残留产物。
   - 移除根 `oh-package.json5` 与锁文件中的 `@ohos/hamock`。
   - 新增 legacy 门禁，阻止 `DEV_MOCK`、`TEST_REAL`、`Spring Boot`、`MySQL`、`localhost:8080`、`@ohos/hamock` 回流到活跃运行路径。

2. **服务契约治理**
   - 以 `entry/src/main/ets/services/agc/AgcFunctionContracts.ts` 作为前端唯一 AGC 路由契约。
   - 继续用 `cloud-functions/function-manifest.json`、分域 `contract.json` 和 Cloud DB schema 维护云端能力清单。
   - 登录、会话设备、通知 endpoint、WorkbenchManifest 必须形成端云闭环。

3. **前端 UI 框架升级**
   - 保留并强化 `HarmonyDesign` 作为视觉 token 单一入口。
   - 页面统一接入 `PageScaffold`、`StatefulContainer`、`WorkbenchActionGrid`、`FormFields`。
   - 三端首页继续拆分为业务 section，页面层不堆视觉细节。
   - 登录页以外的核心页面使用低饱和角色色板、原生 ArkUI 组件、统一卡片半径和边线层级。

4. **视觉资产治理**
   - 项目内持久化场景图资源，不依赖临时生成目录或外链。
   - 用生成资产补齐高频场景：家长照护、教师考勤辅导、机构运营、空态。
   - SVG 图标只承担功能识别，不再用 emoji 式装饰。

5. **质量门禁**
   - `run-refactor-gates.ps1` 纳入旧链路检查、页面注册、AGC 一致性、页面体量、UI 治理。
   - 每批 UI 改造后运行构建，避免旧 Mock/Java 入口和编码乱码反弹。

## 已落地

- 删除本地 `backend/` 残留目录。
- 移除 `@ohos/hamock` 依赖并新增 `scripts/check-legacy-artifacts.ps1`。
- 登录页入口、表单、基础字符串资源已完成编码治理和场景图替换。
- 家长首页接入 `ParentHomeWorkspaceSection`，由 WorkbenchManifest 驱动常用模块入口。
- 教师作业页完成二次收口，清理未使用状态 badge 和可见乱码。
- 本轮新增三张非登录场景资产：
  - `entry/src/main/resources/base/media/sg_scene_parent_care_v2.png`
  - `entry/src/main/resources/base/media/sg_scene_teacher_workbench_v2.png`
  - `entry/src/main/resources/base/media/sg_scene_admin_operations_v2.png`
- 三端首页 Hero 卡片改为低饱和浅色信息面板，并接入对应场景资产。
- `RoleTheme` 改为更克制的角色色板，机构端从高饱和紫色调整为低饱和蓝灰。
- `EmptyState`、`ErrorState`、`GreetingHeader`、`WorkbenchActionGrid`、三端首页 section 完成中文文案治理。
- 教师端首页、机构端首页的 WorkbenchManifest 文案、模块标题、统计卡片、活动流、状态文本已恢复正常中文。

## 收口状态

- AGC-only 运行收口：已完成。
- 服务契约治理：当前脚本校验通过，后续按 AGC contracts 维护。
- 前端 UI 框架升级：登录页、三端首页、教师作业页和公共状态组件已完成本批改造。
- 视觉资产治理：登录页与三端首页场景图已持久化到工程资源目录。
- 质量门禁：legacy gate 已接入 `run-refactor-gates.ps1`，本批改造需要继续跑构建验收。

## 参考依据

- 顶层设计文档：`docs/01-顶层设计/基于鸿蒙系统的学生智慧托管系统顶层设计方案-规范版.md`
- 华为 HarmonyOS UI Design：强调一次开发、多设备自适应、多态控件和平衡视图布局。
- 华为 ArkUI：优先使用声明式 UI、官方组件和状态驱动交互。
- AGC Cloud Functions：以 Serverless 承担函数运行、弹性扩缩容和业务服务代码。
