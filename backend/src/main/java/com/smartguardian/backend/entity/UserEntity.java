package com.smartguardian.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "user")
public class UserEntity extends BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "account_no", nullable = false)
  private String accountNo;

  @Column(nullable = false)
  private String username;

  @Column(name = "password_hash", nullable = false)
  private String passwordHash;

  @Column(name = "real_name", nullable = false)
  private String realName;

  @Column(nullable = false)
  private String mobile;

  @Column(name = "role_type", nullable = false)
  private String roleType;

  @Column(nullable = false)
  private String status;

  @Column(name = "last_login_time")
  private LocalDateTime lastLoginTime;

  public Long getId() { return id; }
  public void setId(Long id) { this.id = id; }
  public String getAccountNo() { return accountNo; }
  public void setAccountNo(String accountNo) { this.accountNo = accountNo; }
  public String getUsername() { return username; }
  public void setUsername(String username) { this.username = username; }
  public String getPasswordHash() { return passwordHash; }
  public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
  public String getRealName() { return realName; }
  public void setRealName(String realName) { this.realName = realName; }
  public String getMobile() { return mobile; }
  public void setMobile(String mobile) { this.mobile = mobile; }
  public String getRoleType() { return roleType; }
  public void setRoleType(String roleType) { this.roleType = roleType; }
  public String getStatus() { return status; }
  public void setStatus(String status) { this.status = status; }
  public LocalDateTime getLastLoginTime() { return lastLoginTime; }
  public void setLastLoginTime(LocalDateTime lastLoginTime) { this.lastLoginTime = lastLoginTime; }
}
