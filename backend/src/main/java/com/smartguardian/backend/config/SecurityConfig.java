package com.smartguardian.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.security.JwtAuthenticationFilter;
import jakarta.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity,
                                                 JwtAuthenticationFilter jwtAuthenticationFilter,
                                                 ObjectMapper objectMapper) throws Exception {
    httpSecurity
      .csrf(csrf -> csrf.disable())
      .cors(Customizer.withDefaults())
      .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
      .authorizeHttpRequests(authorize -> authorize
        .requestMatchers("/api/v1/auth/login", "/api/v1/payments/callback", "/actuator/health").permitAll()
        .requestMatchers("/api/v1/reports/**", "/api/v1/alerts/**", "/api/v1/refunds/**").hasAnyRole("ADMIN", "TEACHER")
        .requestMatchers("/api/v1/service-products/**", "/api/v1/sessions/**", "/api/v1/homework/**").hasAnyRole("ADMIN", "TEACHER")
        .requestMatchers("/api/v1/orders/**", "/api/v1/attendance/**", "/api/v1/messages/**", "/api/v1/cards/**", "/api/v1/timeline/**", "/api/v1/students/**").authenticated()
        .anyRequest().authenticated())
      .exceptionHandling(ex -> ex
        .authenticationEntryPoint((request, response, authException) -> writeJson(response, objectMapper, 401, "未授权或登录已过期"))
        .accessDeniedHandler((request, response, accessDeniedException) -> writeJson(response, objectMapper, 403, "无权限访问")))
      .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
    return httpSecurity.build();
  }

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  private void writeJson(HttpServletResponse response, ObjectMapper objectMapper, int code, String message) throws java.io.IOException {
    response.setStatus(code);
    response.setCharacterEncoding(StandardCharsets.UTF_8.name());
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    objectMapper.writeValue(response.getWriter(), ApiResponse.fail(code, message));
  }
}
