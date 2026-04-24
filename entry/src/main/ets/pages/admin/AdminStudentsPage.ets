/**
 * SmartGuardian - 学生档案管理页
 * 管理员查看和筛选学生信息
 */

import { StudentService } from '../../services/api/auth';
import { Student } from '../../models/user';
import { StudentStore } from '../../stores/studentStore';
import { DataMaskUtil } from '../../utils/DataMaskUtil';
import { LogUtil } from '../../utils/LogUtil';
import { Card, EmptyState, EmptyType, HeaderTheme, IconActionButton, LoadingSize, LoadingState, PageHeader, SectionHeader, StatCard } from '../../components/common';

interface StudentWithGuardian extends Student {
  guardianName?: string;
  guardianMobile?: string;
}

@Entry
@Component
export struct AdminStudentsPage {
  @StorageLink('student_list') studentList: StudentWithGuardian[] = [];

  @State isLoading: boolean = false;
  @State searchKeyword: string = '';
  @State selectedGrade: string = 'ALL';
  @State currentPage: number = 1;
  @State totalPages: number = 1;

  private allStudents: StudentWithGuardian[] = [];
  private lastLoadTime: number = 0;
  private readonly CACHE_DURATION: number = 5 * 60 * 1000;
  private readonly pageSize: number = 20;
  private grades: string[] = ['ALL', '1', '2', '3', '4', '5', '6'];

  aboutToAppear() {
    this.loadStudentsWithCache();
  }

  async loadStudentsWithCache() {
    const cachedStudents = StudentStore.getStudentList();
    if (cachedStudents.length > 0) {
      this.allStudents = cachedStudents as StudentWithGuardian[];
      this.applyFiltersAndPagination();
      LogUtil.info('AdminStudentsPage', `Using cached students: ${cachedStudents.length} items`);
    }

    const now = Date.now();
    const shouldRefresh = (now - this.lastLoadTime) > this.CACHE_DURATION;
    if (shouldRefresh || cachedStudents.length === 0) {
      await this.loadStudents();
    }
  }

  async loadStudents() {
    this.isLoading = true;
    try {
      const resp = await StudentService.getStudents({
        keyword: this.searchKeyword || undefined,
        pageNum: 1,
        pageSize: 500
      });

      if (resp.code === 0 && resp.data) {
        const rawList = resp.data.list ?? [];
        const list: StudentWithGuardian[] = rawList.map((s: StudentWithGuardian) => {
          const processed: StudentWithGuardian = {
            id: s.id,
            name: DataMaskUtil.maskName(s.name),
            studentNo: DataMaskUtil.maskStudentNo(s.studentNo),
            grade: s.grade,
            classId: s.classId,
            className: s.className,
            gender: s.gender,
            schoolId: s.schoolId,
            guardianUserId: s.guardianUserId,
            status: s.status,
            createdAt: s.createdAt,
            updatedAt: s.updatedAt
          };

          if (s.guardianName) {
            processed.guardianName = DataMaskUtil.maskName(s.guardianName);
          }
          if (s.guardianMobile) {
            processed.guardianMobile = DataMaskUtil.maskPhone(s.guardianMobile);
          }
          return processed;
        });

        this.allStudents = list;
        StudentStore.setStudentList(list);
        this.lastLoadTime = Date.now();
        this.applyFiltersAndPagination();
        LogUtil.info('AdminStudentsPage', `Loaded and cached ${list.length} students`);
      } else {
        this.allStudents = [];
        this.studentList = [];
        this.totalPages = 1;
      }
    } catch (error) {
      LogUtil.error('AdminStudentsPage', `Load students failed: ${String(error)}`);
      this.allStudents = [];
      this.studentList = [];
      this.totalPages = 1;
    } finally {
      this.isLoading = false;
    }
  }

  private applyFiltersAndPagination(): void {
    const filtered = this.allStudents.filter((student: StudentWithGuardian) => {
      if (this.selectedGrade === 'ALL') {
        return true;
      }

      const gradeText = student.grade ? String(student.grade) : '';
      return gradeText === this.selectedGrade || gradeText.includes(this.selectedGrade);
    });

    this.totalPages = Math.max(1, Math.ceil(filtered.length / this.pageSize));
    if (this.currentPage > this.totalPages) {
      this.currentPage = this.totalPages;
    }

    const start = (this.currentPage - 1) * this.pageSize;
    this.studentList = filtered.slice(start, start + this.pageSize);
  }

