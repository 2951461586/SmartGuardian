import { ActivityFeedItem, ActivityFeedCard, AdminOperationsOverviewCard } from './AdminDashboardCards';
import { Card } from './Card';
import { ResponsiveSplitPanel } from './PageScaffold';
import { StatCardRow, StatRowItem } from './StatCardRow';
import { WorkbenchActionGrid } from './WorkbenchActionGrid';
import { WorkbenchModule } from '../../models/workbench';
import { UserRole } from '../../models/common';
import { getRolePalette } from '../../common/RoleTheme';

@Component
export struct AdminHomeWorkbenchSection {
  @Prop overviewTopItems: StatRowItem[] = [];
  @Prop overviewBottomItems: StatRowItem[] = [];
  @Prop quickActionTitle: string = '';
  @Prop quickActionSubtitle: string = '';
  @Prop modules: WorkbenchModule[] = [];
  subtitleResolver?: (code: string) => string;
  iconResolver?: (code: string) => Resource;
  bgColorResolver?: (code: string) => string;
  iconColorResolver?: (code: string) => string;
  onModuleClick?: (module: WorkbenchModule) => void;

  build() {
    ResponsiveSplitPanel({
      primary: this.buildOverviewPanel,
      secondary: this.buildQuickActionsPanel
    })
      .margin({ bottom: 14 })
  }

  @Builder
  private buildOverviewPanel() {
    Column() {
      StatCardRow({
        items: this.overviewTopItems
      })

      StatCardRow({
        items: this.overviewBottomItems
      })
      .margin({ top: 10 })
    }
    .width('100%')
  }

  @Builder
  private buildQuickActionsPanel() {
    Card({
      title: this.quickActionTitle,
      subtitle: this.quickActionSubtitle,
      content: this.buildQuickActions
    })
  }

  @Builder
  private buildQuickActions() {
    WorkbenchActionGrid({
      modules: this.modules,
      subtitleResolver: (code: string): string => this.resolveSubtitle(code),
      iconResolver: (code: string): Resource => this.resolveIcon(code),
      bgColorResolver: (code: string): string => this.resolveBgColor(code),
      iconColorResolver: (code: string): string => this.resolveIconColor(code),
      onModuleClick: (module: WorkbenchModule): void => {
        if (this.onModuleClick) {
          this.onModuleClick(module);
        }
      }
    })
  }

  private resolveSubtitle(code: string): string {
    if (this.subtitleResolver) {
      return this.subtitleResolver(code);
    }
    return '进入模块';
  }

  private resolveIcon(code: string): Resource {
    if (this.iconResolver) {
      return this.iconResolver(code);
    }
    return $r('app.media.ic_home');
  }

  private resolveBgColor(code: string): string {
    const adminPalette = getRolePalette(UserRole.ORG_ADMIN);
    if (this.bgColorResolver) {
      return this.bgColorResolver(code);
    }
    return adminPalette.light;
  }

  private resolveIconColor(code: string): string {
    const adminPalette = getRolePalette(UserRole.ORG_ADMIN);
    if (this.iconColorResolver) {
      return this.iconColorResolver(code);
    }
    return adminPalette.primary;
  }
}

@Component
export struct AdminHomeOperationsSection {
  @Prop operationsSubtitle: string = '';
  @Prop totalStudents: number = 0;
  @Prop presentStudents: number = 0;
  @Prop attendanceRateText: string = '0%';
  @Prop netIncomeText: string = '￥0';
  @Prop activityItems: ActivityFeedItem[] = [];
  @Prop activityActionText: string = '查看详情';
  onActivityAction?: () => void;

  build() {
    ResponsiveSplitPanel({
      primary: this.buildOperationsPanel,
      secondary: this.buildActivityPanel
    })
  }

  @Builder
  private buildOperationsPanel() {
    AdminOperationsOverviewCard({
      subtitle: this.operationsSubtitle,
      totalStudents: this.totalStudents,
      presentStudents: this.presentStudents,
      attendanceRateText: this.attendanceRateText,
      netIncomeText: this.netIncomeText
    })
  }

  @Builder
  private buildActivityPanel() {
    ActivityFeedCard({
      items: this.activityItems,
      actionText: this.activityActionText,
      onAction: (): void => {
        if (this.onActivityAction) {
          this.onActivityAction();
        }
      }
    })
  }
}
