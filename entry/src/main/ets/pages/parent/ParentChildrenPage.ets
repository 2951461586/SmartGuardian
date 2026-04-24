/**
 * SmartGuardian - Parent Children Page
 * 孩子管理页面
 */

import { Student } from '../../models/user';
import { StudentService } from '../../services/api/auth';
import { StudentStore } from '../../stores/studentStore';
import { LoadingState, LoadingSize, EmptyState, EmptyType } from '../../components/common';

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
      // Header
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.text_primary'))
          .onClick(() => this.getUIContext().getRouter().back())

        Text('我的孩子')
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('').width(24)
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
      .backgroundColor(Color.White)

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
              .backgroundColor(Color.White)
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

