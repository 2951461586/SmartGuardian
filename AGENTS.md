# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
你正在为 HarmonyOS 应用开发相关功能。以下是你需要遵循的开发规则。

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
- 跑单个测试：在对应测试文件里保留/只启用目标 `it(...)`，再从 DevEco Studio 只运行该测试用例或测试套件

## 结构要点

### 端侧（entry/）

- `entry/src/main/ets/pages/`：页面层，按 `parent/`、`teacher/`、`admin/`、`common/` 分域组织，共 47 个 @Entry 页面。
- `entry/src/main/ets/components/`：可复用 UI 组件，`components/common/` 是通用组件出口。
- `entry/src/main/ets/services/`：业务服务层，核心子目录：
  - `services/api/`：16 个业务域 API 服务，统一由 `services/api/index.ts` 导出。
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
- `cloud-functions/shared/`：共享模块（`router.js`、`store.js`、`auth.js`、`events.js`、`push.js`、`audit.js`、`read-models.js`）。
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
- AGC 生产验收需要配置：Push 服务端凭据、事件 trigger secret、Storage bucket。当前本机未配置这些变量。
- 真机能力（Push Kit token、Cloud Storage SDK 上传、分布式软总线、桌面卡片刷新）必须在设备/控制台环境验收。
- LLM 能力通过 `SMARTGUARDIAN_LLM_*` 环境变量配置，未配置时走本地规则回答。

## ArkTS/ets 语法约束(违反条目将无法编译通过)

