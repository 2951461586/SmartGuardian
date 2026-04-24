package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.SecurityUtils;
import com.smartguardian.backend.domain.CurrentUser;
import com.smartguardian.backend.service.WorkbenchService;
import java.util.Map;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/workbench")
public class WorkbenchController {

  private final WorkbenchService workbenchService;

  public WorkbenchController(WorkbenchService workbenchService) {
    this.workbenchService = workbenchService;
  }

  @GetMapping("/manifest")
  public ApiResponse<Map<String, Object>> manifest(Authentication authentication) {
    CurrentUser currentUser = SecurityUtils.currentUser(authentication);
    return ApiResponse.success(workbenchService.getManifest(currentUser.roleType()));
  }
}
