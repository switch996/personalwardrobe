package com.personalwardrobe.backend.auth.security;

import com.personalwardrobe.backend.common.exception.UnauthorizedException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.util.Base64;
import java.util.Date;

@Service
public class JwtService {

    private final String base64Secret;
    private final long accessTokenExpirationSeconds;
    private final long refreshTokenExpirationSeconds;

    private SecretKey signingKey;

    public JwtService(
        @Value("${app.jwt.secret}") String base64Secret,
        @Value("${app.jwt.access-token-expiration-seconds}") long accessTokenExpirationSeconds,
        @Value("${app.jwt.refresh-token-expiration-seconds}") long refreshTokenExpirationSeconds
    ) {
        this.base64Secret = base64Secret;
        this.accessTokenExpirationSeconds = accessTokenExpirationSeconds;
        this.refreshTokenExpirationSeconds = refreshTokenExpirationSeconds;
    }

    @PostConstruct
    public void init() {
        byte[] keyBytes = Base64.getDecoder().decode(base64Secret);
        this.signingKey = Keys.hmacShaKeyFor(keyBytes);
    }

    public String generateAccessToken(String userId) {
        return buildToken(userId, "access", accessTokenExpirationSeconds);
    }

    public String generateRefreshToken(String userId) {
        return buildToken(userId, "refresh", refreshTokenExpirationSeconds);
    }

    public long getAccessTokenExpirationSeconds() {
        return accessTokenExpirationSeconds;
    }

    public Instant getTokenExpiration(String token) {
        return parseClaims(token).getExpiration().toInstant();
    }

    public String validateAndExtractUserId(String token, String expectedType) {
        Claims claims = parseClaims(token);
        String tokenType = claims.get("type", String.class);
        if (!expectedType.equals(tokenType)) {
            throw new UnauthorizedException("Invalid token type.");
        }
        if (claims.getExpiration().toInstant().isBefore(Instant.now())) {
            throw new UnauthorizedException("Token expired.");
        }
        return claims.getSubject();
    }

    private String buildToken(String userId, String type, long expiresInSeconds) {
        Instant now = Instant.now();
        Instant expireAt = now.plusSeconds(expiresInSeconds);
        return Jwts.builder()
            .subject(userId)
            .issuedAt(Date.from(now))
            .expiration(Date.from(expireAt))
            .claim("type", type)
            .signWith(signingKey)
            .compact();
    }

    private Claims parseClaims(String token) {
        try {
            return Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
        } catch (JwtException | IllegalArgumentException ex) {
            throw new UnauthorizedException("Invalid token.");
        }
    }
}
