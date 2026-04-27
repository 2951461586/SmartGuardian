# SmartGuardian 改造优化索引

> 日期：2026-04-27  
> 范围：HarmonyOS ArkTS 前端、AGC Serverless、Cloud DB、接口契约、UI 治理、文档归档。

## 主线总览

- [2026-04-25-全栈深度扫描与重构清单.md](./2026-04-25-全栈深度扫描与重构清单.md)
- [2026-04-26-文档归档与应用框架重构执行清单.md](./2026-04-26-文档归档与应用框架重构执行清单.md)
- [2026-04-26-架构服务与前端治理大颗粒执行清单.md](./2026-04-26-架构服务与前端治理大颗粒执行清单.md)
- [2026-04-27-重构改造大颗粒执行清单.md](./2026-04-27-重构改造大颗粒执行清单.md)

## 专项方案

- [2026-04-25-AGC-Serverless后端架构迁移方案.md](./2026-04-25-AGC-Serverless后端架构迁移方案.md)
- [2026-04-25-AGC云函数分域目录设计.md](./2026-04-25-AGC云函数分域目录设计.md)
- [2026-04-25-CloudDB数据模型迁移方案.md](./2026-04-25-CloudDB数据模型迁移方案.md)
- [2026-04-25-前端请求层AGC适配落地说明.md](./2026-04-25-前端请求层AGC适配落地说明.md)
- [2026-04-26-前端UI深度重构落地方案.md](./2026-04-26-前端UI深度重构落地方案.md)
- [2026-04-27-AGC客户端密钥管理说明.md](./2026-04-27-AGC客户端密钥管理说明.md)

## 执行记录

- [2026-04-27-P0-P4重构改造落地记录.md](./2026-04-27-P0-P4重构改造落地记录.md)
- [历史执行记录/2026-04-26-UI重构批次/](./历史执行记录/2026-04-26-UI重构批次/)
- [历史执行记录/2026-04-26-专项收口/](./历史执行记录/2026-04-26-专项收口/)

## 治理规则

- 主线总览只保留仍能指导当前改造的清单。
- 专项方案承载独立主题，不重复记录全量进度。
- 执行记录只记录代码落点、验证命令、结果和遗留项。
- 已完成且只用于追溯的过程性记录移动到 `历史执行记录/`。
- 门禁顺序固定为：页面注册、AGC 一致性、页面体量、UI 治理、构建 warning、`assembleHap --analyze=advanced`。

## 参考文档

- [HarmonyOS 开发文档入口](https://developer.huawei.com/consumer/cn/doc/)
- [ArkUI 指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkui)
- [AGC Cloud Functions](https://developer.huawei.com/consumer/cn/agconnect/cloud-function/)
- [AGC Cloud DB](https://developer.huawei.com/consumer/cn/agconnect/cloud-base/)
