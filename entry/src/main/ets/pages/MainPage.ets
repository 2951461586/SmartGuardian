/**
 * SmartGuardian - Main Entry Page
 * Main shell with bottom navigation for different roles
 */

import { ApiConfig } from '../config/api.config';
import { UserRole } from '../models/common';
import { AuthService } from '../services/api/auth';
import { UserStore } from '../stores/userStore';
import { getToken } from '../utils/request';
import { AdminHomePage } from './admin/AdminHomePage';
import { AdminOrdersPage } from './admin/AdminOrdersPage';
import { AdminReportsPage } from './admin/AdminReportsPage';
import { ParentHomePage } from './parent/ParentHomePage';
import { ParentMessagesPage } from './parent/ParentMessagesPage';
import { ParentOrdersPage } from './parent/ParentOrdersPage';
import { ParentProfilePage } from './parent/ParentProfilePage';
import { TeacherAttendancePage } from './teacher/TeacherAttendancePage';
import { TeacherHomePage } from './teacher/TeacherHomePage';
import { TeacherHomeworkPage } from './teacher/TeacherHomeworkPage';

interface NavItem {
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

  private ensureValidCurrentIndex(): void {
    const maxIndex = this.currentRole === UserRole.PARENT ? 3 : 2;
    if (this.currentIndex > maxIndex) {
      this.currentIndex = 0;
    }
  }

  private getNavItems(): NavItem[] {
    if (this.currentRole === UserRole.PARENT) {
      return [
        { label: $r('app.string.nav_home'), icon: $r('app.media.ic_home') },
        { label: $r('app.string.nav_orders'), icon: $r('app.media.ic_order') },
        { label: $r('app.string.nav_messages'), icon: $r('app.media.ic_message') },
        { label: $r('app.string.nav_profile'), icon: $r('app.media.ic_profile') }
      ];
    }

    if (this.currentRole === UserRole.TEACHER) {
      return [
        { label: $r('app.string.nav_home'), icon: $r('app.media.ic_home') },
        { label: $r('app.string.nav_attendance'), icon: $r('app.media.ic_attendance') },
        { label: $r('app.string.nav_homework'), icon: $r('app.media.ic_homework') }
      ];
    }

    return [
      { label: $r('app.string.nav_home'), icon: $r('app.media.ic_home') },
      { label: $r('app.string.nav_orders'), icon: $r('app.media.ic_order') },
      { label: $r('app.string.nav_reports'), icon: $r('app.media.ic_report') }
    ];
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
  buildInitializingState() {
    Column() {
      Column() {
        LoadingProgress()
          .color(Color.White)
          .width(40)
          .height(40)
      }
      .width(76)
      .height(76)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.primary'))
      .borderRadius(28)
      .shadow({
        radius: 18,
        color: '#1F5EFF33',
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
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildAuthLockedState() {
    Column() {
      Column() {
        Text('登录状态已失效')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text('请重新登录后继续使用智慧学生托管系统。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 10 })

        Button('返回登录')
          .width('100%')
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(16)
          .margin({ top: 22 })
          .onClick(() => {
            this.navigateToLogin();
          })
      }
      .width('100%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(24)
      .border({
        width: 1,
        color: '#EAF0F7',
        radius: 24,
        style: BorderStyle.Solid
      })
      .shadow({
        radius: 18,
        color: '#10172F12',
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
  buildContent() {
    Stack() {
      if (this.currentRole === UserRole.PARENT) {
        if (this.currentIndex === 0) {
          ParentHomePage()
        } else if (this.currentIndex === 1) {
          ParentOrdersPage()
        } else if (this.currentIndex === 2) {
          ParentMessagesPage()
        } else {
          ParentProfilePage()
        }
      } else if (this.currentRole === UserRole.TEACHER) {
        if (this.currentIndex === 0) {
          TeacherHomePage()
        } else if (this.currentIndex === 1) {
          TeacherAttendancePage()
        } else {
          TeacherHomeworkPage()
        }
      } else {
        if (this.currentIndex === 0) {
          AdminHomePage()
        } else if (this.currentIndex === 1) {
          AdminOrdersPage()
        } else {
          AdminReportsPage()
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildBottomNav() {
    Column() {
      Row() {
        ForEach(this.getNavItems(), (item: NavItem, index: number) => {
          this.buildNavItem(index, item.label, item.icon)
        })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      .backgroundColor($r('app.color.bottom_nav_background'))
      .borderRadius(26)
      .border({
        width: 1,
        color: '#EAF0F7',
        radius: 26,
        style: BorderStyle.Solid
      })
      .shadow({
        radius: 16,
        color: '#10172F14',
        offsetX: 0,
        offsetY: 6
      })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 14 })
  }

  @Builder
  buildNavItem(index: number, label: ResourceStr, icon: Resource) {
    Column() {
      Column() {
        Image(icon)
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .fillColor(this.currentIndex === index ? Color.White : $r('app.color.nav_icon_inactive'))
      }
      .width(42)
      .height(42)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentIndex === index ? $r('app.color.primary') : '#F3F7FB')
      .borderRadius(18)

      Text(label)
        .fontSize(11)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.nav_icon_inactive'))
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .padding({ top: 6, bottom: 4 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
    })
  }
}
