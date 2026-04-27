import { HomeworkTask } from '../../models/homework';
import { WorkbenchModule } from '../../models/workbench';
import { Card } from './Card';
import { ParentHomeworkPreviewCard } from './ParentHomeworkPreviewCard';
import { ParentNoticeCard } from './ParentNoticeCard';
import { ParentScheduleCard, ParentScheduleNode } from './ParentScheduleCard';
import { ParentStudentHeroCard } from './ParentStudentHeroCard';
import { ResponsiveSplitPanel } from './PageScaffold';

@Component
export struct ParentHomeWorkspaceSection {
  @Prop studentName: string = '';
  @Prop studentMeta: string = '';
  @Prop studentNo: string = '';
  @Prop schoolName: string = '';
  @Prop sessionTitle: string = '';
  @Prop noticeSummary: string = '';
  @Prop noticeDateText: string = '';
  @Prop scheduleItems: ParentScheduleNode[] = [];
  @Prop recentHomework: HomeworkTask[] = [];
  @Prop homeworkSubtitle: string = '';
  @Prop homeworkFallbackText: string = '';
  @Prop quickActionsTitle: string = '';
  @Prop quickActionsSubtitle: string = '';
  @Prop quickActionsActionText: string = '全部功能';
  onQuickActions?: () => void;
  onTimeline?: () => void;
  onHomework?: () => void;
  @BuilderParam quickActionsContent: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {}

  build() {
    Scroll() {
      Column() {
        ParentStudentHeroCard({
          studentName: this.studentName,
          studentMeta: this.studentMeta,
          studentNo: this.studentNo,
          schoolName: this.schoolName,
          sessionTitle: this.sessionTitle
        })
          .margin({ bottom: 14 })

        ResponsiveSplitPanel({
          primary: () => { this.buildNoticePanel() },
          secondary: () => { this.buildQuickActionsPanel() }
        })
          .margin({ bottom: 14 })

        ResponsiveSplitPanel({
          primary: () => { this.buildSchedulePanel() },
          secondary: () => { this.buildHomeworkPanel() }
        })
      }
      .width('100%')
      .padding({ top: 12, bottom: 24 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildNoticePanel() {
    ParentNoticeCard({
      summary: this.noticeSummary,
      dateText: this.noticeDateText
    })
  }

  @Builder
  private buildQuickActionsPanel() {
    Card({
      title: this.quickActionsTitle,
      subtitle: this.quickActionsSubtitle,
      actionText: this.quickActionsActionText,
      onAction: () => {
        if (this.onQuickActions) {
          this.onQuickActions();
        }
      },
      content: () => { this.buildQuickActionsContent() }
    })
  }

  @Builder
  private buildQuickActionsContent() {
    this.quickActionsContent()
  }

  @Builder
  private buildSchedulePanel() {
    ParentScheduleCard({
      items: this.scheduleItems,
      onAction: (): void => {
        if (this.onTimeline) {
          this.onTimeline();
        }
      }
    })
  }

  @Builder
  private buildHomeworkPanel() {
    ParentHomeworkPreviewCard({
      tasks: this.recentHomework,
      subtitle: this.homeworkSubtitle,
      fallbackText: this.homeworkFallbackText,
      onAction: (): void => {
        if (this.onHomework) {
          this.onHomework();
        }
      }
    })
  }
}
