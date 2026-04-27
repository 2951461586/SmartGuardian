/**
 * SmartGuardian - Parent Sessions Page
 * Parent-facing workbench for daily session schedules.
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  Card,
  EmptyType,
  HeaderTheme,
  IconActionButton,
  PageHeader,
  SectionHeader,
  SessionBadge,
  StatefulContainer,
  StatCardRow,
  StatRowItem,
  ViewState,
  WorkbenchListPageTemplate
} from '../../components/common';
import { SessionSchedule } from '../../models/service';
import { SessionService } from '../../services/api/service';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';
import { formatDate, formatTime } from '../../utils/date';

@Entry
@Component
struct ParentSessionsPage {
  build() {
    Stack() {
      ParentSessionsPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentSessionsPageContent {
  @State sessions: SessionSchedule[] = [];
  @State isLoading: boolean = true;
  @State selectedDate: string = '';
  @State errorMessage: string = '';
  private sessionDataSource: LazyArrayDataSource<SessionSchedule> = new LazyArrayDataSource<SessionSchedule>();

  async aboutToAppear() {
    this.selectedDate = formatDate(new Date());
    await this.loadSessions();
  }

  async loadSessions() {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const response = await SessionService.getSessions({
        sessionDate: this.selectedDate
      });
      if (response.code === 0 && response.data) {
        this.sessions = response.data;
        this.sessionDataSource.setItems(this.sessions);
      } else {
        this.clearSessions();
      }
    } catch (error) {
      console.error('Failed to load sessions:', String(error));
      this.clearSessions();
      this.errorMessage = '班次加载失败，请稍后重试。';
    } finally {
      this.isLoading = false;
    }
  }

  private clearSessions(): void {
    this.sessions = [];
    this.sessionDataSource.clear();
  }

  private getViewState(): ViewState {
    if (this.isLoading) {
      return ViewState.LOADING;
    }
    if (this.errorMessage.length > 0) {
      return ViewState.ERROR;
    }
    if (this.sessions.length === 0) {
      return ViewState.EMPTY;
    }
    return ViewState.CONTENT;
  }

  private getOverviewItems(): StatRowItem[] {
    return [
      {
        value: `${this.sessions.length}`,
        label: '今日班次',
        icon: $r('app.media.ic_calendar'),
        iconColor: HarmonyColor.info
      },
      {
        value: `${this.getOngoingCount()}`,
        label: '进行中',
        icon: $r('app.media.ic_attendance'),
        iconColor: HarmonyReport.positive
      },
      {
        value: this.selectedDate.length > 5 ? this.selectedDate.slice(5) : this.selectedDate,
        label: '查看日期',
        icon: $r('app.media.ic_clock'),
        iconColor: HarmonyReport.caution
      }
    ];
  }

  private getOngoingCount(): number {
    let count = 0;
    for (let i = 0; i < this.sessions.length; i++) {
      const status = this.normalizeStatus(this.sessions[i].status);
      if (status === 'ONGOING') {
        count++;
      }
    }
    return count;
  }

  private normalizeStatus(status?: string): string {
    if (status === 'ONGOING' || status === 'ENDED' || status === 'CANCELLED') {
      return status;
    }
    if (status === 'IN_PROGRESS') {
      return 'ONGOING';
    }
    if (status === 'COMPLETED') {
      return 'ENDED';
    }
    return 'SCHEDULED';
  }

  private getSessionSubtitle(session: SessionSchedule): string {
    const teacherName = session.teacherName ?? '待分配教师';
    const location = session.location ?? '待安排场地';
    return `${teacherName} · ${location}`;
  }

  build() {
    Column() {
      WorkbenchListPageTemplate({
        scrollable: false,
        enableWideContent: true,
        header: () => { this.buildHeader() },
        overview: () => { this.buildOverviewSection() },
        controls: () => { this.buildDateSection() },
        content: () => { this.buildSessionContent() }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHeader() {
    PageHeader({
      title: '班次安排',
      subtitle: '查看孩子当天托管班次、教师和时间安排。',
      showBack: true,
      theme: HeaderTheme.WHITE,
      onBackClick: () => this.getUIContext().getRouter().back(),
      rightContent: this.buildHeaderAction
    })
  }

  @Builder
  private buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: HarmonyColor.info,
      boxBgColor: HarmonyColor.surface,
      boxBorderColor: HarmonyColor.line,
      onButtonClick: () => {
        this.loadSessions();
      }
    })
  }

  @Builder
  private buildOverviewSection() {
    StatCardRow({
      items: this.getOverviewItems()
    })
  }

  @Builder
  private buildDateSection() {
    Card({
      title: '查看日期',
      subtitle: this.selectedDate,
      actionText: '回到今天',
      onAction: () => {
        this.selectedDate = formatDate(new Date());
        this.loadSessions();
      },
      content: () => { this.buildDateContent() }
    })
  }

  @Builder
  private buildDateContent() {
    Column() {
      Text('当前按日期展示孩子的托管班次，便于提前确认上课时间、地点和教师安排。')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyColor.textSecondary)
        .lineHeight(20)

      Row() {
        this.buildDateInfoChip('班次总数', `${this.sessions.length}`)
        Blank().width(10)
        this.buildDateInfoChip('当前状态', this.getOngoingCount() > 0 ? '进行中' : '待开始')
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
  }

  @Builder
  private buildDateInfoChip(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor(HarmonyColor.textTertiary)

      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(HarmonyColor.textPrimary)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildSessionContent() {
    StatefulContainer({
      state: this.getViewState(),
      loadingMessage: '正在同步班次安排...',
      emptyType: EmptyType.DEFAULT,
      emptyTitle: '当天暂无班次安排',
      emptyDescription: '当前日期没有可展示的托管班次。',
      errorMessage: this.errorMessage,
      onRetry: () => {
        this.loadSessions();
      },
      content: () => { this.buildSessionList() }
    })
      .layoutWeight(1)
  }

  @Builder
  private buildSessionList() {
    List() {
      ListItem() {
        SectionHeader({
          title: '班次列表',
          subtitle: '按时间顺序查看当天的全部托管安排。'
        })
      }

      LazyForEach(this.sessionDataSource, (session: SessionSchedule) => {
        ListItem() {
          this.buildSessionCard(session)
        }
      }, (session: SessionSchedule) => `${session.id}`)
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0 })
    .scrollBar(BarState.Off)
    .cachedCount(6)
  }

  @Builder
  private buildSessionCard(session: SessionSchedule) {
    Column() {
      Row() {
        Column() {
          Text(session.serviceProductName ?? '托管班次')
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor(HarmonyColor.textPrimary)

          Text(this.getSessionSubtitle(session))
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(HarmonyColor.textSecondary)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        SessionBadge({
          status: this.normalizeStatus(session.status)
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        this.buildMetaItem($r('app.media.ic_clock'), `${formatTime(session.startTime)} - ${formatTime(session.endTime)}`)
        Blank().width(12)
        this.buildMetaItem($r('app.media.ic_user'), `${session.currentCount ?? 0}名学生`)
      }
      .width('100%')
      .margin({ top: 14 })

      if (session.teacherName || session.location) {
        Row() {
          this.buildMetaItem($r('app.media.ic_info'), this.getSessionSubtitle(session))
        }
        .width('100%')
        .margin({ top: 10 })
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(24)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 24,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: HarmonyColor.overlaySoft,
      offsetX: 0,
      offsetY: 6
    })
    .margin({ bottom: 12 })
  }

  @Builder
  private buildMetaItem(icon: Resource, text: string) {
    Row() {
      Image(icon)
        .width(14)
        .height(14)
        .objectFit(ImageFit.Contain)
        .fillColor(HarmonyColor.info)

      Text(text)
        .fontSize(12)
        .fontColor(HarmonyColor.textSecondary)
        .margin({ left: 6 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(16)
  }
}
