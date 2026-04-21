package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.service.OverviewService;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/cards")
public class OverviewController {

  private final OverviewService overviewService;

  public OverviewController(OverviewService overviewService) {
    this.overviewService = overviewService;
  }

  @GetMapping("/today-status")
  public ApiResponse<Map<String, Object>> todayStatus(@RequestParam(required = false) Long studentId) {
    return ApiResponse.success(overviewService.getTodayStatus(studentId));
  }

  @GetMapping("/abnormal-alert")
  public ApiResponse<?> abnormalAlert(@RequestParam(required = false) Long studentId) {
    return ApiResponse.success(overviewService.getAbnormalAlert(studentId));
  }
}
