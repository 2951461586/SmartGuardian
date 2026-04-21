/**
 * SmartGuardian - Teacher Student Detail Page
 * Student detail placeholder page for teacher flow
 */

import { PageHeader, HeaderTheme, Card, InfoCard, EmptyState, EmptyType } from '../../components/common';

@Entry
@Component
struct TeacherStudentDetailPage {
  @State studentId: string = '--';

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as Record<string, number | string>;
    const studentId = params?.studentId;
    this.studentId = studentId ? `${studentId}` : '--';
  }

  build() {
    Column() {
      PageHeader({
        title: '学生详情',
        subtitle: '扫码后查看学生信息与状态',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      Scroll() {
        Column() {
          Card({
            title: '扫码结果',
            content: this.buildBasicInfo
          })

          Card({
            title: '后续能力',
            content: this.buildPlaceholder
          })
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildBasicInfo() {
    InfoCard({
      items: [
        { label: '学生ID', value: this.studentId },
        { label: '入口来源', value: '教师扫码/学生二维码' }
      ]
    })
  }

  @Builder
  buildPlaceholder() {
    EmptyState({
      type: EmptyType.DEFAULT,
      customTitle: '详情信息待接入',
      customDescription: '后续可展示学生档案、考勤状态和家长联系信息'
    })
  }
}
