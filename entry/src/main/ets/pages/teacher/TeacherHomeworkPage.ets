/**
 * SmartGuardian - Teacher Homework Page
 * Teacher can manage homework tasks and feedback
 */

import { HomeworkService } from '../../services/api/attendance';
import { HomeworkTask, HomeworkFeedback, HomeworkFeedbackCreateRequest } from '../../models/attendance';
import { SessionService } from '../../services/api/service';
import { SessionSchedule } from '../../models/service';

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

  private tabs: string[] = ['待辅导', '已完成', '待确认'];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    try {
      // Load sessions
      const today = new Date().toISOString().split('T')[0];
      const sessionResp = await SessionService.getSessions({
        sessionDate: today,
        pageSize: 20
      });

      if (sessionResp.code === 0 && sessionResp.data) {
        this.sessions = sessionResp.data.list;
      }

      // Load homework based on tab
      await this.loadHomeworkByTab();
    } catch (error) {
      this.errorMessage = '加载数据失败';
    } finally {
      this.isLoading = false;
    }
  }

  async loadHomeworkByTab() {
    let status: string | undefined;
    if (this.currentTab === 0) status = 'PENDING';
    else if (this.currentTab === 1) status = 'COMPLETED';
    else if (this.currentTab === 2) status = 'CONFIRMED';

    try {
      const resp = await HomeworkService.getTasks({
        pageNum: 1,
        pageSize: 20,
        status
      });

      if (resp.code === 0 && resp.data) {
        this.homeworkList = resp.data.list;
      }
    } catch (error) {
      this.errorMessage = '加载作业失败';
    }
  }

  async handleSubmitFeedback() {
    if (!this.selectedTask || !this.feedbackContent) {
      return;
    }

    try {
      const request: HomeworkFeedbackCreateRequest = {
        taskId: this.selectedTask.id,
        feedbackContent: this.feedbackContent,
        performance: 'GOOD'
      };

      await HomeworkService.submitFeedback(request);
      this.showFeedbackDialog = false;
      this.feedbackContent = '';
      this.selectedTask = null;
      this.loadHomeworkByTab();
    } catch (error) {
      this.errorMessage = '提交反馈失败';
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Tab bar
      this.buildTabBar()

      // Homework list
      this.buildHomeworkList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Text('作业管理')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: Number($r('app.float.status_bar_height')) + 20, bottom: 20 })
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
              .width(20)
              .height(2)
              .backgroundColor($r('app.color.primary'))
              .borderRadius(1)
          }
        }
        .width('33%')
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.currentTab = index;
          this.loadHomeworkByTab();
        })
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
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
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)

        Text('暂无作业')
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
    Column() {
      // Header
      Row() {
        Text(task.studentName || '学生')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        this.buildStatusBadge(task.status)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: $r('app.float.card_content_margin') })

      // Content
      Text(task.content)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // Date and action
      Row() {
        Text(task.taskDate)
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_tertiary'))

        if (this.currentTab === 0) {
          Button('提交反馈')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.button_radius'))
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .onClick(() => {
              this.selectedTask = task;
              this.showFeedbackDialog = true;
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: $r('app.float.card_content_margin') })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildStatusBadge(status: string) {
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

  getStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      'PENDING': '待辅导',
      'IN_PROGRESS': '辅导中',
      'COMPLETED': '已完成',
      'CONFIRMED': '已确认'
    };
    return statusMap[status] || status;
  }

  getStatusColor(status: string): string {
    const colorMap: Record<string, string> = {
      'PENDING': '#FF9800',
      'IN_PROGRESS': '#2196F3',
      'COMPLETED': '#4CAF50',
      'CONFIRMED': '#9C27B0'
    };
    return colorMap[status] || '#666666';
  }

  getStatusBgColor(status: string): string {
    const colorMap: Record<string, string> = {
      'PENDING': '#FFF3E0',
      'IN_PROGRESS': '#E3F2FD',
      'COMPLETED': '#E8F5E9',
      'CONFIRMED': '#F3E5F5'
    };
    return colorMap[status] || '#F5F5F5';
  }
}