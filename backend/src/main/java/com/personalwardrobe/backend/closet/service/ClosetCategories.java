package com.personalwardrobe.backend.closet.service;

import java.util.Set;

public final class ClosetCategories {

    public static final Set<String> ALLOWED = Set.of(
        "top", "bottom", "shoes", "accessory", "outerwear", "dress", "bag"
    );

    private ClosetCategories() {
    }
}
