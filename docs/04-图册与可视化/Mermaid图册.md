# Mermaid 图册

> 项目名称：基于鸿蒙系统的学生智慧托管系统  
> 文档类型：图册与可视化  
> 版本：V1.4  
> 日期：2026-04-27

---

## 一、业务闭环图

```mermaid
flowchart LR
A[家长预约] --> B[订单审核]
B --> C[智能排课]
C --> D[学生签到]
D --> E[作业辅导]
E --> F[家校反馈]
F --> G[签退接回]
G --> H[数据统计分析]
```

## 二、签到异常预警时序

```mermaid
sequenceDiagram
participant P as 家长
participant T as 教师终端
participant A as 考勤服务
participant M as 消息中心
participant W as 预警中心
T->>A: 发起签到
A->>A: 校验订单/班次/时间窗
alt 签到正常
A-->>M: 推送签到成功消息
M-->>P: 通知已签到
else 触发异常
A-->>W: 生成异常事件
W-->>M: 下发预警通知
M-->>P: 推送异常提醒
end
```

## 三、核心 ER 关系图（文字简化版）

```mermaid
erDiagram
USER ||--o{ GUARDIAN_RELATION : binds
STUDENT ||--o{ GUARDIAN_RELATION : has
STUDENT ||--o{ ORDER_INFO : owns
SERVICE_PRODUCT ||--o{ ORDER_INFO : belongs
SERVICE_PRODUCT ||--o{ SESSION_SCHEDULE : generates
STUDENT ||--o{ ATTENDANCE_RECORD : attends
STUDENT ||--o{ HOMEWORK_TASK : has
HOMEWORK_TASK ||--o{ HOMEWORK_FEEDBACK : produces
USER ||--o{ MESSAGE_RECORD : sends
USER ||--o{ MESSAGE_RECORD : receives
STUDENT ||--o{ STUDENT_TIMELINE : generates
STUDENT ||--o{ ALERT_RECORD : triggers
USER ||--o{ ALERT_RECORD : acknowledges
USER ||--o{ ALERT_RECORD : resolves
ORDER_INFO ||--o{ REFUND_RECORD : has
USER ||--o{ REFUND_RECORD : reviews
```

**新增实体说明：**
- `ALERT_RECORD`：告警记录，关联学生、确认人、解决人
- `REFUND_RECORD`：退款记录，关联订单、审核人

## 四、分层架构图

```mermaid
flowchart TB
A[HarmonyOS 家长端/教师端/管理端] --> B[AGC API Gateway]
B --> C[Cloud Functions: auth]
B --> D[Cloud Functions: order/service]
B --> E[Cloud Functions: attendance]
B --> F[Cloud Functions: homework/message]
B --> G[Cloud Functions: report/alert/refund]
C --> I[(AGC Cloud DB)]
D --> I
E --> I
F --> I
G --> I
B --> J[AGConnect Auth]
B --> K[NotificationKit / Location / Push Endpoint]
```

## 五、告警处理时序图

```mermaid
sequenceDiagram
participant S as 系统/考勤服务
participant A as 告警服务
participant N as 消息中心
participant T as 教师/管理员
participant P as 家长

S->>A: 触发异常事件（迟到/缺勤等）
A->>A: 创建告警记录
A->>N: 推送预警通知
N-->>T: 通知管理员处理
N-->>P: 通知家长异常

alt 管理员确认
T->>A: 确认告警(acknowledge)
A->>A: 更新状态为已确认
A-->>N: 发送确认通知
else 直接解决
T->>A: 解决告警(resolve)
A->>A: 更新状态为已解决
A-->>N: 发送解决通知
else 忽略告警
T->>A: 忽略告警(dismiss)
A->>A: 更新状态为已忽略
end
```

## 六、退款处理流程图

```mermaid
flowchart TD
A[家长发起退款申请] --> B{订单状态判断}
B -->|已支付未开始| C[创建退款申请]
B -->|服务已开始| D[退款金额计算]
D --> E{是否可退款?}
E -->|是| C
E -->|否| F[拒绝退款申请]

C --> G[退款审核]
G --> H{审核结果}
H -->|通过| I[发起退款打款]
I --> J[更新订单状态]
J --> K[通知家长]
H -->|拒绝| L[通知家长拒绝原因]

subgraph 退款金额计算规则
D --> D1[查看服务进度]
D1 --> D2[计算已消费金额]
D2 --> D3[计算可退金额]
end
```
