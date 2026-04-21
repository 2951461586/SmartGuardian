package com.smartguardian.backend.security;

import com.smartguardian.backend.config.AppSecurityProperties;
import com.smartguardian.backend.domain.CurrentUser;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Component;

@Component
public class JwtTokenService {

  private static final int MIN_SECRET_LENGTH = 32;

  private final AppSecurityProperties securityProperties;
  private final SecretKey secretKey;

  public JwtTokenService(AppSecurityProperties securityProperties) {
    this.securityProperties = securityProperties;
    this.secretKey = createSecretKey(securityProperties.getJwtSecret());
  }

  public String createToken(CurrentUser currentUser) {
    Instant now = Instant.now();
    Instant expiry = now.plusSeconds(securityProperties.getJwtExpirationSeconds());
    return Jwts.builder()
      .subject(currentUser.username())
      .claim("userId", currentUser.userId())
      .claim("roleType", currentUser.roleType())
      .issuedAt(Date.from(now))
      .expiration(Date.from(expiry))
      .signWith(secretKey)
      .compact();
  }

  public CurrentUser parseToken(String token) {
    Claims claims = Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload();
    return new CurrentUser(
      claims.get("userId", Long.class),
      claims.getSubject(),
      claims.get("roleType", String.class)
    );
  }

  private SecretKey createSecretKey(String raw) {
    if (raw == null || raw.isBlank() || "${JWT_SECRET}".equals(raw)) {
      throw new IllegalStateException("JWT secret configuration is invalid");
    }
    byte[] keyBytes = raw.matches("^[A-Za-z0-9+/=]+$") && raw.length() >= 43
      ? tryDecodeBase64(raw)
      : raw.getBytes(StandardCharsets.UTF_8);
    if (keyBytes.length < MIN_SECRET_LENGTH) {
      throw new IllegalStateException("JWT secret configuration is invalid");
    }
    return Keys.hmacShaKeyFor(keyBytes);
  }

  private byte[] tryDecodeBase64(String raw) {
    try {
      return Decoders.BASE64.decode(raw);
    } catch (IllegalArgumentException ignored) {
      return raw.getBytes(StandardCharsets.UTF_8);
    }
  }
}
