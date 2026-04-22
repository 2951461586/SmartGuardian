/**
 * SmartGuardian - 学生档案管理页
 * 管理员查看和筛选学生信息
 */

import { StudentService } from '../../services/api/auth';
import { Student } from '../../models/user';
import { StudentStore } from '../../stores/studentStore';
import { DataMaskUtil } from '../../utils/DataMaskUtil';
import { LogUtil } from '../../utils/LogUtil';

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

  build() {
    Column() {
      this.buildHeader()
      this.buildSearchBar()
      this.buildGradeFilter()
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
        .onClick(() => this.getUIContext().getRouter().back())

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
          this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminStudentEditPage' });
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
              this.applyFiltersAndPagination();
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
    if (this.isLoading && this.studentList.length === 0) {
      Column() {
        LoadingProgress()
          .color($r('app.color.primary'))
          .width(48)
          .height(48)

        Text('加载中...')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 16 })
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
          .margin({ top: 16 })
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

        this.buildPagination()
      }
      .width('100%')
      .layoutWeight(1)
    }
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
            Text(student.gender === 'MALE' ? 'M' : 'F')
              .fontSize(14)
              .margin({ left: 4 })
          }
        }

        Text(`学号: ${student.studentNo || '--'}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 2 })

        Text(`${student.grade || '--'} 年级 ${student.className || '--'}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 2 })

        if (student.guardianName) {
          Row() {
            Image($r('app.media.ic_user'))
              .width(12)
              .height(12)
              .fillColor($r('app.color.text_tertiary'))

            Text(` 监护人: ${student.guardianName}`)
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
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
    .shadow({
      radius: 2,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 1
    })
  }

  @Builder
  buildPagination() {
    Row() {
      Button('Prev')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.currentPage > 1 ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .backgroundColor(Color.Transparent)
        .border({ width: 1, color: this.currentPage > 1 ? $r('app.color.primary') : $r('app.color.text_tertiary') })
        .borderRadius(4)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .enabled(this.currentPage > 1)
        .opacity(this.currentPage > 1 ? 1 : 0.3)
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

      Button('Next')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.currentPage < this.totalPages ? $r('app.color.primary') : $r('app.color.text_tertiary'))
        .backgroundColor(Color.Transparent)
        .border({ width: 1, color: this.currentPage < this.totalPages ? $r('app.color.primary') : $r('app.color.text_tertiary') })
        .borderRadius(4)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .enabled(this.currentPage < this.totalPages)
        .opacity(this.currentPage < this.totalPages ? 1 : 0.3)
        .onClick(() => {
          if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.applyFiltersAndPagination();
          }
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
  }
}
