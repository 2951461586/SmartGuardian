import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HomeworkFeedback, HomeworkTask, HomeworkTaskStatus } from '../../../models/homework';
import { ApiResponse, PageResponse } from '../../../models/common';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { mockHomeworkTasks } from '../mockData';
import { createPageResponse, extractId, getQueryParam, mockNotFound, mockResponse } from '../shared/mockUtils';

export class HomeworkMockHandler {
  static async getHomeworkTasks(params?: {
    studentId?: number;
    status?: string;
  }): Promise<ApiResponse<PageResponse<HomeworkTask>>> {
    let tasks = mockHomeworkTasks;
    if (params?.studentId) {
      tasks = tasks.filter((item: HomeworkTask) => item.studentId === params.studentId);
    }
    if (params?.status) {
      tasks = tasks.filter((item: HomeworkTask) => item.status === params.status);
    }
    return mockResponse(createPageResponse(tasks, 1, 10));
  }

  static async handleRequest<T>(url: string, path: string, method: HttpMethod, data?: object): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.HOMEWORK_TASKS && method === HttpMethod.GET) {
      return this.getHomeworkTasks({
        studentId: Number(getQueryParam(url, 'studentId')) || undefined,
        status: getQueryParam(url, 'status') || undefined
      }) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.HOMEWORK_TASKS && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        status: HomeworkTaskStatus.PENDING,
        ...(data as Record<string, string | number>)
      } as HomeworkTask) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/status') > -1 && method === HttpMethod.POST) {
      const taskId = extractId(path, ApiEndpoints.HOMEWORK_TASKS + '/');
      const task = mockHomeworkTasks.find((item: HomeworkTask) => item.id === taskId) ?? mockHomeworkTasks[0];
      const body = data as Record<string, string>;
      return mockResponse({
        ...task,
        status: body.status ? body.status as HomeworkTaskStatus : task.status,
        updatedAt: new Date().toISOString()
      }) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf('/feedbacks') > -1 && method === HttpMethod.GET) {
      return mockResponse([
        {
          id: 1,
          taskId: extractId(path, ApiEndpoints.HOMEWORK_TASKS + '/'),
          teacherId: 2,
          teacherName: '王老师',
          studentId: 1,
          feedbackContent: '作业已完成，表现良好',
          status: HomeworkTaskStatus.CONFIRMED,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        }
      ] as HomeworkFeedback[]) as Promise<HttpResponse<T>>;
    }
    if (path === ApiEndpoints.HOMEWORK_FEEDBACK && method === HttpMethod.POST) {
      return mockResponse({
        id: Date.now(),
        ...(data as Record<string, string | number>)
      } as HomeworkFeedback) as Promise<HttpResponse<T>>;
    }
    if (path.indexOf(ApiEndpoints.HOMEWORK_FEEDBACK + '/') === 0 && path.indexOf('/confirm') > -1 && method === HttpMethod.POST) {
      const feedbackId = extractId(path, ApiEndpoints.HOMEWORK_FEEDBACK + '/');
      return mockResponse({
        id: feedbackId,
        taskId: 1,
        teacherId: 2,
        teacherName: '王老师',
        studentId: 1,
        feedbackContent: '作业已完成，表现良好',
        status: HomeworkTaskStatus.CONFIRMED,
        guardianConfirmTime: new Date().toISOString(),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      } as HomeworkFeedback) as Promise<HttpResponse<T>>;
    }
    const taskId = extractId(path, ApiEndpoints.HOMEWORK_TASKS + '/');
    if (taskId > 0 && method === HttpMethod.GET) {
      const task = mockHomeworkTasks.find((item: HomeworkTask) => item.id === taskId);
      if (task) {
        return mockResponse(task) as Promise<HttpResponse<T>>;
      }
    }
    return mockNotFound<T>();
  }
}
