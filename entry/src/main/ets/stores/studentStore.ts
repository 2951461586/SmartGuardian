/**
 * SmartGuardian - Student Store
 * Student state management with reactive support
 * 
 * @description 学生状态管理 Store，负责学生数据的全局状态管理
 * @features
 * - 学生列表缓存管理
 * - 当前选中学生追踪
 * - 学生搜索条件维护
 * - 学生 CRUD 操作支持
 * - 响应式状态变更通知
 * - 持久化支持
 */

import { Student } from '../models/user';
import { ReactiveStore, StateChangeListener } from './core';

/**
 * Student store keys
 * 
 * @description AppStorage 存储键名常量
 */
const STUDENT_LIST_KEY = 'student_list';
const CURRENT_STUDENT_KEY = 'current_student';
const STUDENT_SEARCH_KEY = 'student_search';
const STUDENT_COUNT_KEY = 'student_count';

/**
 * Student search params
 * 
 * @description 学生搜索参数接口
 */
export interface StudentSearchParams {
  /** 搜索关键词 */
  keyword?: string;
  
  /** 年级 */
  grade?: string;
  
  /** 班级ID */
  classId?: number;
  
  /** 学生状态 */
  status?: string;
}

/**
 * Student state management with reactive support
 * 
 * @description 学生状态管理类，提供学生数据的增删改查操作
 * @class
 * @example
 * ```typescript
 * // 设置学生列表
 * StudentStore.setStudentList(students);
 * 
 * // 监听学生列表变更
 * StudentStore.onStudentListChange((event) => {
 *   console.log('学生列表已更新');
 * });
 * 
 * // 按年级筛选
 * const grade1Students = StudentStore.getStudentsByGrade('一年级');
 * ```
 */
export class StudentStore extends ReactiveStore {
  // 初始化 Store 配置
  static {
    this.initOptions({
      name: 'StudentStore',
      persistent: false
    });
  }
  
  /**
   * Set student list
   * 
   * @description 设置学生列表到全局状态
   * @param {Student[]} students - 学生列表数组
   */
  static setStudentList(students: Student[]): void {
    this.setValue(STUDENT_LIST_KEY, students);
    // 自动更新学生总数
    this.setStudentCount(students.length);
  }
  
  /**
   * Get student list
   * 
   * @description 从全局状态获取学生列表
   * @returns {Student[]} 学生列表数组，如果为空则返回空数组
   */
  static getStudentList(): Student[] {
    return this.getValue<Student[]>(STUDENT_LIST_KEY) ?? [];
  }
  
  /**
   * Set current student
   * 
   * @description 设置当前选中的学生（用于学生详情页）
   * @param {Student} student - 学生对象
   */
  static setCurrentStudent(student: Student): void {
    this.setValue(CURRENT_STUDENT_KEY, student);
  }
  
  /**
   * Get current student
   * 
   * @description 获取当前选中的学生
   * @returns {Student | null} 当前学生对象，如果未设置则返回 null
   */
  static getCurrentStudent(): Student | null {
    return this.getValue<Student>(CURRENT_STUDENT_KEY) ?? null;
  }
  
  /**
   * Get current student ID
   * 
   * @description 获取当前学生的 ID（便捷方法）
   * @returns {number | null} 当前学生 ID，如果未设置则返回 null
   */
  static getCurrentStudentId(): number | null {
    const student = this.getCurrentStudent();
    return student?.id ?? null;
  }
  
  /**
   * Set search params
   * 
   * @description 设置学生搜索参数（用于搜索条件持久化）
   * @param {StudentSearchParams} params - 搜索参数对象
   */
  static setSearchParams(params: StudentSearchParams): void {
    this.setValue(STUDENT_SEARCH_KEY, params);
  }
  
  /**
   * Get search params
   * 
   * @description 获取当前的学生搜索参数
   * @returns {StudentSearchParams} 搜索参数对象，如果未设置则返回空对象
   */
  static getSearchParams(): StudentSearchParams {
    return this.getValue<StudentSearchParams>(STUDENT_SEARCH_KEY) ?? {};
  }
  
  /**
   * Set student count
   * 
   * @description 设置学生总数（持久化）
   * @param {number} count - 学生总数
   */
  static setStudentCount(count: number): void {
    this.setValue(STUDENT_COUNT_KEY, count, { persist: true });
  }
  
