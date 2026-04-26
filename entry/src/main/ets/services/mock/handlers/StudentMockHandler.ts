import { ApiResponse, PageResponse } from '../../../models/common';
import { GuardianRelation, Student } from '../../../models/user';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockGuardians, mockStudents } from '../mockData';
import { createPageResponse, extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class StudentMockHandler {
  static async getStudents(params?: {
    pageNum?: number;
    pageSize?: number;
    keyword?: string;
  }): Promise<ApiResponse<PageResponse<Student>>> {
    let students = mockStudents;
    if (params?.keyword) {
      students = students.filter((item: Student) => item.name.indexOf(params.keyword ?? '') > -1 || item.studentNo.indexOf(params.keyword ?? '') > -1);
    }
    const pageNum = params?.pageNum ?? 1;
    const pageSize = params?.pageSize ?? 10;
    return mockResponse(createPageResponse(students, pageNum, pageSize));
  }

  static async getStudentDetail(studentId: number): Promise<ApiResponse<Student>> {
    const student = mockStudents.find((item: Student) => item.id === studentId);
    if (!student) {
      return mockNotFound<Student>('Student not found');
    }
    return mockResponse(student);
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.STUDENTS && method === HttpMethod.GET) {
      return this.getStudents({
        pageNum: Number(getQueryParam(url, 'pageNum')) || 1,
        pageSize: Number(getQueryParam(url, 'pageSize')) || 10,
        keyword: getQueryParam(url, 'keyword') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.STUDENTS && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        status: 'ACTIVE',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        ...(data as Record<string, string | number>)
      } as Student) as Promise<HttpResponse<T>>;
    }

    const studentId = extractId(path, ApiEndpoints.STUDENTS + '/');
    if (path.indexOf('/guardians') > -1 && method === HttpMethod.GET) {
      return mockResponse(mockGuardians.filter((item: GuardianRelation) => item.studentId === studentId)) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/guardians') > -1 && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        studentId,
        ...(data as Record<string, string | number | boolean>)
      } as GuardianRelation) as Promise<HttpResponse<T>>;
    }
    if (studentId > 0 && method === HttpMethod.GET) {
      return this.getStudentDetail(studentId) as Promise<HttpResponse<T>>;
    }
    if (studentId > 0 && method === HttpMethod.PUT) {
      const detail = await this.getStudentDetail(studentId);
      if (detail.code === 0 && detail.data) {
        return mockResponse({
          ...detail.data,
          ...(data as Record<string, string | number>)
        }) as Promise<HttpResponse<T>>;
      }
    }
    if (studentId > 0 && method === HttpMethod.DELETE) {
      return mockResponse(null) as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
