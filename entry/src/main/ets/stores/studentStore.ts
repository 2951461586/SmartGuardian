/**
 * SmartGuardian - Student Store
 * Student state management
 * 
 * @description 学生状态管理 Store，负责学生数据的全局状态管理
 * @features
 * - 学生列表缓存管理
 * - 当前选中学生追踪
 * - 学生搜索条件维护
 * - 学生 CRUD 操作支持
 */

import { Student } from '../models/user';

/**
 * Student store keys
 * 
 * @description AppStorage 存储键名常量
 */
const STUDENT_LIST_KEY = 'student_list';
const CURRENT_STUDENT_KEY = 'current_student';
const STUDENT_SEARCH_KEY = 'student_search';

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
 * Student state management
 * 
 * @description 学生状态管理类，提供学生数据的增删改查操作
 * @class
 * @example
 * ```typescript
 * // 设置学生列表
 * StudentStore.setStudentList(students);
 * 
 * // 获取学生列表
 * const students = StudentStore.getStudentList();
 * 
 * // 按年级筛选
 * const grade1Students = StudentStore.getStudentsByGrade('一年级');
 * ```
 */
export class StudentStore {
  /**
   * Set student list
   * 
   * @description 设置学生列表到全局状态
   * @param {Student[]} students - 学生列表数组
   * @returns {void}
   * @example
   * ```typescript
   * const students = await StudentService.getStudents();
   * StudentStore.setStudentList(students.data);
   * ```
   */
  static setStudentList(students: Student[]): void {
    AppStorage.setOrCreate(STUDENT_LIST_KEY, students);
  }

  /**
   * Get student list
   * 
   * @description 从全局状态获取学生列表
   * @returns {Student[]} 学生列表数组，如果为空则返回空数组
   * @example
   * ```typescript
   * const students = StudentStore.getStudentList();
   * console.log('学生数量:', students.length);
   * ```
   */
  static getStudentList(): Student[] {
    return AppStorage.get<Student[]>(STUDENT_LIST_KEY) ?? [];
  }

  /**
   * Set current student
   * 
   * @description 设置当前选中的学生（用于学生详情页）
   * @param {Student} student - 学生对象
   * @returns {void}
   * @example
   * ```typescript
   * StudentStore.setCurrentStudent(student);
   * router.pushUrl({ url: '/pages/admin/AdminStudentDetailPage' });
   * ```
   */
  static setCurrentStudent(student: Student): void {
    AppStorage.setOrCreate(CURRENT_STUDENT_KEY, student);
  }

  /**
   * Get current student
   * 
   * @description 获取当前选中的学生
   * @returns {Student | null} 当前学生对象，如果未设置则返回 null
   * @example
   * ```typescript
   * const currentStudent = StudentStore.getCurrentStudent();
   * if (currentStudent) {
   *   console.log('当前学生:', currentStudent.name);
   * }
   * ```
   */
  static getCurrentStudent(): Student | null {
    return AppStorage.get<Student>(CURRENT_STUDENT_KEY) ?? null;
  }

  /**
   * Get current student ID
   * 
   * @description 获取当前学生的 ID（便捷方法）
   * @returns {number | null} 当前学生 ID，如果未设置则返回 null
   * @example
   * ```typescript
   * const studentId = StudentStore.getCurrentStudentId();
   * if (studentId) {
   *   await StudentService.getStudentDetail(studentId);
   * }
   * ```
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
   * @returns {void}
   * @example
   * ```typescript
   * StudentStore.setSearchParams({ keyword: '张三' });
   * ```
   */
  static setSearchParams(params: StudentSearchParams): void {
    AppStorage.setOrCreate(STUDENT_SEARCH_KEY, params);
  }

  /**
   * Get search params
   * 
   * @description 获取当前的学生搜索参数
   * @returns {StudentSearchParams} 搜索参数对象，如果未设置则返回空对象
   * @example
   * ```typescript
   * const params = StudentStore.getSearchParams();
   * if (params.keyword) {
   *   // 使用搜索关键词
   * }
   * ```
   */
  static getSearchParams(): StudentSearchParams {
    return AppStorage.get<StudentSearchParams>(STUDENT_SEARCH_KEY) ?? {};
  }

  /**
   * Find student by ID
   * 
   * @description 在学生列表中查找指定 ID 的学生
   * @param {number} studentId - 学生 ID
   * @returns {Student | null} 找到的学生对象，未找到则返回 null
   * @example
   * ```typescript
   * const student = StudentStore.findStudentById(123);
   * if (student) {
   *   console.log('找到学生:', student.name);
   * }
   * ```
   */
  static findStudentById(studentId: number): Student | null {
    const students = this.getStudentList();
    return students.find(s => s.id === studentId) ?? null;
  }

  /**
   * Get students by grade
   * 
   * @description 按年级筛选学生列表
   * @param {string} grade - 年级名称
   * @returns {Student[]} 符合年级的学生列表
   * @example
   * ```typescript
   * const grade1Students = StudentStore.getStudentsByGrade('一年级');
   * console.log('一年级学生数量:', grade1Students.length);
   * ```
   */
  static getStudentsByGrade(grade: string): Student[] {
    const students = this.getStudentList();
    return students.filter(s => s.grade === grade);
  }

  /**
   * Get students by status
   * 
   * @description 按学生状态筛选学生列表
   * @param {string} status - 学生状态 (ACTIVE, INACTIVE, GRADUATED)
   * @returns {Student[]} 符合状态的学生列表
   * @example
   * ```typescript
   * const activeStudents = StudentStore.getStudentsByStatus('ACTIVE');
   * console.log('在读学生数量:', activeStudents.length);
   * ```
   */
  static getStudentsByStatus(status: string): Student[] {
    const students = this.getStudentList();
    return students.filter(s => s.status === status);
  }

  /**
   * Search students
   * 
   * @description 按关键词搜索学生（支持姓名、学号模糊匹配）
   * @param {string} keyword - 搜索关键词
   * @returns {Student[]} 匹配的学生列表
   * @example
   * ```typescript
   * const results = StudentStore.searchStudents('张三');
   * console.log('搜索结果:', results.length);
   * ```
   */
  static searchStudents(keyword: string): Student[] {
    const students = this.getStudentList();
    if (!keyword) {
      return students;
    }
    const lowerKeyword = keyword.toLowerCase();
    return students.filter(s =>
      s.name.toLowerCase().includes(lowerKeyword) ||
      s.studentNo.toLowerCase().includes(lowerKeyword)
    );
  }

  /**
   * Clear all student data
   * 
   * @description 清除所有学生相关数据（用于退出登录）
   * @returns {void}
   * @example
   * ```typescript
   * // 用户退出登录时调用
   * StudentStore.clearAll();
   * ```
   */
  static clearAll(): void {
    AppStorage.delete(STUDENT_LIST_KEY);
    AppStorage.delete(CURRENT_STUDENT_KEY);
    AppStorage.delete(STUDENT_SEARCH_KEY);
  }
}
