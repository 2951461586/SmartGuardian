package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.service.HomeworkService;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeworkController {

  private final HomeworkService homeworkService;

  public HomeworkController(HomeworkService homeworkService) {
    this.homeworkService = homeworkService;
  }

  @GetMapping("/api/v1/homework/tasks")
  public ApiResponse<PageResponse<Map<String, Object>>> tasks(@RequestParam(required = false) Long studentId,
                                                              @RequestParam(required = false) String status,
                                                              @RequestParam(required = false) String taskDate,
                                                              @RequestParam(defaultValue = "1") int pageNum,
                                                              @RequestParam(defaultValue = "20") int pageSize) {
    return ApiResponse.success(homeworkService.getTasks(studentId, status, taskDate, pageNum, pageSize));
  }

  @PostMapping("/api/v1/homework/tasks")
  public ApiResponse<Map<String, Object>> createTask(@RequestBody Map<String, Object> request) {
    return ApiResponse.success(homeworkService.createTask(request));
  }

  @GetMapping("/api/v1/homework/tasks/{taskId}")
  public ApiResponse<Map<String, Object>> taskDetail(@PathVariable Long taskId) {
    return ApiResponse.success(homeworkService.getTaskDetail(taskId));
  }

  @PostMapping("/api/v1/homework/tasks/{taskId}/status")
  public ApiResponse<Map<String, Object>> updateStatus(@PathVariable Long taskId, @RequestBody Map<String, Object> request) {
    return ApiResponse.success(homeworkService.updateTaskStatus(taskId, request));
  }

  @PostMapping("/api/v1/homework/feedback")
  public ApiResponse<Map<String, Object>> submitFeedback(@RequestBody Map<String, Object> request) {
    return ApiResponse.success(homeworkService.submitFeedback(request));
  }

  @GetMapping("/api/v1/homework/tasks/{taskId}/feedbacks")
  public ApiResponse<List<Map<String, Object>>> feedbacks(@PathVariable Long taskId) {
    return ApiResponse.success(homeworkService.getFeedbacks(taskId));
  }

  @PostMapping("/api/v1/homework/feedback/{feedbackId}/confirm")
  public ApiResponse<Map<String, Object>> confirmFeedback(@PathVariable Long feedbackId, @RequestBody Map<String, Object> request) {
    return ApiResponse.success(homeworkService.confirmFeedback(feedbackId, request));
  }
}
