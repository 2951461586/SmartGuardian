/**
 * SmartGuardian - Main Entry Page
 * Main shell with bottom navigation for different roles
 */

import { AuthService } from '../services/api/auth';
import { UserStore } from '../stores/userStore';
import { UserRole } from '../models/common';
import { getToken } from '../utils/request';

// Import page components
import { ParentHomePage } from './parent/ParentHomePage';
import { ParentOrdersPage } from './parent/ParentOrdersPage';
import { ParentMessagesPage } from './parent/ParentMessagesPage';
import { ParentProfilePage } from './parent/ParentProfilePage';
import { TeacherHomePage } from './teacher/TeacherHomePage';
import { TeacherAttendancePage } from './teacher/TeacherAttendancePage';
import { TeacherHomeworkPage } from './teacher/TeacherHomeworkPage';
import { AdminHomePage } from './admin/AdminHomePage';
import { AdminOrdersPage } from './admin/AdminOrdersPage';
import { AdminReportsPage } from './admin/AdminReportsPage';

@Entry
@Component
struct MainPage {
  @StorageLink('main_current_index') currentIndex: number = 0;
  @StorageLink('main_auth_locked') authLocked: boolean = false;
  @State currentRole: UserRole = UserRole.PARENT;
  @State isInitializing: boolean = true;

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
    this.syncStoredNavigationScope();
    this.isInitializing = false;
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
    const currentScope = `${this.currentRole}:${userInfo?.id ?? 0}`;
    const storedScope = AppStorage.get<string>('main_navigation_scope') ?? '';

    if (storedScope !== currentScope) {
      this.currentIndex = 0;
      AppStorage.setOrCreate('main_navigation_scope', currentScope);
      return;
    }

    this.ensureValidCurrentIndex();
  }

  getNavItemWidth(): string {
    return this.currentRole === UserRole.PARENT ? '25%' : '33.33%';
  }

  ensureValidCurrentIndex(): void {
    const maxIndex = this.currentRole === UserRole.PARENT ? 3 : 2;
    if (this.currentIndex > maxIndex) {
      this.currentIndex = 0;
    }
  }

  build() {
    Column() {
      if (this.isInitializing) {
        Column() {
          LoadingProgress()
            .color($r('app.color.primary'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.authLocked) {
        Column({ space: 12 }) {
          Text('登录状态已失效')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text('请重新登录以继续使用')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
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
  buildContent() {
    if (this.currentRole === UserRole.PARENT) {
      Stack() {
        if (this.currentIndex === 0) {
          ParentHomePage()
        } else if (this.currentIndex === 1) {
          ParentOrdersPage()
        } else if (this.currentIndex === 2) {
          ParentMessagesPage()
        } else if (this.currentIndex === 3) {
          ParentProfilePage()
        }
      }
      .layoutWeight(1)
    } else if (this.currentRole === UserRole.TEACHER) {
      Stack() {
        if (this.currentIndex === 0) {
          TeacherHomePage()
        } else if (this.currentIndex === 1) {
          TeacherAttendancePage()
        } else if (this.currentIndex === 2) {
          TeacherHomeworkPage()
        }
      }
      .layoutWeight(1)
    } else {
      Stack() {
        if (this.currentIndex === 0) {
          AdminHomePage()
        } else if (this.currentIndex === 1) {
          AdminOrdersPage()
        } else if (this.currentIndex === 2) {
          AdminReportsPage()
        }
      }
      .layoutWeight(1)
    }
  }

  @Builder
  buildBottomNav() {
    Row() {
      if (this.currentRole === UserRole.PARENT) {
        this.buildNavItem(0, $r('app.string.nav_home'), $r('app.media.ic_home'))
        this.buildNavItem(1, $r('app.string.nav_orders'), $r('app.media.ic_order'))
        this.buildNavItem(2, $r('app.string.nav_messages'), $r('app.media.ic_message'))
        this.buildNavItem(3, $r('app.string.nav_profile'), $r('app.media.ic_profile'))
      } else if (this.currentRole === UserRole.TEACHER) {
        this.buildNavItem(0, $r('app.string.nav_home'), $r('app.media.ic_home'))
        this.buildNavItem(1, $r('app.string.nav_attendance'), $r('app.media.ic_attendance'))
        this.buildNavItem(2, $r('app.string.nav_homework'), $r('app.media.ic_homework'))
      } else {
        this.buildNavItem(0, $r('app.string.nav_home'), $r('app.media.ic_home'))
        this.buildNavItem(1, $r('app.string.nav_orders'), $r('app.media.ic_order'))
        this.buildNavItem(2, $r('app.string.nav_reports'), $r('app.media.ic_report'))
      }
    }
    .width('100%')
    .height($r('app.float.bottom_nav_height'))
    .backgroundColor($r('app.color.bottom_nav_background'))
    .padding({ top: $r('app.float.nav_padding') })
  }

  @Builder
  buildNavItem(index: number, label: ResourceStr, icon: Resource) {
    Column() {
      Image(icon)
        .width($r('app.float.nav_icon_size'))
        .height($r('app.float.nav_icon_size'))
        .objectFit(ImageFit.Contain)
        .fillColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.nav_icon_inactive'))

      Text(label)
        .fontSize($r('app.float.nav_text_size'))
        .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.nav_icon_inactive'))
        .margin({ top: $r('app.float.nav_text_margin') })
    }
    .width(this.getNavItemWidth())
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
    })
  }
}
