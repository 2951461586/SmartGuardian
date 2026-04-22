/**
 * SmartGuardian - Admin Student Detail Page
 * Student profile overview for admin flow
 */

import { Card, EmptyState, EmptyType, HeaderTheme, InfoCard, InfoItem, PageHeader, SectionHeader } from '../../components/common';

interface StudentDetailParams {
  studentId?: number | string;
}

@Entry
@Component
struct AdminStudentDetailPage {
  @State studentId: string = '--';

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as StudentDetailParams;
    const studentId = params.studentId;
    this.studentId = studentId ? `${studentId}` : '--';
  }

  build() {
    Column() {
      PageHeader({
        title: '学生档案详情',
        subtitle: '查看学生基础资料、监护关系和后续扩展信息。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      Scroll() {
        Column() {
          SectionHeader({
            title: '档案概览',
            subtitle: '当前先保留稳定入口，后续接入完整学生档案。'
          })

          InfoCard({
            items: this.getBasicItems(),
            columns: 2
          })

          Card({
            title: '后续接入内容',
            subtitle: '可在这里扩展健康档案、监护人信息与历史记录。',
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
      { label: '页面状态', value: '可访问' },
      { label: '信息范围', value: '基础档案' },
      { label: '维护角色', value: '管理端' }
    ];
  }

  @Builder
  private buildPlaceholder() {
    EmptyState({
      type: EmptyType.DEFAULT,
      customTitle: '详情模块待补齐',
      customDescription: '后续可接入学生档案、监护人信息、健康备注和历史服务记录。'
    })
  }
}
