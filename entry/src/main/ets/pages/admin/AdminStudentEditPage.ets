/**
 * SmartGuardian - Admin Student Edit Page
 * Student create and edit page for admin flow
 */

import {
  Card,
  EmptyState,
  EmptyType,
  HeaderTheme,
  InfoCard,
  InfoItem,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader
} from '../../components/common';
import { HarmonyColor } from '../../common/HarmonyDesign';
import { Student, StudentCreateRequest } from '../../models/user';
import { StudentService } from '../../services/api/auth';
import { StudentStore } from '../../stores/studentStore';
import { UserStore } from '../../stores/userStore';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { LogUtil } from '../../utils/LogUtil';

interface StudentEditParams {
  studentId?: number | string;
}

@Entry
@Component
struct AdminStudentEditPage {
  @State studentId: number = 0;
  @State isEditMode: boolean = false;
  @State isLoading: boolean = true;
  @State isSaving: boolean = false;
  @State errorMessage: string = '';

  @State studentNo: string = '';
  @State studentName: string = '';
  @State schoolIdText: string = '';
  @State classIdText: string = '';
  @State gradeText: string = '';
  @State guardianUserIdText: string = '';
  @State birthDateText: string = '';
  @State selectedGender: 'MALE' | 'FEMALE' | '' = '';
  @State healthNotes: string = '';

  async aboutToAppear() {
    ErrorHandlerUtil.setUIContext(this.getUIContext());
    const params = this.getUIContext().getRouter().getParams() as StudentEditParams;
    const rawStudentId = params.studentId;
    this.studentId = rawStudentId ? Number(rawStudentId) : 0;
    this.isEditMode = this.studentId > 0;
    await this.initializeForm();
  }

