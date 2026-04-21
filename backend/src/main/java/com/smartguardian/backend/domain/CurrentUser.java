package com.smartguardian.backend.domain;

public record CurrentUser(Long userId, String username, String roleType) {
}
