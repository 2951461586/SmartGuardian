import { HarmonyColor, HarmonyReport, harmonyShadowColor } from '../../common/HarmonyDesign';
import { RouteUrls } from '../../constants/app.constants';
import { Student } from '../../models/user';
import { Card, StatCard } from './Card';
import { SectionHeader } from './SectionHeader';

export interface StudentWithGuardian extends Student {
  guardianName?: string;
  guardianMobile?: string;
}

@Component
export struct AdminStudentsExecutiveCard {
  @Prop filteredTotal: number = 0;
  @Prop selectedGradeText: string = '全部';
  @Prop currentPage: number = 1;
  @Prop totalPages: number = 1;

  build() {
    Card({
      title: '学生档案驾驶舱',
      subtitle: '先定位年级和关键词，再进入档案列表查看和编辑学生资料。',
      customPadding: 18,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Row() {
      Column() {
        Text('档案范围')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(HarmonyReport.cautionSurface)
          .borderRadius(999)

        Text(`${this.filteredTotal}`)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 14 })

        Text('当前筛选范围内的学生档案总数')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        AdminStudentsMetricTile({
          label: '年级',
          value: this.selectedGradeText,
          valueColor: HarmonyReport.positive,
          fullWidth: true
        })
        AdminStudentsMetricTile({
          label: '页码',
          value: `${this.currentPage}/${this.totalPages}`,
          valueColor: HarmonyColor.brandBlue,
          fullWidth: true
        })
      }
      .width(128)
    }
    .width('100%')
  }
}

@Component
export struct AdminStudentsOverviewRow {
  @Prop totalStudents: number = 0;
  @Prop pageCount: number = 0;
  @Prop selectedGradeText: string = '全部';

  build() {
    Row() {
      StatCard({
        value: this.totalStudents,
        label: '学生总数',
        icon: $r('app.media.ic_user'),
        iconColor: HarmonyColor.brandBlue
      })
      .layoutWeight(1)

      StatCard({
        value: this.pageCount,
        label: '当前页条数',
        icon: $r('app.media.ic_report'),
        iconColor: HarmonyReport.caution
      })
      .layoutWeight(1)
      .margin({ left: 12, right: 12 })

      StatCard({
        value: this.selectedGradeText,
        label: '筛选年级',
        icon: $r('app.media.ic_filter'),
        iconColor: HarmonyReport.positive
      })
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}

@Component
export struct AdminStudentsControlCard {
  @Prop searchKeyword: string = '';
  @Prop selectedGrade: string = 'ALL';
  @Prop grades: string[] = [];
  onSearchChange?: (value: string) => void;
  onSearchSubmit?: () => void;
  onGradeSelect?: (grade: string) => void;

  build() {
    Card({
      title: '搜索控制台',
      subtitle: '统一控制关键词检索和年级切换，再进入学生档案列表。',
      customPadding: 14,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Column() {
      Row() {
        Image($r('app.media.ic_search'))
          .width(18)
          .height(18)
          .fillColor($r('app.color.text_tertiary'))

        TextInput({
          placeholder: '搜索学生姓名或学号',
          text: this.searchKeyword
        })
          .fontSize($r('app.float.text_primary_size'))
          .backgroundColor(HarmonyColor.clear)
          .flexGrow(1)
          .margin({ left: 8, right: 8 })
          .onChange((value: string) => {
            if (this.onSearchChange) {
              this.onSearchChange(value);
            }
          })
          .onSubmit(() => {
            if (this.onSearchSubmit) {
              this.onSearchSubmit();
            }
          })
      }
      .width('100%')
      .padding(12)
      .backgroundColor(HarmonyColor.surfaceSubtle)
      .borderRadius(16)

      SectionHeader({
        title: '年级筛选',
        subtitle: '快速限定当前学生档案范围'
      })
      .margin({ top: 14 })

      Scroll() {
        Row() {
          ForEach(this.grades, (grade: string) => {
            Text(grade === 'ALL' ? '全部' : `${grade}年级`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor(this.selectedGrade === grade ? HarmonyColor.textInverse : $r('app.color.text_secondary'))
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.selectedGrade === grade ? $r('app.color.primary') : HarmonyColor.surfaceMuted)
              .borderRadius(16)
              .onClick(() => {
                if (this.onGradeSelect) {
                  this.onGradeSelect(grade);
                }
              })
              .margin({ right: 8 })
          }, (grade: string) => grade)
        }
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .padding({ left: 2, right: 2, top: 4, bottom: 4 })
    }
    .width('100%')
  }
}

@Component
export struct AdminStudentsSummaryCard {
  @Prop pageCount: number = 0;
  @Prop filteredTotal: number = 0;
  @Prop searchKeyword: string = '';

  build() {
    Card({
      customPadding: 14,
      customBgColor: HarmonyColor.surfaceSubtle,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Row() {
      AdminStudentsMetricTile({
        label: '当前页',
        value: `${this.pageCount}`,
        valueColor: HarmonyColor.brandBlue
      })
      Blank().width(10)
      AdminStudentsMetricTile({
        label: '筛选总量',
        value: `${this.filteredTotal}`,
        valueColor: HarmonyReport.caution
      })
      Blank().width(10)
      AdminStudentsMetricTile({
        label: '检索词',
        value: this.searchKeyword.length > 0 ? this.searchKeyword : '未输入',
        valueColor: HarmonyColor.textPrimary
      })
    }
    .width('100%')
  }
}

@Component
export struct AdminStudentListItemCard {
  @Prop student: StudentWithGuardian = {} as StudentWithGuardian;

  build() {
    Row() {
      Image($r('app.media.ic_default_avatar'))
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('app.color.primary_light'))
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(this.student.name)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          if (this.student.gender) {
            Text(this.student.gender === 'MALE' ? '男' : '女')
              .fontSize(12)
              .fontColor(this.student.gender === 'MALE' ? HarmonyColor.brandBlue : HarmonyColor.textSecondary)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(this.student.gender === 'MALE' ? HarmonyReport.cautionSurface : HarmonyColor.surfaceSubtle)
              .borderRadius(999)
              .margin({ left: 8 })
          }
        }

        Text(`学号：${this.student.studentNo ? this.student.studentNo : '--'}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 6 })

        Text(`${this.student.grade ? this.student.grade : '--'} 年级 · ${this.student.className ? this.student.className : '--'}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 4 })

        if (this.student.guardianName) {
          Row() {
            Image($r('app.media.ic_user'))
              .width(12)
              .height(12)
              .fillColor($r('app.color.text_tertiary'))

            Text(` 监护人：${this.student.guardianName}`)
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_tertiary'))

            if (this.student.guardianMobile) {
              Text(` ${this.student.guardianMobile}`)
                .fontSize($r('app.float.text_tiny_size'))
                .fontColor($r('app.color.text_tertiary'))
            }
          }
          .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
      }
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({
          url: RouteUrls.ADMIN_STUDENT_DETAIL,
          params: { studentId: this.student.id }
        });
      })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(20)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 4
    })
  }
}

@Component
export struct AdminStudentsPaginationCard {
  @Prop currentPage: number = 1;
  @Prop totalPages: number = 1;
  onPrevious?: () => void;
  onNext?: () => void;

