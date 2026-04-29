# API Smoke Test 清单

## 1. 适用范围

本清单用于两类场景：

1. **当前主线：AGC_SERVERLESS**
   - 目标：对 AGC API Gateway + Cloud Functions + Cloud DB 做最小可用连通性验证
   - 重点：接口可达、鉴权可用、业务返回结构与前端约定一致
2. **历史基线：DEV_MOCK**
   - 说明：该口径仅作为 2026-04 历史联调记录保留，当前运行时已经收口为 AGC-only
   - 目标：用于回看早期页面联调时如何验证前端接口消费结构

---

## 2. 基础环境检查

### 2.1 AGC_SERVERLESS

- `ApiConfig.CURRENT_ENV === AGC_SERVERLESS`
- AGC API Gateway 地址、函数 manifest 与 `AgcFunctionContracts.ts` 必须一致
- 如需登录态，先完成登录并确认 token 已写入 `AppStorage`
- 关键断言：
  - 非公开接口返回 200/业务成功码
  - 401 时前端跳转逻辑正常
  - 真实响应字段至少覆盖页面实际使用字段

### 2.2 DEV_MOCK（历史归档口径）

- 当前代码主线不再提供运行时 DEV_MOCK 切换入口。
- 历史记录中的 `DEV_MOCK` 用于解释早期 Mock 页面联调方法，不作为当前交付验收目标。
- 关键断言：
  - 相关历史结论迁入 `docs/99-历史版本` 后不再阻塞当前 AGC 验收。

---

## 3. 分模块 Smoke Test

> 说明：
> - “Mock 覆盖”表示本轮是否已在 `entry/src/main/ets/services/mock/mockService.ts` 中补齐
> - “鉴权”表示切到 AGC Serverless 时通常是否需要登录态

### 3.1 Auth

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 登录 | POST | `/api/v1/auth/login` | 无 | `code=0`，返回 `token`、`userInfo` | 是 | 否 |
| 当前用户 | GET | `/api/v1/auth/me` | 已登录 | `code=0`，返回 `id`、`roleType` | 是 | 是 |
| 登出 | POST | `/api/v1/auth/logout` | 已登录 | `code=0` | 是 | 是 |
| 刷新 Token | POST | `/api/v1/auth/refresh` | 已登录/Token 可刷新 | `code=0`，返回新 token | 是 | 是 |

### 3.2 Students

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 学生列表 | GET | `/api/v1/students` | 无 | `code=0`，`data.list`/分页结构有效 | 是 | 是 |
| 学生详情 | GET | `/api/v1/students/{id}` | 学生存在 | `code=0`，返回 `id`、`name`、`studentNo` | 是 | 是 |
| 创建学生 | POST | `/api/v1/students` | 参数完整 | `code=0`，返回新建学生对象 | 是 | 是 |
| 更新学生 | PUT | `/api/v1/students/{id}` | 学生存在 | `code=0`，返回更新后对象 | 是 | 是 |
| 删除学生（V2 兼容） | DELETE | `/api/v1/students/{id}` | 学生存在 | `code=0` | 是 | 是 |
| 监护人列表 | GET | `/api/v1/students/{studentId}/guardians` | 学生存在 | `code=0`，返回 guardian 数组 | 是 | 是 |
| 绑定监护人 | POST | `/api/v1/students/{studentId}/guardians` | 参数完整 | `code=0`，返回 guardian relation | 是 | 是 |

### 3.3 Service Products

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 服务列表 | GET | `/api/v1/service-products` | 无 | `code=0`，列表/分页结构有效 | 是 | 是 |
| 服务详情 | GET | `/api/v1/service-products/{serviceId}` | 服务存在 | `code=0`，返回 `serviceName`、`price` | 是 | 是 |
| 创建服务 | POST | `/api/v1/service-products` | 参数完整 | `code=0`，返回新对象 | 是 | 是 |
| 更新服务 | PUT | `/api/v1/service-products/{serviceId}` | 服务存在 | `code=0`，返回更新后对象 | 是 | 是 |

