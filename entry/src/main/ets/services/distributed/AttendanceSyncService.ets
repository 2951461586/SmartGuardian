/**
 * SmartGuardian - 考勤数据跨设备同步服务(Simplified Stub)
 * 实现教师端和家长的考勤数据实时同步
 */

import { common } from '@kit.AbilityKit';
import { LogUtil } from '../../utils/LogUtil';
import { DistributedDataManager, SyncMode } from './DistributedDataManager';
import { DistributedAbilityManager, DeviceInfo } from './DistributedAbilityManager';

const TAG = 'AttendanceSyncService';

/**
 * 签到记录
 */
export interface AttendanceRecord {
  id: number;
  studentId: number;
  studentName: string;
  classId: number;
  className: string;
  signInTime: string;
  signOutTime?: string;
  status: string;
  deviceId: string;
  teacherId?: number;
  teacherName?: string;
  remark?: string;
}

/**
 * 同步状态
 */
export interface SyncStatus {
  lastSyncTime: number;
  pendingRecords: number;
  syncedDevices: string[];
}

/**
 * 考勤数据同步服务 (简化版本)
 */
export class AttendanceSyncService {
  private context: common.UIAbilityContext;
  private dataManager: DistributedDataManager;
  private abilityManager: DistributedAbilityManager;
  private syncInterval: number = 30000;
  private timerId: number = 0;
  private isRunning: boolean = false;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
    this.dataManager = new DistributedDataManager(context);
    this.abilityManager = new DistributedAbilityManager(context);
  }

  /**
   * 启动同步服务
   */
  async start(): Promise<boolean> {
    try {
      const dataInit = await this.dataManager.initialize();
      const abilityInit = await this.abilityManager.initialize();

      if (!dataInit || !abilityInit) {
        LogUtil.error('Failed to initialize sync service');
        return false;
      }

      this.startPeriodicSync();
      this.isRunning = true;
      LogUtil.info('AttendanceSyncService started (stub mode)');
      return true;
    } catch (error) {
      LogUtil.error('Failed to start AttendanceSyncService:', String(error));
      return false;
    }
  }

  /**
   * 停止同步服务
   */
  stop(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }

    this.dataManager.destroy();
    this.abilityManager.destroy();
    this.isRunning = false;

    LogUtil.info('AttendanceSyncService stopped');
  }

  /**
   * 教师端：上传签到记录
   */
  async uploadSignInRecord(record: AttendanceRecord): Promise<boolean> {
    try {
      const key = `attendance_${record.id}`;
      const value = JSON.stringify(record);
      const success = await this.dataManager.putData(key, value);

      if (success) {
        LogUtil.info(`Sign-in record uploaded: ${record.studentName}`);
      }

      return success;
    } catch (error) {
      LogUtil.error('Failed to upload sign-in record:', String(error));
      return false;
    }
  }

  /**
   * 家长端：获取孩子的签到记录
   */
  async getChildAttendance(childId: number, date: string): Promise<AttendanceRecord | null> {
    try {
      const key = `attendance_child_${childId}_${date}`;
      const data = await this.dataManager.getData(key);

      if (data) {
        return JSON.parse(data) as AttendanceRecord;
      }

      return null;
    } catch (error) {
      LogUtil.error('Failed to get child attendance:', String(error));
      return null;
    }
  }

  /**
   * 实时同步签到状态
   */
  async syncSignInStatus(classId: number): Promise<void> {
    try {
      await this.dataManager.syncToAllDevices(SyncMode.PUSH_PULL);
      LogUtil.info(`Sign-in status synced for class: ${classId}`);
    } catch (error) {
      LogUtil.error('Failed to sync sign-in status:', String(error));
    }
  }

  /**
   * 启动定时同步
   */
  private startPeriodicSync(): void {
    this.timerId = setInterval(() => {
      this.performPeriodicSync();
    }, this.syncInterval);
  }

  /**
   * 执行定时同步
   */
  private async performPeriodicSync(): Promise<void> {
    try {
      await this.dataManager.syncToAllDevices(SyncMode.PUSH_PULL);
      LogUtil.info('Periodic sync completed');
    } catch (error) {
      LogUtil.error('Periodic sync failed:', String(error));
    }
  }

  /**
   * 获取今日日期
   */
  private getTodayDate(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 获取同步状态
   */
  async getSyncStatus(): Promise<SyncStatus> {
    const devices = await this.abilityManager.getTrustedDevices();
    
    return {
      lastSyncTime: Date.now(),
      pendingRecords: 0,
      syncedDevices: devices.filter(d => d.isOnline).map(d => d.deviceId)
    };
  }
}