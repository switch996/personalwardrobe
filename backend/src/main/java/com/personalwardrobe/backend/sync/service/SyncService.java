package com.personalwardrobe.backend.sync.service;

import com.personalwardrobe.backend.auth.security.SecurityUtils;
import com.personalwardrobe.backend.closet.service.ClosetItemService;
import com.personalwardrobe.backend.outfit.service.OutfitService;
import com.personalwardrobe.backend.sync.dto.SyncChangesResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
public class SyncService {

    private final OutfitService outfitService;
    private final ClosetItemService closetItemService;

    public SyncService(OutfitService outfitService, ClosetItemService closetItemService) {
        this.outfitService = outfitService;
        this.closetItemService = closetItemService;
    }

    @Transactional(readOnly = true)
    public SyncChangesResponse getChanges(Instant since) {
        String userId = SecurityUtils.currentUserId();
        Instant serverTime = Instant.now();

        SyncChangesResponse response = new SyncChangesResponse();
        response.setOutfits(outfitService.changedSince(userId, since));
        response.setClosetItems(closetItemService.changedSince(userId, since));
        response.setDeletedOutfitIds(outfitService.deletedIdsSince(userId, since));
        response.setDeletedClosetItemIds(closetItemService.deletedIdsSince(userId, since));
        response.setServerTime(serverTime);
        response.setNextSince(serverTime);
        return response;
    }
}