### 3.4 Orders

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 订单列表 | GET | `/api/v1/orders` | 无 | `code=0`，返回订单数组 | 是 | 是 |
| 订单详情 | GET | `/api/v1/orders/{orderId}` | 订单存在 | `code=0`，返回 `orderNo`、`orderStatus` | 是 | 是 |
| 创建订单 | POST | `/api/v1/orders` | 参数完整 | `code=0`，返回新订单 | 是 | 是 |
| 审核订单 | POST | `/api/v1/orders/{orderId}/audit` | 订单存在 | `code=0`，状态变化正确 | 是 | 是 |
| 订单退款 | POST | `/api/v1/orders/{orderId}/refund` | 订单存在 | `code=0`，返回退款后订单 | 是 | 是 |

### 3.5 Sessions

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 班次列表 | GET | `/api/v1/sessions` | 无 | `code=0`，返回班次数组 | 是 | 是 |
| 今日班次 | GET | `/api/v1/sessions/today` | 无 | `code=0` | 是 | 是 |
| 班次详情 | GET | `/api/v1/sessions/{sessionId}` | 班次存在 | `code=0`，返回班次及 students | 是 | 是 |
| 创建班次 | POST | `/api/v1/sessions` | 参数完整 | `code=0`，返回新班次 | 是 | 是 |
| 更新班次 | POST | `/api/v1/sessions/{sessionId}` | 班次存在 | `code=0`，返回更新后班次 | 是 | 是 |
| 自动排课 | POST | `/api/v1/sessions/generate` | 参数完整 | `code=0`，返回班次数组 | 是 | 是 |
| 班次学生列表 | GET | `/api/v1/sessions/{sessionId}/students` | 班次存在 | `code=0`，返回 students 字段 | 是 | 是 |

### 3.6 Attendance / Leave

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 考勤列表 | GET | `/api/v1/attendance` | 无 | `code=0`，`data.list` 有效 | 是 | 是 |
| 签到 | POST | `/api/v1/attendance/sign-in` | 学生/班次存在 | `code=0`，返回 `status=SIGNED_IN` | 是 | 是 |
| 签退 | POST | `/api/v1/attendance/sign-out` | 学生/班次存在 | `code=0`，返回 `status=SIGNED_OUT` | 是 | 是 |
| 异常考勤 | GET | `/api/v1/attendance/abnormal-events` | 无 | `code=0`，仅含异常记录或缺勤记录 | 是 | 是 |
| 提交请假 | POST | `/api/v1/attendance/leave` | 参数完整 | `code=0`，返回请假记录 | 是 | 是 |
| 请假列表 | GET | `/api/v1/attendance/leave` | 无 | `code=0`，`data.list` 有效 | 是 | 是 |
| 取消请假 | POST | `/api/v1/attendance/leave/{id}/cancel` | 请假记录存在 | `code=0`，状态变为 `CANCELLED` | 是 | 是 |
| 考勤统计 | GET | `/api/v1/attendance/statistics` | 无 | `code=0`，返回 total/signedIn/absent 等字段 | 是 | 是 |

### 3.7 Homework

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 作业列表 | GET | `/api/v1/homework/tasks` | 无 | `code=0`，`data.list` 有效 | 是 | 是 |
| 作业详情 | GET | `/api/v1/homework/tasks/{taskId}` | 任务存在 | `code=0`，返回 task 对象 | 是 | 是 |
| 创建作业 | POST | `/api/v1/homework/tasks` | 参数完整 | `code=0`，返回新 task | 是 | 是 |
| 更新状态 | POST | `/api/v1/homework/tasks/{taskId}/status` | 任务存在 | `code=0`，状态更新成功 | 是 | 是 |
| 提交反馈 | POST | `/api/v1/homework/feedback` | 参数完整 | `code=0`，返回 feedback 对象 | 是 | 是 |
| 反馈列表 | GET | `/api/v1/homework/tasks/{taskId}/feedbacks` | 任务存在 | `code=0`，返回 feedback 数组 | 是 | 是 |
| 确认反馈 | POST | `/api/v1/homework/feedback/{feedbackId}/confirm` | feedback 存在 | `code=0`，状态/确认时间有效 | 是 | 是 |

