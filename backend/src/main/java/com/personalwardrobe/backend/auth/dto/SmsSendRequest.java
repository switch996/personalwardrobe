package com.personalwardrobe.backend.auth.dto;

import jakarta.validation.constraints.NotBlank;

public class SmsSendRequest {

    @NotBlank
    private String phone;

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
}
