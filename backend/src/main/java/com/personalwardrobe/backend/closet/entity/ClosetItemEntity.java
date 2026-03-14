package com.personalwardrobe.backend.closet.entity;

import com.personalwardrobe.backend.common.model.SoftDeleteEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "closet_items")
public class ClosetItemEntity extends SoftDeleteEntity {

    @Column(nullable = false, length = 64)
    private String userId;

    @Column(nullable = false, length = 128)
    private String name;

    @Column(nullable = false, length = 32)
    private String category;

    @Column(length = 128)
    private String brand;

    @Column(length = 64)
    private String color;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(columnDefinition = "TEXT")
    private String imageUrl;

    @Column(length = 64)
    private String imageMediaId;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
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
}
