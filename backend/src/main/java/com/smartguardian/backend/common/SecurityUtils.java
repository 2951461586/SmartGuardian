package com.smartguardian.backend.common;

import com.smartguardian.backend.domain.CurrentUser;
import org.springframework.security.core.Authentication;

public final class SecurityUtils {

  private SecurityUtils() {
  }

  public static CurrentUser currentUser(Authentication authentication) {
    if (authentication == null || !(authentication.getPrincipal() instanceof CurrentUser currentUser)) {
      throw new BizException(401, "未授权或登录已过期");
    }
    return currentUser;
  }
}
