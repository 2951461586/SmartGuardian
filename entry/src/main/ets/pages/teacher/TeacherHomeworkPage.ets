/**
 * SmartGuardian - Teacher Homework Page
 * Teacher can manage homework tasks and feedback.
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
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
import { HomeworkFeedbackCreateRequest, HomeworkTask, HomeworkTaskStatus, PerformanceLevel } from '../../models/homework';
import { SessionSchedule } from '../../models/service';
import { HomeworkService } from '../../services/api/homework';
import { SessionService } from '../../services/api/service';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';

@Entry
@Component
struct TeacherHomeworkPage {
  build() {
    Stack() {
      TeacherHomeworkPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct TeacherHomeworkPageContent {
  @State homeworkList: HomeworkTask[] = [];
  @State sessions: SessionSchedule[] = [];
  @State currentTab: number = 0;
  @State isLoading: boolean = false;
  @State showFeedbackDialog: boolean = false;
  @State selectedTask: HomeworkTask | null = null;
  @State feedbackContent: string = '';
  @State errorMessage: string = '';
  @State isSubmittingFeedback: boolean = false;

  private tabs: string[] = ['待辅导', '已完成', '待确认'];

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
        this.sessions = sessionResp.data;
      }

      await this.loadHomeworkByTab();
    } catch (error) {
      this.errorMessage = '加载数据失败';
    } finally {
      this.isLoading = false;
    }
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
        status
      });

      if (resp.code === 0) {
        this.homeworkList = resp.data ? resp.data.list : [];
      }
    } catch (error) {
      this.errorMessage = '加载作业失败';
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
      ErrorHandlerUtil.showErrorToast('请输入本次辅导反馈内容');
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
        ErrorHandlerUtil.showSuccessToast('反馈提交成功');
        this.closeFeedbackDialog();
        await this.loadHomeworkByTab();
      } else {
        this.errorMessage = resp.message ? resp.message : '提交反馈失败';
        ErrorHandlerUtil.showErrorToast(this.errorMessage);
      }
    } catch (error) {
      this.errorMessage = '提交反馈失败';
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

        Column() {
          this.buildOverviewPanel()
          this.buildTabSection()
          this.buildHomeworkList()
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
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
        iconColor: HarmonyColor.brandBlue
      })
      .layoutWeight(1)

      StatCard({
        value: this.homeworkList.length,
        label: '当前任务',
        icon: $r('app.media.ic_homework'),
        iconColor: HarmonyReport.caution
      })
      .layoutWeight(1)
      .margin({ left: 12, right: 12 })

      StatCard({
        value: this.getCurrentTabLabel(),
        label: '处理阶段',
        icon: $r('app.media.ic_attendance'),
        iconColor: HarmonyReport.positive
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
      subtitle: '在待辅导、已完成和待确认之间切换查看。',
      customPadding: 12,
      content: () => { this.buildTabSectionContent() }
    })
  }

  @Builder
  buildTabSectionContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        this.currentTab = index;
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

        List({ space: 12 }) {
          ForEach(this.homeworkList, (task: HomeworkTask) => {
            ListItem() {
              this.buildHomeworkItem(task)
            }
          }, (task: HomeworkTask) => `${task.id}`)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)
        .cachedCount(6)
        .padding({ top: 12, bottom: 8 })
      }
      .width('100%')
      .layoutWeight(1)
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
        Text('作业反馈')
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: $r('app.float.card_margin') })

        if (this.selectedTask) {
          this.buildSelectedTaskSummary()
        }

        TextArea({ text: this.feedbackContent, placeholder: '请输入本次辅导反馈内容' })
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
          Button('取消')
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

          Button(this.isSubmittingFeedback ? '提交中...' : '确认')
            .layoutWeight(1)
            .height($r('app.float.button_height'))
            .fontSize($r('app.float.button_text_size'))
            .fontColor(HarmonyColor.textInverse)
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
  private buildSelectedTaskSummary() {
    Column() {
      Text(`学生：${this.selectedTask?.studentName ? this.selectedTask.studentName : ''}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ bottom: $r('app.float.card_content_margin') })

      Text(`作业内容：${this.selectedTask?.content ? this.selectedTask.content : ''}`)
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

  private getCurrentTabLabel(): string {
    if (this.currentTab === 0) {
      return '待辅导';
    }
    if (this.currentTab === 1) {
      return '已完成';
    }
    if (this.currentTab === 2) {
      return '待确认';
    }
    return '全部';
  }
}
