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
      primary: '#1A8C5F',
      primaryDark: '#116A49',
      light: '#EAF8F1',
      soft: '#F5FBF8',
      border: '#CDEBDD',
      gradientStart: '#EAF8F1',
      gradientEnd: '#F8FFFB',
      shadow: '#1A8C5F18'
    };
  }

  if (normalizedRole === UserRole.ORG_ADMIN) {
    return {
      primary: '#6D5DD3',
      primaryDark: '#4F46A8',
      light: '#F0EEFF',
      soft: '#FAF9FF',
      border: '#DDD8FF',
      gradientStart: '#F0EEFF',
      gradientEnd: '#FCFBFF',
      shadow: '#6D5DD318'
    };
  }

  return {
    primary: '#0A59F7',
    primaryDark: '#0646C8',
    light: '#EAF2FF',
    soft: '#F7FAFF',
    border: '#D8E6FF',
    gradientStart: '#EAF2FF',
    gradientEnd: '#F8FBFF',
    shadow: '#0A59F718'
  };
}

export function getCurrentRolePalette(): RolePalette {
  return getRolePalette(UserStore.getUserRole());
}
