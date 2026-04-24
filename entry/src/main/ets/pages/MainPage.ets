/**
 * SmartGuardian - Main Entry Page
 * Main shell with bottom navigation for different roles
 */

import { ApiConfig } from '../config/api.config';
import { getRolePalette } from '../common/RoleTheme';
import { UserRole } from '../models/common';
import { WorkbenchManifest, WorkbenchModule } from '../models/workbench';
import { AuthService } from '../services/api/auth';
import { WorkbenchService } from '../services/api/workbench';
import { UserStore } from '../stores/userStore';
import { getToken } from '../utils/request';
import { AdminHomePage } from './admin/AdminHomePage';
import { AdminOrdersPage } from './admin/AdminOrdersPage';
import { AdminReportsPage } from './admin/AdminReportsPage';
import { AdminStudentsPage } from './admin/AdminStudentsPage';
import { AdminProfilePage } from './admin/AdminProfilePage';
import { ParentHomePage } from './parent/ParentHomePage';
import { ParentMessagesPage } from './parent/ParentMessagesPage';
import { ParentOrdersPage } from './parent/ParentOrdersPage';
import { ParentProfilePage } from './parent/ParentProfilePage';
import { ParentServicesPage } from './parent/ParentServicesPage';
import { ParentTimelinePage } from './parent/ParentTimelinePage';
import { TeacherAttendancePage } from './teacher/TeacherAttendancePage';
import { TeacherHomePage } from './teacher/TeacherHomePage';
import { TeacherHomeworkPage } from './teacher/TeacherHomeworkPage';
import { TeacherMessagesPage } from './teacher/TeacherMessagesPage';
import { TeacherProfilePage } from './teacher/TeacherProfilePage';

interface NavItem {
  code: string;
  label: ResourceStr;
  icon: Resource;
}

@Entry
@Component
struct MainPage {
  @StorageLink('main_current_index') currentIndex: number = 0;
  @StorageLink('main_auth_locked') authLocked: boolean = false;
  @State currentRole: UserRole = UserRole.PARENT;
  @State isInitializing: boolean = true;
  @State workbenchManifest: WorkbenchManifest | null = null;

  aboutToAppear() {
    this.initAuthState();
  }

  async initAuthState(): Promise<void> {
    const token = getToken();
    if (!token || !UserStore.isLoggedIn()) {
      UserStore.clearUserInfo();
      this.authLocked = true;
      this.isInitializing = false;
      this.navigateToLogin();
      return;
    }

    try {
      const resp = await AuthService.getCurrentUser();
      if (resp.code === 0 && resp.data) {
        UserStore.setUserInfo(resp.data);
        this.currentRole = resp.data.roleType;
      } else {
        UserStore.clearUserInfo();
        this.authLocked = true;
        this.navigateToLogin();
        return;
      }
    } catch (error) {
      UserStore.clearUserInfo();
      this.authLocked = true;
      this.navigateToLogin();
      return;
    }

    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.currentRole = userInfo.roleType;
    }

