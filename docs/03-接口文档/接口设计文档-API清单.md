# 学生智慧托管系统接口设计文档（API 清单）

> 项目名称：基于鸿蒙系统的学生智慧托管系统  
> 文档类型：接口设计文档（API 清单）  
> 文档编号：SG-API-001  
> 版本：V1.2  
> 状态：正式交付版  
> 日期：2026-04-16  
> 页眉建议：基于鸿蒙系统的学生智慧托管系统｜接口设计文档  
> 页脚建议：SmartGuardian 正式交付版｜第 X 页 / 共 Y 页

---

## 目录

- [1. 说明](#1-说明)
- [2. 接口分组](#2-接口分组)
- [3. 统一规范](#3-统一规范)
- [4. 联调建议](#4-联调建议)

---

## 1. 说明

本文依据 `openapi.yaml` 与 `openapi-full.yaml` 整理接口清单，作为正式交付版接口索引文档。字段明细、Schema 与更完整的示例请以 OpenAPI 原始文件为准。

## 2. 接口分组

### 2.1 Auth
- `POST /api/v1/auth/login`：用户登录
- `GET /api/v1/auth/me`：获取当前用户信息
- `POST /api/v1/auth/logout`：退出登录

### 2.2 Students
- `GET /api/v1/students`：查询学生列表
- `POST /api/v1/students`：新增学生档案
- `GET /api/v1/students/{studentId}`：查询学生详情
- `PUT /api/v1/students/{studentId}`：更新学生档案
- `POST /api/v1/students/{studentId}/guardians`：绑定监护关系

### 2.3 ServiceProducts
- `GET /api/v1/service-products`：查询托管服务列表
- `POST /api/v1/service-products`：新增托管服务
- `GET /api/v1/service-products/{serviceId}`：查询托管服务详情
- `PUT /api/v1/service-products/{serviceId}`：更新托管服务

### 2.4 Orders
- `GET /api/v1/orders`：查询订单列表
- `POST /api/v1/orders`：创建订单
- `POST /api/v1/orders/{orderId}/audit`：审核订单
- `POST /api/v1/orders/{orderId}/refund`：订单退费

### 2.5 Sessions
- `GET /api/v1/sessions`：查询班次列表
- `POST /api/v1/sessions/auto-schedule`：智能排课
- `GET /api/v1/sessions/{sessionId}`：查询班次详情

### 2.6 Attendance
- `GET /api/v1/attendance`：查询考勤列表
- `POST /api/v1/attendance/sign-in`：签到
- `POST /api/v1/attendance/sign-out`：签退
- `GET /api/v1/attendance/abnormal`：查询异常考勤

### 2.7 Homework
- `GET /api/v1/homework/tasks`：查询作业任务
- `POST /api/v1/homework/tasks`：新增作业任务
- `POST /api/v1/homework/feedback`：提交作业反馈
- `POST /api/v1/homework/feedback/{feedbackId}/confirm`：家长确认反馈

### 2.8 Messages
- `GET /api/v1/messages`：查询消息列表
- `POST /api/v1/messages`：发送消息
- `POST /api/v1/messages/{messageId}/read`：消息已读

### 2.9 Timeline
- `GET /api/v1/timeline/{studentId}`：查询学生动态时间线

### 2.10 Payments
- `POST /api/v1/payments/create`：创建支付单
- `POST /api/v1/payments/callback`：支付回调

### 2.11 Reports
- `GET /api/v1/reports/attendance`：考勤报表
- `GET /api/v1/reports/finance`：财务收支看板
- `GET /api/v1/reports/performance`：教师绩效统计

### 2.12 Cards
- `GET /api/v1/cards/today-summary`：今日托管卡片摘要
- `GET /api/v1/cards/abnormal-alert`：异常提醒卡片摘要

## 3. 统一规范

- 协议：HTTPS
- 风格：RESTful API
- 数据格式：JSON
- 认证方式：Bearer Token
- 标准：OpenAPI 3.0.3

## 4. 联调建议

1. 登录接口先获取 Token。  
2. 订单、签到、作业反馈建议串联联调。  
3. Postman/Swagger 调试优先导入 `openapi-full.yaml`。  
4. 与数据库字段校验时，建议同步参考字段字典与建表 SQL。
