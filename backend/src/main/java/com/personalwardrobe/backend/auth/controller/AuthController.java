package com.personalwardrobe.backend.auth.controller;

import com.personalwardrobe.backend.auth.dto.AuthTokenResponse;
import com.personalwardrobe.backend.auth.dto.LogoutRequest;
import com.personalwardrobe.backend.auth.dto.RefreshTokenRequest;
import com.personalwardrobe.backend.auth.dto.SmsSendRequest;
import com.personalwardrobe.backend.auth.dto.SmsSendResponse;
import com.personalwardrobe.backend.auth.dto.SmsVerifyRequest;
import com.personalwardrobe.backend.auth.dto.UserResponse;
import com.personalwardrobe.backend.auth.service.AuthService;
import com.personalwardrobe.backend.common.web.MessageResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/auth/sms/send")
    public SmsSendResponse sendSms(@Valid @RequestBody SmsSendRequest request) {
        return authService.sendSmsCode(request.getPhone());
    }

    @PostMapping("/auth/sms/verify")
    public AuthTokenResponse verifySms(@Valid @RequestBody SmsVerifyRequest request) {
        return authService.verifySmsAndLogin(request);
    }

    @PostMapping("/auth/refresh")
    public AuthTokenResponse refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return authService.refresh(request);
    }

    @PostMapping("/auth/logout")
    public MessageResponse logout(@RequestBody(required = false) LogoutRequest request) {
        if (request == null) {
            request = new LogoutRequest();
        }
        return authService.logout(request);
    }

    @GetMapping("/me")
    public UserResponse me() {
        return authService.getCurrentUser();
    }
}