    this.authLocked = false;
    await this.loadWorkbenchManifest();
    this.syncStoredNavigationScope();
    this.isInitializing = false;
  }

  private async loadWorkbenchManifest(): Promise<void> {
    try {
      const resp = await WorkbenchService.getManifest();
      if (resp.code === 0 && resp.data) {
        this.workbenchManifest = resp.data;
        AppStorage.setOrCreate('workbench_manifest', resp.data);
        return;
      }
    } catch (error) {
      console.warn('MainPage load workbench manifest failed:', String(error));
    }

    this.workbenchManifest = null;
    AppStorage.delete('workbench_manifest');
  }

  private navigateToLogin(): void {
    try {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/LoginPage' });
    } catch (error) {
      this.authLocked = true;
      this.isInitializing = false;
      this.currentIndex = 0;
      console.error('MainPage navigate to login failed:', String(error));
    }
  }

  private syncStoredNavigationScope(): void {
    const userInfo = UserStore.getUserInfo();
    const manifestVersion = this.workbenchManifest?.version ?? 'fallback';
    const currentScope = `${this.currentRole}:${userInfo?.id ?? 0}:${manifestVersion}`;
    const storedScope = AppStorage.get<string>('main_navigation_scope') ?? '';

    if (storedScope !== currentScope) {
      this.currentIndex = 0;
      AppStorage.setOrCreate('main_navigation_scope', currentScope);
      return;
    }

    this.ensureValidCurrentIndex();
  }

  private ensureValidCurrentIndex(): void {
    const maxIndex = this.getNavItems().length - 1;
    if (this.currentIndex > maxIndex) {
      this.currentIndex = 0;
    }
  }

  private getRolePrimary(): string {
    return getRolePalette(this.currentRole).primary;
  }

  private getRoleLight(): string {
    return getRolePalette(this.currentRole).light;
  }

  private getRoleBorder(): string {
    return getRolePalette(this.currentRole).border;
  }

  private getRoleShadow(): string {
    return getRolePalette(this.currentRole).shadow;
  }

  private getNavItems(): NavItem[] {
    const manifestNavItems = this.getManifestNavItems();
    if (manifestNavItems.length > 0) {
      return manifestNavItems;
    }

    if (this.currentRole === UserRole.PARENT) {
      return [
        { code: 'home', label: $r('app.string.nav_home'), icon: $r('app.media.ic_home') },
        { code: 'orders', label: $r('app.string.nav_orders'), icon: $r('app.media.ic_order') },
        { code: 'messages', label: $r('app.string.nav_messages'), icon: $r('app.media.ic_message') },
        { code: 'profile', label: $r('app.string.nav_profile'), icon: $r('app.media.ic_profile') }
      ];
    }

    if (this.currentRole === UserRole.TEACHER) {
      return [
        { code: 'home', label: $r('app.string.nav_home'), icon: $r('app.media.ic_home') },
        { code: 'attendance', label: $r('app.string.nav_attendance'), icon: $r('app.media.ic_attendance') },
        { code: 'homework', label: $r('app.string.nav_homework'), icon: $r('app.media.ic_homework') }
      ];
    }

    return [
      { code: 'home', label: $r('app.string.nav_home'), icon: $r('app.media.ic_home') },
      { code: 'orders', label: $r('app.string.nav_orders'), icon: $r('app.media.ic_order') },
      { code: 'reports', label: $r('app.string.nav_reports'), icon: $r('app.media.ic_report') }
    ];
  }

  private getManifestNavItems(): NavItem[] {
    const modules = this.workbenchManifest?.modules ?? [];
    const supportedCodes = this.getSupportedNavCodes();
    const items: NavItem[] = [];

    supportedCodes.forEach((code: string) => {
      const module = modules.find((item: WorkbenchModule): boolean => item.code === code);
      if (!module || !module.enabled) {
        return;
      }
      items.push({
        code: module.code,
        label: module.name,
        icon: this.getModuleIcon(module.code)
      });
    });

    return items;
  }

  private getSupportedNavCodes(): string[] {
    if (this.currentRole === UserRole.PARENT) {
      return ['home', 'services', 'messages', 'timeline', 'profile'];
    }
    if (this.currentRole === UserRole.TEACHER) {
      return ['home', 'attendance', 'messages', 'homework', 'profile'];
    }
    return ['home', 'students', 'orders', 'reports', 'profile'];
  }

  private getModuleIcon(code: string): Resource {
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

  private getCurrentNavCode(): string {
    const navItems = this.getNavItems();
    return navItems[this.currentIndex]?.code ?? 'home';
  }

  build() {
    Column() {
      if (this.isInitializing) {
        this.buildInitializingState()
      } else if (this.authLocked) {
        this.buildAuthLockedState()
      } else {
        this.buildContent()
        this.buildBottomNav()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildInitializingState() {
    Column() {
      Column() {
        LoadingProgress()
          .color(Color.White)
          .width(36)
          .height(36)
      }
      .width(82)
      .height(82)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.getRolePrimary())
      .borderRadius(30)
      .shadow({
        radius: 22,
        color: this.getRoleShadow(),
        offsetX: 0,
        offsetY: 10
      })

      Text('正在准备工作台')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 22 })

      Text(`当前模式：${ApiConfig.getEnvironmentLabel()}`)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      Text('正在同步导航、模块入口和后端能力清单')
        .fontSize(12)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: 6 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildAuthLockedState() {
    Column() {
      Column() {
        Text('登录状态已失效')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text('请重新登录后继续使用 SmartGuardian 工作台。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .lineHeight(21)
          .margin({ top: 10 })

        Button('返回登录')
          .width('100%')
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .backgroundColor(this.getRolePrimary())
          .borderRadius(18)
          .margin({ top: 22 })
          .onClick(() => {
            this.navigateToLogin();
          })
      }
      .width('100%')
      .padding(24)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(28)
      .border({
        width: 1,
        color: '#E6ECF5',
        radius: 28,
        style: BorderStyle.Solid
      })
      .shadow({
        radius: 22,
        color: this.getRoleShadow(),
        offsetX: 0,
        offsetY: 8
      })
      .margin({ left: 24, right: 24 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildContent() {
    Stack() {
      if (this.currentRole === UserRole.PARENT) {
        if (this.getCurrentNavCode() === 'home') {
          ParentHomePage()
        } else if (this.getCurrentNavCode() === 'services') {
          ParentServicesPage()
        } else if (this.getCurrentNavCode() === 'messages') {
          ParentMessagesPage()
        } else if (this.getCurrentNavCode() === 'timeline') {
          ParentTimelinePage()
        } else if (this.getCurrentNavCode() === 'orders') {
          ParentOrdersPage()
        } else {
          ParentProfilePage()
        }
      } else if (this.currentRole === UserRole.TEACHER) {
        if (this.getCurrentNavCode() === 'home') {
          TeacherHomePage()
        } else if (this.getCurrentNavCode() === 'attendance') {
          TeacherAttendancePage()
        } else if (this.getCurrentNavCode() === 'messages') {
          TeacherMessagesPage()
        } else if (this.getCurrentNavCode() === 'homework') {
          TeacherHomeworkPage()
        } else {
          TeacherProfilePage()
        }
      } else {
        if (this.getCurrentNavCode() === 'home') {
          AdminHomePage()
        } else if (this.getCurrentNavCode() === 'students') {
          AdminStudentsPage()
        } else if (this.getCurrentNavCode() === 'orders') {
          AdminOrdersPage()
        } else if (this.getCurrentNavCode() === 'reports') {
          AdminReportsPage()
        } else {
          AdminProfilePage()
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  private buildBottomNav() {
    Column() {
      Divider()
        .color('#EEF3FA')

      Row() {
        ForEach(this.getNavItems(), (item: NavItem, index: number) => {
          this.buildNavItem(index, item.label, item.icon)
        })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 12 })
    }
    .width('100%')
    .backgroundColor($r('app.color.bottom_nav_background'))
    .shadow({
      radius: 16,
      color: '#18233F12',
      offsetX: 0,
      offsetY: -2
    })
  }

  @Builder
  private buildNavItem(index: number, label: ResourceStr, icon: Resource) {
    Column() {
      Image(icon)
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .fillColor(this.currentIndex === index ? this.getRolePrimary() : $r('app.color.nav_icon_inactive'))

      Text(label)
        .fontSize(11)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? this.getRolePrimary() : $r('app.color.nav_icon_inactive'))
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .height(58)
    .padding({ top: 6, bottom: 6 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.currentIndex === index ? this.getRoleLight() : Color.Transparent)
    .borderRadius(18)
    .border({
      width: this.currentIndex === index ? 1 : 0,
      color: this.currentIndex === index ? this.getRoleBorder() : Color.Transparent,
      radius: 18,
      style: BorderStyle.Solid
    })
    .opacity(this.currentIndex === index ? 1 : 0.96)
    .onClick(() => {
      this.currentIndex = index;
    })
  }
}
