package com.personalwardrobe.backend.outfit.service;

import com.personalwardrobe.backend.auth.security.SecurityUtils;
import com.personalwardrobe.backend.common.exception.BadRequestException;
import com.personalwardrobe.backend.common.exception.NotFoundException;
import com.personalwardrobe.backend.common.web.DeleteResponse;
import com.personalwardrobe.backend.common.web.PagedResponse;
import com.personalwardrobe.backend.common.util.IdGenerator;
import com.personalwardrobe.backend.outfit.dto.OutfitCreateRequest;
import com.personalwardrobe.backend.outfit.dto.OutfitResponse;
import com.personalwardrobe.backend.outfit.dto.OutfitUpdateRequest;
import com.personalwardrobe.backend.outfit.entity.OutfitEntity;
import com.personalwardrobe.backend.outfit.repository.OutfitRepository;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class OutfitService {

    private final OutfitRepository outfitRepository;

    public OutfitService(OutfitRepository outfitRepository) {
        this.outfitRepository = outfitRepository;
    }

    @Transactional
    public OutfitResponse create(OutfitCreateRequest request) {
        String userId = SecurityUtils.currentUserId();

        OutfitEntity entity = new OutfitEntity();
        entity.setId(IdGenerator.newId("outfit"));
        entity.setUserId(userId);
        entity.setWearDate(request.getDate());
        entity.setNote(request.getNote());
        entity.setTags(request.getTags());
        entity.setImageUrl(request.getImageUrl());
        entity.setClosetItemIds(request.getClosetItemIds());

        OutfitEntity saved = outfitRepository.save(entity);
        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public PagedResponse<OutfitResponse> list(LocalDate dateFrom,
                                              LocalDate dateTo,
                                              String tag,
                                              String closetItemId,
                                              int page,
                                              int pageSize,
                                              String sortBy,
                                              String sortOrder) {
        String userId = SecurityUtils.currentUserId();
        validatePaging(page, pageSize);

        Sort sort = Sort.by(parseSortDirection(sortOrder), mapSortField(sortBy));
        Pageable pageable = PageRequest.of(page - 1, pageSize, sort);

        Specification<OutfitEntity> specification = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("userId"), userId));
            predicates.add(cb.isNull(root.get("deletedAt")));

            if (dateFrom != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("wearDate").as(LocalDate.class), dateFrom));
            }
            if (dateTo != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("wearDate").as(LocalDate.class), dateTo));
            }
            if (tag != null && !tag.isBlank()) {
                Join<OutfitEntity, String> tagJoin = root.join("tags", JoinType.LEFT);
                predicates.add(cb.equal(tagJoin, tag));
                if (query != null) {
                    query.distinct(true);
                }
            }
            if (closetItemId != null && !closetItemId.isBlank()) {
                Join<OutfitEntity, String> closetJoin = root.join("closetItemIds", JoinType.LEFT);
                predicates.add(cb.equal(closetJoin, closetItemId));
                if (query != null) {
                    query.distinct(true);
                }
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };

        Page<OutfitEntity> result = outfitRepository.findAll(specification, pageable);
        List<OutfitResponse> items = result.getContent().stream().map(this::toResponse).toList();
        return new PagedResponse<>(items, page, pageSize, result.getTotalElements());
    }

    @Transactional(readOnly = true)
    public OutfitResponse getById(String id) {
        String userId = SecurityUtils.currentUserId();
        OutfitEntity entity = outfitRepository.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new NotFoundException("Outfit not found."));
        return toResponse(entity);
    }

    @Transactional
    public OutfitResponse update(String id, OutfitUpdateRequest request) {
        String userId = SecurityUtils.currentUserId();
        OutfitEntity entity = outfitRepository.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new NotFoundException("Outfit not found."));

        if (request.getDate() != null) {
            entity.setWearDate(request.getDate());
        }
        if (request.getNote() != null) {
            entity.setNote(request.getNote());
        }
        if (request.getTags() != null) {
            entity.setTags(request.getTags());
        }
        if (request.getImageUrl() != null) {
            entity.setImageUrl(request.getImageUrl());
        }
        if (request.getClosetItemIds() != null) {
            entity.setClosetItemIds(request.getClosetItemIds());
        }

        return toResponse(outfitRepository.save(entity));
    }

    @Transactional
    public DeleteResponse delete(String id) {
        String userId = SecurityUtils.currentUserId();
        OutfitEntity entity = outfitRepository.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new NotFoundException("Outfit not found."));

        Instant now = Instant.now();
        entity.setDeletedAt(now);
        entity.setUpdatedAt(now);
        outfitRepository.save(entity);
        return new DeleteResponse(entity.getId(), now);
    }

    @Transactional(readOnly = true)
    public List<OutfitResponse> changedSince(String userId, Instant since) {
        return outfitRepository.findByUserIdAndDeletedAtIsNullAndUpdatedAtAfter(userId, since)
            .stream()
            .map(this::toResponse)
            .toList();
    }

    @Transactional(readOnly = true)
    public List<String> deletedIdsSince(String userId, Instant since) {
        return outfitRepository.findByUserIdAndDeletedAtIsNotNullAndDeletedAtAfter(userId, since)
            .stream()
            .map(OutfitEntity::getId)
            .toList();
    }

    private OutfitResponse toResponse(OutfitEntity entity) {
        OutfitResponse response = new OutfitResponse();
        response.setId(entity.getId());
        response.setDate(entity.getWearDate());
        response.setNote(entity.getNote());
        response.setTags(entity.getTags());
        response.setImageUrl(entity.getImageUrl());
        response.setImageMediaId(entity.getImageMediaId());
        response.setClosetItemIds(entity.getClosetItemIds());
        response.setCreatedAt(entity.getCreatedAt());
        response.setUpdatedAt(entity.getUpdatedAt());
        response.setDeletedAt(entity.getDeletedAt());
        return response;
    }

    private void validatePaging(int page, int pageSize) {
        if (page < 1 || pageSize < 1 || pageSize > 100) {
            throw new BadRequestException("INVALID_PAGINATION", "Invalid pagination parameters.");
        }
    }

    private Sort.Direction parseSortDirection(String sortOrder) {
        if (sortOrder == null || sortOrder.isBlank()) {
            return Sort.Direction.DESC;
        }
        if ("asc".equalsIgnoreCase(sortOrder)) {
            return Sort.Direction.ASC;
        }
        if ("desc".equalsIgnoreCase(sortOrder)) {
            return Sort.Direction.DESC;
        }
        throw new BadRequestException("BAD_REQUEST", "Invalid sortOrder.");
    }

    private String mapSortField(String sortBy) {
        if (sortBy == null || sortBy.isBlank()) {
            return "updatedAt";
        }
        return switch (sortBy) {
            case "date" -> "wearDate";
            case "createdAt" -> "createdAt";
            case "updatedAt" -> "updatedAt";
            default -> throw new BadRequestException("BAD_REQUEST", "Invalid sortBy.");
        };
    }
}
