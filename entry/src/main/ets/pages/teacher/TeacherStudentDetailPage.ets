/**
 * SmartGuardian - Teacher Student Detail Page
 * Student overview for teacher flow
 */

import { Card, EmptyState, EmptyType, HeaderTheme, InfoCard, InfoItem, PageHeader, SectionHeader } from '../../components/common';

interface TeacherStudentDetailParams {
  studentId?: number | string;
}

@Entry
@Component
struct TeacherStudentDetailPage {
  @State studentId: string = '--';

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as TeacherStudentDetailParams;
    const studentId = params.studentId;
    this.studentId = studentId ? `${studentId}` : '--';
  }

  build() {
    Column() {
      PageHeader({
        title: '学生详情',
        subtitle: '教师可在这里查看学生信息、考勤表现和联系入口。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      Scroll() {
        Column() {
          SectionHeader({
            title: '扫码结果',
            subtitle: '先保证教师端跳转稳定，后续再接完整详情。'
          })

          InfoCard({
            items: this.getBasicItems(),
            columns: 2
          })

          Card({
            title: '待接入内容',
            subtitle: '可继续接入考勤状态、作业记录和家长联系方式。',
            content: this.buildPlaceholder
          })
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
  }

  private getBasicItems(): InfoItem[] {
    return [
      { label: '学生编号', value: this.studentId },
      { label: '入口来源', value: '教师端' },
      { label: '当前状态', value: '待接入详情' },
      { label: '使用场景', value: '扫码查看' }
    ];
  }

  @Builder
  private buildPlaceholder() {
    EmptyState({
      type: EmptyType.DEFAULT,
      customTitle: '教师详情能力待补齐',
      customDescription: '后续可展示学生档案、考勤状态、作业完成情况和家校联系信息。'
    })
  }
}
