package com.personalwardrobe.backend.auth.security;

import com.personalwardrobe.backend.common.exception.UnauthorizedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static String currentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new UnauthorizedException("Unauthorized.");
        }
        Object principal = authentication.getPrincipal();
        if (!(principal instanceof String userId)) {
            throw new UnauthorizedException("Unauthorized.");
        }
        return userId;
    }

    public static UsernamePasswordAuthenticationToken buildAuthentication(String userId) {
        return new UsernamePasswordAuthenticationToken(userId, null, List.of());
    }
}
