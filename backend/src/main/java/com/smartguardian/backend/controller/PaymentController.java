package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.service.PaymentService;
import java.util.Map;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/payments")
public class PaymentController {

  private final PaymentService paymentService;

  public PaymentController(PaymentService paymentService) {
    this.paymentService = paymentService;
  }

  @PostMapping
  public ApiResponse<Map<String, Object>> create(@RequestBody Map<String, Object> request) {
    return ApiResponse.success(paymentService.createPayment(request));
  }

  @PostMapping("/callback")
  public ApiResponse<?> callback(@RequestBody Map<String, Object> request) {
    paymentService.callback(request);
    return ApiResponse.success();
  }
}
