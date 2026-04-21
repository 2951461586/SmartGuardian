package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.service.StudentService;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/students")
public class StudentController {

  private final StudentService studentService;

  public StudentController(StudentService studentService) {
    this.studentService = studentService;
  }

  @GetMapping
  public ApiResponse<PageResponse<Map<String, Object>>> list(@RequestParam(required = false) String keyword,
                                                             @RequestParam(required = false) Long classId,
                                                             @RequestParam(defaultValue = "1") int pageNum,
                                                             @RequestParam(defaultValue = "20") int pageSize) {
    return ApiResponse.success(studentService.getStudents(keyword, classId, pageNum, pageSize));
  }

  @GetMapping("/{studentId}")
  public ApiResponse<Map<String, Object>> detail(@PathVariable Long studentId) {
    return ApiResponse.success(studentService.getStudentDetail(studentId));
  }
}
