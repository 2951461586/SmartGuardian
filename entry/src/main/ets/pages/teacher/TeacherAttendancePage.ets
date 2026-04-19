/**
 * SmartGuardian - Teacher Attendance Page
 * Teacher can manage attendance - sign in/out students
 * 
 * @optimized Using AttendanceStore for state management
 * @migrated 2026-04-18 - P1 Migration
 */

import { router } from '@kit.ArkUI';
import { AttendanceService } from '../../services/api/attendance';
import { AttendanceRecord, SignInRequest, SignOutRequest } from '../../models/attendance';
import { SessionService } from '../../services/api/service';
import { SessionWithStudents } from '../../models/service';
import { AttendanceStore } from '../../stores/attendanceStore';
import { LogUtil } from '../../utils/LogUtil';

interface AttendanceStudent {
  studentId: number;
  studentName: string;
  studentNo: string;
  attendanceStatus: string;
  signInTime?: string;
  signOutTime?: string;
}

@Component
export struct TeacherAttendancePage {
  // ✅ 使用 Store 管理考勤数据（缓存优先）
  @StorageLink('today_attendance') todayAttendance: AttendanceRecord[] = [];
  @StorageLink('current_session') currentSessionData: SessionWithStudents | null = null;
  
  // 本地 UI 状态
  @State sessions: SessionWithStudents[] = [];
  @State currentSessionIndex: number = 0;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  
  // 缓存时间戳
  private lastLoadTime: number = 0;
  private readonly CACHE_DURATION: number = 3 * 60 * 1000; // 3分钟缓存

  aboutToAppear() {
    this.loadTodaySessionsWithCache();
  }

