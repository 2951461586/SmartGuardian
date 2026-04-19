/**
 * SmartGuardian - Attendance Store
 * Attendance state management
 */

import { AttendanceRecord, AttendanceStatus } from '../models/attendance';
import { SessionSchedule } from '../models/service';

/**
 * Attendance store keys
 */
const TODAY_ATTENDANCE_KEY = 'today_attendance';
const CURRENT_SESSION_KEY = 'current_session';
const ATTENDANCE_RECORD_KEY = 'attendance_record';

/**
 * Attendance state management
 */
export class AttendanceStore {
  /**
   * Set today attendance records
   */
  static setTodayAttendance(records: AttendanceRecord[]): void {
    AppStorage.setOrCreate(TODAY_ATTENDANCE_KEY, records);
  }

  /**
   * Get today attendance records
   */
  static getTodayAttendance(): AttendanceRecord[] {
    return AppStorage.get<AttendanceRecord[]>(TODAY_ATTENDANCE_KEY) ?? [];
  }

  /**
   * Set current session
   */
  static setCurrentSession(session: SessionSchedule): void {
    AppStorage.setOrCreate(CURRENT_SESSION_KEY, session);
  }

  /**
   * Get current session
   */
  static getCurrentSession(): SessionSchedule | null {
    return AppStorage.get<SessionSchedule>(CURRENT_SESSION_KEY) ?? null;
  }

  /**
   * Get current session ID
   */
  static getCurrentSessionId(): number | null {
    const session = this.getCurrentSession();
    return session?.id ?? null;
  }

  /**
   * Set attendance record
   */
  static setAttendanceRecord(record: AttendanceRecord): void {
    AppStorage.setOrCreate(ATTENDANCE_RECORD_KEY, record);
  }

  /**
   * Get attendance record
   */
  static getAttendanceRecord(): AttendanceRecord | null {
    return AppStorage.get<AttendanceRecord>(ATTENDANCE_RECORD_KEY) ?? null;
  }

  /**
   * Update attendance in today list
   */
  static updateTodayAttendance(updatedRecord: AttendanceRecord): void {
    const records = this.getTodayAttendance();
    const index = records.findIndex(r => r.studentId === updatedRecord.studentId);
    if (index > -1) {
      records[index] = updatedRecord;
      this.setTodayAttendance(records);
    }
  }

  /**
   * Find attendance by student ID
   */
  static findAttendanceByStudentId(studentId: number): AttendanceRecord | null {
    const records = this.getTodayAttendance();
    return records.find(r => r.studentId === studentId) ?? null;
  }

  /**
   * Get attendance statistics
   */
  static getAttendanceStats(): {
    total: number;
    signedIn: number;
    signedOut: number;
    absent: number;
  } {
    const records = this.getTodayAttendance();
    return {
      total: records.length,
      signedIn: records.filter(r => r.status === AttendanceStatus.SIGNED_IN).length,
      signedOut: records.filter(r => r.status === AttendanceStatus.SIGNED_OUT).length,
      absent: records.filter(r => r.status === AttendanceStatus.ABSENT).length,
    };
  }

  /**
   * Clear all attendance data
   */
  static clearAll(): void {
    AppStorage.delete(TODAY_ATTENDANCE_KEY);
    AppStorage.delete(CURRENT_SESSION_KEY);
    AppStorage.delete(ATTENDANCE_RECORD_KEY);
  }
}