- 不支持索引访问类型。请改用类型名称。
- 不支持环境模块声明，因为它有自己的与 JavaScript 互操作的机制。请从原始模块中导入所需的内容。
- 不支持 any 和 unknown 类型。请显式指定类型。
- 不支持 as const 断言，因为在标准 TypeScript 中，as const 用于使用相应的字面量类型标注字面量，而 ArkTS 不支持字面量类型。请避免使用 as const 断言。请改用字面量的显式类型标注。
- 不支持对象类型中的调用签名。请改用 class（类）来实现。
- 不支持类字面量。请显式引入新的命名类类型。
- 不支持将类用作对象（将其赋值给变量等）。这是因为在 ArkTS 中，类声明引入的是一种新类型，而不是一个值。请勿将类用作对象；类声明引入的是一种新类型，而不是一个值。
- 仅在 for 循环中支持逗号运算符。在其他情况下，逗号运算符是无用的，因为它会使执行顺序更难理解。在 for 循环之外，请使用显式执行顺序而不是逗号运算符。
- 不支持条件类型别名。请显式引入带约束的新类型，或使用 Object 重写逻辑。不支持 infer 关键字。
- 不支持在构造函数中声明类字段。请在类声明内部声明类字段。
- 不支持使用构造函数类型。请改用 lambdas（匿名函数）。
- 不支持接口中的构造函数签名。请改用方法（methods）。
- 不支持对象类型中的构造函数签名。请改用 class（类）来实现。
- 不支持声明合并。请保持代码库中所有类和接口的定义紧凑。
- 不支持确定性赋值断言 let v!: T，因为它们被认为是过度的编译器提示。使用确定性赋值断言运算符（!）需要运行时类型检查，导致额外的运行时开销并生成此警告。请改用带初始化的声明。如果使用了!，请确保实例属性在使用前已赋值，并注意运行时开销和警告。
- 假定对象布局在编译时已知且运行时不可更改。因此，删除属性的操作没有意义。为了模拟原始语义，您可以声明一个可空类型并赋值为 null 以标记值的缺失。
- 不支持解构赋值。请改用其他惯用法（例如，在适用情况下使用临时变量）代替。
- 不支持解构变量声明。这是一个依赖于结构兼容性的动态特性。创建中间对象并逐字段操作，不受名称限制。
- 要求参数直接传递给函数，并手动分配局部名称。请将参数直接传递给函数，并手动分配局部名称，而不是使用解构参数声明。
- 不支持枚举的声明合并。请保持代码库中每个枚举的声明紧凑。
- 不支持使用在程序运行时评估的表达式初始化枚举成员。此外，所有显式设置的初始化器必须是相同类型。请仅使用相同类型的编译时表达式初始化枚举成员。
- 不支持 export = ...语法。请改用普通的 export 和 import 语法。
- 不允许接口包含两个具有不可区分签名的方法（例如，参数列表相同但返回类型不同）。请避免接口扩展具有相同方法签名的其他接口。重构方法名称或返回类型。
- 不支持通过 for .. in 循环遍历对象内容。对于对象，运行时遍历属性被认为是冗余的，因为对象布局在编译时已知且运行时不可更改。对于数组，请使用常规的 for 循环进行迭代。
- 不支持 Function.apply 或 Function.call。这些 API 在标准库中用于显式设置被调用函数的 this 参数。在 ArkTS 中，this 的语义被限制为传统的 OOP 风格，并且禁止在独立函数中使用 this。请避免使用 Function.apply 和 Function.call。请遵循传统的 OOP 风格来处理 this 的语义。
- 不支持 Function.bind。这些 API 在标准库中用于显式设置被调用函数的 this 参数。在 ArkTS 中，this 的语义被限制为传统的 OOP 风格，并且禁止在独立函数中使用 this。请避免使用 Function.bind。请遵循传统的 OOP 风格来处理 this 的语义。
- 不支持函数表达式。请改用箭头函数来显式指定。
- 不支持在函数上声明属性，因为不支持具有动态更改布局的对象。函数对象遵循此规则，其布局在运行时不可更改。请勿直接在函数上声明属性，因为它们的布局在运行时不可更改。
- 当前不支持生成器函数。请使用 async/await 机制进行多任务处理。
- 不支持全局作用域和 globalThis，因为不支持具有动态更改布局的无类型对象。请使用显式模块导出和导入来在文件之间共享数据，而不是依赖全局作用域。
- 支持函数返回类型推断，但此功能目前受到限制。特别是，当 return 语句中的表达式是对返回类型被省略的函数或方法的调用时，会发生编译时错误。当返回类型被省略时，请显式指定函数的返回类型。
- 不支持导入断言，因为导入在 ArkTS 中是编译时特性，而不是运行时特性。因此，对于静态类型语言来说，在运行时断言导入 API 的正确性没有意义。请改用普通的 import 语法；导入的正确性将在编译时检查。
- 不支持 in 运算符。此运算符意义不大，因为对象布局在编译时已知且运行时不可更改。如果您想检查是否存在某些类成员，请使用 instanceof 作为替代方案。
- 不允许索引签名。请改用数组（arrays）。
- 允许在函数调用时省略泛型类型参数（如果可以从传递给函数的参数中推断出具体类型），否则会发生编译时错误。特别地，仅基于函数返回类型推断泛型类型参数是被禁止的。当推断受限时（特别是仅基于函数返回类型时），请显式指定返回类型。
- 当前不支持交叉类型。请使用继承（inheritance）作为替代方案。
- 不支持 is 运算符，必须将其替换为 instanceof 运算符。请注意，在使用对象字段之前，必须使用 as 运算符将其转换为适当的类型。请将 is 运算符替换为 instanceof。在使用对象字段之前，请使用 as 运算符将其转换为适当的类型。
- 不支持 JSX 表达式。请勿使用 JSX，因为没有提供替代方案来重写它。
- 不支持映射类型。请使用其他语言惯用法和常规类来实现相同的行为。
- 不支持重新分配对象方法。在静态类型语言中，对象的布局是固定的，同一对象的所有实例必须共享每个方法的相同代码。如果需要为特定对象添加特定行为，可以创建单独的包装函数或使用继承。
- 所有 import 语句都应该在程序中的所有其他语句之前。请将所有 import 语句放在程序的开头，在任何其他语句之前。
- 不支持模块名称中的通配符，因为 import 在 ArkTS 中是编译时特性，而不是运行时特性。请改用普通的 export 语法。
- 不允许类初始化存在多个静态代码块。将所有静态代码块语句合并到一个静态代码块中。
- 不支持嵌套函数。请改用 lambdas（匿名函数）。
- 不支持 new.target，因为语言中没有运行时原型继承的概念。此功能被认为不适用于静态类型。此功能不适用于静态类型和运行时原型继承，因此不受支持。没有提供直接的替代方案，因为它是一个根本性的差异。
- 如果数组字面量中至少有一个元素具有不可推断的类型（例如，无类型对象字面量），则会发生编译时错误。请确保数组字面量中的所有元素都具有可推断的类型，或将元素显式转换为已定义的类型。
- 不支持将命名空间用作对象。请将类或模块解释为命名空间的类似物。
- 不支持命名空间中的语句。请使用函数来执行语句。
- 不支持将对象字面量直接用作类型声明。请显式声明类和接口。
- 只允许一元运算符+、-和~作用于数字类型。如果这些运算符应用于非数字类型，则会发生编译时错误。与 TypeScript 不同，此上下文中不支持字符串的隐式类型转换，必须显式进行类型转换。请确保一元运算符+、-和~仅应用于数字类型。如有必要，请执行显式类型转换。
- 不支持以#符号开头的私有标识符。请改用 private 关键字。
- 不支持动态字段声明和访问，也不支持通过索引访问对象字段（obj["field"]）。请在类中立即声明所有对象字段，并使用 obj.field 语法访问字段。标准库中的所有类型化数组（如 Int32Array）是例外，它们支持通过 container[index]语法访问元素。
- 不支持原型赋值，因为语言中没有运行时原型继承的概念。此功能被认为不适用于静态类型。请改用类和/或接口来静态地将方法与数据"组合"在一起。
- 不支持通过 require 导入。它也不支持 import 赋值。请改用常规的 import 语法。
- 展开运算符唯一支持的场景是将数组或派生自数组的类展开到 rest 参数或数组字面量中。否则，必要时手动从数组和对象中"解包"数据。展开运算符仅用于将数组或派生自数组的类展开到 rest 参数或数组字面量中。对于其他情况，请手动从数组和对象中解包数据。
- 不支持在独立函数和静态方法中使用 this。this 只能在实例方法中使用。
- 当前不支持结构化类型。这意味着编译器无法比较两种类型的公共 API 并判断它们是否相同。请改用其他机制（继承、接口或类型别名）。
- 不支持 Symbol() API，因为其最常见的用例在静态类型环境中没有意义，对象的布局在编译时定义且运行时不可更改。除 Symbol.iterator 外，避免使用 Symbol() API。
- 目前，用标准 TypeScript 语言实现的 codebase 不得通过导入 ArkTS codebase 来依赖 ArkTS。请避免 TypeScript 代码库依赖 ArkTS 代码库。反向导入（ArkTS 导入 TS）是支持的。
- 仅在表达式上下文中支持 typeof 运算符。不支持使用 typeof 指定类型标注。请改用显式类型声明而不是 typeof 进行类型标注。
- 在 TypeScript 中，catch 子句变量类型标注必须是 any 或 unknown（如果指定）。由于 ArkTS 不支持这些类型，因此请省略类型标注。请省略 catch 子句中的类型标注。
- 不支持使用 this 关键字进行类型标注。请改用显式类型。
- 不支持通用模块定义（UMD），因为它没有"脚本"的概念（与"模块"相对）。此外，import 在 ArkTS 中是编译时特性，而不是运行时特性。请改用普通的 export 和 import 语法。
- 支持对象字面量，前提是编译器可以推断出这些字面量所对应的类或接口。否则，会发生编译时错误。在以下上下文中，不支持使用字面量初始化类和接口：初始化 any、Object 或 object 类型；初始化带有方法的类或接口；初始化声明带参数构造函数的类；初始化带有 readonly 字段的类。请确保对象字面量对应于显式声明的类或接口。避免将它们用于 any、Object、object 类型，或用于初始化带有方法、参数化构造函数或只读字段的类。
- 目前不支持 TypeScript 扩展标准库中的实用类型。Partial、Required、Readonly 和 Record 是例外。对于 Record<K, V>类型，索引表达式 rec[index]的类型为 V | undefined。请避免使用不支持的 TypeScript 实用类型。Partial、Required、Readonly 和 Record 可用于其特定目的。
- 不支持 var 关键字。请改用 let 关键字。
- 不支持 with 语句。请使用其他语言惯用法来实现相同的行为。

