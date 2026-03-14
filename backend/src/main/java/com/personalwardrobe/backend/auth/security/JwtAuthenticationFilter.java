package com.personalwardrobe.backend.auth.security;

import com.personalwardrobe.backend.auth.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final DevBypassAuthService devBypassAuthService;

    public JwtAuthenticationFilter(JwtService jwtService,
                                   UserRepository userRepository,
                                   DevBypassAuthService devBypassAuthService) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
        this.devBypassAuthService = devBypassAuthService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
        throws ServletException, IOException {

        boolean authenticated = false;
        String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                String userId = jwtService.validateAndExtractUserId(token, "access");
                if (userRepository.existsById(userId)
                    && SecurityContextHolder.getContext().getAuthentication() == null) {
                    SecurityContextHolder.getContext().setAuthentication(SecurityUtils.buildAuthentication(userId));
                    authenticated = true;
                }
            } catch (Exception ignored) {
                SecurityContextHolder.clearContext();
            }
        }

        if (!authenticated
            && devBypassAuthService.isEnabled()
            && SecurityContextHolder.getContext().getAuthentication() == null) {
            try {
                String userId = devBypassAuthService.resolveUserId();
                SecurityContextHolder.getContext().setAuthentication(SecurityUtils.buildAuthentication(userId));
            } catch (Exception ignored) {
                SecurityContextHolder.clearContext();
            }
        }

        filterChain.doFilter(request, response);
    }
}
