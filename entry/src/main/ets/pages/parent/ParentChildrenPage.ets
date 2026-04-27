/**
 * SmartGuardian - Parent Children Page
 * 孩子管理页面
 */

import { HarmonyColor, HarmonyRadius, HarmonySpace } from '../../common/HarmonyDesign';
import { Student } from '../../models/user';
import { StudentService } from '../../services/api/auth';
import { StudentStore } from '../../stores/studentStore';
import { EmptyState, EmptyType, HeaderTheme, LoadingSize, LoadingState, PageHeader } from '../../components/common';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';

@Entry
@Component
struct ParentChildrenPage {
  @State children: Student[] = [];
  @State isLoading: boolean = true;
  private childrenDataSource: LazyArrayDataSource<Student> = new LazyArrayDataSource<Student>();

  async aboutToAppear() {
    await this.loadChildren();
  }

  async loadChildren() {
    this.isLoading = true;
    try {
      const response = await StudentService.getStudents({ pageNum: 1, pageSize: 100 });
      if (response.code === 0 && response.data) {
        this.children = response.data.list ?? [];
        this.childrenDataSource.setItems(this.children);
        StudentStore.setStudentList(this.children);
        if (this.children.length > 0) {
          StudentStore.setCurrentStudent(this.children[0]);
        }
      } else {
        this.clearChildren();
      }
    } catch (error) {
      console.error('Load children failed:', error);
      this.clearChildren();
    } finally {
      this.isLoading = false;
    }
  }

  private clearChildren(): void {
    this.children = [];
    this.childrenDataSource.clear();
  }

  build() {
    Column() {
      PageHeader({
        title: '我的孩子',
        subtitle: '查看当前登录家长名下的学生档案。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.WHITE
      })

      // Content
      if (this.isLoading) {
        LoadingState({ loadingSize: LoadingSize.DEFAULT })
      } else if (this.children.length === 0) {
        EmptyState({ type: EmptyType.DEFAULT, customTitle: '暂无孩子信息' })
      } else {
        List() {
          LazyForEach(this.childrenDataSource, (child: Student) => {
            ListItem() {
              this.buildChildCard(child)
            }
          }, (child: Student) => `${child.id}`)
        }
        .width('100%')
        .layoutWeight(1)
        .padding($r('app.float.page_padding'))
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)
        .cachedCount(8)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildChildCard(child: Student) {
    Row() {
      Image($r('app.media.ic_default_avatar'))
        .width($r('app.float.avatar_medium_size'))
        .height($r('app.float.avatar_medium_size'))
        .borderRadius(HarmonyRadius.pill)

      Column() {
        Text(child.name)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(`学号: ${child.studentNo}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: HarmonySpace.compact / 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: HarmonySpace.section })
      .layoutWeight(1)

      Image($r('app.media.ic_arrow_right'))
        .width($r('app.float.icon_small_size'))
        .height($r('app.float.icon_small_size'))
        .fillColor($r('app.color.text_tertiary'))
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(HarmonyRadius.control)
    .margin({ bottom: $r('app.float.card_margin') })
  }
}

