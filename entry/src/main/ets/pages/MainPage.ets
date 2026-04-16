/**
 * SmartGuardian - Main Entry Page
 * Main shell with bottom navigation for different roles
 */

import { UserStore } from '../stores/userStore';
import { UserRole } from '../models/common';

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
  @State currentIndex: number = 0;
  @State currentRole: string = 'PARENT';

  aboutToAppear() {
    // Get current user role from store
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.currentRole = userInfo.role;
    }
  }

  build() {
    Column() {
      // Main content area
      this.buildContent()

      // Bottom navigation
      this.buildBottomNav()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildContent() {
    // Parent role pages
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
    }
    // Teacher role pages
    else if (this.currentRole === UserRole.TEACHER) {
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
    }
    // Admin role pages
    else {
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
    .width('25%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
    })
  }
}