### 3.8 Messages

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 消息列表 | GET | `/api/v1/messages` | 无 | `code=0`，`data.list` 有效 | 是 | 是 |
| 消息详情 | GET | `/api/v1/messages/{messageId}` | 消息存在 | `code=0`，返回 detail | 是 | 是 |
| 发送消息 | POST | `/api/v1/messages` | 参数完整 | `code=0`，返回新消息 | 是 | 是 |
| 单条已读 | POST | `/api/v1/messages/{messageId}/read` | 消息存在 | `code=0` | 是 | 是 |
| 批量已读 | POST | `/api/v1/messages/batch-read` | 参数完整 | `code=0` | 是 | 是 |
| 全部已读 | POST | `/api/v1/messages/read-all` | 无 | `code=0` | 是 | 是 |
| 删除消息（旧） | POST | `/api/v1/messages/{messageId}/delete` | 消息存在 | `code=0` | 是 | 是 |
| 删除消息（V2） | DELETE | `/api/v1/messages/{messageId}` | 消息存在 | `code=0` | 是 | 是 |
| 未读数 | GET | `/api/v1/messages/unread-count` | 无 | `code=0`，返回 `count` | 是 | 是 |
| 消息统计 | GET | `/api/v1/messages/statistics` | 无 | `code=0`，返回 `total/unread/byType` | 是 | 是 |

### 3.9 Timeline

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 学生时间线 | GET | `/api/v1/timeline/students/{studentId}` | 学生存在 | `code=0`，返回 timeline 数组 | 是 | 是 |

### 3.10 Cards

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 今日状态卡片 | GET | `/api/v1/cards/today-status` | 无 | `code=0`，返回 `studentName`、`attendanceStatus` | 是 | 是 |
| 异常告警卡片（代码） | GET | `/api/v1/cards/abnormal-alert` | 无 | `code=0`，返回卡片对象或 `null` | 是 | 是 |
| 异常告警卡片（文档） | GET | `/api/v1/cards/alerts` | 无 | `code=0`，与代码别名行为一致 | 是 | 是 |

### 3.11 Alerts

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 告警列表 | GET | `/api/v1/alerts` | 无 | `code=0`，`data.list` 有效 | 是 | 是 |
| 告警详情 | GET | `/api/v1/alerts/{alertId}` | 告警存在 | `code=0`，返回 detail | 是 | 是 |
| 确认告警 | POST | `/api/v1/alerts/{alertId}/acknowledge` | 告警存在 | `code=0` | 是 | 是 |
| 解决告警 | POST | `/api/v1/alerts/{alertId}/resolve` | 告警存在 | `code=0` | 是 | 是 |
| 忽略告警 | POST | `/api/v1/alerts/{alertId}/dismiss` | 告警存在 | `code=0` | 是 | 是 |
| 活跃数量 | GET | `/api/v1/alerts/active-count` | 无 | `code=0`，返回 `count` | 是 | 是 |
| 告警统计 | GET | `/api/v1/alerts/statistics` | 无 | `code=0`，返回统计结构 | 是 | 是 |

### 3.12 Payments

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 创建支付单 | POST | `/api/v1/payments` | 参数完整 | `code=0`，返回 `paymentNo/payUrl` | 是 | 是 |
| 支付回调 | POST | `/api/v1/payments/callback` | 无 | `code=0` | 是 | 否 |
| 支付详情 | GET | `/api/v1/payments/{paymentNo}` | 支付单存在 | `code=0`，返回支付详情 | 是 | 是 |
| 支付退款 | POST | `/api/v1/payments/{paymentNo}/refund` | 支付单存在 | `code=0`，返回 `payStatus=REFUNDED` | 是 | 是 |

