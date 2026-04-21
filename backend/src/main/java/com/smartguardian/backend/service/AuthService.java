package com.smartguardian.backend.service;

import com.smartguardian.backend.common.BizException;
import com.smartguardian.backend.config.AppSecurityProperties;
import com.smartguardian.backend.domain.CurrentUser;
import com.smartguardian.backend.entity.UserEntity;
import com.smartguardian.backend.repository.UserRepository;
import com.smartguardian.backend.security.JwtTokenService;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;
  private final JwtTokenService jwtTokenService;
  private final AppSecurityProperties securityProperties;

  public AuthService(UserRepository userRepository,
                     PasswordEncoder passwordEncoder,
                     JwtTokenService jwtTokenService,
                     AppSecurityProperties securityProperties) {
    this.userRepository = userRepository;
    this.passwordEncoder = passwordEncoder;
    this.jwtTokenService = jwtTokenService;
    this.securityProperties = securityProperties;
  }

  public Map<String, Object> login(String username, String password) {
    UserEntity userEntity = userRepository.findByUsernameAndStatus(username, "ENABLED")
      .orElseThrow(() -> new BizException(401, "用户名或密码错误"));
    if (!passwordEncoder.matches(password, userEntity.getPasswordHash())) {
      throw new BizException(401, "用户名或密码错误");
    }
    userEntity.setLastLoginTime(LocalDateTime.now());
    userRepository.save(userEntity);
    CurrentUser currentUser = new CurrentUser(userEntity.getId(), userEntity.getUsername(), userEntity.getRoleType());

    Map<String, Object> response = new LinkedHashMap<>();
    response.put("token", jwtTokenService.createToken(currentUser));
    response.put("expiresIn", securityProperties.getJwtExpirationSeconds());
    response.put("userInfo", toUserInfo(userEntity));
    return response;
  }

  public Map<String, Object> getCurrentUser(Long userId) {
    UserEntity userEntity = userRepository.findById(userId).orElseThrow(() -> new BizException(404, "用户不存在"));
    return toUserInfo(userEntity);
  }

  private Map<String, Object> toUserInfo(UserEntity userEntity) {
    Map<String, Object> userInfo = new LinkedHashMap<>();
    userInfo.put("id", userEntity.getId());
    userInfo.put("username", userEntity.getUsername());
    userInfo.put("realName", userEntity.getRealName());
    userInfo.put("mobile", userEntity.getMobile());
    userInfo.put("roleType", userEntity.getRoleType());
    userInfo.put("orgId", 1);
    userInfo.put("schoolId", 101);
    return userInfo;
  }
}
