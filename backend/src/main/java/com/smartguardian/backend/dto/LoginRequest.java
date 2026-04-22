package com.smartguardian.backend.dto;

import jakarta.validation.constraints.NotBlank;

public class LoginRequest {
  @NotBlank(message = "username cannot be blank")
  private String username;

  @NotBlank(message = "password cannot be blank")
  private String password;

  public LoginRequest() {
  }

  public LoginRequest(String username, String password) {
    this.username = username;
    this.password = password;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public String username() {
    return username;
  }

  public String password() {
    return password;
  }
}