  private getFilteredTotal(): number {
    return this.allStudents.filter((student: StudentWithGuardian) => {
      if (this.selectedGrade === 'ALL') {
        return true;
      }

      const gradeText = student.grade ? String(student.grade) : '';
      return gradeText === this.selectedGrade || gradeText.includes(this.selectedGrade);
    }).length;
  }

  private getExecutiveTitle(): string {
    return '学生档案控制台';
  }

  private getExecutiveSubtitle(): string {
    return '先定位年级和关键词，再进入档案列表进行查看与编辑';
  }

  build() {
    Column() {
      PageHeader({
        title: '学生档案管理',
        subtitle: '统一查看学生基础档案、监护人信息与年级分布。',
        theme: HeaderTheme.PRIMARY,
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        rightContent: this.buildHeaderAction
      })

      Scroll() {
        Column() {
          this.buildExecutivePanel()
          this.buildOverviewPanel()
          this.buildControlDeck()
          this.buildStudentList()
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

  @Builder
  buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_add'),
      iconColor: Color.White,
      boxBgColor: '#FFFFFF1F',
      boxBorderColor: '#FFFFFF29',
      boxSize: 42,
      iconSize: 22,
      onButtonClick: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminStudentEditPage' });
      }
    })
  }

  @Builder
  buildExecutivePanel() {
    Card({
      title: this.getExecutiveTitle(),
      subtitle: this.getExecutiveSubtitle(),
      customPadding: 18,
      content: this.buildExecutiveContent
    })
    .margin({ bottom: 14 })
  }

