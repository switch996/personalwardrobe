package com.personalwardrobe.backend.auth.dto;

public class SmsSendResponse {

    private String message;

    public SmsSendResponse() {
    }

    public SmsSendResponse(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
