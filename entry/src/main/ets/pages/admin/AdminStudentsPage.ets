/**
 * SmartGuardian - 学生档案管理页
 * 机构管理员管理学生信息
 */

import { router } from '@kit.ArkUI';
import { UserService, StudentInfo, GuardianRelation } from '../../services/api/auth';
import { SecurityUtils } from '../../utils/security';

interface StudentWithGuardian extends StudentInfo {
  guardianName?: string;
  guardianMobile?: string;
}

@Component
struct AdminStudentsPage {
  @State studentList: StudentWithGuardian[] = [];
  @State isLoading: boolean = false;
  @State searchKeyword: string = '';
  @State selectedGrade: string = 'ALL';
  @State currentPage: number = 1;
  @State totalPages: number = 1;

  private grades: string[] = ['ALL', '1', '2', '3', '4', '5', '6'];

  aboutToAppear() {
    this.loadStudents();
  }

  async loadStudents() {
    this.isLoading = true;
    try {
      const resp = await UserService.getStudentList({
        keyword: this.searchKeyword || undefined,
        grade: this.selectedGrade === 'ALL' ? undefined : Number(this.selectedGrade),
        page: this.currentPage,
        pageSize: 20
      });

      if (resp.code === 0 && resp.data) {
        this.studentList = (resp.data.list || []).map(s => ({
          ...s,
          // 脱敏处理
          name: SecurityUtils.desensitizeName(s.name),
          guardianName: s.guardianName ? SecurityUtils.desensitizeName(s.guardianName) : undefined,
          guardianMobile: s.guardianMobile ? SecurityUtils.desensitizeMobile(s.guardianMobile) : undefined
        }));
        this.totalPages = Math.ceil(resp.data.total / 20);
      }
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Search bar
      this.buildSearchBar()

      // Filter tabs
      this.buildGradeFilter()

      // Student list
      this.buildStudentList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .fillColor($r('app.color.text_primary'))
        .onClick(() => router.back())

      Text('学生档案管理')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Image($r('app.media.ic_add'))
        .width(24)
        .height(24)
        .fillColor($r('app.color.primary'))
        .onClick(() => {
          router.pushUrl({ url: 'pages/admin/AdminStudentEditPage' });
        })
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor(Color.White)
  }

  @Builder
  buildSearchBar() {
    Row() {
      Image($r('app.media.ic_search'))
        .width(18)
        .height(18)
        .fillColor($r('app.color.text_tertiary'))

      TextInput({
        placeholder: '搜索学生姓名/学号',
        text: this.searchKeyword
      })
        .fontSize($r('app.float.text_primary_size'))
        .backgroundColor(Color.Transparent)
        .flexGrow(1)
        .margin({ left: 8, right: 8 })
        .onChange((value: string) => {
          this.searchKeyword = value;
        })
        .onSubmit(() => {
          this.currentPage = 1;
          this.loadStudents();
        })
    }
    .width('100%')
    .padding(12)
    .margin({ top: 1 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildGradeFilter() {
    Scroll() {
      Row() {
        ForEach(this.grades, (grade: string) => {
          Text(grade === 'ALL' ? '全部' : `${grade}年级`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.selectedGrade === grade ? Color.White : $r('app.color.text_secondary'))
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .backgroundColor(this.selectedGrade === grade ? $r('app.color.primary') : $r('app.color.page_background'))
            .borderRadius(14)
            .onClick(() => {
              this.selectedGrade = grade;
              this.currentPage = 1;
              this.loadStudents();
            })
        })
      }
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  buildStudentList() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .color($r('app.color.primary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.studentList.length === 0) {
      Column() {
        Image($r('app.media.ic_empty'))
          .width(100)
          .height(100)
          .opacity(0.5)

        Text('暂无学生数据')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Column() {
        Scroll() {
          Column() {
            ForEach(this.studentList, (student: StudentWithGuardian) => {
              this.buildStudentCard(student)
            })
          }
          .width('100%')
          .padding($r('app.float.page_padding'))
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // Pagination
        this.buildPagination()
      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  @Builder
  buildStudentCard(student: StudentWithGuardian) {
    Row() {
      // Avatar
      Image($r('app.media.ic_default_avatar'))
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('app.color.primary_light'))
        .margin({ right: 12 })

      // Student info
      Column() {
        Text(student.name)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(`学号: ${student.studentNo || '--'}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 2 })

        if (student.guardianName) {
          Text(`监护人: ${student.guardianName} ${student.guardianMobile || ''}`)
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor($r('app.color.text_tertiary'))
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // Actions
      Column() {
        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
      }
      .onClick(() => {
        router.pushUrl({
          url: 'pages/admin/AdminStudentDetailPage',
          params: { studentId: student.id }
        });
      })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildPagination() {
    Row() {
      Text('上一页')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.currentPage > 1 ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .enabled(this.currentPage > 1)
        .onClick(() => {
          if (this.currentPage > 1) {
            this.currentPage--;
            this.loadStudents();
          }
        })

      Text(`${this.currentPage} / ${this.totalPages}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ left: 20, right: 20 })

      Text('下一页')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.currentPage < this.totalPages ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .enabled(this.currentPage < this.totalPages)
        .onClick(() => {
          if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadStudents();
          }
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
  }
}