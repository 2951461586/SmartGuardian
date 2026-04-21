package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.service.RefundService;
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
@RequestMapping("/api/v1/refunds")
public class RefundController {

  private final RefundService refundService;

  public RefundController(RefundService refundService) {
    this.refundService = refundService;
  }

  @PostMapping
  public ApiResponse<Map<String, Object>> create(@RequestBody Map<String, Object> request) {
    return ApiResponse.success(refundService.createRefund(request));
  }

  @GetMapping
  public ApiResponse<PageResponse<Map<String, Object>>> list(@RequestParam(required = false) Long orderId,
                                                             @RequestParam(required = false) Long studentId,
                                                             @RequestParam(required = false) String status,
                                                             @RequestParam(defaultValue = "1") int pageNum,
                                                             @RequestParam(defaultValue = "20") int pageSize) {
    return ApiResponse.success(refundService.getRefunds(orderId, studentId, status, pageNum, pageSize));
  }

  @GetMapping("/{refundId}")
  public ApiResponse<Map<String, Object>> detail(@PathVariable Long refundId) {
    return ApiResponse.success(refundService.getRefundDetail(refundId));
  }

  @PostMapping("/{refundId}/cancel")
  public ApiResponse<?> cancel(@PathVariable Long refundId) {
    refundService.cancelRefund(refundId);
    return ApiResponse.success();
  }

  @GetMapping("/statistics")
  public ApiResponse<Map<String, Object>> statistics() {
    return ApiResponse.success(refundService.getStatistics());
  }

  @GetMapping("/calculate")
  public ApiResponse<Map<String, Object>> calculate(@RequestParam Long orderId) {
    return ApiResponse.success(refundService.calculateRefundAmount(orderId));
  }

  @GetMapping("/order/{orderId}")
  public ApiResponse<List<Map<String, Object>>> byOrder(@PathVariable Long orderId) {
    return ApiResponse.success(refundService.getRefundsByOrder(orderId));
  }
}
