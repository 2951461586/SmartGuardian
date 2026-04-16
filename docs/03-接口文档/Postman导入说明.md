# Postman 导入说明

> 项目名称：基于鸿蒙系统的学生智慧托管系统  
> 文档类型：Postman导入说明  
> 版本：V1.2  
> 日期：2026-04-16

---

## 一、推荐导入文件

- `openapi.yaml`
- `openapi-full.yaml`

其中 `openapi-full.yaml` 覆盖接口更多、示例更完整，推荐优先导入。

## 二、导入步骤

1. 打开 Postman。  
2. 点击 `Import`。  
3. 选择 `File` 并导入 `docs/03-接口文档/openapi-full.yaml`。  
4. 导入完成后，按标签查看各分组接口。  
5. 配置环境变量，如 `baseUrl`、`token`、`studentId`、`orderId` 等。

## 三、联调建议

- 登录接口先获取 Token。  
- 将 Token 设置为 Bearer Token 全局变量。  
- 对签到、订单、作业反馈等接口建议串联执行。  
- 使用测试环境地址进行联调，避免误调生产环境。

## 四、注意事项

- 部分接口需先准备数据库测试数据。  
- 支付回调接口建议使用 Mock 或本地签名模拟。  
- 完整字段定义与 schema 请以 OpenAPI 文件为准。
