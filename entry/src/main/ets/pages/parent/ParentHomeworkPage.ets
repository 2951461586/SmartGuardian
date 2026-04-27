/**
 * SmartGuardian - Parent Homework Page
 * View student's homework tasks
 */

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
  TabBar
} from '../../components/common';
import { HomeworkQueryParams } from '../../models/common';
import { HomeworkTask, HomeworkTaskStatus } from '../../models/homework';
import { HomeworkService } from '../../services/api/homework';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';

@Entry
@Component
struct ParentHomeworkPage {
  build() {
    Stack() {
      ParentHomeworkPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentHomeworkPageContent {
  @State homeworkList: HomeworkTask[] = [];
  @State filteredHomeworkList: HomeworkTask[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State pageNum: number = 1;
  @State hasMore: boolean = true;

  private readonly tabs: string[] = ['全部', '待完成', '已完成'];
  private homeworkDataSource: LazyArrayDataSource<HomeworkTask> = new LazyArrayDataSource<HomeworkTask>();

  async aboutToAppear() {
    await this.loadHomework();
  }

  async loadHomework(refresh: boolean = false) {
    if (refresh) {
      this.pageNum = 1;
      this.hasMore = true;
    }

    if (!this.hasMore && !refresh) {
      return;
    }

    this.isLoading = true;
    try {
      const params: HomeworkQueryParams = {
        pageNum: this.pageNum,
        pageSize: 10
      };

      const response = await HomeworkService.getTasks(params);
      if (response.code === 0 && response.data) {
        const newList = response.data.list ?? [];
        if (refresh) {
          this.homeworkList = newList;
        } else {
          this.homeworkList = [...this.homeworkList, ...newList];
        }
        this.hasMore = newList.length >= 10;
        this.applyHomeworkFilter();
      }
    } catch (error) {
      console.error('Failed to load homework:', error);
    } finally {
      this.isLoading = false;
    }
  }

  onTabChange(index: number) {
    if (this.currentTab !== index) {
      this.currentTab = index;
      this.applyHomeworkFilter();
    }
  }

  private applyHomeworkFilter(): void {
    const filtered: HomeworkTask[] = [];
    for (let i = 0; i < this.homeworkList.length; i++) {
      const task = this.homeworkList[i];
      if (this.currentTab === 1) {
        if (task.status === HomeworkTaskStatus.COMPLETED || task.status === HomeworkTaskStatus.CONFIRMED) {
          continue;
        }
      }
      if (this.currentTab === 2) {
        if (task.status !== HomeworkTaskStatus.COMPLETED && task.status !== HomeworkTaskStatus.CONFIRMED) {
          continue;
        }
      }
      filtered.push(task);
    }
    this.filteredHomeworkList = filtered;
    this.homeworkDataSource.setItems(filtered);
  }

  private getSummaryText(): string {
    if (this.currentTab === 1) {
      return `当前待完成 ${this.filteredHomeworkList.length} 项`;
    }
    if (this.currentTab === 2) {
      return `当前已完成 ${this.filteredHomeworkList.length} 项`;
    }
    return `累计作业 ${this.filteredHomeworkList.length} 项`;
  }

  build() {
    Column() {
      PageHeader({
        title: '作业列表',
        subtitle: '按状态查看孩子的作业任务、完成进度与反馈。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      TabBar({
        tabs: this.tabs,
        currentIndex: this.currentTab,
        onTabChange: (index: number) => {
          this.onTabChange(index);
        }
      })

      if (this.isLoading && this.filteredHomeworkList.length === 0) {
        Column() {
          LoadingState({ loadingSize: LoadingSize.LARGE })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.filteredHomeworkList.length === 0) {
        Column() {
          EmptyState({ type: EmptyType.NO_HOMEWORK, customTitle: '暂无作业' })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        this.buildPageList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildPageList() {
    List() {
      ListItem() {
        SectionHeader({
          title: '作业清单',
          subtitle: this.getSummaryText()
        })
      }

      ListItem() {
        Card({
          title: '状态说明',
          subtitle: '待完成会持续追踪，已完成和已确认会进入归档视图。',
          content: () => { this.buildSummaryContent() }
        })
      }

      LazyForEach(this.homeworkDataSource, (homework: HomeworkTask) => {
        ListItem() {
          HomeworkCard({
            homework: homework,
            mode: HomeworkCardMode.DETAIL
          })
        }
      }, (homework: HomeworkTask) => `${homework.id}`)

      if (this.hasMore) {
        ListItem() {
          Row() {
            LoadingState({ loadingSize: LoadingSize.SMALL })
          }
          .width('100%')
          .height(48)
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 12, bottom: 16 })
    .divider({ strokeWidth: 0 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(8)
  }

  @Builder
  private buildSummaryContent() {
    Text(this.getSummaryText())
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_primary'))
      .width('100%')
  }
}
