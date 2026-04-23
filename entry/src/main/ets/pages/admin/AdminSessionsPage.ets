/**
 * SmartGuardian - Admin Sessions Page
 * Admin session scheduling workspace
 */

import {
  Card,
  EmptyState,
  EmptyType,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader,
  StatCard,
  TabBar
} from '../../components/common';
import { AutoScheduleRequest, SessionSchedule, SessionStudent, SessionWithStudents } from '../../models/service';
import { SessionService } from '../../services/api/service';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
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
      } else {
        this.sessions = [];
        this.errorMessage = response.message ? response.message : '班次加载失败';
      }
    } catch (error) {
      this.sessions = [];
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
      return '#15803D';
    }
    if (status === 'ENDED') {
      return '#7A879A';
    }
    if (status === 'CANCELLED') {
      return '#DC2626';
    }
    return '#1F5EFF';
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
        Scroll() {
          Column() {
            this.buildOverviewPanel()
            this.buildFilterPanel()
            this.buildSessionList()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showStudentsSheet, this.buildStudentsSheet(), {
      height: 420,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  private buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_add'),
      iconColor: Color.White,
      boxBgColor: '#FFFFFF1F',
      boxBorderColor: '#FFFFFF29',
      boxSize: 42,
      iconSize: 22,
      onButtonClick: () => {
        this.createQuickSession();
      }
    })
  }

  @Builder
  private buildOverviewPanel() {
    Column() {
      SectionHeader({
        title: '班次概览',
        subtitle: '集中看清今日排班、满载情况和当前班次规模。'
      })

      Row() {
        StatCard({
          value: this.sessions.length,
          label: '当前班次数',
          icon: $r('app.media.ic_session'),
          iconColor: '#1F5EFF'
        })
        .layoutWeight(1)

        StatCard({
          value: this.getTodayCount(),
          label: '今日班次',
          icon: $r('app.media.ic_clock'),
          iconColor: '#15803D'
        })
        .layoutWeight(1)
        .margin({ left: 12, right: 12 })

        StatCard({
          value: this.getFullCount(),
          label: '满载班次',
          icon: $r('app.media.ic_alert_center'),
          iconColor: '#D97706'
        })
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private buildFilterPanel() {
    Card({
      title: '班次筛选',
      subtitle: '可按今日、满载和已结束状态快速查看排期压力。',
      actionText: '自动排班',
      onAction: () => {
        this.autoGenerateSessions();
      },
      content: this.buildFilterContent
    })
  }

  @Builder
  private buildFilterContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadSessions();
      }
    })
  }

  @Builder
  private buildSessionList() {
    Column() {
      SectionHeader({
        title: '班次列表',
        subtitle: this.errorMessage ? this.errorMessage : `当前共 ${this.sessions.length} 个班次`
      })

      if (this.sessions.length === 0) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '暂无班次',
          customDescription: this.errorMessage ? this.errorMessage : '可以先新增一个临时班次，或者直接自动排班。',
          actionText: '新增班次',
          onAction: () => {
            this.createQuickSession();
          }
        })
      } else {
        Column() {
          ForEach(this.sessions, (session: SessionSchedule) => {
            this.buildSessionItem(session);
          })
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private buildSessionItem(session: SessionSchedule) {
    Column() {
      Row() {
        Column() {
          Text(`${session.serviceProductName ? session.serviceProductName : '托管班次'} · ${session.sessionNo ? session.sessionNo : session.id}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(`${session.sessionDate} ${session.startTime} - ${session.endTime}`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.getStatusText(session.status))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getStatusColor(session.status))
      }
      .width('100%')

      Row() {
        this.buildMetricColumn('当前人数', `${Number(session.currentCount ?? 0)}`)
        this.buildMetricColumn('最大容量', `${Number(session.maxCapacity ?? session.capacity ?? 0)}`)
        this.buildMetricColumn('教师', session.teacherName ? session.teacherName : '--')
      }
      .width('100%')
      .margin({ top: 14 })

      Text(`地点：${session.location ? session.location : '--'}`)
        .width('100%')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 12 })

      Text('查看学生名单')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary'))
        .margin({ top: 12 })
        .onClick(() => {
          this.openStudentsSheet(session.id);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 12 })
  }

  @Builder
  private buildMetricColumn(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildStudentsSheet() {
    Column() {
      if (this.selectedSessionDetail) {
        Text(this.selectedSessionDetail.serviceProductName ? this.selectedSessionDetail.serviceProductName : '班次学生名单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 8, bottom: 8 })

        Text(`${this.selectedSessionDetail.sessionDate} · ${this.selectedSessionDetail.startTime} - ${this.selectedSessionDetail.endTime}`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 16 })

        if (this.selectedSessionDetail.students.length === 0) {
          Text('当前班次还没有学生名单。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        } else {
          Scroll() {
            Column() {
              ForEach(this.selectedSessionDetail.students, (student: SessionStudent) => {
                Row() {
                  Column() {
                    Text(student.studentName)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.text_primary'))

                    Text(`学号：${student.studentNo}`)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text(student.attendanceStatus)
                    .fontSize(12)
                    .fontColor($r('app.color.primary'))
                }
                .width('100%')
                .padding({ top: 10, bottom: 10 })
              })
            }
            .width('100%')
          }
          .width('100%')
          .layoutWeight(1)
        }
      } else {
        Text('暂无班次详情')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