  /**
   * 带缓存的班次加载策略
   * 1. 优先使用缓存数据（Store）
   * 2. 判断缓存是否过期
   * 3. 过期则后台刷新
   */
  async loadTodaySessionsWithCache() {
    // 尝试从 Store 恢复当前班次
    const cachedSession = AttendanceStore.getCurrentSession();
    if (cachedSession) {
      LogUtil.info('TeacherAttendancePage', `Using cached session: ${cachedSession.id}`);
    }
    
    // 判断是否需要刷新
    const now = Date.now();
    const shouldRefresh = (now - this.lastLoadTime) > this.CACHE_DURATION;
    
    if (shouldRefresh || !cachedSession) {
      await this.loadTodaySessions();
    }
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
        for (const session of resp.data) {
          const detailResp = await SessionService.getSessionDetail(session.id);
          if (detailResp.code === 0 && detailResp.data) {
            sessionDetails.push(detailResp.data);
          }
        }
        
        this.sessions = sessionDetails;
        
        // 更新 Store - 保存当前班次
        if (sessionDetails.length > 0) {
          AttendanceStore.setCurrentSession(sessionDetails[this.currentSessionIndex]);
        }
        
        // 更新今日考勤缓存
        if (sessionDetails[this.currentSessionIndex]?.students) {
          const records = this.convertStudentsToRecords(sessionDetails[this.currentSessionIndex].students);
          AttendanceStore.setTodayAttendance(records);
          this.todayAttendance = records;
        }
        
        this.lastLoadTime = Date.now();
        LogUtil.info('TeacherAttendancePage', `Loaded ${sessionDetails.length} sessions`);
      }
    } catch (error) {
      this.errorMessage = '加载班次失败';
      LogUtil.error('TeacherAttendancePage', `Load failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 将学生数据转换为考勤记录
   */
  convertStudentsToRecords(students: AttendanceStudent[]): AttendanceRecord[] {
    const records: AttendanceRecord[] = [];
    for (let i = 0; i < students.length; i++) {
      const s = students[i];
      const record: AttendanceRecord = {
        id: 0,
        studentId: s.studentId,
        studentName: s.studentName,
        sessionId: this.sessions[this.currentSessionIndex]?.id || 0,
        status: this.mapStatus(s.attendanceStatus),
        signInTime: s.signInTime,
        signOutTime: s.signOutTime
      };
      records.push(record);
    }
    return records;
  }

  /**
   * 映射考勤状态
   */
  mapStatus(status: string): string {
    const statusMap: Record<string, string> = {
      'NOT_SIGNED': 'ABSENT',
      'SIGNED_IN': 'SIGNED_IN',
      'SIGNED_OUT': 'SIGNED_OUT'
    };
    return statusMap[status] || 'ABSENT';
  }

  async handleSignIn(studentId: number) {
    try {
      const request: SignInRequest = {
        studentId,
        sessionId: this.sessions[this.currentSessionIndex].id,
        signMethod: 'MANUAL'
      };
      
      await AttendanceService.signIn(request);
      
      // 更新 Store
      const record = AttendanceStore.findAttendanceByStudentId(studentId);
      if (record) {
        record.status = 'SIGNED_IN';
        record.signInTime = new Date().toISOString();
        AttendanceStore.updateTodayAttendance(record);
      }
      
      // 刷新数据
      await this.loadTodaySessions();
      
      LogUtil.info('TeacherAttendancePage', `Student ${studentId} signed in`);
    } catch (error) {
      this.errorMessage = '签到失败';
      LogUtil.error('TeacherAttendancePage', `Sign in failed: ${JSON.stringify(error)}`);
    }
  }

  async handleSignOut(studentId: number) {
    try {
      const request: SignOutRequest = {
        studentId,
        sessionId: this.sessions[this.currentSessionIndex].id,
        signMethod: 'MANUAL'
      };
      
      await AttendanceService.signOut(request);
      
      // 更新 Store
      const record = AttendanceStore.findAttendanceByStudentId(studentId);
      if (record) {
        record.status = 'SIGNED_OUT';
        record.signOutTime = new Date().toISOString();
        AttendanceStore.updateTodayAttendance(record);
      }
      
      // 刷新数据
      await this.loadTodaySessions();
      
      LogUtil.info('TeacherAttendancePage', `Student ${studentId} signed out`);
    } catch (error) {
      this.errorMessage = '签退失败';
      LogUtil.error('TeacherAttendancePage', `Sign out failed: ${JSON.stringify(error)}`);
    }
  }

  handleOpenScan(scanType: 'SIGN_IN' | 'SIGN_OUT') {
    const currentSession = this.sessions[this.currentSessionIndex];
    if (!currentSession) {
      this.errorMessage = '暂无可用班次';
      return;
    }

    router.pushUrl({
      url: 'pages/teacher/TeacherScanPage',
      params: {
        sessionId: currentSession.id,
        scanType
      }
    });
  }

  getCurrentStudents(): AttendanceStudent[] {
    return this.sessions[this.currentSessionIndex]?.students || [];
  }

  getSignedInCount(students: AttendanceStudent[]): number {
    return students.filter((student: AttendanceStudent) => student.attendanceStatus === 'SIGNED_IN').length;
  }

  getSignedOutCount(students: AttendanceStudent[]): number {
    return students.filter((student: AttendanceStudent) => student.attendanceStatus === 'SIGNED_OUT').length;
  }

  getNotSignedCount(students: AttendanceStudent[]): number {
    return students.filter((student: AttendanceStudent) => student.attendanceStatus === 'NOT_SIGNED').length;
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
    .padding({ top: Number($r('app.float.status_bar_height')) + 20, bottom: 20 })
    .backgroundColor($r('app.color.primary'))
  }

  @Builder
  buildSessionSelector() {
    Row() {
      Column() {
        Text(this.sessions[this.currentSessionIndex]?.sessionNo || '选择班次')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))

        Text(`${this.sessions[this.currentSessionIndex]?.startTime || ''} - ${this.sessions[this.currentSessionIndex]?.endTime || ''}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Row() {
        Button('扫码签到')
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius($r('app.float.button_radius'))
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => this.handleOpenScan('SIGN_IN'))

        Button('扫码签退')
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.primary'))
          .backgroundColor('#EAF3FF')
          .borderRadius($r('app.float.button_radius'))
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ left: 8 })
          .onClick(() => this.handleOpenScan('SIGN_OUT'))
      }
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
      Scroll() {
        Column() {
          // Stats
          this.buildStatsRow(this.getCurrentStudents())

          // Student list
          ForEach(this.getCurrentStudents(), (student: AttendanceStudent) => {
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
  buildStatsRow(students: AttendanceStudent[]) {
    Row() {

      Column() {
        Text(`${this.getSignedInCount(students)}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
        Text('已签到')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)

      Column() {
        Text(`${this.getSignedOutCount(students)}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2196F3')
        Text('已签退')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)

      Column() {
        Text(`${this.getNotSignedCount(students)}`)
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
  buildStudentItem(student: AttendanceStudent) {
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
