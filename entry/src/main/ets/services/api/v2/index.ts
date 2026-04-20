/**
 * SmartGuardian - API Services (V2) [BETA]
 * 
 * @description 实验性 API 服务架构，提供类型安全和链式调用
 * @beta 此模块为实验版本，尚未启用，仅供未来 API 升级预研
 * @status RESERVED - 预留架构，暂未投入使用
 * 
 * @features
 * - 类型安全的 API 调用
 * - 统一的错误处理
 * - 自动重试机制
 * - 结果链式处理
 * 
 * @note 当前项目使用 v1 API（../services/api/），v2 为未来升级预留
 * @see ../services/api/ - 当前生产环境 API 服务
 */

export { AuthApi, StudentApi } from './AuthApi';
export { AttendanceApi } from './AttendanceApi';
export { MessageApi } from './MessageApi';