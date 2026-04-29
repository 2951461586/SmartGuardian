/**
 * SmartGuardian - Attendance Sync Service
 * Local attendance sync compatibility service with sync status tracking.
 */

import { common } from '@kit.AbilityKit';
import { LogUtil } from '../../utils/LogUtil';
import { DistributedDataManager, DistributedStoreSnapshot, SyncMode } from './DistributedDataManager';
import { DeviceInfo, DistributedAbilityManager } from './DistributedAbilityManager';

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

export interface SyncStatus {
  lastSyncTime: number;
  pendingRecords: number;
  syncedDevices: string[];
}

export class AttendanceSyncService {
  private context: common.UIAbilityContext;
  private dataManager: DistributedDataManager;
  private abilityManager: DistributedAbilityManager;
  private syncInterval: number = 30000;
  private timerId: number = 0;
  private isRunning: boolean = false;
  private lastSyncTime: number = 0;
  private pendingRecordIds: number[] = [];

  constructor(context: common.UIAbilityContext) {
    this.context = context;
    this.dataManager = new DistributedDataManager(context);
    this.abilityManager = new DistributedAbilityManager(context);
  }

  async start(): Promise<boolean> {
    try {
      const dataReady = await this.dataManager.initialize();
      const abilityReady = await this.abilityManager.initialize();
      if (!dataReady || !abilityReady) {
        LogUtil.error('AttendanceSyncService start failed during initialization');
        return false;
      }

      this.startPeriodicSync();
      this.isRunning = true;
      this.lastSyncTime = Date.now();
      LogUtil.info('AttendanceSyncService started in local compatibility mode');
      return true;
    } catch (error) {
      LogUtil.error(`AttendanceSyncService start failed: ${String(error)}`);
      return false;
    }
  }

  stop(): void {
    if (this.timerId > 0) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }
    this.isRunning = false;
    this.pendingRecordIds = [];
    this.dataManager.destroy();
    this.abilityManager.destroy();
    LogUtil.info('AttendanceSyncService stopped');
  }

  async uploadSignInRecord(record: AttendanceRecord): Promise<boolean> {
    try {
      const recordKey = `attendance_${record.id}`;
      const recordValue = JSON.stringify(record);
      const recordSaved = await this.dataManager.putData(recordKey, recordValue, record.deviceId);
      const childKey = `attendance_child_${record.studentId}_${this.extractDate(record.signInTime)}`;
      const childSaved = await this.dataManager.putData(childKey, recordValue, record.deviceId);

      if (recordSaved && childSaved && this.pendingRecordIds.indexOf(record.id) < 0) {
        this.pendingRecordIds.push(record.id);
      }
      return recordSaved && childSaved;
    } catch (error) {
      LogUtil.error(`AttendanceSyncService uploadSignInRecord failed: ${String(error)}`);
      return false;
    }
  }

  async getChildAttendance(childId: number, date: string): Promise<AttendanceRecord | null> {
    try {
      const key = `attendance_child_${childId}_${date}`;
      const data = await this.dataManager.getData(key);
      if (!data) {
        return null;
      }
      return JSON.parse(data) as AttendanceRecord;
    } catch (error) {
      LogUtil.error(`AttendanceSyncService getChildAttendance failed: ${String(error)}`);
      return null;
    }
  }

  async syncSignInStatus(classId: number): Promise<void> {
    try {
      await this.dataManager.syncToAllDevices(SyncMode.PUSH_PULL);
      this.pendingRecordIds = [];
      this.lastSyncTime = Date.now();
      LogUtil.info(`AttendanceSyncService synced class ${classId}`);
    } catch (error) {
      LogUtil.error(`AttendanceSyncService syncSignInStatus failed: ${String(error)}`);
    }
  }

  async getSyncStatus(): Promise<SyncStatus> {
    const devices = await this.abilityManager.getTrustedDevices();
    const syncedDevices: string[] = [];
    for (let i = 0; i < devices.length; i++) {
      if (devices[i].isOnline) {
        syncedDevices.push(devices[i].deviceId);
      }
    }
    const status: SyncStatus = {
      lastSyncTime: this.lastSyncTime,
      pendingRecords: this.pendingRecordIds.length,
      syncedDevices: syncedDevices
    };
    return status;
  }

  async getTrustedDevices(): Promise<DeviceInfo[]> {
    return this.abilityManager.getTrustedDevices();
  }

  getStoreSnapshot(): DistributedStoreSnapshot {
    return this.dataManager.getSnapshot();
  }

  isActive(): boolean {
    return this.isRunning;
  }

  getLastSyncTime(): number {
    return this.lastSyncTime;
  }

  private startPeriodicSync(): void {
    if (this.timerId > 0) {
      clearInterval(this.timerId);
    }
    this.timerId = setInterval(() => {
      this.performPeriodicSync();
    }, this.syncInterval);
  }

  private async performPeriodicSync(): Promise<void> {
    if (!this.isRunning) {
      return;
    }
    try {
      await this.dataManager.syncToAllDevices(SyncMode.PUSH_PULL);
      this.lastSyncTime = Date.now();
      this.pendingRecordIds = [];
      LogUtil.info('AttendanceSyncService periodic sync completed');
    } catch (error) {
      LogUtil.error(`AttendanceSyncService periodic sync failed: ${String(error)}`);
    }
  }

  private extractDate(value: string): string {
    if (value && value.indexOf('T') > -1) {
      return value.substring(0, 10);
    }
    return this.getTodayDate();
  }

  private getTodayDate(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = `${now.getMonth() + 1}`.padStart(2, '0');
    const day = `${now.getDate()}`.padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}
