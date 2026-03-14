package com.personalwardrobe.backend.outfit.repository;

import com.personalwardrobe.backend.outfit.entity.OutfitEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

public interface OutfitRepository extends JpaRepository<OutfitEntity, String>, JpaSpecificationExecutor<OutfitEntity> {

    Optional<OutfitEntity> findByIdAndUserIdAndDeletedAtIsNull(String id, String userId);

    List<OutfitEntity> findByUserIdAndDeletedAtIsNullAndUpdatedAtAfter(String userId, Instant since);

    List<OutfitEntity> findByUserIdAndDeletedAtIsNotNullAndDeletedAtAfter(String userId, Instant since);
}
