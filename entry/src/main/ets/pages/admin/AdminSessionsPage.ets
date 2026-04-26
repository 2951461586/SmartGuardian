/**
 * SmartGuardian - Admin Sessions Page
 * Admin session scheduling workspace
 */

import {
  AdminSessionListItemCard,
  AdminSessionStudentsSheet,
  AdminSessionsFilterCard,
  AdminSessionsOverviewCard,
  EmptyState,
  EmptyType,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader
} from '../../components/common';
import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { AutoScheduleRequest, SessionSchedule, SessionStudent, SessionWithStudents } from '../../models/service';
import { SessionService } from '../../services/api/service';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';
import { LogUtil } from '../../utils/LogUtil';

@Entry
@Component
struct AdminSessionsPage {
  @State sessions: SessionSchedule[] = [];
  @State isLoading: boolean = false;
  @State isScheduling: boolean = false;
  @State currentTab: number = 0;
  @State errorMessage: string = '';
  @State showStudentsSheet: boolean = false;
  @State selectedSessionDetail: SessionWithStudents | null = null;

  private readonly tabs: string[] = ['全部班次', '今日班次', '满载班次', '已结束'];
  private sessionDataSource: LazyArrayDataSource<SessionSchedule> = new LazyArrayDataSource<SessionSchedule>();
  private sessionStudentDataSource: LazyArrayDataSource<SessionStudent> = new LazyArrayDataSource<SessionStudent>();

  aboutToAppear() {
    ErrorHandlerUtil.setUIContext(this.getUIContext());
    this.loadSessions();
  }

  private getTodayText(): string {
    return new Date().toISOString().split('T')[0];
  }

  private filterSessions(source: SessionSchedule[]): SessionSchedule[] {
    const result: SessionSchedule[] = [];
    const today = this.getTodayText();
    for (let i = 0; i < source.length; i++) {
      const session = source[i];
      const maxCapacity = Number(session.maxCapacity ?? session.capacity ?? 0);
      const currentCount = Number(session.currentCount ?? 0);
      if (this.currentTab === 1 && session.sessionDate !== today) {
        continue;
      }
      if (this.currentTab === 2 && !(maxCapacity > 0 && currentCount >= maxCapacity)) {
        continue;
      }
      if (this.currentTab === 3 && session.status !== 'ENDED') {
        continue;
      }
      result.push(session);
    }
    return result;
  }

  async loadSessions() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const response = await SessionService.getSessions({
        pageNum: 1,
        pageSize: 100
      });

