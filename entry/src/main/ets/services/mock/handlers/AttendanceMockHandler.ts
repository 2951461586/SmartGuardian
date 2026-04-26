import { ApiResponse, PageResponse } from '../../../models/common';
import { AttendanceRecord, LeaveRecord } from '../../../models/attendance';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockAttendanceRecords, mockLeaveRecords, mockSessions, mockStudents } from '../mockData';
import { createPageResponse, extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class AttendanceMockHandler {
  static async getAttendanceList(params?: {
    studentId?: number;
    sessionId?: number;
  }): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    let records = mockAttendanceRecords;
    if (params?.studentId) {
      records = records.filter((item: AttendanceRecord) => item.studentId === params.studentId);
    }
    if (params?.sessionId) {
      records = records.filter((item: AttendanceRecord) => item.sessionId === params.sessionId);
    }
    return mockResponse(createPageResponse(records, 1, 10));
  }

  static async signIn(data: object): Promise<ApiResponse<AttendanceRecord>> {
    const body = data as Record<string, string | number>;
    const session = mockSessions[0];
    const student = mockStudents.find((item) => item.id === Number(body.studentId)) ?? mockStudents[0];
    return mockResponse({
      id: Date.now(),
      studentId: student.id,
      sessionId: Number(body.sessionId) || session.id,
      signInTime: new Date().toISOString(),
      signInMethod: body.signMethod ? String(body.signMethod) : 'MANUAL',
      signInLocation: body.location ? String(body.location) : session.location,
      status: 'SIGNED_IN',
      studentName: student.name,
      studentNo: student.studentNo,
      sessionNo: session.sessionNo,
      attendanceDate: session.sessionDate
    });
  }

  static async signOut(data: object): Promise<ApiResponse<AttendanceRecord>> {
    const body = data as Record<string, string | number>;
    const session = mockSessions[0];
    const student = mockStudents.find((item) => item.id === Number(body.studentId)) ?? mockStudents[0];
    return mockResponse({
      id: Date.now(),
      studentId: student.id,
      sessionId: Number(body.sessionId) || session.id,
      signInTime: new Date().toISOString(),
      signOutTime: new Date().toISOString(),
      signOutMethod: body.signMethod ? String(body.signMethod) : 'MANUAL',
      signOutLocation: body.location ? String(body.location) : session.location,
      status: 'SIGNED_OUT',
      studentName: student.name,
      studentNo: student.studentNo,
      sessionNo: session.sessionNo,
      attendanceDate: session.sessionDate
    });
  }

  static async getAbnormalAttendance(): Promise<ApiResponse<PageResponse<AttendanceRecord>>> {
    const abnormalRecords = mockAttendanceRecords.filter((item: AttendanceRecord) => item.abnormalFlag || item.status === 'ABSENT');
    return mockResponse(createPageResponse(abnormalRecords, 1, 20));
  }

  static async submitLeave(data: object): Promise<ApiResponse<LeaveRecord>> {
    const body = data as Record<string, string | number | string[]>;
    return mockResponse({
      id: mockLeaveRecords.length + 1,
      studentId: Number(body.studentId) || 0,
      leaveDate: String(body.leaveDate ?? new Date().toISOString().split('T')[0]),
      leaveType: String(body.leaveType ?? 'PERSONAL'),
      reason: String(body.reason ?? ''),
      attachments: Array.isArray(body.attachments) ? body.attachments as string[] : [],
      status: 'PENDING',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  }

  static async getLeaveList(): Promise<ApiResponse<PageResponse<LeaveRecord>>> {
    return mockResponse(createPageResponse(mockLeaveRecords, 1, 20));
  }

  static async cancelLeave(leaveId: number): Promise<ApiResponse<LeaveRecord>> {
    const leave = mockLeaveRecords.find((item: LeaveRecord) => item.id === leaveId) ?? mockLeaveRecords[0];
    return mockResponse({
      ...leave,
      status: 'CANCELLED',
      updatedAt: new Date().toISOString()
    });
  }

  static async getAttendanceStatistics(): Promise<ApiResponse<{ total: number; signedIn: number; signedOut: number; absent: number; leave: number }>> {
    return mockResponse({
      total: mockAttendanceRecords.length,
      signedIn: mockAttendanceRecords.filter((item: AttendanceRecord) => item.status === 'SIGNED_IN').length,
      signedOut: mockAttendanceRecords.filter((item: AttendanceRecord) => item.status === 'SIGNED_OUT').length,
      absent: mockAttendanceRecords.filter((item: AttendanceRecord) => item.status === 'ABSENT').length,
      leave: mockLeaveRecords.length
    });
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.ATTENDANCE && method === HttpMethod.GET) {
      return this.getAttendanceList({
        studentId: Number(getQueryParam(url, 'studentId')) || undefined,
        sessionId: Number(getQueryParam(url, 'sessionId')) || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_SIGN_IN && method === HttpMethod.POST) {
      return this.signIn(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_SIGN_OUT && method === HttpMethod.POST) {
      return this.signOut(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_ABNORMAL && method === HttpMethod.GET) {
      return this.getAbnormalAttendance() as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_LEAVE && method === HttpMethod.POST) {
      return this.submitLeave(data ?? {}) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_LEAVE && method === HttpMethod.GET) {
      return this.getLeaveList() as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/cancel') > -1 && method === HttpMethod.POST) {
      return this.cancelLeave(extractId(path, ApiEndpoints.ATTENDANCE_LEAVE + '/')) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.ATTENDANCE_STATS && method === HttpMethod.GET) {
      return this.getAttendanceStatistics() as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
