/**
 * SmartGuardian - Admin Student Detail Page
 * Student detail placeholder page
 */

import { PageHeader, HeaderTheme, Card, InfoCard, EmptyState, EmptyType } from '../../components/common';

@Entry
@Component
struct AdminStudentDetailPage {
  @State studentId: string = '--';

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as Record<string, number | string>;
    const studentId = params?.studentId;
    this.studentId = studentId ? `${studentId}` : '--';
  }

  build() {
    Column() {
      PageHeader({
        title: '学生档案详情',
        subtitle: '查看学生基础信息与后续扩展字段',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      Scroll() {
        Column() {
          Card({
            title: '基础信息',
            content: this.buildBasicInfo
          })

          Card({
            title: '页面状态',
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
        { label: '状态', value: '详情页已恢复可访问' }
      ]
    })
  }

  @Builder
  buildPlaceholder() {
    EmptyState({
      type: EmptyType.DEFAULT,
      customTitle: '详情内容待完善',
      customDescription: '后续可在此接入学生档案、监护人信息和历史记录'
    })
  }
}
