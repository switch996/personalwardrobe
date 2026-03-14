package com.personalwardrobe.backend.outfit.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

public class OutfitResponse {

    private String id;
    private LocalDate date;
    private String note;
    private List<String> tags;
    private String imageUrl;
    private String imageMediaId;
    private List<String> closetItemIds;
    private Instant createdAt;
    private Instant updatedAt;
    private Instant deletedAt;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getImageMediaId() {
        return imageMediaId;
    }

    public void setImageMediaId(String imageMediaId) {
        this.imageMediaId = imageMediaId;
    }

    public List<String> getClosetItemIds() {
        return closetItemIds;
    }

    public void setClosetItemIds(List<String> closetItemIds) {
        this.closetItemIds = closetItemIds;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Instant getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Instant deletedAt) {
        this.deletedAt = deletedAt;
    }
}
