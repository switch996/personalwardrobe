package com.personalwardrobe.backend.outfit.entity;

import com.personalwardrobe.backend.common.model.SoftDeleteEntity;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "outfits")
public class OutfitEntity extends SoftDeleteEntity {

    @Column(nullable = false, length = 64)
    private String userId;

    @Column(name = "wear_date", nullable = false)
    private LocalDate wearDate;

    @Column(columnDefinition = "TEXT")
    private String note;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "outfit_tags", joinColumns = @JoinColumn(name = "outfit_id"))
    @Column(name = "tag", nullable = false)
    private List<String> tags = new ArrayList<>();

    @Column(columnDefinition = "TEXT")
    private String imageUrl;

    @Column(length = 64)
    private String imageMediaId;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "outfit_closet_item_ids", joinColumns = @JoinColumn(name = "outfit_id"))
    @Column(name = "closet_item_id", nullable = false)
    private List<String> closetItemIds = new ArrayList<>();

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public LocalDate getWearDate() {
        return wearDate;
    }

    public void setWearDate(LocalDate wearDate) {
        this.wearDate = wearDate;
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
        this.tags = tags == null ? new ArrayList<>() : new ArrayList<>(tags);
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
        this.closetItemIds = closetItemIds == null ? new ArrayList<>() : new ArrayList<>(closetItemIds);
    }
}
