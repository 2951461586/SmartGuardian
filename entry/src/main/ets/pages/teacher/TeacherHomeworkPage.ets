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
import { HomeworkCard, HomeworkCardMode } from '../../components/common';

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
        this.buildHeader()
        this.buildTabBar()
        this.buildHomeworkList()
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
  buildHeader() {
    Row() {
      Text($r('app.string.homework_title'))
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      top: Number($r('app.float.status_bar_height')) + Number($r('app.float.homework_header_top_extra')),
      bottom: $r('app.float.homework_header_bottom_padding')
    })
    .backgroundColor($r('app.color.primary'))
  }

  @Builder
  buildTabBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize($r('app.float.text_primary_size'))
            .fontColor(this.currentTab === index ? $r('app.color.primary') : $r('app.color.text_secondary'))

          if (this.currentTab === index) {
            Row()
              .width($r('app.float.homework_tab_indicator_width'))
              .height($r('app.float.homework_tab_indicator_height'))
              .backgroundColor($r('app.color.primary'))
              .borderRadius($r('app.float.homework_tab_indicator_radius'))
          }
        }
        .width('33%')
        .height($r('app.float.homework_tab_height'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentTab = index;
          this.loadHomeworkByTab();
        })
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.homework_tab_background'))
  }

  @Builder
  buildHomeworkList() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .color($r('app.color.primary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.homeworkList.length === 0) {
      Column() {
        Image($r('app.media.ic_empty'))
          .width($r('app.float.homework_empty_icon_size'))
          .height($r('app.float.homework_empty_icon_size'))
          .objectFit(ImageFit.Contain)

        Text($r('app.string.homework_empty'))
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: $r('app.float.card_margin') })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Column() {
          ForEach(this.homeworkList, (task: HomeworkTask) => {
            this.buildHomeworkItem(task)
          })
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
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
}