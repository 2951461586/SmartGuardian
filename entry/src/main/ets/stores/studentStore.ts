/**
 * SmartGuardian - Student Store
 * Student state management
 */

import { Student } from '../models/user';

/**
 * Student store keys
 */
const STUDENT_LIST_KEY = 'student_list';
const CURRENT_STUDENT_KEY = 'current_student';
const SELECTED_STUDENTS_KEY = 'selected_students';

/**
 * Student state management
 */
export class StudentStore {
  /**
   * Set student list
   */
  static setStudentList(students: Student[]): void {
    AppStorage.setOrCreate(STUDENT_LIST_KEY, students);
  }

  /**
   * Get student list
   */
  static getStudentList(): Student[] {
    return AppStorage.get<Student[]>(STUDENT_LIST_KEY) ?? [];
  }

  /**
   * Set current student
   */
  static setCurrentStudent(student: Student): void {
    AppStorage.setOrCreate(CURRENT_STUDENT_KEY, student);
  }

  /**
   * Get current student
   */
  static getCurrentStudent(): Student | null {
    return AppStorage.get<Student>(CURRENT_STUDENT_KEY) ?? null;
  }

  /**
   * Get current student ID
   */
  static getCurrentStudentId(): number | null {
    const student = this.getCurrentStudent();
    return student?.id ?? null;
  }

  /**
   * Set selected students (for multi-select scenarios)
   */
  static setSelectedStudents(studentIds: number[]): void {
    AppStorage.setOrCreate(SELECTED_STUDENTS_KEY, studentIds);
  }

  /**
   * Get selected students
   */
  static getSelectedStudents(): number[] {
    return AppStorage.get<number[]>(SELECTED_STUDENTS_KEY) ?? [];
  }

  /**
   * Add student to selection
   */
  static addToSelection(studentId: number): void {
    const selected = this.getSelectedStudents();
    if (!selected.includes(studentId)) {
      selected.push(studentId);
      this.setSelectedStudents(selected);
    }
  }

  /**
   * Remove student from selection
   */
  static removeFromSelection(studentId: number): void {
    const selected = this.getSelectedStudents();
    const index = selected.indexOf(studentId);
    if (index > -1) {
      selected.splice(index, 1);
      this.setSelectedStudents(selected);
    }
  }

  /**
   * Clear selection
   */
  static clearSelection(): void {
    this.setSelectedStudents([]);
  }

  /**
   * Find student by ID
   */
  static findStudentById(studentId: number): Student | null {
    const students = this.getStudentList();
    return students.find(s => s.id === studentId) ?? null;
  }

  /**
   * Clear all student data
   */
  static clearAll(): void {
    AppStorage.delete(STUDENT_LIST_KEY);
    AppStorage.delete(CURRENT_STUDENT_KEY);
    AppStorage.delete(SELECTED_STUDENTS_KEY);
  }
}
