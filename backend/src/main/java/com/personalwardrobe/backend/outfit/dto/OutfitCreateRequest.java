package com.personalwardrobe.backend.outfit.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class OutfitCreateRequest {

    @NotNull
    private LocalDate date;
    private String note;
    private List<String> tags = new ArrayList<>();
    private String imageUrl;
    private List<String> closetItemIds = new ArrayList<>();

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
        this.tags = tags == null ? new ArrayList<>() : tags;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public List<String> getClosetItemIds() {
        return closetItemIds;
    }

    public void setClosetItemIds(List<String> closetItemIds) {
        this.closetItemIds = closetItemIds == null ? new ArrayList<>() : closetItemIds;
    }
}
