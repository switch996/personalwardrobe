package com.personalwardrobe.backend.closet.repository;

import com.personalwardrobe.backend.closet.entity.ClosetItemEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

public interface ClosetItemRepository extends JpaRepository<ClosetItemEntity, String>, JpaSpecificationExecutor<ClosetItemEntity> {

    Optional<ClosetItemEntity> findByIdAndUserIdAndDeletedAtIsNull(String id, String userId);

    List<ClosetItemEntity> findByUserIdAndDeletedAtIsNullAndUpdatedAtAfter(String userId, Instant since);

    List<ClosetItemEntity> findByUserIdAndDeletedAtIsNotNullAndDeletedAtAfter(String userId, Instant since);
}
