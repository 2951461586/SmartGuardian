/**
 * SmartGuardian - Parent QR Code Page
 * Parent pickup QR code workbench.
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  Card,
  EmptyType,
  HeaderTheme,
  IconActionButton,
  PageHeader,
  SectionHeader,
  StatefulContainer,
  StatCardRow,
  StatRowItem,
  ViewState,
  WorkbenchListPageTemplate
} from '../../components/common';
import { Student } from '../../models/user';
import { StudentService } from '../../services/api/auth';
import { UserStore } from '../../stores/userStore';

@Entry
@Component
struct ParentQRCodePage {
  build() {
    Stack() {
      ParentQRCodePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentQRCodePageContent {
  @State students: Student[] = [];
  @State selectedStudent: Student | null = null;
  @State qrCodeData: string = '';
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State remainingTime: number = 300;
  private timer: number = -1;

  async aboutToAppear() {
    await this.loadStudents();
    this.startTimer();
  }

  aboutToDisappear() {
    this.clearTimer();
  }

  private clearTimer(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  private startTimer(): void {
    if (this.timer !== -1) {
      return;
    }
    this.timer = setInterval(() => {
      if (this.remainingTime > 0) {
        this.remainingTime--;
      } else {
        this.generateQRCode();
      }
    }, 1000);
  }

  async loadStudents() {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const userInfo = UserStore.getUserInfo();
      if (userInfo?.id) {
        const response = await StudentService.getStudents({ pageNum: 1, pageSize: 100 });
        if (response.code === 0 && response.data) {
          this.students = response.data.list ?? [];
          if (this.students.length > 0) {
            this.selectedStudent = this.students[0];
            this.generateQRCode();
          } else {
            this.selectedStudent = null;
            this.qrCodeData = '';
          }
        } else {
          this.students = [];
          this.selectedStudent = null;
          this.qrCodeData = '';
        }
      }
    } catch (error) {
      console.error('Failed to load students:', String(error));
      this.students = [];
      this.selectedStudent = null;
      this.qrCodeData = '';
      this.errorMessage = '学生信息加载失败，请稍后重试。';
    } finally {
      this.isLoading = false;
    }
  }

  private generateQRCode(): void {
    if (this.selectedStudent) {
      const timestamp = Date.now();
      this.qrCodeData = JSON.stringify({
        type: 'PICKUP',
        studentId: this.selectedStudent.id,
        studentName: this.selectedStudent.name,
        guardianId: UserStore.getUserInfo()?.id,
        timestamp: timestamp
      });
      this.remainingTime = 300;
    }
  }

  private getViewState(): ViewState {
    if (this.isLoading) {
      return ViewState.LOADING;
    }
    if (this.errorMessage.length > 0) {
      return ViewState.ERROR;
    }
    if (this.students.length === 0 || !this.selectedStudent) {
      return ViewState.EMPTY;
    }
    return ViewState.CONTENT;
  }

  private getOverviewItems(): StatRowItem[] {
    return [
      {
        value: `${this.students.length}`,
        label: '绑定学生',
        icon: $r('app.media.ic_user'),
        iconColor: HarmonyColor.info
      },
      {
        value: this.selectedStudent ? this.selectedStudent.studentNo : '--',
        label: '当前学号',
        icon: $r('app.media.ic_child'),
        iconColor: HarmonyReport.positive
      },
      {
        value: this.formatTime(this.remainingTime),
        label: '剩余有效期',
        icon: $r('app.media.ic_clock'),
        iconColor: HarmonyReport.caution
      }
    ];
  }

  private formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    const secondText = secs < 10 ? `0${secs}` : `${secs}`;
    return `${minutes}:${secondText}`;
  }

  private isSelectedStudent(student: Student): boolean {
    return this.selectedStudent?.id === student.id;
  }

  build() {
    Column() {
      WorkbenchListPageTemplate({
        scrollable: false,
        enableWideContent: true,
        header: () => { this.buildHeader() },
        overview: () => { this.buildOverviewSection() },
        controls: () => { this.buildStudentSelectorSection() },
        content: () => { this.buildQRCodeContent() }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHeader() {
    PageHeader({
      title: '接送码',
      subtitle: '出示动态二维码，便于托管机构快速核验家长接送身份。',
      showBack: true,
      theme: HeaderTheme.WHITE,
      onBackClick: () => this.getUIContext().getRouter().back(),
      rightContent: this.buildHeaderAction
    })
  }

  @Builder
  private buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_refresh'),
      iconColor: HarmonyColor.info,
      boxBgColor: HarmonyColor.surface,
      boxBorderColor: HarmonyColor.line,
      onButtonClick: () => {
        this.generateQRCode();
      }
    })
  }

  @Builder
  private buildOverviewSection() {
    StatCardRow({
      items: this.getOverviewItems()
    })
  }

  @Builder
  private buildStudentSelectorSection() {
    Card({
      title: '切换学生',
      subtitle: this.students.length > 1 ? '为不同学生切换独立接送码。' : '当前已选中唯一绑定学生。',
      content: () => { this.buildStudentSelectorContent() }
    })
  }

  @Builder
  private buildStudentSelectorContent() {
    if (this.students.length === 0) {
      Text('暂无可切换的学生。')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyColor.textSecondary)
    } else {
      Scroll() {
        Row() {
          ForEach(this.students, (student: Student) => {
            this.buildStudentChip(student)
          }, (student: Student) => `${student.id}`)
        }
      }
      .width('100%')
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  private buildStudentChip(student: Student) {
    Column() {
      Text(student.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isSelectedStudent(student) ? HarmonyColor.textInverse : HarmonyColor.textPrimary)

      Text(student.studentNo)
        .fontSize(11)
        .fontColor(this.isSelectedStudent(student) ? HarmonyColor.textInverseStrong : HarmonyColor.textSecondary)
        .margin({ top: 4 })
    }
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor(this.isSelectedStudent(student) ? HarmonyColor.info : HarmonyColor.surfaceSubtle)
    .borderRadius(18)
    .margin({ right: 10 })
    .onClick(() => {
      this.selectedStudent = student;
      this.generateQRCode();
    })
  }

  @Builder
  private buildQRCodeContent() {
    StatefulContainer({
      state: this.getViewState(),
      loadingMessage: '正在生成接送码...',
      emptyType: EmptyType.NO_STUDENT,
      emptyTitle: '暂无学生信息',
      emptyDescription: '请先完成学生绑定，再生成接送二维码。',
      errorMessage: this.errorMessage,
      onRetry: () => {
        this.loadStudents();
      },
      content: () => { this.buildQRCodeWorkspace() }
    })
      .layoutWeight(1)
  }

  @Builder
  private buildQRCodeWorkspace() {
    Scroll() {
      Column() {
        this.buildQRCodeCard()
        this.buildStudentSummaryCard()
        this.buildGuideCard()
      }
      .width('100%')
      .padding({ top: 4, bottom: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildQRCodeCard() {
    Card({
      title: '动态二维码',
      subtitle: '二维码过期后会自动刷新，也可以手动立即更新。',
      actionText: '刷新',
      onAction: () => {
        this.generateQRCode();
      },
      content: () => { this.buildQRCodeCardContent() }
    })
  }

  @Builder
  private buildQRCodeCardContent() {
    Column() {
      Column() {
        if (this.qrCodeData.length > 0) {
          QRCode(this.qrCodeData)
            .width(188)
            .height(188)
            .color(HarmonyColor.info)
        }
      }
      .width(232)
      .height(232)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(HarmonyColor.surface)
      .borderRadius(28)
      .border({
        width: 2,
        color: HarmonyColor.lineStrong,
        radius: 28,
        style: BorderStyle.Solid
      })

      Text('请在托管中心出示此码完成接送核验')
        .fontSize(12)
        .fontColor(HarmonyColor.textSecondary)
        .margin({ top: 14 })

      Text(`剩余有效期 ${this.formatTime(this.remainingTime)}`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(HarmonyColor.info)
        .margin({ top: 10 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildStudentSummaryCard() {
    Card({
      title: '当前学生',
      subtitle: '确认接送码对应的学生档案，避免错用二维码。',
      content: () => { this.buildStudentSummaryContent() }
    })
  }

  @Builder
  private buildStudentSummaryContent() {
    if (this.selectedStudent) {
      Column() {
        this.buildSummaryRow('学生姓名', this.selectedStudent.name)
        this.buildSummaryRow('学号', this.selectedStudent.studentNo)
        this.buildSummaryRow('学校', this.selectedStudent.schoolName ?? '待补充')
        this.buildSummaryRow('班级', this.selectedStudent.className ?? '待补充')
      }
      .width('100%')
    }
  }

  @Builder
  private buildGuideCard() {
    Card({
      title: '使用须知',
      subtitle: '家长和被授权接送人都应遵循以下核验规则。',
      content: () => { this.buildGuideContent() }
    })
  }

  @Builder
  private buildGuideContent() {
    Column() {
      SectionHeader({
        title: '核验说明',
        subtitle: '建议在接送前一刻再打开页面，确保二维码处于最新有效状态。'
      })

      this.buildGuideItem('1', '二维码默认 5 分钟有效，过期后系统会自动生成新码。')
      this.buildGuideItem('2', '如学生信息切换，请先确认顶部学生标签已切换成功。')
      this.buildGuideItem('3', '如网络异常，建议手动刷新二维码后再出示。')
    }
    .width('100%')
  }

  @Builder
  private buildSummaryRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor(HarmonyColor.textSecondary)
        .width(72)

      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(HarmonyColor.textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  private buildGuideItem(index: string, text: string) {
    Row() {
      Text(index)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(HarmonyColor.info)
        .width(22)

      Text(text)
        .fontSize(13)
        .fontColor(HarmonyColor.textSecondary)
        .lineHeight(19)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(18)
    .margin({ top: 10 })
  }
}
