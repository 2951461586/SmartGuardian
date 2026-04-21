package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.service.AlertService;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/alerts")
public class AlertController {

  private final AlertService alertService;

  public AlertController(AlertService alertService) {
    this.alertService = alertService;
  }

  @GetMapping
  public ApiResponse<PageResponse<Map<String, Object>>> list(@RequestParam(required = false) Long studentId,
                                                             @RequestParam(required = false) String status,
                                                             @RequestParam(defaultValue = "1") int pageNum,
                                                             @RequestParam(defaultValue = "20") int pageSize) {
    return ApiResponse.success(alertService.getAlerts(studentId, status, pageNum, pageSize));
  }

  @GetMapping("/{alertId}")
  public ApiResponse<Map<String, Object>> detail(@PathVariable Long alertId) {
    return ApiResponse.success(alertService.getAlertDetail(alertId));
  }

  @PostMapping("/{alertId}/acknowledge")
  public ApiResponse<?> acknowledge(@PathVariable Long alertId) {
    alertService.acknowledge(alertId);
    return ApiResponse.success();
  }

  @PostMapping("/{alertId}/resolve")
  public ApiResponse<?> resolve(@PathVariable Long alertId, @RequestBody Map<String, Object> request) {
    alertService.resolve(alertId, request);
    return ApiResponse.success();
  }

  @PostMapping("/{alertId}/dismiss")
  public ApiResponse<?> dismiss(@PathVariable Long alertId) {
    alertService.dismiss(alertId);
    return ApiResponse.success();
  }

  @GetMapping("/active-count")
  public ApiResponse<Map<String, Object>> activeCount() {
    return ApiResponse.success(alertService.getActiveCount());
  }

  @GetMapping("/statistics")
  public ApiResponse<Map<String, Object>> statistics() {
    return ApiResponse.success(alertService.getStatistics());
  }
}
