package com.personalwardrobe.backend.auth.service;

import com.personalwardrobe.backend.auth.dto.AuthTokenResponse;
import com.personalwardrobe.backend.auth.dto.LogoutRequest;
import com.personalwardrobe.backend.auth.dto.RefreshTokenRequest;
import com.personalwardrobe.backend.auth.dto.SmsSendResponse;
import com.personalwardrobe.backend.auth.dto.SmsVerifyRequest;
import com.personalwardrobe.backend.auth.dto.UserResponse;
import com.personalwardrobe.backend.auth.entity.RefreshTokenEntity;
import com.personalwardrobe.backend.auth.entity.UserEntity;
import com.personalwardrobe.backend.auth.repository.RefreshTokenRepository;
import com.personalwardrobe.backend.auth.repository.UserRepository;
import com.personalwardrobe.backend.auth.security.JwtService;
import com.personalwardrobe.backend.auth.security.SecurityUtils;
import com.personalwardrobe.backend.common.exception.UnauthorizedException;
import com.personalwardrobe.backend.common.web.MessageResponse;
import com.personalwardrobe.backend.common.util.IdGenerator;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class AuthService {

    private final SmsCodeService smsCodeService;
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;

    public AuthService(SmsCodeService smsCodeService,
                       UserRepository userRepository,
                       RefreshTokenRepository refreshTokenRepository,
                       JwtService jwtService) {
        this.smsCodeService = smsCodeService;
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.jwtService = jwtService;
    }

    public SmsSendResponse sendSmsCode(String phone) {
        smsCodeService.generateAndStoreCode(phone);
        return new SmsSendResponse("Verification code sent.");
    }

    @Transactional
    public AuthTokenResponse verifySmsAndLogin(SmsVerifyRequest request) {
        if (!smsCodeService.verifyCode(request.getPhone(), request.getCode())) {
            throw new UnauthorizedException("Invalid verification code.");
        }

        UserEntity user = userRepository.findByPhone(request.getPhone())
            .orElseGet(() -> createUser(request.getPhone()));

        return issueTokenPair(user);
    }

    @Transactional
    public AuthTokenResponse refresh(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();
        String userId = jwtService.validateAndExtractUserId(refreshToken, "refresh");

        RefreshTokenEntity tokenEntity = refreshTokenRepository.findByToken(refreshToken)
            .orElseThrow(() -> new UnauthorizedException("Refresh token is invalid."));

        if (tokenEntity.isRevoked() || tokenEntity.getExpiresAt().isBefore(Instant.now())) {
            throw new UnauthorizedException("Refresh token is invalid.");
        }

        tokenEntity.setRevoked(true);
        refreshTokenRepository.save(tokenEntity);

        UserEntity user = userRepository.findById(userId)
            .orElseThrow(() -> new UnauthorizedException("User not found."));

        return issueTokenPair(user);
    }

    @Transactional
    public MessageResponse logout(LogoutRequest request) {
        if (request.getRefreshToken() != null && !request.getRefreshToken().isBlank()) {
            refreshTokenRepository.findByToken(request.getRefreshToken()).ifPresent(token -> {
                token.setRevoked(true);
                refreshTokenRepository.save(token);
            });
            return new MessageResponse("OK");
        }

        String userId = SecurityUtils.currentUserId();
        List<RefreshTokenEntity> activeTokens = refreshTokenRepository.findByUserIdAndRevokedIsFalse(userId);
        for (RefreshTokenEntity tokenEntity : activeTokens) {
            tokenEntity.setRevoked(true);
        }
        refreshTokenRepository.saveAll(activeTokens);
        return new MessageResponse("OK");
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUser() {
        String userId = SecurityUtils.currentUserId();
        UserEntity user = userRepository.findById(userId)
            .orElseThrow(() -> new UnauthorizedException("User not found."));
        return toUserResponse(user);
    }

    private UserEntity createUser(String phone) {
        UserEntity user = new UserEntity();
        user.setId(IdGenerator.newId("user"));
        user.setPhone(phone);
        return userRepository.save(user);
    }

    private AuthTokenResponse issueTokenPair(UserEntity user) {
        String accessToken = jwtService.generateAccessToken(user.getId());
        String refreshToken = jwtService.generateRefreshToken(user.getId());

        RefreshTokenEntity tokenEntity = new RefreshTokenEntity();
        tokenEntity.setId(IdGenerator.newId("rt"));
        tokenEntity.setUserId(user.getId());
        tokenEntity.setToken(refreshToken);
        tokenEntity.setExpiresAt(jwtService.getTokenExpiration(refreshToken));
        tokenEntity.setRevoked(false);
        refreshTokenRepository.save(tokenEntity);

        AuthTokenResponse response = new AuthTokenResponse();
        response.setAccessToken(accessToken);
        response.setRefreshToken(refreshToken);
        response.setTokenType("Bearer");
        response.setExpiresIn(jwtService.getAccessTokenExpirationSeconds());
        response.setUser(toUserResponse(user));
        return response;
    }

    private UserResponse toUserResponse(UserEntity entity) {
        UserResponse response = new UserResponse();
        response.setId(entity.getId());
        response.setPhone(entity.getPhone());
        response.setCreatedAt(entity.getCreatedAt());
        response.setUpdatedAt(entity.getUpdatedAt());
        return response;
    }
}