  /**
   * Get student count
   * 
   * @description 获取学生总数
   * @returns {number} 学生总数
   */
  static getStudentCount(): number {
    return this.getValue<number>(STUDENT_COUNT_KEY) ?? 0;
  }
  
  /**
   * Update student in list
   * 
   * @description 更新学生列表中的指定学生（用于局部更新）
   * @param {Student} updatedStudent - 更新后的学生对象
   */
  static updateStudentInList(updatedStudent: Student): void {
    const students = this.getStudentList();
    const index = students.findIndex(s => s.id === updatedStudent.id);
    if (index > -1) {
      students[index] = updatedStudent;
      this.setStudentList([...students]);
    }
  }
  
  /**
   * Add student to list
   * 
   * @description 添加新学生到列表
   * @param {Student} student - 新学生对象
   */
  static addStudent(student: Student): void {
    const students = this.getStudentList();
    this.setStudentList([...students, student]);
  }
  
  /**
   * Remove student from list
   * 
   * @description 从列表中移除学生
   * @param {number} studentId - 学生 ID
   */
  static removeStudent(studentId: number): void {
    const students = this.getStudentList();
    this.setStudentList(students.filter(s => s.id !== studentId));
  }
  
  /**
   * Find student by ID
   * 
   * @description 根据 ID 查找学生
   * @param {number} studentId - 学生 ID
   * @returns {Student | undefined} 找到的学生
   */
  static findStudentById(studentId: number): Student | undefined {
    return this.getStudentList().find(s => s.id === studentId);
  }
  
  /**
   * Get students by grade
   * 
   * @description 按年级获取学生列表
   * @param {string} grade - 年级
   * @returns {Student[]} 筛选后的学生列表
   */
  static getStudentsByGrade(grade: string): Student[] {
    return this.getStudentList().filter(s => s.grade === grade);
  }
  
  /**
   * Get students by class
   * 
   * @description 按班级获取学生列表
   * @param {number} classId - 班级 ID
   * @returns {Student[]} 筛选后的学生列表
   */
  static getStudentsByClass(classId: number): Student[] {
    return this.getStudentList().filter(s => s.classId === classId);
  }
  
  /**
   * Search students
   * 
   * @description 搜索学生（根据关键词）
   * @param {string} keyword - 搜索关键词
   * @returns {Student[]} 匹配的学生列表
   */
  static searchStudents(keyword: string): Student[] {
    if (!keyword) {
      return this.getStudentList();
    }
    const lowerKeyword = keyword.toLowerCase();
    return this.getStudentList().filter(s => 
      s.name.toLowerCase().includes(lowerKeyword) ||
      s.studentNo.toLowerCase().includes(lowerKeyword)
    );
  }
  
  /**
   * Clear student list
   * 
   * @description 清空学生列表
   */
  static clearStudentList(): void {
    this.setStudentList([]);
  }
  
  /**
   * Clear current student
   * 
   * @description 清除当前选中学生
   */
  static clearCurrentStudent(): void {
    this.deleteValue(CURRENT_STUDENT_KEY);
  }
  
  // ============ 响应式订阅方法 ============
  
  /**
   * Subscribe to student list changes
   * 
   * @description 订阅学生列表变更
   * @param {StateChangeListener<Student[]>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onStudentListChange(listener: StateChangeListener<Student[]>): () => void {
    return this.subscribe<Student[]>(STUDENT_LIST_KEY, listener);
  }
  
  /**
   * Subscribe to current student changes
   * 
   * @description 订阅当前学生变更
   * @param {StateChangeListener<Student>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onCurrentStudentChange(listener: StateChangeListener<Student>): () => void {
    return this.subscribe<Student>(CURRENT_STUDENT_KEY, listener);
  }
  
  /**
   * Subscribe to search params changes
   * 
   * @description 订阅搜索参数变更
   * @param {StateChangeListener<StudentSearchParams>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onSearchParamsChange(listener: StateChangeListener<StudentSearchParams>): () => void {
    return this.subscribe<StudentSearchParams>(STUDENT_SEARCH_KEY, listener);
  }
  
  /**
   * Subscribe to student count changes
   * 
   * @description 订阅学生总数变更
   * @param {StateChangeListener<number>} listener - 监听器
   * @returns {() => void} 取消订阅函数
   */
  static onStudentCountChange(listener: StateChangeListener<number>): () => void {
    return this.subscribe<number>(STUDENT_COUNT_KEY, listener);
  }
}
