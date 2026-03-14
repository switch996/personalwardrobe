package com.personalwardrobe.backend.closet.controller;

import com.personalwardrobe.backend.closet.dto.ClosetItemCreateRequest;
import com.personalwardrobe.backend.closet.dto.ClosetItemResponse;
import com.personalwardrobe.backend.closet.dto.ClosetItemUpdateRequest;
import com.personalwardrobe.backend.closet.service.ClosetItemService;
import com.personalwardrobe.backend.common.web.DeleteResponse;
import com.personalwardrobe.backend.common.web.PagedResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ClosetItemController {

    private final ClosetItemService closetItemService;

    public ClosetItemController(ClosetItemService closetItemService) {
        this.closetItemService = closetItemService;
    }

    @PostMapping("/closet-items")
    @ResponseStatus(HttpStatus.CREATED)
    public ClosetItemResponse create(@Valid @RequestBody ClosetItemCreateRequest request) {
        return closetItemService.create(request);
    }

    @GetMapping("/closet-items")
    public PagedResponse<ClosetItemResponse> list(
        @RequestParam(required = false) String category,
        @RequestParam(required = false) String keyword,
        @RequestParam(required = false) String color,
        @RequestParam(required = false) String brand,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "20") int pageSize,
        @RequestParam(required = false) String sortBy,
        @RequestParam(required = false) String sortOrder
    ) {
        return closetItemService.list(category, keyword, color, brand, page, pageSize, sortBy, sortOrder);
    }

    @GetMapping("/closet-items/{id}")
    public ClosetItemResponse getById(@PathVariable String id) {
        return closetItemService.getById(id);
    }

    @PutMapping("/closet-items/{id}")
    public ClosetItemResponse update(@PathVariable String id, @Valid @RequestBody ClosetItemUpdateRequest request) {
        return closetItemService.update(id, request);
    }

    @DeleteMapping("/closet-items/{id}")
    public DeleteResponse delete(@PathVariable String id) {
        return closetItemService.delete(id);
    }
}
