/**
 * SmartGuardian - Parent Children Page
 * 孩子管理页面
 */

import { HarmonyColor } from '../../common/HarmonyDesign';
import { Student } from '../../models/user';
import { StudentService } from '../../services/api/auth';
import { StudentStore } from '../../stores/studentStore';
import { EmptyState, EmptyType, HeaderTheme, LoadingSize, LoadingState, PageHeader } from '../../components/common';

@Entry
@Component
struct ParentChildrenPage {
  @State children: Student[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear() {
    await this.loadChildren();
  }

  async loadChildren() {
    this.isLoading = true;
    try {
      const response = await StudentService.getStudents({ pageNum: 1, pageSize: 100 });
      if (response.code === 0 && response.data) {
        this.children = response.data.list ?? [];
        StudentStore.setStudentList(this.children);
        if (this.children.length > 0) {
          StudentStore.setCurrentStudent(this.children[0]);
        }
      }
    } catch (error) {
      console.error('Load children failed:', error);
    } finally {
      this.isLoading = false;
    }
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
          ForEach(this.children, (child: Student) => {
            ListItem() {
              Row() {
                Image($r('app.media.ic_default_avatar'))
                  .width(50)
                  .height(50)
                  .borderRadius(25)

                Column() {
                  Text(child.name)
                    .fontSize($r('app.float.text_primary_size'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))

                  Text(`学号: ${child.studentNo}`)
                    .fontSize($r('app.float.text_secondary_size'))
                    .fontColor($r('app.color.text_secondary'))
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)

                Image($r('app.media.ic_arrow_right'))
                  .width(16)
                  .height(16)
                  .fillColor($r('app.color.text_tertiary'))
              }
              .width('100%')
              .padding(16)
              .backgroundColor(HarmonyColor.surface)
              .borderRadius(12)
              .margin({ bottom: 12 })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding($r('app.float.page_padding'))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}

