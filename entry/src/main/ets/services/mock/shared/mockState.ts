import { UserInfo } from '../../../models/user';
import { StorageKeys } from '../../../constants/app.constants';
import { mockUsers } from '../mockData';

export class MockSessionState {
  private static currentUser: UserInfo = mockUsers[0];

  static getCurrentUser(): UserInfo {
    const storedUser = AppStorage.get<UserInfo>(StorageKeys.USER_INFO);
    if (storedUser) {
      this.currentUser = storedUser;
    }
    return this.currentUser;
  }

  static setCurrentUser(user: UserInfo): void {
    this.currentUser = user;
  }

  static resetCurrentUser(): void {
    this.currentUser = mockUsers[0];
  }
}
