# SmartGuardian AGC Cloud Functions Layered ZIP 包

先创建并发布层：smartguardian-nodejs-deps-layer.zip

层字段建议：
层名称：smartguardian-nodejs-deps
层描述：SmartGuardian 云函数 Node.js 公共依赖层，包含 AGC Cloud Server SDK 及生产依赖；ZIP 同时包含 nodejs/node_modules 与根 node_modules 以兼容不同 Node.js 层加载路径。
层范围：项目内共享（如果同团队多项目复用，可选团队共享）
兼容运行时：node.js
代码输入类型：*.zip

如果只是先测试 smartguardian-auth 登录链路，可暂不设置 SMARTGUARDIAN_CLOUD_DB_PROVIDER=agc，让函数使用包内 seed 数据；正式接入 Cloud DB 时再绑定本层并配置 SMARTGUARDIAN_* 环境变量。