  private async initializeForm(): Promise<void> {
    const currentUser = UserStore.getUserInfo();
    this.schoolIdText = currentUser?.schoolId ? `${currentUser.schoolId}` : '1';

    if (!this.isEditMode) {
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const response = await StudentService.getStudentDetail(this.studentId);
      if (response.code !== 0 || !response.data) {
        this.errorMessage = response.message ? response.message : '学生信息加载失败';
        return;
      }

      this.fillForm(response.data);
    } catch (error) {
      LogUtil.error('AdminStudentEditPage', `Load student failed: ${String(error)}`);
      this.errorMessage = '学生信息加载失败，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  private fillForm(student: Student): void {
    this.studentNo = student.studentNo;
    this.studentName = student.name;
    this.schoolIdText = `${student.schoolId}`;
    this.classIdText = student.classId ? `${student.classId}` : '';
    this.gradeText = student.grade ? student.grade : '';
    this.guardianUserIdText = `${student.guardianUserId}`;
    this.birthDateText = student.birthDate ? student.birthDate : '';
    this.selectedGender = student.gender ? student.gender : '';
    this.healthNotes = student.healthNotes ? student.healthNotes : '';
  }

  private validateForm(): boolean {
    if (!ErrorHandlerUtil.validateRequired(this.studentNo, '学号')) {
      return false;
    }
    if (!ErrorHandlerUtil.validateRequired(this.studentName, '学生姓名')) {
      return false;
    }
    if (!ErrorHandlerUtil.validateRequired(this.schoolIdText, '学校ID')) {
      return false;
    }
    if (!ErrorHandlerUtil.validateRequired(this.guardianUserIdText, '监护人用户ID')) {
      return false;
    }

    if (Number(this.schoolIdText) <= 0 || Number.isNaN(Number(this.schoolIdText))) {
      ErrorHandlerUtil.showErrorToast('学校ID必须为正整数');
      return false;
    }
    if (Number(this.guardianUserIdText) <= 0 || Number.isNaN(Number(this.guardianUserIdText))) {
      ErrorHandlerUtil.showErrorToast('监护人用户ID必须为正整数');
      return false;
    }
    if (this.classIdText && (Number(this.classIdText) <= 0 || Number.isNaN(Number(this.classIdText)))) {
      ErrorHandlerUtil.showErrorToast('班级ID必须为正整数');
      return false;
    }
    if (this.birthDateText && !/^\d{4}-\d{2}-\d{2}$/.test(this.birthDateText.trim())) {
      ErrorHandlerUtil.showErrorToast('出生日期请按 YYYY-MM-DD 填写');
      return false;
    }
    return true;
  }

  private buildRequest(): StudentCreateRequest {
    return {
      studentNo: this.studentNo.trim(),
      name: this.studentName.trim(),
      schoolId: Number(this.schoolIdText),
      classId: this.classIdText ? Number(this.classIdText) : undefined,
      grade: this.gradeText.trim() ? this.gradeText.trim() : undefined,
      gender: this.selectedGender ? this.selectedGender : undefined,
      birthDate: this.birthDateText.trim() ? this.birthDateText.trim() : undefined,
      guardianUserId: Number(this.guardianUserIdText),
      healthNotes: this.healthNotes.trim() ? this.healthNotes.trim() : undefined
    };
  }

  async saveStudent() {
    if (this.isSaving || !this.validateForm()) {
      return;
    }

    this.isSaving = true;
    try {
      const payload = this.buildRequest();
      const response = this.isEditMode
        ? await StudentService.updateStudent(this.studentId, payload)
        : await StudentService.createStudent(payload);

      if (response.code !== 0 || !response.data) {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '保存学生档案失败');
        return;
      }

      StudentStore.clearStudentList();
      StudentStore.setCurrentStudent(response.data);
      ErrorHandlerUtil.showSuccessToast(this.isEditMode ? '学生档案已更新' : '学生档案已创建');
      this.getUIContext().getRouter().back();
    } catch (error) {
      LogUtil.error('AdminStudentEditPage', `Save student failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('保存学生档案失败，请稍后重试');
    } finally {
      this.isSaving = false;
    }
  }

  build() {
    Column() {
      PageHeader({
        title: this.isEditMode ? '编辑学生档案' : '新增学生档案',
        subtitle: this.isEditMode
          ? '统一维护学籍基础信息、监护关系与健康备注。'
          : '补齐核心建档字段，保存后即可回到档案列表继续管理。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY,
        rightContent: this.buildSaveAction
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.DEFAULT,
          message: '正在加载学生档案...'
        })
      } else if (this.errorMessage && this.isEditMode) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '学生档案暂不可编辑',
          customDescription: this.errorMessage,
          actionText: '重新加载',
          onAction: () => {
            this.initializeForm();
          }
        })
      } else {
        Scroll() {
          Column() {
            InfoCard({
              items: this.getOverviewItems(),
              columns: 2
            })

            this.buildBasicSection()
            this.buildSchoolSection()
            this.buildExtraSection()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildSaveAction() {
    Text(this.isSaving ? '保存中' : '保存')
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(HarmonyColor.textInverse)
      .opacity(this.isSaving ? 0.7 : 1)
      .onClick(() => {
        if (!this.isSaving) {
          this.saveStudent();
        }
      })
  }

  @Builder
  private buildBasicSection() {
    Column() {
      SectionHeader({
        title: '基础档案',
        subtitle: '优先补齐学号、姓名、性别和出生日期。'
      })

      Card({
        title: '学生信息',
        subtitle: '这些字段决定档案识别与后续检索。',
        content: this.buildBasicContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildBasicContent() {
    Column() {
      this.buildTextField('学号', '请输入学号', this.studentNo, (value: string) => {
        this.studentNo = value;
      })

      this.buildTextField('学生姓名', '请输入学生姓名', this.studentName, (value: string) => {
        this.studentName = value;
      })

      Column() {
        this.buildFieldLabel('性别')

        Row() {
          this.buildGenderChip('男生', 'MALE')
          this.buildGenderChip('女生', 'FEMALE')
        }
        .width('100%')
      }
      .width('100%')
      .margin({ top: 14 })

      this.buildTextField('出生日期', 'YYYY-MM-DD', this.birthDateText, (value: string) => {
        this.birthDateText = value;
      })
    }
    .width('100%')
  }

  @Builder
  private buildSchoolSection() {
    Column() {
      SectionHeader({
        title: '归属关系',
        subtitle: '把学校、班级和监护人 ID 维护完整，后续接口就能串起来。'
      })

      Card({
        title: '组织与监护',
        subtitle: '当前先沿用项目现有数据结构，以 ID 方式维护归属。',
        content: this.buildSchoolContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildSchoolContent() {
    Column() {
      this.buildTextField('学校ID', '请输入学校ID', this.schoolIdText, (value: string) => {
        this.schoolIdText = value;
      })

      this.buildTextField('班级ID', '请输入班级ID（可选）', this.classIdText, (value: string) => {
        this.classIdText = value;
      })

      this.buildTextField('年级', '例如：三年级', this.gradeText, (value: string) => {
        this.gradeText = value;
      })

      this.buildTextField('监护人用户ID', '请输入监护人用户ID', this.guardianUserIdText, (value: string) => {
        this.guardianUserIdText = value;
      })
    }
    .width('100%')
  }

  @Builder
  private buildExtraSection() {
    Column() {
      SectionHeader({
        title: '补充说明',
        subtitle: '把健康备注留在档案里，方便后续签到、请假和异常告警联动。'
      })

      Card({
        title: '健康备注',
        subtitle: '可填写过敏、用药提醒、特殊照护要求等。',
        content: this.buildExtraContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildExtraContent() {
    Column() {
      this.buildFieldLabel('健康备注')

      TextArea({
        text: this.healthNotes,
        placeholder: '请输入健康备注或特殊照护要求'
      })
        .width('100%')
        .height(120)
        .fontSize(15)
        .backgroundColor(HarmonyColor.surfaceSubtle)
        .borderRadius(16)
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .margin({ top: 8 })
        .onChange((value: string) => {
          this.healthNotes = value;
        })
    }
    .width('100%')
  }

  @Builder
  private buildTextField(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column() {
      this.buildFieldLabel(label)

      TextInput({
        text: value,
        placeholder: placeholder
      })
        .width('100%')
        .height(52)
        .fontSize(15)
        .backgroundColor(HarmonyColor.surfaceSubtle)
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .margin({ top: 8 })
        .onChange((nextValue: string) => {
          onChange(nextValue);
        })
    }
    .width('100%')
    .margin({ top: 14 })
  }

  @Builder
  private buildFieldLabel(label: string) {
    Text(label)
      .width('100%')
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_secondary'))
  }

  @Builder
  private buildGenderChip(label: string, value: 'MALE' | 'FEMALE') {
    Text(label)
      .fontSize(14)
      .fontColor(this.selectedGender === value ? HarmonyColor.textInverse : $r('app.color.text_primary'))
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor(this.selectedGender === value ? $r('app.color.primary') : HarmonyColor.surfaceSubtle)
      .borderRadius(18)
      .margin({ right: 10 })
      .onClick(() => {
        this.selectedGender = value;
      })
  }

  private getOverviewItems(): InfoItem[] {
    return [
      { label: '页面模式', value: this.isEditMode ? '编辑档案' : '新建档案' },
      { label: '保存策略', value: '直接走 StudentService' },
      { label: '缓存处理', value: '保存后清空学生列表缓存' },
      { label: '字段范围', value: '基础档案 + 归属关系 + 健康备注' }
    ];
  }
}

