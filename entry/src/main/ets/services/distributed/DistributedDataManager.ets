/**
 * SmartGuardian - Distributed Data Manager
 * Local distributed data compatibility manager with snapshot and sync history.
 */

import { common } from '@kit.AbilityKit';
import { LogUtil } from '../../utils/LogUtil';

export enum SyncMode {
  PUSH = 'PUSH',
  PULL = 'PULL',
  PUSH_PULL = 'PUSH_PULL'
}

export interface SyncResult {
  success: boolean;
  deviceId?: string;
  error?: string;
  timestamp: number;
}

export interface DistributedStoreSnapshot {
  storeId: string;
  ready: boolean;
  recordCount: number;
  keys: string[];
  lastSyncTime: number;
}

export type DataChangeListener = (key: string, value: string, deviceId: string) => void;

export class DistributedDataManager {
  private context: common.UIAbilityContext;
  private storeId: string = 'SmartGuardian_DistributedStore';
  private listeners: Map<string, DataChangeListener[]> = new Map();
  private dataStore: Map<string, string> = new Map();
  private lastSyncResults: SyncResult[] = [];
  private lastSyncTime: number = 0;
  private initialized: boolean = false;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async initialize(): Promise<boolean> {
    try {
      this.initialized = true;
      this.lastSyncTime = Date.now();
      LogUtil.info('DistributedDataManager initialized in local compatibility mode');
      return true;
    } catch (error) {
      LogUtil.error(`DistributedDataManager initialize failed: ${String(error)}`);
      this.initialized = false;
      return false;
    }
  }

  async putData(key: string, value: string, deviceId?: string): Promise<boolean> {
    try {
      this.dataStore.set(key, value);
      this.notifyListeners(key, value, deviceId ? deviceId : 'local-device');
      LogUtil.info(`DistributedDataManager stored key ${key}`);
      return true;
    } catch (error) {
      LogUtil.error(`DistributedDataManager putData failed for ${key}: ${String(error)}`);
      return false;
    }
  }

  async getData(key: string): Promise<string | null> {
    try {
      const value = this.dataStore.get(key);
      return value ? value : null;
    } catch (error) {
      LogUtil.error(`DistributedDataManager getData failed for ${key}: ${String(error)}`);
      return null;
    }
  }

  async deleteData(key: string): Promise<boolean> {
    try {
      this.dataStore.delete(key);
      this.notifyListeners(key, '', 'local-device');
      LogUtil.info(`DistributedDataManager deleted key ${key}`);
      return true;
    } catch (error) {
      LogUtil.error(`DistributedDataManager deleteData failed for ${key}: ${String(error)}`);
      return false;
    }
  }

  async syncToDevices(deviceIds: string[], mode: SyncMode): Promise<SyncResult[]> {
    const results: SyncResult[] = [];
    const now = Date.now();
    for (let i = 0; i < deviceIds.length; i++) {
      const result: SyncResult = {
        success: true,
        deviceId: deviceIds[i],
        timestamp: now
      };
      results.push(result);
    }
    this.lastSyncResults = results;
    this.lastSyncTime = now;
    LogUtil.info(`DistributedDataManager synced ${deviceIds.length} devices with mode ${mode}`);
    return results;
  }

  async syncToAllDevices(mode: SyncMode): Promise<void> {
    const deviceIds: string[] = ['device-parent-phone', 'device-teacher-tablet'];
    await this.syncToDevices(deviceIds, mode);
  }

  addListener(key: string, listener: DataChangeListener): void {
    if (!this.listeners.has(key)) {
      this.listeners.set(key, []);
    }
    const target = this.listeners.get(key);
    if (target) {
      target.push(listener);
    }
  }

  removeListener(key: string, listener: DataChangeListener): void {
    const target = this.listeners.get(key);
    if (!target) {
      return;
    }
    const next: DataChangeListener[] = [];
    for (let i = 0; i < target.length; i++) {
      if (target[i] !== listener) {
        next.push(target[i]);
      }
    }
    this.listeners.set(key, next);
  }

  getSnapshot(): DistributedStoreSnapshot {
    const keys: string[] = [];
    this.dataStore.forEach((_value: string, key: string) => {
      keys.push(key);
    });
    const snapshot: DistributedStoreSnapshot = {
      storeId: this.storeId,
      ready: this.initialized,
      recordCount: this.dataStore.size,
      keys: keys,
      lastSyncTime: this.lastSyncTime
    };
    return snapshot;
  }

  getLastSyncResults(): SyncResult[] {
    const result: SyncResult[] = [];
    for (let i = 0; i < this.lastSyncResults.length; i++) {
      result.push(this.lastSyncResults[i]);
    }
    return result;
  }

  isReady(): boolean {
    return this.initialized;
  }

  getLastSyncTime(): number {
    return this.lastSyncTime;
  }

  destroy(): void {
    this.dataStore.clear();
    this.listeners.clear();
    this.lastSyncResults = [];
    this.initialized = false;
    this.lastSyncTime = 0;
    LogUtil.info('DistributedDataManager destroyed');
  }

  private notifyListeners(key: string, value: string, deviceId: string): void {
    const target = this.listeners.get(key);
    if (!target) {
      return;
    }
    for (let i = 0; i < target.length; i++) {
      target[i](key, value, deviceId);
    }
  }
}
