package com.smartguardian.backend.config;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Validated
@ConfigurationProperties(prefix = "app.security")
public class AppSecurityProperties {

  @NotBlank
  private String jwtSecret;

  @Positive
  private long jwtExpirationSeconds;

  public String getJwtSecret() {
    return jwtSecret;
  }

  public void setJwtSecret(String jwtSecret) {
    this.jwtSecret = jwtSecret;
  }

  public long getJwtExpirationSeconds() {
    return jwtExpirationSeconds;
  }

  public void setJwtExpirationSeconds(long jwtExpirationSeconds) {
    this.jwtExpirationSeconds = jwtExpirationSeconds;
  }
}