## HarmonyOS API 使用规范(必读条目)

- 优先使用 HarmonyOS 官方提供的 API、UI 组件、动画、代码模板
- API 调用前请确认遵循官方文档入参、返回值及对应 API Level 和设备支持情况
- 对于任何不肯定的语法和 API 使用，不要猜测或自行构造 API，请尝试使用搜索工具获取华为开发者官方文档并进行确认
- 使用 API 前请确认是否需要在文件头添加 import 语句
- 调用 API 前请确认是否需要对应权限，在对应模块的`module.json5`中确认权限配置
- 如需使用依赖库，请确认依赖库的存在和匹配版本，并在对应模块的`oh-package.json5`中添加依赖配置
- 使用`@Component`和`@ComponentV2`时需要区分兼容性，尽量与已有工程代码保持一致
- UI 界面展示引用的常量需要定义 resources 资源值，并使用`$r`引用, 一般不直接使用字面值
- 新增国际化资源字符串时在对应的国际化每种语言下添加值，避免遗漏
- 新增颜色等资源请确认是否需要添加黑色主题支持(参考历史工程)，新工程建议默认支持黑色及白色主题

## ArkUI 动画规范(`animateTo`,`transform`,`renderGroup`,`opacity`)

- 优先使用 HarmonyOS 提供的原生动画 API 和高级模板
- 优先使用 HarmonyOS 的声明式 UI 和 `@State` 驱动动画，通过改变状态变量触发动画
- 对于包含复杂子组件的动画，将其设置为 `renderGroup(true)`，减少渲染批次
- 不可以在动画过程中频繁改变组件的 `width`、`height`、`padding`、`margin` 等布局属性，严重影响性能