      if (response.code === 0 && response.data) {
        this.sessions = this.filterSessions(response.data);
        this.sessionDataSource.setItems(this.sessions);
      } else {
        this.sessions = [];
        this.sessionDataSource.clear();
        this.errorMessage = response.message ? response.message : '班次加载失败';
      }
    } catch (error) {
      this.sessions = [];
      this.sessionDataSource.clear();
      this.errorMessage = '班次加载失败，请稍后重试';
      LogUtil.error(`AdminSessionsPage loadSessions failed: ${String(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  async createQuickSession() {
    if (this.isScheduling) {
      return;
    }

    this.isScheduling = true;
    try {
      const response = await SessionService.createSession({
        sessionDate: this.getTodayText(),
        startTime: '16:30:00',
        endTime: '18:30:00',
        teacherUserId: 2,
        capacity: 35,
        serviceProductId: 2,
        maxCapacity: 35,
        location: '托管教室 A',
        status: 'SCHEDULED'
      });

      if (response.code === 0) {
        ErrorHandlerUtil.showSuccessToast('已新增临时班次');
        this.currentTab = 0;
        await this.loadSessions();
      } else {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '新增班次失败');
      }
    } catch (error) {
      LogUtil.error(`AdminSessionsPage createQuickSession failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('新增班次失败，请稍后重试');
    } finally {
      this.isScheduling = false;
    }
  }

  async autoGenerateSessions() {
    if (this.isScheduling) {
      return;
    }

    this.isScheduling = true;
    try {
      const payload: AutoScheduleRequest = {
        serviceProductId: 2,
        startDate: this.getTodayText(),
        endDate: '2026-05-30',
        weekdays: [1, 3, 5],
        startTime: '16:30',
        endTime: '18:30',
        teacherIds: [2],
        maxCapacity: 35,
        location: '托管教室 A'
      };

      const response = await SessionService.autoSchedule(payload);
      if (response.code === 0) {
        ErrorHandlerUtil.showSuccessToast('已生成模板排班');
        this.currentTab = 0;
        await this.loadSessions();
      } else {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '自动排班失败');
      }
    } catch (error) {
      LogUtil.error(`AdminSessionsPage autoGenerateSessions failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('自动排班失败，请稍后重试');
    } finally {
      this.isScheduling = false;
    }
  }

  async openStudentsSheet(sessionId: number) {
    try {
      const response = await SessionService.getSessionDetail(sessionId);
      if (response.code === 0 && response.data) {
        this.selectedSessionDetail = response.data;
        this.sessionStudentDataSource.setItems(response.data.students);
        this.showStudentsSheet = true;
      } else {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '班次详情加载失败');
      }
    } catch (error) {
      LogUtil.error(`AdminSessionsPage openStudentsSheet failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('班次详情加载失败');
    }
  }

  private getTodayCount(): number {
    let count = 0;
    const today = this.getTodayText();
    for (let i = 0; i < this.sessions.length; i++) {
      if (this.sessions[i].sessionDate === today) {
        count++;
      }
    }
    return count;
  }

  private getFullCount(): number {
    let count = 0;
    for (let i = 0; i < this.sessions.length; i++) {
      const maxCapacity = Number(this.sessions[i].maxCapacity ?? this.sessions[i].capacity ?? 0);
      if (maxCapacity > 0 && Number(this.sessions[i].currentCount ?? 0) >= maxCapacity) {
        count++;
      }
    }
    return count;
  }

  private getStatusText(status?: string): string {
    if (status === 'SCHEDULED') {
      return '待开始';
    }
    if (status === 'ONGOING') {
      return '进行中';
    }
    if (status === 'ENDED') {
      return '已结束';
    }
    if (status === 'CANCELLED') {
      return '已取消';
    }
    return status ? status : '未标记';
  }

  private getStatusColor(status?: string): string {
    if (status === 'ONGOING') {
      return HarmonyReport.positive;
    }
    if (status === 'ENDED') {
      return HarmonyColor.textTertiary;
    }
    if (status === 'CANCELLED') {
      return HarmonyReport.danger;
    }
    return HarmonyReport.accent;
  }

  build() {
    Column() {
      PageHeader({
        title: '班次排期管理',
        subtitle: '查看班次占用、学生名单，并支持快速补班与模板排班。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY,
        rightContent: this.buildHeaderAction
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.DEFAULT,
          message: '正在加载班次...'
        })
      } else {
        this.buildPageList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showStudentsSheet, this.buildStudentsSheet(), {
      height: 420,
      backgroundColor: HarmonyColor.surface,
      dragBar: true
    })
  }

  @Builder
  private buildPageList() {
    List() {
      ListItem() {
        this.buildOverviewPanel()
      }

      ListItem() {
        this.buildFilterPanel()
      }

      this.buildSessionListSections()
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0 })
    .padding({ left: 16, right: 16, top: 16, bottom: 24 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(8)
  }

  @Builder
  private buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_add'),
      iconColor: HarmonyColor.textInverse,
      boxBgColor: HarmonyColor.overlayInverseSoft,
      boxBorderColor: HarmonyColor.overlayInverseBorder,
      boxSize: 42,
      iconSize: 22,
      onButtonClick: () => {
        this.createQuickSession();
      }
    })
  }

  @Builder
  private buildOverviewPanel() {
    AdminSessionsOverviewCard({
      totalCount: this.sessions.length,
      todayCount: this.getTodayCount(),
      fullCount: this.getFullCount()
    })
  }

  @Builder
  private buildFilterPanel() {
    AdminSessionsFilterCard({
      tabs: this.tabs,
      currentTab: this.currentTab,
      onAutoSchedule: () => {
        this.autoGenerateSessions();
      },
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadSessions();
      }
    })
  }

  @Builder
  private buildSessionListSections() {
    ListItem() {
      SectionHeader({
        title: '班次列表',
        subtitle: this.errorMessage ? this.errorMessage : `当前共 ${this.sessions.length} 个班次`
      })
    }

    if (this.sessions.length === 0) {
      ListItem() {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '暂无班次',
          customDescription: this.errorMessage ? this.errorMessage : '可以先新增一个临时班次，或者直接自动排班。',
          actionText: '新增班次',
          onAction: () => {
            this.createQuickSession();
          }
        })
      }
    } else {
      LazyForEach(this.sessionDataSource, (session: SessionSchedule) => {
        ListItem() {
          AdminSessionListItemCard({
            session: session,
            statusText: this.getStatusText(session.status),
            statusColor: this.getStatusColor(session.status),
            onOpenStudents: (sessionId: number) => {
              this.openStudentsSheet(sessionId);
            }
          })
            .margin({ bottom: 12 })
        }
      }, (session: SessionSchedule) => `${session.id}`)
    }
  }

  @Builder
  private buildStudentsSheet() {
    AdminSessionStudentsSheet({
      sessionDetail: this.selectedSessionDetail,
      studentItems: this.selectedSessionDetail ? this.selectedSessionDetail.students : []
    })
  }
}

