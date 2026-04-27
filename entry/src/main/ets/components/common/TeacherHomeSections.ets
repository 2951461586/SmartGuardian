import { HarmonyColor } from '../../common/HarmonyDesign';
import { WorkbenchModule } from '../../models/workbench';
import { Card } from './Card';
import { ResponsiveSplitPanel } from './PageScaffold';
import { StatCardRow, StatRowItem } from './StatCardRow';
import {
  TeacherSessionListItemData,
  TeacherSessionStatsCard,
  TeacherSessionsPreviewCard,
  TeacherSessionSummaryData
} from './TeacherSessionCards';
import { WorkbenchActionGrid } from './WorkbenchActionGrid';

@Component
export struct TeacherHomeWorkbenchSection {
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
      primary: () => { this.buildOverviewPanel() },
      secondary: () => { this.buildQuickActionsPanel() }
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
      content: () => { this.buildQuickActionsContent() }
    })
  }

  @Builder
  private buildQuickActionsContent() {
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
    if (this.bgColorResolver) {
      return this.bgColorResolver(code);
    }
    return HarmonyColor.surfaceSubtle;
  }

  private resolveIconColor(code: string): string {
    if (this.iconColorResolver) {
      return this.iconColorResolver(code);
    }
    return HarmonyColor.textSecondary;
  }
}

@Component
export struct TeacherHomeSessionSection {
  @Prop hasSession: boolean = false;
  @Prop statsSubtitle: string = '';
  @Prop statsEmptyDescription: string = '';
  @Prop sessionSummary: TeacherSessionSummaryData = {
    title: '',
    timeText: '',
    statusText: '',
    statusColor: HarmonyColor.textSecondary,
    statusBgColor: HarmonyColor.surfaceSubtle,
    signedCount: '0',
    unsignedCount: '0'
  };
  @Prop sessionItems: TeacherSessionListItemData[] = [];
  @Prop sessionEmptyDescription: string = '';
  @Prop sessionActionText: string = '查看全部';
  onSessionAction?: () => void;

  build() {
    ResponsiveSplitPanel({
      primary: () => { this.buildStatsPanel() },
      secondary: () => { this.buildSessionPanel() }
    })
  }

  @Builder
  private buildStatsPanel() {
    TeacherSessionStatsCard({
      hasSession: this.hasSession,
      subtitle: this.statsSubtitle,
      emptyDescription: this.statsEmptyDescription,
      summary: this.sessionSummary
    })
  }

  @Builder
  private buildSessionPanel() {
    TeacherSessionsPreviewCard({
      items: this.sessionItems,
      emptyDescription: this.sessionEmptyDescription,
      actionText: this.sessionActionText,
      onAction: (): void => {
        if (this.onSessionAction) {
          this.onSessionAction();
        }
      }
    })
  }
}
