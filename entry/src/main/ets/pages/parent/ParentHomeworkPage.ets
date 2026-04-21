/**
 * SmartGuardian - Parent Homework Page
 * View student's homework tasks
 */

import { HomeworkTask, HomeworkTaskStatus } from '../../models/homework';
import { HomeworkService } from '../../services/api/homework';
import { LoadingState, LoadingSize, EmptyState, EmptyType } from '../../components/common';
import { HomeworkCard, HomeworkCardMode } from '../../components/common';
import { HomeworkQueryParams } from '../../models/common';

@Entry
@Component
export struct ParentHomeworkPage {
  @State homeworkList: HomeworkTask[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State pageNum: number = 1;
  @State hasMore: boolean = true;

  private readonly tabs = ['全部', '待完成', '已完成'];

  async aboutToAppear() {
    await this.loadHomework();
  }

  async loadHomework(refresh: boolean = false) {
    if (refresh) {
      this.pageNum = 1;
      this.hasMore = true;
    }

    if (!this.hasMore && !refresh) return;

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
      this.loadHomework(true);
    }
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .width(36)
        .height(36)
        .backgroundColor('#1AFFFFFF')
        .onClick(() => this.getUIContext().getRouter().back())

        Text('作业列表')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(36)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#4F7CFF', 0], ['#7B68EE', 1]]
      })

      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontColor(this.currentTab === index ? '#4F7CFF' : '#666666')
              .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)

            if (this.currentTab === index) {
              Divider()
                .width(24)
                .height(2)
                .color('#4F7CFF')
                .margin({ top: 4 })
            }
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .onClick(() => this.onTabChange(index))
        })
      }
      .width('100%')
      .backgroundColor(Color.White)

      Divider().color('#E5E5E5')

      if (this.isLoading && this.homeworkList.length === 0) {
        Column() {
          LoadingState({ loadingSize: LoadingSize.LARGE })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.homeworkList.length === 0) {
        Column() {
          EmptyState({ type: EmptyType.NO_HOMEWORK, customTitle: '暂无作业' })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.homeworkList, (homework: HomeworkTask) => {
            ListItem() {
              HomeworkCard({
                homework: homework,
                mode: HomeworkCardMode.DETAIL
              })
            }
            .margin({ top: 8 })
          })

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
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
