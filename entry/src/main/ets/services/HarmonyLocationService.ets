import { common } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { PermissionUtil } from '../utils/PermissionUtil';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'HarmonyLocationService';

export class HarmonyLocationService {
  private static readonly DEFAULT_LOCATION_LABEL: string = '';

  static async captureAttendanceLocation(context: common.UIAbilityContext): Promise<string> {
    const granted = await PermissionUtil.requestLocationPermission(context);
    if (!granted) {
      LogUtil.warn(TAG, 'Location permission denied, continue without location payload');
      return HarmonyLocationService.DEFAULT_LOCATION_LABEL;
    }

    try {
      const request: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.DAILY_LIFE_SERVICE,
        timeoutMs: 5000,
        maxAccuracy: 200
      };

      const location = await geoLocationManager.getCurrentLocation(request);
      return await HarmonyLocationService.resolveLocationLabel(location);
    } catch (error) {
      LogUtil.warn(TAG, `Capture current location failed: ${String(error)}`);
      return HarmonyLocationService.DEFAULT_LOCATION_LABEL;
    }
  }

  private static async resolveLocationLabel(location: geoLocationManager.Location): Promise<string> {
    const coordinateLabel = HarmonyLocationService.buildCoordinateLabel(location);

    try {
      if (!geoLocationManager.isGeocoderAvailable()) {
        return coordinateLabel;
      }

      const addresses = await geoLocationManager.getAddressesFromLocation({
        latitude: location.latitude,
        longitude: location.longitude,
        maxItems: 1,
        locale: 'zh-CN'
      });

      if (addresses.length === 0) {
        return coordinateLabel;
      }

      const addressLabel = HarmonyLocationService.composeAddressLabel(addresses[0]);
      if (addressLabel.length === 0) {
        return coordinateLabel;
      }

      return `${addressLabel} ${coordinateLabel}`;
    } catch (error) {
      LogUtil.warn(TAG, `Reverse geocode failed: ${String(error)}`);
      return coordinateLabel;
    }
  }

  private static composeAddressLabel(address: geoLocationManager.GeoAddress): string {
    const parts: string[] = [];

    if (address.placeName && address.placeName.length > 0) {
      parts.push(address.placeName);
    }
    if (address.locality && address.locality.length > 0) {
      parts.push(address.locality);
    }
    if (address.subLocality && address.subLocality.length > 0) {
      parts.push(address.subLocality);
    }
    if (address.roadName && address.roadName.length > 0) {
      parts.push(address.roadName);
    }
    if (address.premises && address.premises.length > 0) {
      parts.push(address.premises);
    }

    return HarmonyLocationService.joinUnique(parts);
  }

  private static joinUnique(parts: string[]): string {
    const uniqueParts: string[] = [];
    for (let i = 0; i < parts.length; i++) {
      const current = parts[i];
      if (current.length === 0) {
        continue;
      }
      if (uniqueParts.indexOf(current) >= 0) {
        continue;
      }
      uniqueParts.push(current);
    }
    return uniqueParts.join(' | ');
  }

  private static buildCoordinateLabel(location: geoLocationManager.Location): string {
    const latitude = location.latitude.toFixed(6);
    const longitude = location.longitude.toFixed(6);
    const accuracy = Math.round(location.accuracy);
    return `${latitude},${longitude} +/-${accuracy}m`;
  }
}