### 3.13 Refunds

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 创建退款单 | POST | `/api/v1/refunds` | 参数完整 | `code=0`，返回 refund 对象 | 是 | 是 |
| 退款列表 | GET | `/api/v1/refunds` | 无 | `code=0`，`data.list` 有效 | 是 | 是 |
| 退款详情 | GET | `/api/v1/refunds/{refundId}` | 退款单存在 | `code=0` | 是 | 是 |
| 取消退款 | POST | `/api/v1/refunds/{refundId}/cancel` | 退款单存在 | `code=0` | 是 | 是 |
| 退款统计 | GET | `/api/v1/refunds/statistics` | 无 | `code=0`，返回统计结构 | 是 | 是 |
| 退款金额试算 | GET | `/api/v1/refunds/calculate?orderId=...` | 订单存在 | `code=0`，返回 `refundable/refundAmount` | 是 | 是 |
| 按订单查询退款 | GET | `/api/v1/refunds/order/{orderId}` | 订单存在 | `code=0`，返回退款数组 | 是 | 是 |

### 3.14 Reports

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| 考勤报表 | GET | `/api/v1/reports/attendance` | 无 | `code=0`，返回报表汇总 | 是 | 是 |
| 财务报表 | GET | `/api/v1/reports/finance` | 无 | `code=0`，返回财务汇总 | 是 | 是 |
| 教师绩效 | GET | `/api/v1/reports/performance` | 无 | `code=0`，返回数组 | 是 | 是 |
| 每日考勤统计 | GET | `/api/v1/reports/attendance/daily` | 无 | `code=0`，返回数组 | 是 | 是 |
| 学生考勤汇总 | GET | `/api/v1/reports/attendance/students` | 无 | `code=0`，返回数组 | 是 | 是 |
| 每日营收统计 | GET | `/api/v1/reports/finance/daily` | 无 | `code=0`，返回数组 | 是 | 是 |
| 服务产品营收 | GET | `/api/v1/reports/finance/products` | 无 | `code=0`，返回数组 | 是 | 是 |

### 3.15 Agent / Security

| 接口 | 方法 | 路径 | 前置条件 | 关键断言 | Mock 覆盖 | 鉴权 |
|---|---|---|---|---|---|---|
| Agent 问答 | POST | `/api/v1/agent/chat` | 已登录 | `code=0`，返回 `agentId/answer/summary` | AGC 本地烟测 | 是 |
| Agent 总结 | POST | `/api/v1/agent/summary` | 已登录 | `code=0`，返回当前角色作用域摘要 | AGC 本地烟测 | 是 |
| Agent 汇报 | POST | `/api/v1/agent/report` | 已登录 | `code=0`，返回汇报文本 | AGC 本地烟测 | 是 |
| Agent 导航 | POST | `/api/v1/agent/navigation` | 已登录 | `code=0`，返回 `actions` | AGC 本地烟测 | 是 |
| 审计事件列表 | GET | `/api/v1/security/audit-events` | 管理员已登录 | `code=0`，`data.list` 有效 | AGC 本地烟测 | 是 |
| 审计统计 | GET | `/api/v1/security/audit-events/statistics` | 管理员已登录 | `code=0`，返回 `total/successCount/failureCount/byDomain` | AGC 本地烟测 | 是 |

---

## 4. 文档与代码差异备注

### 4.1 Cards 路径差异

- 代码当前实际使用：`/api/v1/cards/abnormal-alert`
- 文档/OpenAPI 常见写法：`/api/v1/cards/alerts`
- 本轮处理：Mock 同时兼容两条路径
- 后续建议：统一文档与常量命名，避免联调歧义

### 4.2 Reports 教师绩效命名差异

- 代码当前使用：`/api/v1/reports/performance`
- 文档历史版本中曾出现：`/api/v1/reports/teacher-performance`
- 本轮处理：Smoke test 以代码实际调用路径为准
- 后续建议：在 OpenAPI 与接口清单中统一成单一路径

### 4.3 Attendance 请假返回类型差异

