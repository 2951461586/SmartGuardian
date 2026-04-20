# API Smoke Test 清单

## 1. 适用范围

本清单用于两类场景：

1. **当前阶段：DEV_MOCK**
   - 目标：验证前端实际调用接口都能命中 Mock，不再出现 `Mock route not found`
   - 重点：响应结构可被页面消费，关键字段齐全
2. **后续阶段：TEST_REAL**
   - 目标：切换 `entry/src/main/ets/config/api.config.ts` 后，对真实后端做最小可用连通性验证
   - 重点：接口可达、鉴权可用、业务返回结构与前端约定一致

---

## 2. 基础环境检查

### 2.1 DEV_MOCK

- `ApiConfig.CURRENT_ENV === DEV_MOCK`
- `ApiConfig.TEST_BASE_URL` 可为空
- 关键断言：
  - 页面请求均返回 `code = 0`
  - 不出现 `Mock route not found`
  - 列表接口返回 `data.list` / `data.total` 或前端当前消费的约定结构

### 2.2 TEST_REAL

- `ApiConfig.CURRENT_ENV === TEST_REAL`
- `ApiConfig.TEST_BASE_URL` 必须配置为真实后端地址
- 如需登录态，先完成登录并确认 token 已写入 `AppStorage`
- 关键断言：
  - 非公开接口返回 200/业务成功码
  - 401 时前端跳转逻辑正常
  - 真实响应字段至少覆盖页面实际使用字段

---

## 3. 分模块 Smoke Test

> 说明：
> - “Mock 覆盖”表示本轮是否已在 `entry/src/main/ets/services/mock/mockService.ts` 中补齐
> - “鉴权”表示切到真实后端时通常是否需要登录态

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

## 5. 建议执行顺序

1. 先在 `DEV_MOCK` 下逐模块过一遍页面主流程
2. 若出现接口错误，优先看是否仍落入 `Mock route not found`
3. Mock 验证通过后，再配置 `TEST_REAL` 和 `TEST_BASE_URL`
4. 按本清单最少覆盖：Auth、Students、Attendance、Messages、Refunds、Reports
5. 最后做一次 `entry` 模块构建验证
