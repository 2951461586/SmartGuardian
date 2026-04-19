# SmartGuardian 项目改造优化清单（第一部分）

> 项目名称：基于鸿蒙系统的学生智慧托管系统  
> 文档类型：改造优化清单  
> 版本：V1.0  
> 日期：2026-04-16  
> 状态：待执行

---

## 📋 改造概述

本文档基于以下维度进行全面扫描分析：
- ✅ 设计文档（需求规格、概要设计、数据库设计、API文档）
- ✅ 当前代码实现情况
- ✅ 编译警告（45个代码优化建议）
- ✅ 功能完整性与架构对齐

**改造目标**：在保证编译通过的前提下，补齐核心功能模块，消除架构差距，优化代码质量。

---

## 🎯 一、核心架构层缺失改造【高优先级】

### 1.1 API服务层完整实现 ⭐⭐⭐⭐⭐

**现状问题**：
- ✅ 已有网络请求工具：entry/src/main/ets/utils/request.ts（基于@kit.NetworkKit）
- ❌ 缺少API服务封装层（services/api目录不存在）
- ❌ OpenAPI文档定义了36+接口，代码中无对应实现
- ❌ 页面中直接使用了AuthService等未定义的服务类

**改造目标**：完整实现所有API服务模块

#### 任务清单：

| 模块 | 接口数量 | 文件路径 | 优先级 | 预估工时 |
|------|---------|---------|--------|---------|
| 认证模块 | 3 | services/api/AuthService.ets | P0 | 2h |
| 学生模块 | 5 | services/api/StudentService.ets | P0 | 3h |
| 订单模块 | 4 | services/api/OrderService.ets | P0 | 4h |
| 考勤模块 | 4 | services/api/AttendanceService.ets | P0 | 3h |
| 作业模块 | 4 | services/api/HomeworkService.ets | P1 | 3h |
| 消息模块 | 3 | services/api/MessageService.ets | P1 | 2h |
| 时间线模块 | 1 | services/api/TimelineService.ets | P1 | 1h |
| 报表模块 | 3 | services/api/ReportService.ets | P1 | 3h |
| 卡片模块 | 2 | services/api/CardService.ets | P1 | 2h |
| 支付模块 | 2 | services/api/PaymentService.ets | P2 | 2h |
| 服务产品模块 | 4 | services/api/ServiceProductService.ets | P0 | 3h |
| 班次模块 | 3 | services/api/SessionService.ets | P1 | 2h |

**总接口数**：38个  
**总预估工时**：30小时

#### 实施要点：

1. **统一代码模板**：
```typescript
import { get, post, put, del } from '../../utils/request';
import type { HttpResponse } from '../../utils/request';

export class XxxService {
  // GET请求示例
  static async getList(params: SearchParams): Promise<HttpResponse<ListData>> {
    return get<ListData>('/api/v1/xxx', params);
  }
  
  // POST请求示例
  static async create(data: CreateRequest): Promise<HttpResponse<CreateResult>> {
    return post<CreateResult>('/api/v1/xxx', data);
  }
}
```

2. **错误处理统一**：
   - 继承request.ts中的异常处理机制
   - 业务错误码映射到友好提示
   - 网络异常重试策略

3. **Mock数据支持**：
   - 提供Mock开关（通过配置文件控制）
   - 为每个Service提供Mock数据返回
   - 便于前端独立开发和测试

---

### 1.2 数据模型层完整定义 ⭐⭐⭐⭐⭐

**现状问题**：
- ❌ 缺少models目录定义
- ❌ 页面中使用的类型不明确（如LoginRequest, UserInfo等）
- ❌ OpenAPI Schema中的数据结构未映射到代码

**改造目标**：完整定义所有数据模型接口

#### 任务清单：

| 模型类别 | 文件路径 | 主要内容 | 优先级 | 预估工时 |
|---------|---------|---------|--------|---------|
| 通用模型 | models/common.ets | ApiResponse, PageResponse, UserRole等 | P0 | 2h |
| 用户模型 | models/user.ets | UserInfo, LoginRequest, LoginResponse | P0 | 1h |
| 学生模型 | models/student.ets | Student, StudentDetail, GuardianRelation | P0 | 2h |
| 订单模型 | models/order.ets | Order, OrderCreateRequest, OrderAuditRequest | P0 | 2h |
| 考勤模型 | models/attendance.ets | AttendanceRecord, SignInRequest, SignOutRequest | P0 | 2h |
| 作业模型 | models/homework.ets | HomeworkTask, HomeworkFeedback | P1 | 2h |
| 消息模型 | models/message.ets | Message, MessageSendRequest | P1 | 1h |
| 时间线模型 | models/timeline.ets | TimelineEvent, TimelineItem | P1 | 1h |
| 报表模型 | models/report.ets | AttendanceReport, FinanceReport | P1 | 2h |
| 卡片模型 | models/card.ets | TodayStatusCard, AbnormalAlertCard | P1 | 1h |

**总预估工时**：16小时

#### 实施要点：

1. **严格匹配OpenAPI Schema**：
```typescript
// 示例：与openapi.yaml中的StudentDetail保持一致
export interface StudentDetail {
  id: number;
  studentNo: string;
  name: string;
  gender?: string;
  grade: string;
  guardianUserId?: number;
  status?: string;
}
```

2. **使用class而非interface（部分场景）**：
   - 需要默认值和方法的场景使用class
   - 纯数据结构使用interface
   - 避免ArkTS结构化类型问题

3. **枚举类型定义**：
   - 订单状态：OrderStatus
   - 支付状态：PayStatus
   - 签到类型：SignInType
   - 角色类型：UserRole

---

### 1.3 状态管理实现 ⭐⭐⭐⭐

**现状问题**：
- ❌ 缺少stores目录
- ❌ 用户状态、订单状态等未统一管理
- ❌ 页面间数据共享通过路由参数传递

**改造目标**：实现核心业务状态管理

#### 任务清单：

| Store模块 | 文件路径 | 管理内容 | 优先级 | 预估工时 |
|----------|---------|---------|--------|---------|
| 用户状态 | stores/userStore.ets | 用户信息、登录状态、Token管理 | P0 | 3h |
| 学生状态 | stores/studentStore.ets | 当前学生列表、选中学生 | P0 | 2h |
| 订单状态 | stores/orderStore.ets | 订单列表、订单详情缓存 | P1 | 2h |
| 消息状态 | stores/messageStore.ets | 未读消息数、消息列表 | P1 | 2h |
| 考勤状态 | stores/attendanceStore.ets | 今日签到状态、当前班次 | P1 | 2h |

**总预估工时**：11小时

#### 实施要点：

1. **基于AppStorage实现**：
```typescript
export class UserStore {
  private static readonly USER_INFO_KEY = 'user_info';
  
  static setUserInfo(user: UserInfo): void {
    AppStorage.setOrCreate(this.USER_INFO_KEY, user);
  }
  
  static getUserInfo(): UserInfo | null {
    return AppStorage.get<UserInfo>(this.USER_INFO_KEY) ?? null;
  }
}
```

2. **响应式更新**：
   - 使用@StorageLink装饰器实现响应式
   - 数据变更自动触发UI更新

3. **持久化策略**：
   - 用户Token：存储到AppStorage
   - 敏感数据：使用加密存储
   - 临时数据：运行时内存存储