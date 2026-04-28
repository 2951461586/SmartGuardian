import { UserRole } from '../models/common';
import { UserStore } from '../stores/userStore';

export interface RolePalette {
  primary: string;
  primaryDark: string;
  light: string;
  soft: string;
  border: string;
  gradientStart: string;
  gradientEnd: string;
  shadow: string;
}

function isAdminRole(role?: UserRole | null): boolean {
  return role === UserRole.ADMIN ||
    role === UserRole.ORG_ADMIN ||
    role === UserRole.SCHOOL_ADMIN ||
    role === UserRole.PLATFORM_ADMIN;
}

export function normalizeRole(role?: UserRole | null): UserRole {
  if (role === UserRole.TEACHER) {
    return UserRole.TEACHER;
  }
  if (isAdminRole(role)) {
    return UserRole.ORG_ADMIN;
  }
  return UserRole.PARENT;
}

export function getRolePalette(role?: UserRole | null): RolePalette {
  const normalizedRole = normalizeRole(role);
  if (normalizedRole === UserRole.TEACHER) {
    return {
      primary: '#2D765E',
      primaryDark: '#205844',
      light: '#EDF6F1',
      soft: '#F7FBF8',
      border: '#D5E8DD',
      gradientStart: '#EDF6F1',
      gradientEnd: '#F9FCFA',
      shadow: '#2D765E14'
    };
  }

  if (normalizedRole === UserRole.ORG_ADMIN) {
    return {
      primary: '#526A83',
      primaryDark: '#34495E',
      light: '#EEF3F7',
      soft: '#F8FAFC',
      border: '#D8E2EA',
      gradientStart: '#EEF3F7',
      gradientEnd: '#FBFCFD',
      shadow: '#526A8314'
    };
  }

  return {
    primary: '#2F7DF6',
    primaryDark: '#1F66D8',
    light: '#EAF4FF',
    soft: '#F6FAFF',
    border: '#D8E5F4',
    gradientStart: '#EAF4FF',
    gradientEnd: '#F8FBFF',
    shadow: '#2F7DF614'
  };
}

export function getCurrentRolePalette(): RolePalette {
  return getRolePalette(UserStore.getUserRole());
}
