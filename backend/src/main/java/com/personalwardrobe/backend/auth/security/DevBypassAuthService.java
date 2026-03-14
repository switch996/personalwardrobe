package com.personalwardrobe.backend.auth.security;

import com.personalwardrobe.backend.auth.entity.UserEntity;
import com.personalwardrobe.backend.auth.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DevBypassAuthService {

    private final UserRepository userRepository;
    private final boolean enabled;
    private final String userId;
    private final String phone;

    public DevBypassAuthService(
        UserRepository userRepository,
        @Value("${app.auth.dev-bypass.enabled:false}") boolean enabled,
        @Value("${app.auth.dev-bypass.user-id:dev_user}") String userId,
        @Value("${app.auth.dev-bypass.phone:13800000000}") String phone
    ) {
        this.userRepository = userRepository;
        this.enabled = enabled;
        this.userId = userId;
        this.phone = phone;
    }

    public boolean isEnabled() {
        return enabled;
    }

    @Transactional
    public String resolveUserId() {
        if (userRepository.existsById(userId)) {
            return userId;
        }
        return userRepository.findByPhone(phone)
            .map(UserEntity::getId)
            .orElseGet(() -> {
                UserEntity user = new UserEntity();
                user.setId(userId);
                user.setPhone(phone);
                return userRepository.save(user).getId();
            });
    }
}
