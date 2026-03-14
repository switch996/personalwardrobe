package com.personalwardrobe.backend.auth.repository;

import com.personalwardrobe.backend.auth.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, String> {

    Optional<UserEntity> findByPhone(String phone);
}
