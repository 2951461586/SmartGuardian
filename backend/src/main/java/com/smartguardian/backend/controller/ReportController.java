package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.service.ReportService;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/reports")
public class ReportController {

  private final ReportService reportService;

  public ReportController(ReportService reportService) {
    this.reportService = reportService;
  }

  @GetMapping("/attendance")
  public ApiResponse<Map<String, Object>> attendance() {
    return ApiResponse.success(reportService.getAttendanceReport());
  }

  @GetMapping("/finance")
  public ApiResponse<Map<String, Object>> finance() {
    return ApiResponse.success(reportService.getFinanceReport());
  }

  @GetMapping("/performance")
  public ApiResponse<List<Map<String, Object>>> performance() {
    return ApiResponse.success(reportService.getTeacherPerformance());
  }

  @GetMapping("/attendance/daily")
  public ApiResponse<List<Map<String, Object>>> attendanceDaily() {
    return ApiResponse.success(reportService.getDailyAttendanceStats());
  }

  @GetMapping("/attendance/students")
  public ApiResponse<List<Map<String, Object>>> attendanceStudents() {
    return ApiResponse.success(reportService.getStudentAttendanceSummary());
  }

  @GetMapping("/finance/daily")
  public ApiResponse<List<Map<String, Object>>> financeDaily() {
    return ApiResponse.success(reportService.getDailyRevenueStats());
  }

  @GetMapping("/finance/products")
  public ApiResponse<List<Map<String, Object>>> financeProducts() {
    return ApiResponse.success(reportService.getServiceProductRevenue());
  }
}
