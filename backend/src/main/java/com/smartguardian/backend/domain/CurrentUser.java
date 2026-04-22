package com.smartguardian.backend.domain;

public class CurrentUser {
  private Long userId;
  private String username;
  private String roleType;

  public CurrentUser() {
  }

  public CurrentUser(Long userId, String username, String roleType) {
    this.userId = userId;
    this.username = username;
    this.roleType = roleType;
  }

  public Long getUserId() {
    return userId;
  }

  public void setUserId(Long userId) {
    this.userId = userId;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getRoleType() {
    return roleType;
  }

  public void setRoleType(String roleType) {
    this.roleType = roleType;
  }

  public Long userId() {
    return userId;
  }

  public String username() {
    return username;
  }

  public String roleType() {
    return roleType;
  }
}
