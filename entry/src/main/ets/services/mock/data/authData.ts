import { UserRole } from '../../../models/common';
import { LoginResponse, UserInfo } from '../../../models/user';
import { mockUsers } from './userData';

export const mockV2Examples = {
  authResponse: {
    token: 'v2_mock_token_' + Date.now(),
    refreshToken: 'v2_refresh_token_' + Date.now(),
    expiresIn: 7200,
    tokenType: 'Bearer',
    userInfo: {
      id: 1,
      username: 'parent_zhang',
      realName: 'Zhang Li',
      mobile: '13800000001',
      roleType: 'PARENT',
      avatar: 'https://example.com/avatar/parent_zhang.jpg'
    }
  },
  attendanceResponse: {
    id: 1,
    studentId: 1,
    sessionId: 1,
    signInTime: new Date().toISOString(),
    signOutTime: null,
    status: 'SIGNED_IN',
    studentName: 'Wang Xiaoming',
    studentNo: 'S20260001',
    sessionNo: 'SES20260416001',
    attendanceDate: new Date().toISOString().split('T')[0],
    signInMethod: 'FACE',
    signInLocation: 'Campus Classroom A'
  },
  messageResponse: {
    id: Date.now(),
    userId: 1,
    msgType: 'ATTENDANCE',
    title: 'Sign-in notice',
    content: 'The student has arrived at the campus classroom safely.',
    readStatus: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
};

function isAdminRole(roleType: UserRole): boolean {
  return roleType === UserRole.ADMIN ||
    roleType === UserRole.ORG_ADMIN ||
    roleType === UserRole.SCHOOL_ADMIN ||
    roleType === UserRole.PLATFORM_ADMIN;
}

function findMockUserByRole(roleType?: UserRole): UserInfo | undefined {
  if (!roleType) {
    return undefined;
  }

  if (isAdminRole(roleType)) {
    return mockUsers.find((user: UserInfo) => isAdminRole(user.roleType));
  }

  return mockUsers.find((user: UserInfo) => user.roleType === roleType);
}

export function getMockLoginResponse(username: string, roleType?: UserRole): LoginResponse {
  const normalizedUsername = username.trim();
  const user = mockUsers.find((item: UserInfo) => item.username === normalizedUsername) ??
    findMockUserByRole(roleType) ??
    mockUsers[0];

  return {
    token: 'mock_token_' + Date.now(),
    expiresIn: 7200,
    userInfo: user
  };
}
