/**
 * SmartGuardian - Admin Student Edit Page
 * Student create/edit placeholder page
 */

import { PageHeader, HeaderTheme, Card, EmptyState, EmptyType } from '../../components/common';

@Entry
@Component
struct AdminStudentEditPage {
  build() {
    Column() {
      PageHeader({
        title: '学生信息维护',
        subtitle: '新增与编辑能力待接入正式表单',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      Scroll() {
        Column() {
          Card({
            title: '功能说明',
            content: this.buildIntro
          })

          Card({
            title: '当前状态',
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
  buildIntro() {
    Text('此页面已恢复为可访问入口，后续可在此接入学生新增、编辑、监护人维护等表单能力。')
      .width('100%')
      .fontSize($r('app.float.text_primary_size'))
      .fontColor($r('app.color.text_primary'))
      .lineHeight(24)
  }

  @Builder
  buildPlaceholder() {
    EmptyState({
      type: EmptyType.DEFAULT,
      customTitle: '表单能力建设中',
      customDescription: '当前先保证导航链路可达，避免运行时跳转失败'
    })
  }
}
