# SmartGuardian AGC Cloud Functions ZIP 包

上传顺序建议：
1. 先上传 smartguardian-auth.zip，配置入口 index.handler，HTTP POST 触发器。
2. 再上传 smartguardian-workbench.zip，跑通登录后的工作台能力。
3. 继续上传其余业务域函数。

统一环境变量：
SMARTGUARDIAN_CLOUD_DB_PROVIDER=agc
AGC_CLOUD_DB_ZONE=ClouddbDev
AGC_REGION=CN

注意：包内未包含 secrets/*.json。若 AGC Cloud Functions 运行时需要 Server SDK 文件凭据，请在控制台安全配置或环境变量中配置，不建议把私钥打进 ZIP。
