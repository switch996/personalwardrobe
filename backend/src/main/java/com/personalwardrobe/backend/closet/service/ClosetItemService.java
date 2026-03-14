package com.personalwardrobe.backend.closet.service;

import com.personalwardrobe.backend.auth.security.SecurityUtils;
import com.personalwardrobe.backend.closet.dto.ClosetItemCreateRequest;
import com.personalwardrobe.backend.closet.dto.ClosetItemResponse;
import com.personalwardrobe.backend.closet.dto.ClosetItemUpdateRequest;
import com.personalwardrobe.backend.closet.entity.ClosetItemEntity;
import com.personalwardrobe.backend.closet.repository.ClosetItemRepository;
import com.personalwardrobe.backend.common.exception.BadRequestException;
import com.personalwardrobe.backend.common.exception.NotFoundException;
import com.personalwardrobe.backend.common.util.IdGenerator;
import com.personalwardrobe.backend.common.web.DeleteResponse;
import com.personalwardrobe.backend.common.web.PagedResponse;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Expression;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
public class ClosetItemService {

    private final ClosetItemRepository closetItemRepository;

    public ClosetItemService(ClosetItemRepository closetItemRepository) {
        this.closetItemRepository = closetItemRepository;
    }

    @Transactional
    public ClosetItemResponse create(ClosetItemCreateRequest request) {
        validateCategory(request.getCategory());

        ClosetItemEntity entity = new ClosetItemEntity();
        entity.setId(IdGenerator.newId("item"));
        entity.setUserId(SecurityUtils.currentUserId());
        entity.setName(request.getName());
        entity.setCategory(request.getCategory());
        entity.setBrand(request.getBrand());
        entity.setColor(request.getColor());
        entity.setNote(request.getNote());
        entity.setImageUrl(request.getImageUrl());

        return toResponse(closetItemRepository.save(entity));
    }

    @Transactional(readOnly = true)
    public PagedResponse<ClosetItemResponse> list(String category,
                                                  String keyword,
                                                  String color,
                                                  String brand,
                                                  int page,
                                                  int pageSize,
                                                  String sortBy,
                                                  String sortOrder) {
        String userId = SecurityUtils.currentUserId();
        validatePaging(page, pageSize);
        if (category != null && !category.isBlank()) {
            validateCategory(category);
        }

        Sort sort = Sort.by(parseSortDirection(sortOrder), mapSortField(sortBy));
        Pageable pageable = PageRequest.of(page - 1, pageSize, sort);

        Specification<ClosetItemEntity> specification = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("userId"), userId));
            predicates.add(cb.isNull(root.get("deletedAt")));

            if (category != null && !category.isBlank()) {
                predicates.add(cb.equal(root.get("category"), category));
            }
            if (keyword != null && !keyword.isBlank()) {
                String pattern = "%" + keyword.toLowerCase(Locale.ROOT) + "%";
                Expression<String> nameExpr = root.get("name").as(String.class);
                Expression<String> noteExpr = cb.coalesce(root.get("note").as(String.class), "");
                Predicate nameLike = cb.like(cb.lower(nameExpr), pattern);
                Predicate noteLike = cb.like(cb.lower(noteExpr), pattern);
                predicates.add(cb.or(nameLike, noteLike));
            }
            if (color != null && !color.isBlank()) {
                predicates.add(cb.equal(root.get("color"), color));
            }
            if (brand != null && !brand.isBlank()) {
                predicates.add(cb.equal(root.get("brand"), brand));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        Page<ClosetItemEntity> result = closetItemRepository.findAll(specification, pageable);
        List<ClosetItemResponse> items = result.getContent().stream().map(this::toResponse).toList();
        return new PagedResponse<>(items, page, pageSize, result.getTotalElements());
    }

    @Transactional(readOnly = true)
    public ClosetItemResponse getById(String id) {
        String userId = SecurityUtils.currentUserId();
        ClosetItemEntity entity = closetItemRepository.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new NotFoundException("Closet item not found."));
        return toResponse(entity);
    }

    @Transactional
    public ClosetItemResponse update(String id, ClosetItemUpdateRequest request) {
        String userId = SecurityUtils.currentUserId();
        ClosetItemEntity entity = closetItemRepository.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new NotFoundException("Closet item not found."));

        if (request.getName() != null) {
            entity.setName(request.getName());
        }
        if (request.getCategory() != null) {
            validateCategory(request.getCategory());
            entity.setCategory(request.getCategory());
        }
        if (request.getBrand() != null) {
            entity.setBrand(request.getBrand());
        }
        if (request.getColor() != null) {
            entity.setColor(request.getColor());
        }
        if (request.getNote() != null) {
            entity.setNote(request.getNote());
        }
        if (request.getImageUrl() != null) {
            entity.setImageUrl(request.getImageUrl());
        }

        return toResponse(closetItemRepository.save(entity));
    }

    @Transactional
    public DeleteResponse delete(String id) {
        String userId = SecurityUtils.currentUserId();
        ClosetItemEntity entity = closetItemRepository.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new NotFoundException("Closet item not found."));

        Instant now = Instant.now();
        entity.setDeletedAt(now);
        entity.setUpdatedAt(now);
        closetItemRepository.save(entity);
        return new DeleteResponse(entity.getId(), now);
    }

    @Transactional(readOnly = true)
    public List<ClosetItemResponse> changedSince(String userId, Instant since) {
        return closetItemRepository.findByUserIdAndDeletedAtIsNullAndUpdatedAtAfter(userId, since)
            .stream()
            .map(this::toResponse)
            .toList();
    }

    @Transactional(readOnly = true)
    public List<String> deletedIdsSince(String userId, Instant since) {
        return closetItemRepository.findByUserIdAndDeletedAtIsNotNullAndDeletedAtAfter(userId, since)
            .stream()
            .map(ClosetItemEntity::getId)
            .toList();
    }

    private ClosetItemResponse toResponse(ClosetItemEntity entity) {
        ClosetItemResponse response = new ClosetItemResponse();
        response.setId(entity.getId());
        response.setName(entity.getName());
        response.setCategory(entity.getCategory());
        response.setBrand(entity.getBrand());
        response.setColor(entity.getColor());
        response.setNote(entity.getNote());
        response.setImageUrl(entity.getImageUrl());
        response.setImageMediaId(entity.getImageMediaId());
        response.setCreatedAt(entity.getCreatedAt());
        response.setUpdatedAt(entity.getUpdatedAt());
        response.setDeletedAt(entity.getDeletedAt());
        return response;
    }

    private void validateCategory(String category) {
        if (!ClosetCategories.ALLOWED.contains(category)) {
            throw new BadRequestException("BAD_REQUEST", "Invalid category.");
        }
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
            case "name" -> "name";
            case "category" -> "category";
            case "createdAt" -> "createdAt";
            case "updatedAt" -> "updatedAt";
            default -> throw new BadRequestException("BAD_REQUEST", "Invalid sortBy.");
        };
    }
}
