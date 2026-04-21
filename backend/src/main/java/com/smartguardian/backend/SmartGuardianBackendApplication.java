package com.smartguardian.backend;

import com.smartguardian.backend.config.AppSecurityProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(AppSecurityProperties.class)
public class SmartGuardianBackendApplication {

  public static void main(String[] args) {
    SpringApplication.run(SmartGuardianBackendApplication.class, args);
  }
}
