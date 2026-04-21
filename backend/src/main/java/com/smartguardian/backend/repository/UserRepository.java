package com.smartguardian.backend.repository;

import com.smartguardian.backend.entity.UserEntity;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<UserEntity, Long> {

  Optional<UserEntity> findByUsernameAndStatus(String username, String status);
}
