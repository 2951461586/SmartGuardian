/**
 * SmartGuardian - Admin Student Edit Page
 * Student create/edit form placeholder with unified shell
 */

import { Card, EmptyState, EmptyType, HeaderTheme, InfoCard, InfoItem, PageHeader, SectionHeader } from '../../components/common';

@Entry
@Component
struct AdminStudentEditPage {
  build() {
    Column() {
      PageHeader({
        title: '学生信息维护',
        subtitle: '用于新增学生档案、补充资料和维护监护关系。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      Scroll() {
        Column() {
          SectionHeader({
            title: '表单规划',
            subtitle: '先把页面壳层和信息层级统一，后续再接真实字段。'
          })

          InfoCard({
            items: this.getPlanItems(),
            columns: 2
          })

          Card({
            title: '表单能力待接入',
            subtitle: '建议按基础信息、班级归属、监护人、健康备注四个分区接入。',
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

  private getPlanItems(): InfoItem[] {
    return [
      { label: '使用角色', value: '管理员' },
      { label: '页面类型', value: '表单页' },
      { label: '状态目标', value: '统一设计系统' },
      { label: '下一步', value: '接入真实字段' }
    ];
  }

  @Builder
  private buildPlaceholder() {
    EmptyState({
      type: EmptyType.DEFAULT,
      customTitle: '正式表单待接入',
      customDescription: '后续可在此接入学生新增、编辑、监护人维护和状态更新等表单逻辑。'
    })
  }
}
