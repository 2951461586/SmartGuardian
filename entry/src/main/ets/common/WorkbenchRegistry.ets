/**
 * SmartGuardian - Workbench Registry
 * Central registry for role-aware workbench navigation and page resolution.
 */

import { RouteUrls } from '../constants/app.constants';
import { UserRole } from '../models/common';
import { WorkbenchManifest, WorkbenchModule } from '../models/workbench';

export interface WorkbenchNavItem {
  code: string;
  label: ResourceStr;
  icon: Resource;
  route: string;
}

interface WorkbenchNavDefinition extends WorkbenchNavItem {
  roles: UserRole[];
}

const ROLE_NAV_ORDER: Record<string, string[]> = {
  [UserRole.PARENT]: ['home', 'services', 'messages', 'timeline', 'profile'],
  [UserRole.TEACHER]: ['home', 'attendance', 'messages', 'homework', 'profile'],
  [UserRole.ORG_ADMIN]: ['home', 'students', 'orders', 'reports', 'profile']
};

function getWorkbenchRoute(role: UserRole, code: string): string {
  const normalizedRole = normalizeWorkbenchRole(role);

  if (normalizedRole === UserRole.PARENT) {
    if (code === 'home') return RouteUrls.PARENT_HOME;
    if (code === 'services') return RouteUrls.PARENT_SERVICES;
    if (code === 'messages') return RouteUrls.PARENT_MESSAGES;
    if (code === 'timeline') return RouteUrls.PARENT_TIMELINE;
    if (code === 'orders') return RouteUrls.PARENT_ORDERS;
    if (code === 'profile') return RouteUrls.PARENT_PROFILE;
  }

  if (normalizedRole === UserRole.TEACHER) {
    if (code === 'home') return RouteUrls.TEACHER_HOME;
    if (code === 'attendance') return RouteUrls.TEACHER_ATTENDANCE;
    if (code === 'messages') return RouteUrls.TEACHER_MESSAGES;
    if (code === 'homework') return RouteUrls.TEACHER_HOMEWORK;
    if (code === 'profile') return RouteUrls.TEACHER_PROFILE;
  }

  if (code === 'home') return RouteUrls.ADMIN_HOME;
  if (code === 'students') return RouteUrls.ADMIN_STUDENTS;
  if (code === 'orders') return RouteUrls.ADMIN_ORDERS;
  if (code === 'reports') return RouteUrls.ADMIN_REPORTS;
  if (code === 'messages') return RouteUrls.ADMIN_MESSAGES;
  if (code === 'profile') return RouteUrls.ADMIN_PROFILE;
  return RouteUrls.MAIN;
}

function fallbackNavDefinitions(): WorkbenchNavDefinition[] {
  return [
    {
      code: 'home',
      label: $r('app.string.nav_home'),
      icon: $r('app.media.ic_home'),
      route: RouteUrls.MAIN,
      roles: [UserRole.PARENT, UserRole.TEACHER, UserRole.ORG_ADMIN]
    },
    {
      code: 'services',
      label: $r('app.string.nav_services'),
      icon: $r('app.media.ic_service'),
      route: RouteUrls.PARENT_SERVICES,
      roles: [UserRole.PARENT]
    },
    {
      code: 'messages',
      label: $r('app.string.nav_messages'),
      icon: $r('app.media.ic_message'),
      route: RouteUrls.PARENT_MESSAGES,
      roles: [UserRole.PARENT, UserRole.TEACHER]
    },
    {
      code: 'timeline',
      label: $r('app.string.nav_timeline'),
      icon: $r('app.media.ic_calendar'),
      route: RouteUrls.PARENT_TIMELINE,
      roles: [UserRole.PARENT]
    },
    {
      code: 'orders',
      label: $r('app.string.nav_orders'),
      icon: $r('app.media.ic_order'),
      route: RouteUrls.PARENT_ORDERS,
      roles: [UserRole.PARENT, UserRole.ORG_ADMIN]
    },
    {
      code: 'attendance',
      label: $r('app.string.nav_attendance'),
      icon: $r('app.media.ic_attendance'),
      route: RouteUrls.TEACHER_ATTENDANCE,
      roles: [UserRole.TEACHER]
    },
    {
      code: 'homework',
      label: $r('app.string.nav_homework'),
      icon: $r('app.media.ic_homework'),
      route: RouteUrls.TEACHER_HOMEWORK,
      roles: [UserRole.TEACHER]
    },
    {
      code: 'students',
      label: $r('app.string.nav_students'),
      icon: $r('app.media.ic_child'),
      route: RouteUrls.ADMIN_STUDENTS,
      roles: [UserRole.ORG_ADMIN]
    },
    {
      code: 'reports',
      label: $r('app.string.nav_reports'),
      icon: $r('app.media.ic_report'),
      route: RouteUrls.ADMIN_REPORTS,
      roles: [UserRole.ORG_ADMIN]
    },
    {
      code: 'profile',
      label: $r('app.string.nav_profile'),
      icon: $r('app.media.ic_profile'),
      route: RouteUrls.PARENT_PROFILE,
      roles: [UserRole.PARENT, UserRole.TEACHER, UserRole.ORG_ADMIN]
    }
  ];
}

