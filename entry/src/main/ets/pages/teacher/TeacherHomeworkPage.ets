/**
 * SmartGuardian - Teacher Homework Page
 * Teacher can manage homework tasks and feedback
 */

import { HomeworkService } from '../../services/api/homework';
import { HomeworkTask, HomeworkFeedbackCreateRequest, HomeworkTaskStatus, PerformanceLevel } from '../../models/homework';
import { SessionService } from '../../services/api/service';
import { SessionSchedule } from '../../models/service';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { PageResponse } from '../../models/common';
// Common Components
import {
  Card,
  EmptyState,
  EmptyType,
  HeaderTheme,
  HomeworkCard,
  HomeworkCardMode,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader,
  StatCard,
  TabBar
} from '../../components/common';

@Component
export struct TeacherHomeworkPage {
  @State homeworkList: HomeworkTask[] = [];
  @State sessions: SessionSchedule[] = [];
  @State currentTab: number = 0;
  @State isLoading: boolean = false;
  @State showFeedbackDialog: boolean = false;
  @State selectedTask: HomeworkTask | null = null;
  @State feedbackContent: string = '';
  @State errorMessage: string = '';
  @State isSubmittingFeedback: boolean = false;

  private tabs: string[] = [
    $r('app.string.homework_tab_pending').toString(),
    $r('app.string.homework_tab_completed').toString(),
    $r('app.string.homework_tab_confirmed').toString()
  ];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    try {
      const today = new Date().toISOString().split('T')[0];
      const sessionResp = await SessionService.getSessions({
        sessionDate: today,
        pageSize: 20
      });

      if (sessionResp.code === 0 && sessionResp.data) {
        this.sessions = Array.isArray(sessionResp.data) ? sessionResp.data : [];
      }

      await this.loadHomeworkByTab();
    } catch (error) {
      this.errorMessage = $r('app.string.homework_data_loading_failed').toString();
    } finally {
      this.isLoading = false;
    }
  }

  private getPageList(data: PageResponse<HomeworkTask> | HomeworkTask[] | null | undefined): HomeworkTask[] {
    if (!data) {
      return [];
    }
    if (Array.isArray(data)) {
      return data;
    }
    return data.list ? data.list : [];
  }

  async loadHomeworkByTab() {
    let status: HomeworkTaskStatus | undefined = undefined;
    if (this.currentTab === 0) {
      status = HomeworkTaskStatus.PENDING;
    } else if (this.currentTab === 1) {
      status = HomeworkTaskStatus.COMPLETED;
    } else if (this.currentTab === 2) {
      status = HomeworkTaskStatus.CONFIRMED;
    }

    try {
      const resp = await HomeworkService.getTasks({
        pageNum: 1,
        pageSize: 20,
        status: status
      });

      if (resp.code === 0) {
        this.homeworkList = this.getPageList(resp.data);
      }
    } catch (error) {
      this.errorMessage = $r('app.string.homework_loading_failed').toString();
    }
  }

  openFeedbackDialog(task: HomeworkTask): void {
    this.selectedTask = task;
    this.feedbackContent = '';
    this.errorMessage = '';
    this.showFeedbackDialog = true;
  }

  closeFeedbackDialog(): void {
    this.showFeedbackDialog = false;
    this.selectedTask = null;
    this.feedbackContent = '';
    this.isSubmittingFeedback = false;
  }

  async handleSubmitFeedback() {
    if (!this.selectedTask) {
      return;
    }

    if (this.feedbackContent.trim().length === 0) {
      ErrorHandlerUtil.showErrorToast($r('app.string.homework_feedback_dialog_hint').toString());
      return;
    }

    this.isSubmittingFeedback = true;
    try {
      const request: HomeworkFeedbackCreateRequest = {
        taskId: this.selectedTask.id,
        feedbackContent: this.feedbackContent,
        performance: PerformanceLevel.GOOD
      };

      const resp = await HomeworkService.submitFeedback(request);
      if (resp.code === 0) {
        ErrorHandlerUtil.showSuccessToast($r('app.string.homework_feedback_submit_success').toString());
        this.closeFeedbackDialog();
        await this.loadHomeworkByTab();
      } else {
        this.errorMessage = resp.message ? resp.message : $r('app.string.homework_feedback_submit_failed').toString();
        ErrorHandlerUtil.showErrorToast(this.errorMessage);
      }
    } catch (error) {
      this.errorMessage = $r('app.string.homework_feedback_submit_failed').toString();
      ErrorHandlerUtil.showErrorToast(this.errorMessage);
    } finally {
      this.isSubmittingFeedback = false;
    }
  }

  build() {
    Stack() {
      Column() {
        PageHeader({
          title: '作业管理',
          subtitle: '按任务状态查看布置、完成和家校确认进度。',
          theme: HeaderTheme.PRIMARY
        })

        Scroll() {
          Column() {
            this.buildOverviewPanel()
            this.buildTabSection()
            this.buildHomeworkList()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))

      if (this.showFeedbackDialog) {
        this.buildFeedbackDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildOverviewPanel() {
    Row() {
      StatCard({
        value: this.sessions.length,
        label: '今日班次',
        icon: $r('app.media.ic_calendar'),
        iconColor: '#1F5EFF'
      })
      .layoutWeight(1)

      StatCard({
        value: this.homeworkList.length,
        label: '当前任务',
        icon: $r('app.media.ic_homework'),
        iconColor: '#D97706'
      })
      .layoutWeight(1)
      .margin({ left: 12, right: 12 })

      StatCard({
        value: this.getCurrentTabLabel(),
        label: '处理阶段',
        icon: $r('app.media.ic_attendance'),
        iconColor: '#15803D'
      })
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: 12 })
  }

  @Builder
  buildTabSection() {
    Card({
      title: '任务状态',
      subtitle: '在待完成、已完成和已确认之间切换查看。',
      customPadding: 12,
      content: this.buildTabSectionContent
    })
  }

  @Builder
  buildTabSectionContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: $currentTab,
      onTabChange: () => {
        this.loadHomeworkByTab();
      }
    })
  }

  @Builder
  buildHomeworkList() {
    if (this.isLoading) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false
      })
    } else if (this.homeworkList.length === 0) {
      EmptyState({
        type: EmptyType.NO_HOMEWORK,
        customTitle: '暂无作业任务',
        customDescription: '当前状态下还没有可展示的作业记录。',
        actionText: '重新加载',
        onAction: () => {
          this.loadHomeworkByTab();
        }
      })
    } else {
      Column() {
        SectionHeader({
          title: '作业清单',
          subtitle: `当前查看：${this.getCurrentTabLabel()}`
        })

        Column() {
          ForEach(this.homeworkList, (task: HomeworkTask) => {
            this.buildHomeworkItem(task)
          })
        }
        .width('100%')
      }
      .width('100%')
    }
  }

  @Builder
  buildHomeworkItem(task: HomeworkTask) {
    HomeworkCard({
      homework: task,
      mode: HomeworkCardMode.DETAIL,
      showFeedbackButton: this.currentTab === 0,
      onSubmitFeedback: () => {
        this.openFeedbackDialog(task);
      }
    })
  }

  @Builder
  buildFeedbackDialog() {
    Column() {
      Column() {
        Text($r('app.string.homework_feedback_dialog_title'))
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: $r('app.float.card_margin') })

        if (this.selectedTask) {
          Column() {
            Text(`${$r('app.string.homework_feedback_student').toString()}：${this.selectedTask.studentName ? this.selectedTask.studentName : ''}`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .margin({ bottom: $r('app.float.card_content_margin') })

            Text(`${$r('app.string.homework_feedback_task_content').toString()}：${this.selectedTask.content ? this.selectedTask.content : ''}`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ bottom: $r('app.float.card_margin') })
          }
          .width('100%')
          .padding($r('app.float.card_padding'))
          .backgroundColor($r('app.color.page_background'))
          .borderRadius($r('app.float.card_border_radius'))
          .margin({ bottom: $r('app.float.card_margin') })
        }

        TextArea({ text: this.feedbackContent, placeholder: $r('app.string.homework_feedback_dialog_hint').toString() })
          .width('100%')
          .height($r('app.float.feedback_input_height'))
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.page_background'))
          .borderRadius($r('app.float.card_border_radius'))
          .onChange((value: string) => {
            this.feedbackContent = value;
          })

        Row() {
          Button($r('app.string.common_cancel'))
            .layoutWeight(1)
            .height($r('app.float.button_height'))
            .fontSize($r('app.float.button_text_size'))
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.page_background'))
            .borderRadius($r('app.float.button_radius'))
            .enabled(!this.isSubmittingFeedback)
            .onClick(() => {
              this.closeFeedbackDialog();
            })

          Button(this.isSubmittingFeedback ? $r('app.string.homework_feedback_submitting') : $r('app.string.common_confirm'))
            .layoutWeight(1)
            .height($r('app.float.button_height'))
            .fontSize($r('app.float.button_text_size'))
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.button_radius'))
            .enabled(!this.isSubmittingFeedback)
            .margin({ left: $r('app.float.card_margin') })
            .onClick(() => {
              this.handleSubmitFeedback();
            })
        }
        .width('100%')
        .margin({ top: $r('app.float.card_margin') })
      }
      .width('100%')
      .constraintSize({ maxWidth: $r('app.float.layout_dialog_max_width_large') })
      .padding($r('app.float.card_padding'))
      .backgroundColor($r('app.color.card_background'))
      .borderRadius($r('app.float.card_border_radius'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.scan_overlay_background'))
    .justifyContent(FlexAlign.Center)
    .padding($r('app.float.page_padding'))
  }

  @Builder
  buildStatusBadge(status: HomeworkTaskStatus) {
    Text(this.getStatusText(status))
      .fontSize($r('app.float.badge_text_size'))
      .fontColor(this.getStatusColor(status))
      .padding({
        left: $r('app.float.badge_padding'),
        right: $r('app.float.badge_padding'),
        top: $r('app.float.badge_padding'),
        bottom: $r('app.float.badge_padding')
      })
      .backgroundColor(this.getStatusBgColor(status))
      .borderRadius($r('app.float.badge_radius'))
  }

  getStatusText(status: HomeworkTaskStatus): string {
    if (status === HomeworkTaskStatus.PENDING) {
      return $r('app.string.homework_status_pending').toString();
    }
    if (status === HomeworkTaskStatus.IN_PROGRESS) {
      return $r('app.string.homework_status_in_progress').toString();
    }
    if (status === HomeworkTaskStatus.COMPLETED) {
      return $r('app.string.homework_status_completed').toString();
    }
    if (status === HomeworkTaskStatus.CONFIRMED) {
      return $r('app.string.homework_status_confirmed').toString();
    }
    return '';
  }

  getStatusColor(status: HomeworkTaskStatus): ResourceColor {
    if (status === HomeworkTaskStatus.PENDING) {
      return $r('app.color.status_pending');
    }
    if (status === HomeworkTaskStatus.IN_PROGRESS) {
      return $r('app.color.status_in_progress');
    }
    if (status === HomeworkTaskStatus.COMPLETED) {
      return $r('app.color.status_completed');
    }
    if (status === HomeworkTaskStatus.CONFIRMED) {
      return $r('app.color.status_confirmed');
    }
    return $r('app.color.text_secondary');
  }

  getStatusBgColor(status: HomeworkTaskStatus): ResourceColor {
    if (status === HomeworkTaskStatus.PENDING) {
      return $r('app.color.status_pending_bg');
    }
    if (status === HomeworkTaskStatus.IN_PROGRESS) {
      return $r('app.color.status_in_progress_bg');
    }
    if (status === HomeworkTaskStatus.COMPLETED) {
      return $r('app.color.status_completed_bg');
    }
    if (status === HomeworkTaskStatus.CONFIRMED) {
      return $r('app.color.status_confirmed_bg');
    }
    return $r('app.color.page_background');
  }

  private getCurrentTabLabel(): string {
    if (this.currentTab === 0) {
      return '待完成';
    }
    if (this.currentTab === 1) {
      return '已完成';
    }
    if (this.currentTab === 2) {
      return '已确认';
    }
    return '全部';
  }
}
