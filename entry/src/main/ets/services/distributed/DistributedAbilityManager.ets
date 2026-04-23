/**
 * SmartGuardian - Distributed Ability Manager
 * Stubbed distributed ability manager with observable device state
 */

import { common } from '@kit.AbilityKit';
import { LogUtil } from '../../utils/LogUtil';

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  isOnline: boolean;
  networkId?: string;
  lastSeenAt?: number;
}

export interface RemoteInvokeResult {
  success: boolean;
  deviceId: string;
  serviceName: string;
  method: string;
  timestamp: number;
  message: string;
}

export type OnDeviceFound = (device: DeviceInfo) => void;
export type OnDeviceStateChanged = (deviceId: string, online: boolean) => void;

export class DistributedAbilityManager {
  private context: common.UIAbilityContext;
  private onDeviceFoundCallbacks: OnDeviceFound[] = [];
  private onDeviceStateCallbacks: OnDeviceStateChanged[] = [];
  private devices: DeviceInfo[] = [];
  private initialized: boolean = false;
  private discovering: boolean = false;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async initialize(): Promise<boolean> {
    try {
      if (!this.initialized) {
        this.bootstrapDevices();
        this.initialized = true;
      }
      LogUtil.info('DistributedAbilityManager initialized in stub mode');
      return true;
    } catch (error) {
      LogUtil.error(`DistributedAbilityManager initialize failed: ${String(error)}`);
      return false;
    }
  }

  async discoverDevices(duration: number = 60000): Promise<void> {
    if (!this.initialized) {
      await this.initialize();
    }

    this.discovering = true;
    for (let i = 0; i < this.devices.length; i++) {
      const device = this.devices[i];
      if (device.isOnline) {
        this.notifyDeviceFound(device);
        this.notifyDeviceState(device.deviceId, true);
      }
    }

    setTimeout(() => {
      this.discovering = false;
    }, duration);
    LogUtil.info(`DistributedAbilityManager discovery started for ${duration}ms`);
  }

  async stopDiscovery(): Promise<void> {
    this.discovering = false;
    LogUtil.info('DistributedAbilityManager discovery stopped');
  }

  async getTrustedDevices(): Promise<DeviceInfo[]> {
    const result: DeviceInfo[] = [];
    for (let i = 0; i < this.devices.length; i++) {
      result.push(this.copyDevice(this.devices[i]));
    }
    return result;
  }

  async startRemoteAbility(
    deviceId: string,
    abilityName: string,
    params?: Record<string, Object>
  ): Promise<boolean> {
    const target = this.findDevice(deviceId);
    if (!target || !target.isOnline) {
      LogUtil.warn(`DistributedAbilityManager startRemoteAbility skipped for offline device ${deviceId}`);
      return false;
    }

    LogUtil.info(`DistributedAbilityManager stub start ability ${abilityName} on ${deviceId} with params ${JSON.stringify(params ?? {})}`);
    return true;
  }

  async migrateToRemoteDevice(deviceId: string, data: Record<string, Object>): Promise<boolean> {
    const target = this.findDevice(deviceId);
    if (!target || !target.isOnline) {
      return false;
    }
    LogUtil.info(`DistributedAbilityManager migrated ${Object.keys(data).length} fields to ${deviceId}`);
    return true;
  }

  async invokeRemoteService(
    deviceId: string,
    serviceName: string,
    method: string,
    params: Object
  ): Promise<Object | null> {
    const target = this.findDevice(deviceId);
    if (!target || !target.isOnline) {
      return null;
    }

    const result: RemoteInvokeResult = {
      success: true,
      deviceId: deviceId,
      serviceName: serviceName,
      method: method,
      timestamp: Date.now(),
      message: `stub invoked with ${JSON.stringify(params)}`
    };
    LogUtil.info(`DistributedAbilityManager invoked ${serviceName}.${method} on ${deviceId}`);
    return result as Object;
  }

  addOnDeviceFoundCallback(callback: OnDeviceFound): void {
    this.onDeviceFoundCallbacks.push(callback);
  }

  addOnDeviceStateCallback(callback: OnDeviceStateChanged): void {
    this.onDeviceStateCallbacks.push(callback);
  }

  getOnlineDeviceCount(): number {
    let count = 0;
    for (let i = 0; i < this.devices.length; i++) {
      if (this.devices[i].isOnline) {
        count++;
      }
    }
    return count;
  }

  getPrimaryDevice(): DeviceInfo | null {
    if (this.devices.length === 0) {
      return null;
    }
    return this.copyDevice(this.devices[0]);
  }

  isReady(): boolean {
    return this.initialized;
  }

  isDiscovering(): boolean {
    return this.discovering;
  }

  destroy(): void {
    this.onDeviceFoundCallbacks = [];
    this.onDeviceStateCallbacks = [];
    this.discovering = false;
    LogUtil.info('DistributedAbilityManager destroyed');
  }

  private bootstrapDevices(): void {
    if (this.devices.length > 0) {
      return;
    }

    const now = Date.now();
    const phone: DeviceInfo = {
      deviceId: 'device-parent-phone',
      deviceName: '家长手机',
      deviceType: 'PHONE',
      isOnline: true,
      networkId: 'network-parent-phone',
      lastSeenAt: now
    };
    const tablet: DeviceInfo = {
      deviceId: 'device-teacher-tablet',
      deviceName: '教师平板',
      deviceType: 'TABLET',
      isOnline: true,
      networkId: 'network-teacher-tablet',
      lastSeenAt: now
    };
    const board: DeviceInfo = {
      deviceId: 'device-campus-board',
      deviceName: '前台大屏',
      deviceType: 'DISPLAY',
      isOnline: false,
      networkId: 'network-campus-board',
      lastSeenAt: now - 180000
    };

    this.devices.push(phone);
    this.devices.push(tablet);
    this.devices.push(board);
  }

  private copyDevice(device: DeviceInfo): DeviceInfo {
    const result: DeviceInfo = {
      deviceId: device.deviceId,
      deviceName: device.deviceName,
      deviceType: device.deviceType,
      isOnline: device.isOnline,
      networkId: device.networkId,
      lastSeenAt: device.lastSeenAt
    };
    return result;
  }

  private findDevice(deviceId: string): DeviceInfo | null {
    for (let i = 0; i < this.devices.length; i++) {
      if (this.devices[i].deviceId === deviceId) {
        return this.devices[i];
      }
    }
    return null;
  }

  private notifyDeviceFound(device: DeviceInfo): void {
    for (let i = 0; i < this.onDeviceFoundCallbacks.length; i++) {
      this.onDeviceFoundCallbacks[i](this.copyDevice(device));
    }
  }

  private notifyDeviceState(deviceId: string, online: boolean): void {
    for (let i = 0; i < this.onDeviceStateCallbacks.length; i++) {
      this.onDeviceStateCallbacks[i](deviceId, online);
    }
  }
}
