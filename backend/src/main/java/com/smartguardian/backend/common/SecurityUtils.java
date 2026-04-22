package com.smartguardian.backend.common;

import com.smartguardian.backend.domain.CurrentUser;
import org.springframework.security.core.Authentication;

public final class SecurityUtils {

  private SecurityUtils() {
  }

  public static CurrentUser currentUser(Authentication authentication) {
    if (authentication == null || !(authentication.getPrincipal() instanceof CurrentUser)) {
      throw new BizException(401, "Unauthorized or session expired");
    }
    return (CurrentUser) authentication.getPrincipal();
  }
}