- `services/api/attendance.ts` 中请假接口仍以 `AttendanceRecord` 作为返回类型
- V2 与模型层已引入 `LeaveRecord`
- 本轮处理：Mock 以“字段兼容、接口可达”为优先，不额外修改服务层签名
- 后续建议：统一旧版与 V2 服务的返回模型

### 4.4 Session Students 调用方式

- 业务代码当前把 `getSessionStudents()` 视为 `getSessionDetail()` 的别名封装
- 本轮处理：Mock 在班次详情中直接带 `students` 字段，兼容两类调用

---

## 5. 当前结论（2026-04-27）

### 5.1 历史 Mock 验证结果

- 以下内容为 2026-04 历史联调记录，当前 `entry/src/main/ets/config/api.config.ts` 已收口为 `AGC_SERVERLESS` 单主线，旧 `DEV_MOCK` 与 `TEST_REAL` 直连后端口径不再作为当前联调目标。
- `entry/src/main/ets/services/mock/mockService.ts` 已覆盖 Auth、Students、Service Products、Orders、Sessions、Attendance/Leave、Homework、Messages、Timeline、Cards、Alerts、Payments、Refunds、Reports 等主模块，主干接口已具备 `code=0` 响应能力。
- 家长端主链路依赖的首页卡片、服务详情、下单、订单详情、支付、消息、作业、时间线等接口，均可在 Mock 层命中。
- 教师端主链路依赖的今日班次、考勤列表、扫码签到、作业反馈、消息入口等接口，均已有 Mock 支撑。
- 管理端主链路依赖的学生管理、订单审核、报表查看、消息入口等接口，均已有 Mock 支撑。

### 5.2 本轮发现的代码/文档差异

1. `docs/03-接口文档/接口设计文档-API清单.md` 仍是交付版精简清单，未完整反映当前代码中已使用的扩展接口，例如：
   - `POST /api/v1/auth/refresh`
   - `DELETE /api/v1/students/{id}`
   - `GET /api/v1/sessions/today`
   - `GET/POST /api/v1/attendance/leave`、`POST /api/v1/attendance/leave/{id}/cancel`
   - `GET /api/v1/attendance/statistics`
   - `POST /api/v1/messages/batch-read`、`POST /api/v1/messages/read-all`
   - `DELETE /api/v1/messages/{messageId}`
   - `GET /api/v1/payments/{paymentNo}`、`POST /api/v1/payments/{paymentNo}/refund`
   - `GET /api/v1/reports/attendance/daily`、`/attendance/students`、`/finance/daily`、`/finance/products`
2. `entry/src/main/ets/services/api/attendance.ts` 目前仅暴露签到、签退、异常考勤与请假提交；Mock 已支持请假列表、取消请假、统计接口，但旧服务层未完全暴露，后续建议统一到单一 API 服务出口。
3. `entry/src/main/ets/services/api/service.ts` 中 `getTodaySessions()` 实际仍调用 `/api/v1/sessions` + `sessionDate=today`，而常量层与 Mock 已提供 `/api/v1/sessions/today`；当前可用，但存在路径语义不统一问题。
4. 历史优化清单中的“核心功能 100% 完成”应理解为 Mock/页面主流程完成，不等同于生产 AGC 环境验收完成。

## 6. 建议执行顺序

1. 先执行 `npm run smoke`（`cloud-functions`）验证 AGC 分域函数、Agent 与 Security 审计出口。
2. 执行 `scripts/check-agc-consistency.ps1` 验证 OpenAPI、manifest、前端合约、Cloud DB 集合一致。
3. 执行 `scripts/check-production-readiness.ps1` 验证 AGC 客户端配置、Server SDK 凭据、Cloud DB seed 与生产前置项。
4. 在模拟器/真机上验证 AGC 登录、当前用户、工作台 manifest、核心业务列表。
5. 最后执行 `scripts/run-refactor-gates.ps1` 与 `hvigorw assembleHap --analyze=advanced`。
