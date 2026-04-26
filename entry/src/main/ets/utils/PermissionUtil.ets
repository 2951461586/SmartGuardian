/**
 * SmartGuardian - Permission Utility
 * Handle runtime permissions for camera, storage, and location
 */

import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { LogUtil } from './LogUtil';

const TAG = 'PermissionUtil';

/**
 * Permission utility for handling runtime permissions
 */
export class PermissionUtil {
  /**
   * Request camera permission
   */
  static async requestCameraPermission(context: common.UIAbilityContext): Promise<boolean> {
    const permission: Permissions = 'ohos.permission.CAMERA';
    
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const grantStatus = await atManager.checkAccessToken(
        context.applicationInfo.accessTokenId,
        permission
      );
      
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        LogUtil.info(TAG, 'Camera permission already granted');
        return true;
      }
      
      // Request permission
      const result = await atManager.requestPermissionsFromUser(context, [permission]);
      
      if (result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        LogUtil.info(TAG, 'Camera permission granted by user');
        return true;
      } else {
        LogUtil.warn(TAG, 'Camera permission denied by user');
        return false;
      }
    } catch (error) {
      LogUtil.error(TAG, `Request camera permission failed: ${JSON.stringify(error)}`);
      return false;
    }
  }
  
  /**
   * Check if camera permission is granted
   */
  static async checkCameraPermission(context: common.UIAbilityContext): Promise<boolean> {
    const permission: Permissions = 'ohos.permission.CAMERA';
    
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const grantStatus = await atManager.checkAccessToken(
        context.applicationInfo.accessTokenId,
        permission
      );
      
      return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      LogUtil.error(TAG, `Check camera permission failed: ${JSON.stringify(error)}`);
      return false;
    }
  }
  
  /**
   * Request storage permission (for reading QR code images)
   */
  static async requestStoragePermission(context: common.UIAbilityContext): Promise<boolean> {
    const permissions: Permissions[] = [
      'ohos.permission.READ_MEDIA',
      'ohos.permission.WRITE_MEDIA'
    ];
    
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(context, permissions);
      
      const allGranted = result.authResults.every(
        status => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      );
      
      if (allGranted) {
        LogUtil.info(TAG, 'Storage permission granted');
      } else {
        LogUtil.warn(TAG, 'Storage permission denied');
      }
      
      return allGranted;
    } catch (error) {
      LogUtil.error(TAG, `Request storage permission failed: ${JSON.stringify(error)}`);
      return false;
    }
  }
  
  /**
   * Request location permission (for future features)
   */
  static async requestLocationPermission(context: common.UIAbilityContext): Promise<boolean> {
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
      'ohos.permission.LOCATION'
    ];
    
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const statuses: abilityAccessCtrl.GrantStatus[] = [];
      for (let i = 0; i < permissions.length; i++) {
        const status = await atManager.checkAccessToken(
          context.applicationInfo.accessTokenId,
          permissions[i]
        );
        statuses.push(status);
      }

      const alreadyGranted = statuses.every(
        status => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      );
      if (alreadyGranted) {
        LogUtil.info(TAG, 'Location permission already granted');
        return true;
      }

      const result = await atManager.requestPermissionsFromUser(context, permissions);

      const granted = result.authResults.every(
        status => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      );

      if (granted) {
        LogUtil.info(TAG, 'Location permission granted');
      } else {
        LogUtil.warn(TAG, 'Location permission denied');
      }
      
      return granted;
    } catch (error) {
      LogUtil.error(TAG, `Request location permission failed: ${JSON.stringify(error)}`);
      return false;
    }
  }
}
