package com.personalwardrobe.backend.sync.dto;

import com.personalwardrobe.backend.closet.dto.ClosetItemResponse;
import com.personalwardrobe.backend.outfit.dto.OutfitResponse;

import java.time.Instant;
import java.util.List;

public class SyncChangesResponse {

    private List<OutfitResponse> outfits;
    private List<ClosetItemResponse> closetItems;
    private List<String> deletedOutfitIds;
    private List<String> deletedClosetItemIds;
    private Instant serverTime;
    private Instant nextSince;

    public List<OutfitResponse> getOutfits() {
        return outfits;
    }

    public void setOutfits(List<OutfitResponse> outfits) {
        this.outfits = outfits;
    }

    public List<ClosetItemResponse> getClosetItems() {
        return closetItems;
    }

    public void setClosetItems(List<ClosetItemResponse> closetItems) {
        this.closetItems = closetItems;
    }

    public List<String> getDeletedOutfitIds() {
        return deletedOutfitIds;
    }

    public void setDeletedOutfitIds(List<String> deletedOutfitIds) {
        this.deletedOutfitIds = deletedOutfitIds;
    }

    public List<String> getDeletedClosetItemIds() {
        return deletedClosetItemIds;
    }

    public void setDeletedClosetItemIds(List<String> deletedClosetItemIds) {
        this.deletedClosetItemIds = deletedClosetItemIds;
    }

    public Instant getServerTime() {
        return serverTime;
    }

    public void setServerTime(Instant serverTime) {
        this.serverTime = serverTime;
    }

    public Instant getNextSince() {
        return nextSince;
    }

    public void setNextSince(Instant nextSince) {
        this.nextSince = nextSince;
    }
}
