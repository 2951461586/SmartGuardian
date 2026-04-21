package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.service.OrderService;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {

  private final OrderService orderService;

  public OrderController(OrderService orderService) {
    this.orderService = orderService;
  }

  @GetMapping
  public ApiResponse<PageResponse<Map<String, Object>>> list(@RequestParam(required = false) Long studentId,
                                                             @RequestParam(required = false) String orderStatus,
                                                             @RequestParam(defaultValue = "1") int pageNum,
                                                             @RequestParam(defaultValue = "20") int pageSize) {
    return ApiResponse.success(orderService.getOrders(studentId, orderStatus, pageNum, pageSize));
  }

  @PostMapping
  public ApiResponse<Map<String, Object>> create(@RequestBody Map<String, Object> request) {
    return ApiResponse.success(orderService.createOrder(request));
  }

  @GetMapping("/{orderId}")
  public ApiResponse<Map<String, Object>> detail(@PathVariable Long orderId) {
    return ApiResponse.success(orderService.getOrderDetail(orderId));
  }

  @PostMapping("/{orderId}/audit")
  public ApiResponse<?> audit(@PathVariable Long orderId, @RequestBody Map<String, Object> request) {
    orderService.auditOrder(orderId, request);
    return ApiResponse.success();
  }

  @PostMapping("/{orderId}/refund")
  public ApiResponse<?> refund(@PathVariable Long orderId, @RequestBody Map<String, Object> request) {
    orderService.refundOrder(orderId, request);
    return ApiResponse.success();
  }
}
