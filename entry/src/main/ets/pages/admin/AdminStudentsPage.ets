/**
 * SmartGuardian - 学生档案管理页
 * 管理员查看和筛选学生信息
 */

import { StudentService } from '../../services/api/auth';
import { RouteUrls } from '../../constants/app.constants';
import { Student } from '../../models/user';
import { StudentStore } from '../../stores/studentStore';
import { DataMaskUtil } from '../../utils/DataMaskUtil';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';
import { LogUtil } from '../../utils/LogUtil';
import { HarmonyColor } from '../../common/HarmonyDesign';
import {
  AdminStudentListItemCard,
  AdminStudentsControlCard,
  AdminStudentsExecutiveCard,
  AdminStudentsOverviewRow,
  AdminStudentsPaginationCard,
  AdminStudentsSummaryCard,
  EmptyState,
  EmptyType,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader,
  StudentWithGuardian
} from '../../components/common';

@Entry
@Component
struct AdminStudentsPage {
  build() {
    Stack() {
      AdminStudentsPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AdminStudentsPageContent {
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
  private studentDataSource: LazyArrayDataSource<StudentWithGuardian> = new LazyArrayDataSource<StudentWithGuardian>();

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
        this.studentDataSource.clear();
      }
    } catch (error) {
      LogUtil.error('AdminStudentsPage', `Load students failed: ${String(error)}`);
      this.allStudents = [];
      this.studentList = [];
      this.totalPages = 1;
      this.studentDataSource.clear();
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
    this.studentDataSource.setItems(this.studentList);
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

      this.buildPageList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildPageList() {
    List() {
      ListItem() {
        this.buildExecutivePanel()
      }

      ListItem() {
        this.buildOverviewPanel()
      }

      ListItem() {
        this.buildControlDeck()
      }

      this.buildStudentListSections()
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0 })
    .padding({ left: 16, right: 16, top: 16, bottom: 24 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(8)
  }

  @Builder
  buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_add'),
      iconColor: HarmonyColor.textInverse,
      boxBgColor: HarmonyColor.overlayInverseSoft,
      boxBorderColor: HarmonyColor.overlayInverseBorder,
      boxSize: 42,
      iconSize: 22,
      onButtonClick: () => {
        this.getUIContext().getRouter().pushUrl({ url: RouteUrls.ADMIN_STUDENT_EDIT });
      }
    })
  }

  @Builder
  buildExecutivePanel() {
    AdminStudentsExecutiveCard({
      filteredTotal: this.getFilteredTotal(),
      selectedGradeText: this.getSelectedGradeText(),
      currentPage: this.currentPage,
      totalPages: this.totalPages
    })
      .margin({ bottom: 14 })
  }

  @Builder
  buildOverviewPanel() {
    AdminStudentsOverviewRow({
      totalStudents: this.allStudents.length,
      pageCount: this.studentList.length,
      selectedGradeText: this.getSelectedGradeText()
    })
      .margin({ bottom: 12 })
  }

  @Builder
  buildControlDeck() {
    AdminStudentsControlCard({
      searchKeyword: this.searchKeyword,
      selectedGrade: this.selectedGrade,
      grades: this.grades,
      onSearchChange: (value: string) => {
        this.searchKeyword = value;
      },
      onSearchSubmit: () => {
        this.currentPage = 1;
        this.loadStudents();
      },
      onGradeSelect: (grade: string) => {
        this.selectedGrade = grade;
        this.currentPage = 1;
        this.applyFiltersAndPagination();
      }
    })
      .margin({ bottom: 12 })
  }

  @Builder
  buildStudentListSections() {
    if (this.isLoading && this.studentList.length === 0) {
      ListItem() {
        LoadingState({
          loadingSize: LoadingSize.LARGE,
          fullscreen: false
        })
      }
    } else if (this.studentList.length === 0) {
      ListItem() {
        EmptyState({
          type: EmptyType.NO_STUDENT,
          customTitle: '暂无学生档案',
          customDescription: '当前筛选条件下没有匹配的学生信息。',
          actionText: '重新加载',
          onAction: () => {
            this.loadStudents();
          }
        })
      }
    } else {
      ListItem() {
        SectionHeader({
          title: '学生列表',
          subtitle: `第 ${this.currentPage} 页，共 ${this.totalPages} 页`
        })
      }

      ListItem() {
        AdminStudentsSummaryCard({
          pageCount: this.studentList.length,
          filteredTotal: this.getFilteredTotal(),
          searchKeyword: this.searchKeyword
        })
      }

      LazyForEach(this.studentDataSource, (student: StudentWithGuardian) => {
        ListItem() {
          AdminStudentListItemCard({
            student: student
          })
            .margin({ bottom: $r('app.float.card_margin') })
        }
      }, (student: StudentWithGuardian) => `${student.id}`)

      ListItem() {
        AdminStudentsPaginationCard({
          currentPage: this.currentPage,
          totalPages: this.totalPages,
          onPrevious: () => {
            if (this.currentPage > 1) {
              this.currentPage--;
              this.applyFiltersAndPagination();
            }
          },
          onNext: () => {
            if (this.currentPage < this.totalPages) {
              this.currentPage++;
              this.applyFiltersAndPagination();
            }
          }
        })
      }
    }
  }

  private getSelectedGradeText(): string {
    return this.selectedGrade === 'ALL' ? '全部' : `${this.selectedGrade}年级`;
  }
}

