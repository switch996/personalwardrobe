package com.personalwardrobe.backend.sync.controller;

import com.personalwardrobe.backend.sync.dto.SyncChangesResponse;
import com.personalwardrobe.backend.sync.service.SyncService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;

@RestController
public class SyncController {

    private final SyncService syncService;

    public SyncController(SyncService syncService) {
        this.syncService = syncService;
    }

    @GetMapping("/sync/changes")
    public SyncChangesResponse getChanges(
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant since
    ) {
        return syncService.getChanges(since);
    }
}
