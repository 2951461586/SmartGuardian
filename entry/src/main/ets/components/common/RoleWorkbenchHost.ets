import { renderWorkbenchPage } from '../../common/WorkbenchRegistry';
import { UserRole } from '../../models/common';
import { AdminHomePageContent } from '../../pages/admin/AdminHomePage';
import { AdminOrdersPageContent } from '../../pages/admin/AdminOrdersPage';
import { AdminProfilePageContent } from '../../pages/admin/AdminProfilePage';
import { AdminReportsPageContent } from '../../pages/admin/AdminReportsPage';
import { AdminStudentsPageContent } from '../../pages/admin/AdminStudentsPage';
import { ParentHomePageContent } from '../../pages/parent/ParentHomePage';
import { ParentMessagesPageContent } from '../../pages/parent/ParentMessagesPage';
import { ParentOrdersPageContent } from '../../pages/parent/ParentOrdersPage';
import { ParentProfilePageContent } from '../../pages/parent/ParentProfilePage';
import { ParentServicesPageContent } from '../../pages/parent/ParentServicesPage';
import { ParentTimelinePageContent } from '../../pages/parent/ParentTimelinePage';
import { TeacherAttendancePageContent } from '../../pages/teacher/TeacherAttendancePage';
import { TeacherHomePageContent } from '../../pages/teacher/TeacherHomePage';
import { TeacherHomeworkPageContent } from '../../pages/teacher/TeacherHomeworkPage';
import { TeacherMessagesPageContent } from '../../pages/teacher/TeacherMessagesPage';
import { TeacherProfilePageContent } from '../../pages/teacher/TeacherProfilePage';

@Component
export struct RoleWorkbenchHost {
  @Prop role: UserRole = UserRole.PARENT;
  @Prop navCode: string = 'home';

  build() {
    Stack() {
      if (this.role === UserRole.PARENT) {
        this.buildParentWorkbench(renderWorkbenchPage(this.role, this.navCode))
      } else if (this.role === UserRole.TEACHER) {
        this.buildTeacherWorkbench(renderWorkbenchPage(this.role, this.navCode))
      } else {
        this.buildAdminWorkbench(renderWorkbenchPage(this.role, this.navCode))
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildParentWorkbench(pageCode: string) {
    if (pageCode === 'services') {
      ParentServicesPageContent()
    } else if (pageCode === 'messages') {
      ParentMessagesPageContent()
    } else if (pageCode === 'timeline') {
      ParentTimelinePageContent()
    } else if (pageCode === 'orders') {
      ParentOrdersPageContent()
    } else if (pageCode === 'profile') {
      ParentProfilePageContent()
    } else {
      ParentHomePageContent()
    }
  }

  @Builder
  private buildTeacherWorkbench(pageCode: string) {
    if (pageCode === 'attendance') {
      TeacherAttendancePageContent()
    } else if (pageCode === 'messages') {
      TeacherMessagesPageContent()
    } else if (pageCode === 'homework') {
      TeacherHomeworkPageContent()
    } else if (pageCode === 'profile') {
      TeacherProfilePageContent()
    } else {
      TeacherHomePageContent()
    }
  }

  @Builder
  private buildAdminWorkbench(pageCode: string) {
    if (pageCode === 'students') {
      AdminStudentsPageContent()
    } else if (pageCode === 'orders') {
      AdminOrdersPageContent()
    } else if (pageCode === 'reports') {
      AdminReportsPageContent()
    } else if (pageCode === 'profile') {
      AdminProfilePageContent()
    } else {
      AdminHomePageContent()
    }
  }
}
