package com.personalwardrobe.backend.common.web;

import java.time.Instant;

public class DeleteResponse {

    private String id;
    private Instant deletedAt;

    public DeleteResponse() {
    }

    public DeleteResponse(String id, Instant deletedAt) {
        this.id = id;
        this.deletedAt = deletedAt;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Instant getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Instant deletedAt) {
        this.deletedAt = deletedAt;
    }
}
