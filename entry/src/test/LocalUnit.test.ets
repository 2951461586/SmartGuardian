import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { ApiConfig, ApiEnvironment, MockSwitch } from '../main/ets/config/api.config';
import { RoleRoutes, RouteUrls } from '../main/ets/constants/app.constants';
import { UserRole } from '../main/ets/models/common';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    beforeAll(() => {
    });

    beforeEach(() => {
    });

    afterEach(() => {
    });

    afterAll(() => {
    });

    it('apiConfigUsesMockBackendByDefault', 0, () => {
      expect(ApiConfig.CURRENT_ENV).assertEqual(ApiEnvironment.DEV_MOCK);
      expect(ApiConfig.getBaseUrl()).assertEqual('');
      expect(ApiConfig.isMockEnabled()).assertEqual(true);
      expect(ApiConfig.USE_MOCK_DATA).assertEqual(true);
      expect(ApiConfig.BASE_URL).assertEqual('');
      expect(MockSwitch.AUTH_SERVICE).assertEqual(true);
      expect(MockSwitch.MESSAGE_SERVICE).assertEqual(true);
    });

    it('adminRoleRoutesGoToAdminHome', 0, () => {
      expect(UserRole.ADMIN).assertEqual('ADMIN');
      expect(RoleRoutes.getDefaultRoute(UserRole.ADMIN)).assertEqual(RouteUrls.ADMIN_HOME);
      expect(RoleRoutes.getDefaultRoute('ADMIN')).assertEqual(RouteUrls.ADMIN_HOME);
      expect(RoleRoutes.getDefaultRoute(UserRole.PLATFORM_ADMIN)).assertEqual(RouteUrls.ADMIN_HOME);
      expect(RoleRoutes.getDefaultRoute('UNKNOWN')).assertEqual(RouteUrls.LOGIN);
    });
  });
}