  @Builder
  buildExecutiveContent() {
    Row() {
      Column() {
        Text('档案范围')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#F6F0E9')
          .borderRadius(999)

        Text(`${this.getFilteredTotal()}`)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 14 })

        Text('当前筛选范围内的学生档案数')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        this.buildExecutiveMetric('年级', this.getSelectedGradeText(), '#2F9E77')
        this.buildExecutiveMetric('页码', `${this.currentPage}/${this.totalPages}`, '#526F95')
      }
      .width(128)
    }
    .width('100%')
  }

  @Builder
  buildExecutiveMetric(label: string, value: string, valueColor: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(valueColor)
        .margin({ top: 6 })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor('#F7FAFE')
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 10 })
  }

  @Builder
  buildOverviewPanel() {
    Row() {
      StatCard({
        value: this.allStudents.length,
        label: '学生总数',
        icon: $r('app.media.ic_user'),
        iconColor: '#526F95'
      })
      .layoutWeight(1)

      StatCard({
        value: this.studentList.length,
        label: '当前页条数',
        icon: $r('app.media.ic_report'),
        iconColor: '#D97706'
      })
      .layoutWeight(1)
      .margin({ left: 12, right: 12 })

      StatCard({
        value: this.getSelectedGradeText(),
        label: '筛选年级',
        icon: $r('app.media.ic_filter'),
        iconColor: '#2F9E77'
      })
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: 12 })
  }

  @Builder
  buildControlDeck() {
    Card({
      title: '检索控制台',
      subtitle: '统一控制关键词搜索和年级切换，再进入档案列表',
      customPadding: 14,
      content: this.buildControlDeckContent
    })
    .margin({ bottom: 12 })
  }

  @Builder
  buildControlDeckContent() {
    Column() {
      this.buildSearchBarContent()

      SectionHeader({
        title: '年级筛选',
        subtitle: '快速限定当前档案池'
      })
      .margin({ top: 14 })

      this.buildGradeFilterContent()
    }
    .width('100%')
  }

  @Builder
  buildSearchBar() {
    Card({
      title: '搜索学生',
      subtitle: '支持按学生姓名或学号快速检索档案。',
      content: this.buildSearchBarContent
    })
  }

  @Builder
  buildSearchBarContent() {
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
    .backgroundColor('#F7FAFD')
    .borderRadius(16)
  }

  @Builder
  buildGradeFilter() {
    Card({
      title: '年级筛选',
      subtitle: '按年级快速切换当前档案池。',
      customPadding: 14,
      content: this.buildGradeFilterContent
    })
  }

  @Builder
  buildGradeFilterContent() {
    Scroll() {
      Row() {
        ForEach(this.grades, (grade: string) => {
          Text(grade === 'ALL' ? '全部' : `${grade}年级`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.selectedGrade === grade ? Color.White : $r('app.color.text_secondary'))
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.selectedGrade === grade ? $r('app.color.primary') : '#F3F7FB')
            .borderRadius(16)
            .onClick(() => {
              this.selectedGrade = grade;
              this.currentPage = 1;
              this.applyFiltersAndPagination();
            })
            .margin({ right: 8 })
        })
      }
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .padding({ left: 2, right: 2, top: 4, bottom: 4 })
  }

  @Builder
  buildStudentList() {
    if (this.isLoading && this.studentList.length === 0) {
      LoadingState({
        loadingSize: LoadingSize.LARGE,
        fullscreen: false
      })
    } else if (this.studentList.length === 0) {
      EmptyState({
        type: EmptyType.NO_STUDENT,
        customTitle: '暂无学生档案',
        customDescription: '当前筛选条件下没有匹配的学生信息。',
        actionText: '重新加载',
        onAction: () => {
          this.loadStudents();
        }
      })
    } else {
      Column() {
        SectionHeader({
          title: '学生列表',
          subtitle: `第 ${this.currentPage} 页，共 ${this.totalPages} 页`
        })

        Card({
          customPadding: 14,
          customBgColor: '#F8FBFF',
          content: this.buildListSummary
        })

        Column() {
          ForEach(this.studentList, (student: StudentWithGuardian) => {
            this.buildStudentCard(student)
          })
        }
        .width('100%')

        this.buildPagination()
      }
      .width('100%')
    }
  }

  @Builder
  buildListSummary() {
    Row() {
      this.buildExecutiveMetric('当前页', `${this.studentList.length}`, '#526F95')
      Blank().width(10)
      this.buildExecutiveMetric('筛选总量', `${this.getFilteredTotal()}`, '#D97706')
      Blank().width(10)
      this.buildExecutiveMetric('检索词', this.searchKeyword || '未输入', '#10203A')
    }
    .width('100%')
  }

  @Builder
  buildStudentCard(student: StudentWithGuardian) {
    Row() {
      Image($r('app.media.ic_default_avatar'))
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('app.color.primary_light'))
        .margin({ right: 12 })

      Column() {
        Row() {
          Text(student.name)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          if (student.gender) {
            Text(student.gender === 'MALE' ? '男' : '女')
              .fontSize(12)
              .fontColor(student.gender === 'MALE' ? '#526F95' : '#8A6A9E')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(student.gender === 'MALE' ? '#F8F0DE' : '#FDF0FF')
              .borderRadius(999)
              .margin({ left: 8 })
          }
        }

        Text(`学号：${student.studentNo || '--'}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 6 })

        Text(`${student.grade || '--'} 年级 · ${student.className || '--'}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 4 })

        if (student.guardianName) {
          Row() {
            Image($r('app.media.ic_user'))
              .width(12)
              .height(12)
              .fillColor($r('app.color.text_tertiary'))

            Text(` 监护人：${student.guardianName}`)
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_tertiary'))

            if (student.guardianMobile) {
              Text(` ${student.guardianMobile}`)
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
          url: 'pages/admin/AdminStudentDetailPage',
          params: { studentId: student.id }
        });
      })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius(20)
    .margin({ bottom: $r('app.float.card_margin') })
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  buildPagination() {
    Card({
      title: '分页导航',
      subtitle: '按页浏览更多学生档案。',
      customPadding: 16,
      content: this.buildPaginationContent
    })
  }

  @Builder
  buildPaginationContent() {
    Row() {
      Button('上一页')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.currentPage > 1 ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .backgroundColor(Color.Transparent)
        .border({ width: 1, color: this.currentPage > 1 ? $r('app.color.primary') : '#D7E1EE', radius: 14 })
        .borderRadius(14)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .enabled(this.currentPage > 1)
        .opacity(this.currentPage > 1 ? 1 : 0.4)
        .onClick(() => {
          if (this.currentPage > 1) {
            this.currentPage--;
            this.applyFiltersAndPagination();
          }
        })

      Text(`${this.currentPage} / ${this.totalPages}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ left: 20, right: 20 })

      Button('下一页')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.currentPage < this.totalPages ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .backgroundColor(Color.Transparent)
        .border({ width: 1, color: this.currentPage < this.totalPages ? $r('app.color.primary') : '#D7E1EE', radius: 14 })
        .borderRadius(14)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .enabled(this.currentPage < this.totalPages)
        .opacity(this.currentPage < this.totalPages ? 1 : 0.4)
        .onClick(() => {
          if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.applyFiltersAndPagination();
          }
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  private getSelectedGradeText(): string {
    return this.selectedGrade === 'ALL' ? '全部' : `${this.selectedGrade}年级`;
  }
}

