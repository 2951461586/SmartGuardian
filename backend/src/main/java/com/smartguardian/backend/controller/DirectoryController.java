package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.service.DirectoryService;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DirectoryController {

  private final DirectoryService directoryService;

  public DirectoryController(DirectoryService directoryService) {
    this.directoryService = directoryService;
  }

  @GetMapping("/api/v1/service-products")
  public ApiResponse<List<Map<String, Object>>> products(@RequestParam(required = false) String serviceType,
                                                         @RequestParam(required = false) String status) {
    return ApiResponse.success(directoryService.getServiceProducts(serviceType, status));
  }

  @GetMapping("/api/v1/sessions")
  public ApiResponse<List<Map<String, Object>>> sessions(@RequestParam(required = false) String sessionDate,
                                                         @RequestParam(required = false) Long teacherUserId) {
    return ApiResponse.success(directoryService.getSessions(sessionDate, teacherUserId));
  }
}
