package com.personalwardrobe.backend.outfit.controller;

import com.personalwardrobe.backend.common.web.DeleteResponse;
import com.personalwardrobe.backend.common.web.PagedResponse;
import com.personalwardrobe.backend.outfit.dto.OutfitCreateRequest;
import com.personalwardrobe.backend.outfit.dto.OutfitResponse;
import com.personalwardrobe.backend.outfit.dto.OutfitUpdateRequest;
import com.personalwardrobe.backend.outfit.service.OutfitService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
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

import java.time.LocalDate;

@RestController
public class OutfitController {

    private final OutfitService outfitService;

    public OutfitController(OutfitService outfitService) {
        this.outfitService = outfitService;
    }

    @PostMapping("/outfits")
    @ResponseStatus(HttpStatus.CREATED)
    public OutfitResponse create(@Valid @RequestBody OutfitCreateRequest request) {
        return outfitService.create(request);
    }

    @GetMapping("/outfits")
    public PagedResponse<OutfitResponse> list(
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateFrom,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateTo,
        @RequestParam(required = false) String tag,
        @RequestParam(required = false) String closetItemId,
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "20") int pageSize,
        @RequestParam(required = false) String sortBy,
        @RequestParam(required = false) String sortOrder
    ) {
        return outfitService.list(dateFrom, dateTo, tag, closetItemId, page, pageSize, sortBy, sortOrder);
    }

    @GetMapping("/outfits/{id}")
    public OutfitResponse getById(@PathVariable String id) {
        return outfitService.getById(id);
    }

    @PutMapping("/outfits/{id}")
    public OutfitResponse update(@PathVariable String id, @Valid @RequestBody OutfitUpdateRequest request) {
        return outfitService.update(id, request);
    }

    @DeleteMapping("/outfits/{id}")
    public DeleteResponse delete(@PathVariable String id) {
        return outfitService.delete(id);
    }
}
