package com.personalwardrobe.backend.auth.service;

import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class SmsCodeService {

    private static final long EXPIRES_IN_SECONDS = 300;

    private final Map<String, CodeEntry> codeStore = new ConcurrentHashMap<>();

    public String generateAndStoreCode(String phone) {
        String code = String.valueOf(ThreadLocalRandom.current().nextInt(100000, 1000000));
        codeStore.put(phone, new CodeEntry(code, Instant.now().plusSeconds(EXPIRES_IN_SECONDS)));
        return code;
    }

    public boolean verifyCode(String phone, String code) {
        CodeEntry entry = codeStore.get(phone);
        if (entry == null) {
            return false;
        }
        if (entry.expiresAt().isBefore(Instant.now())) {
            codeStore.remove(phone);
            return false;
        }
        boolean matched = entry.code().equals(code);
        if (matched) {
            codeStore.remove(phone);
        }
        return matched;
    }

    private record CodeEntry(String code, Instant expiresAt) {
    }
}
