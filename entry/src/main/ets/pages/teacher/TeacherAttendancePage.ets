/**
 * SmartGuardian - Teacher Attendance Page
 * Teacher can manage attendance - sign in/out students
 */

import { AttendanceService, AttendanceRecord, SignInRequest } from '../../services/api/attendance';
import { SessionService, SessionWithStudents } from '../../services/api/service';

@Component
struct TeacherAttendancePage {
  @State sessions: SessionWithStudents[] = [];
  @State currentSessionIndex: number = 0;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear() {
    this.loadTodaySessions();
  }

  async loadTodaySessions() {
    this.isLoading = true;
    try {
      const today = new Date().toISOString().split('T')[0];
      const resp = await SessionService.getSessions({
        sessionDate: today,
        pageSize: 10
      });

      if (resp.code === 0 && resp.data) {
        // Load detail for each session
        const sessionDetails: SessionWithStudents[] = [];
        for (const session of resp.data.list) {
          const detailResp = await SessionService.getSessionDetail(session.id);
          if (detailResp.code === 0 && detailResp.data) {
            sessionDetails.push(detailResp.data);
          }
        }
        this.sessions = sessionDetails;
      }
    } catch (error) {
      this.errorMessage = '加载班次失败';
    } finally {
      this.isLoading = false;
    }
  }

  async handleSignIn(studentId: number) {
    try {
      const request: SignInRequest = {
        studentId,
        sessionId: this.sessions[this.currentSessionIndex].id,
        signMethod: 'MANUAL'
      };
      await AttendanceService.signIn(request);
      this.loadTodaySessions();
    } catch (error) {
      this.errorMessage = '签到失败';
    }
  }

  async handleSignOut(studentId: number) {
    try {
      const request = {
        studentId,
        sessionId: this.sessions[this.currentSessionIndex].id,
        signMethod: 'MANUAL'
      };
      await AttendanceService.signOut(request);
      this.loadTodaySessions();
    } catch (error) {
      this.errorMessage = '签退失败';
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Session selector
      if (this.sessions.length > 0) {
        this.buildSessionSelector()
      }

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
      Text('考勤管理')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: $r('app.float.status_bar_height') + 20, bottom: 20 })
    .backgroundColor($r('app.color.primary'))
  }

  @Builder
  buildSessionSelector() {
    Row() {
      Text(this.sessions[this.currentSessionIndex]?.sessionNo || '选择班次')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))

      Text(`${this.sessions[this.currentSessionIndex]?.startTime || ''} - ${this.sessions[this.currentSessionIndex]?.endTime || ''}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ left: 8 })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
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
    } else if (this.sessions.length === 0 || !this.sessions[this.currentSessionIndex]) {
      Column() {
        Text('暂无班次')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      const students = this.sessions[this.currentSessionIndex].students || [];
      
      Scroll() {
        Column() {
          // Stats
          this.buildStatsRow(students)

          // Student list
          ForEach(students, (student: any) => {
            this.buildStudentItem(student)
          })
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  buildStatsRow(students: any[]) {
    Row() {
      let signedIn = students.filter((s: any) => s.attendanceStatus === 'SIGNED_IN').length;
      let signedOut = students.filter((s: any) => s.attendanceStatus === 'SIGNED_OUT').length;
      let notSigned = students.filter((s: any) => s.attendanceStatus === 'NOT_SIGNED').length;

      Column() {
        Text(`${signedIn}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
        Text('已签到')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)

      Column() {
        Text(`${signedOut}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2196F3')
        Text('已签退')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)

      Column() {
        Text(`${notSigned}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF9800')
        Text('未签到')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildStudentItem(student: any) {
    Row() {
      Column() {
        Text(student.studentName)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(student.studentNo)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (student.attendanceStatus === 'NOT_SIGNED') {
        Column() {
          Text(student.signInTime || '')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
          
          Button('签到')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.button_radius'))
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .margin({ top: 4 })
            .onClick(() => this.handleSignIn(student.studentId))
        }
      } else if (student.attendanceStatus === 'SIGNED_IN') {
        Column() {
          Text(`签到: ${student.signInTime || ''}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor('#4CAF50')
          
          Button('签退')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(Color.White)
            .backgroundColor('#2196F3')
            .borderRadius($r('app.float.button_radius'))
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .margin({ top: 4 })
            .onClick(() => this.handleSignOut(student.studentId))
        }
      } else if (student.attendanceStatus === 'SIGNED_OUT') {
        Column() {
          Text(`签退: ${student.signOutTime || ''}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor('#9E9E9E')
        }
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_content_margin') })
  }
}