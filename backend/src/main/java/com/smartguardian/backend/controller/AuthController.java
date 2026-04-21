package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.SecurityUtils;
import com.smartguardian.backend.domain.CurrentUser;
import com.smartguardian.backend.dto.LoginRequest;
import com.smartguardian.backend.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

  private final AuthService authService;

  public AuthController(AuthService authService) {
    this.authService = authService;
  }

  @PostMapping("/login")
  public ApiResponse<?> login(@Valid @RequestBody LoginRequest request) {
    return ApiResponse.success(authService.login(request.username(), request.password()));
  }

  @GetMapping("/me")
  public ApiResponse<?> me(Authentication authentication) {
    CurrentUser currentUser = SecurityUtils.currentUser(authentication);
    return ApiResponse.success(authService.getCurrentUser(currentUser.userId()));
  }

  @PostMapping("/logout")
  public ApiResponse<?> logout() {
    return ApiResponse.success();
  }
}