  build() {
    Card({
      title: '分页导航',
      subtitle: '按页浏览更多学生档案。',
      customPadding: 16,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Row() {
      Button('上一页')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.currentPage > 1 ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .backgroundColor(HarmonyColor.clear)
        .border({ width: 1, color: this.currentPage > 1 ? $r('app.color.primary') : HarmonyColor.lineStrong, radius: 14 })
        .borderRadius(14)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .enabled(this.currentPage > 1)
        .opacity(this.currentPage > 1 ? 1 : 0.4)
        .onClick(() => {
          if (this.onPrevious) {
            this.onPrevious();
          }
        })

      Text(`${this.currentPage} / ${this.totalPages}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ left: 20, right: 20 })

      Button('下一页')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.currentPage < this.totalPages ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .backgroundColor(HarmonyColor.clear)
        .border({ width: 1, color: this.currentPage < this.totalPages ? $r('app.color.primary') : HarmonyColor.lineStrong, radius: 14 })
        .borderRadius(14)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .enabled(this.currentPage < this.totalPages)
        .opacity(this.currentPage < this.totalPages ? 1 : 0.4)
        .onClick(() => {
          if (this.onNext) {
            this.onNext();
          }
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}

@Component
struct AdminStudentsMetricTile {
  @Prop label: string = '';
  @Prop value: string = '';
  @Prop valueColor: string = HarmonyColor.textPrimary;
  @Prop fullWidth: boolean = false;

  build() {
    Column() {
      Text(this.label)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))

      Text(this.value)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.valueColor)
        .margin({ top: 6 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(this.fullWidth ? '100%' : undefined)
    .layoutWeight(this.fullWidth ? 0 : 1)
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(this.fullWidth ? HarmonyColor.surfaceSubtle : HarmonyColor.surface)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: this.fullWidth ? 10 : 0 })
  }
}
