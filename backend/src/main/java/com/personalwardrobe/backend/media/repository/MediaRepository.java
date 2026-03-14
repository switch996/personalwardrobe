package com.personalwardrobe.backend.media.repository;

import com.personalwardrobe.backend.media.entity.MediaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MediaRepository extends JpaRepository<MediaEntity, String> {

    Optional<MediaEntity> findByIdAndUserIdAndDeletedAtIsNull(String id, String userId);
}
