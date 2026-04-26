# SmartGuardian 改造优化索引

> 日期：2026-04-26  
> 范围：HarmonyOS ArkTS 前端、AGC Serverless 后端、Cloud DB、接口契约、前端 UI 治理、文档归档

## 当前主线

- 前端主壳、统一页面骨架、状态协议和工作台 manifest 已经收口。
- 后端主链路已经切到 `AGC Serverless + Cloud Functions + Cloud DB`。
- `openapi-full.yaml`、AGC 函数契约、Cloud DB schema、Mock handler 已建立一致性检查。
- 目录当前按“主线方案 / 专项方案 / 执行记录”治理，不再继续平铺同类说明。

## 阅读顺序

1. 先看主线总览，确认当前阶段目标和总体进度。
2. 再看专项方案，定位 AGC、Cloud DB、请求层等独立主题。
3. 最后按执行记录回溯具体批次落地情况。

## 主线总览

- [2026-04-25-全栈深度扫描与重构清单.md](./2026-04-25-全栈深度扫描与重构清单.md)
- [2026-04-26-前端UI深度重构落地方案.md](./2026-04-26-前端UI深度重构落地方案.md)
- [2026-04-26-架构服务与前端治理大颗粒执行清单.md](./2026-04-26-架构服务与前端治理大颗粒执行清单.md)
- [2026-04-26-文档归档与应用框架重构执行清单.md](./2026-04-26-文档归档与应用框架重构执行清单.md)

## 专项方案

- [2026-04-25-AGC-Serverless后端架构迁移方案.md](./2026-04-25-AGC-Serverless后端架构迁移方案.md)
- [2026-04-25-AGC云函数分域目录设计.md](./2026-04-25-AGC云函数分域目录设计.md)
- [2026-04-25-CloudDB数据模型迁移方案.md](./2026-04-25-CloudDB数据模型迁移方案.md)
- [2026-04-25-前端请求层AGC适配落地说明.md](./2026-04-25-前端请求层AGC适配落地说明.md)

## 执行记录

- [2026-04-26-UI深度重构第二批落地记录.md](./2026-04-26-UI深度重构第二批落地记录.md)
- [2026-04-26-UI深度重构第三批落地记录.md](./2026-04-26-UI深度重构第三批落地记录.md)
- [2026-04-26-UI深度重构第四批落地记录.md](./2026-04-26-UI深度重构第四批落地记录.md)
- [2026-04-26-UI深度重构第五批落地记录.md](./2026-04-26-UI深度重构第五批落地记录.md)
- [2026-04-26-UI深度重构第六批落地记录.md](./2026-04-26-UI深度重构第六批落地记录.md)
- [2026-04-26-UI深度重构第七批落地记录.md](./2026-04-26-UI深度重构第七批落地记录.md)
- [2026-04-26-UI深度重构第八批收口记录.md](./2026-04-26-UI深度重构第八批收口记录.md)

## 治理规则

- 同一主题只保留一份主线方案文档，后续增量优先写入原主线方案或新增批次记录。
- 专项方案用于承载独立主题，不重复描述总进度。
- 执行记录只记“本轮新增落地”，不再重写全量背景。

## 参考文档

- [HarmonyOS 开发文档入口](https://developer.huawei.com/consumer/cn/doc/)
- [ArkUI 指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [AGC Cloud Functions](https://developer.huawei.com/consumer/cn/agconnect/cloud-function/)
- [AGC Cloud DB](https://developer.huawei.com/consumer/cn/agconnect/cloud-base/)
