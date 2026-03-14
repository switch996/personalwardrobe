package com.personalwardrobe.backend.auth.repository;

import com.personalwardrobe.backend.auth.entity.RefreshTokenEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RefreshTokenRepository extends JpaRepository<RefreshTokenEntity, String> {

    Optional<RefreshTokenEntity> findByToken(String token);

    List<RefreshTokenEntity> findByUserIdAndRevokedIsFalse(String userId);
}