export function normalizeWorkbenchRole(role: UserRole): UserRole {
  if (role === UserRole.TEACHER) {
    return UserRole.TEACHER;
  }
  if (role === UserRole.PARENT) {
    return UserRole.PARENT;
  }
  return UserRole.ORG_ADMIN;
}

export function getWorkbenchScope(role: UserRole, userId: number, manifestVersion: string): string {
  return `${normalizeWorkbenchRole(role)}:${userId}:${manifestVersion}`;
}

export function getSupportedNavCodes(role: UserRole): string[] {
  return ROLE_NAV_ORDER[normalizeWorkbenchRole(role)] ?? ROLE_NAV_ORDER[UserRole.PARENT];
}

export function getWorkbenchNavItems(
  role: UserRole,
  manifest?: WorkbenchManifest | null
): WorkbenchNavItem[] {
  const normalizedRole = normalizeWorkbenchRole(role);
  const definitions = fallbackNavDefinitions()
    .filter((item: WorkbenchNavDefinition): boolean => {
      return item.roles.includes(normalizedRole);
    })
    .map((item: WorkbenchNavDefinition): WorkbenchNavItem => {
      return {
        code: item.code,
        label: item.label,
        icon: item.icon,
        route: getWorkbenchRoute(normalizedRole, item.code)
      };
    });
  const modules = manifest?.modules ?? [];

  if (modules.length === 0) {
    return definitions;
  }

  const manifestItems: WorkbenchNavItem[] = [];
  const supportedCodes = getSupportedNavCodes(normalizedRole);
  for (let index = 0; index < supportedCodes.length; index++) {
    const code = supportedCodes[index];
    const module = modules.find((item: WorkbenchModule): boolean => item.code === code && item.enabled);
    if (!module) {
      continue;
    }

    const fallback = definitions.find((item: WorkbenchNavItem): boolean => item.code === code);
    manifestItems.push({
      code: module.code,
      label: module.name,
      icon: getWorkbenchModuleIcon(module.code),
      route: fallback?.route ?? getWorkbenchRoute(normalizedRole, module.code)
    });
  }

  return manifestItems.length > 0 ? manifestItems : definitions;
}

export function normalizeWorkbenchNavCode(
  role: UserRole,
  navCode: string,
  manifest?: WorkbenchManifest | null
): string {
  const navItems = getWorkbenchNavItems(role, manifest);
  const fallback = navItems[0]?.code ?? 'home';
  return navItems.some((item: WorkbenchNavItem): boolean => item.code === navCode) ? navCode : fallback;
}

export function getWorkbenchModuleIcon(code: string): Resource {
  if (code === 'orders') {
    return $r('app.media.ic_order');
  }
  if (code === 'messages') {
    return $r('app.media.ic_message');
  }
  if (code === 'services') {
    return $r('app.media.ic_service');
  }
  if (code === 'timeline') {
    return $r('app.media.ic_calendar');
  }
  if (code === 'students') {
    return $r('app.media.ic_child');
  }
  if (code === 'profile') {
    return $r('app.media.ic_profile');
  }
  if (code === 'attendance') {
    return $r('app.media.ic_attendance');
  }
  if (code === 'homework') {
    return $r('app.media.ic_homework');
  }
  if (code === 'reports') {
    return $r('app.media.ic_report');
  }
  return $r('app.media.ic_home');
}

export function renderWorkbenchPage(role: UserRole, navCode: string): string {
  const normalizedRole = normalizeWorkbenchRole(role);

  if (normalizedRole === UserRole.PARENT) {
    if (navCode === 'services' || navCode === 'messages' || navCode === 'timeline' || navCode === 'orders' || navCode === 'profile') {
      return navCode;
    }
    return 'home';
  }

  if (normalizedRole === UserRole.TEACHER) {
    if (navCode === 'attendance' || navCode === 'messages' || navCode === 'homework' || navCode === 'profile') {
      return navCode;
    }
    return 'home';
  }

  if (navCode === 'students' || navCode === 'orders' || navCode === 'reports' || navCode === 'profile') {
    return navCode;
  }
  return 'home';
}
