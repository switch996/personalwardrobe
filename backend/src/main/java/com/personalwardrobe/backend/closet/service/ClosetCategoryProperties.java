package com.personalwardrobe.backend.closet.service;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Component
@ConfigurationProperties(prefix = "app.closet")
public class ClosetCategoryProperties {

    private static final List<CategoryOption> DEFAULT_CATEGORIES = List.of(
        option("top", "上装"),
        option("bottom", "下装"),
        option("outerwear", "外套"),
        option("shoes", "鞋子"),
        option("bag", "包袋"),
        option("accessory", "配饰"),
        option("jewelry", "首饰")
    );

    private List<CategoryOption> categories = new ArrayList<>(DEFAULT_CATEGORIES);

    public List<CategoryOption> getCategories() {
        return categories;
    }

    public void setCategories(List<CategoryOption> categories) {
        this.categories = categories;
    }

    public List<CategoryOption> normalizedCategories() {
        if (categories == null || categories.isEmpty()) {
            return new ArrayList<>(DEFAULT_CATEGORIES);
        }

        LinkedHashMap<String, CategoryOption> deduped = new LinkedHashMap<>();
        for (CategoryOption category : categories) {
            if (category == null) {
                continue;
            }

            String key = safe(category.getKey());
            if (key.isEmpty()) {
                continue;
            }

            if (!deduped.containsKey(key)) {
                String label = safe(category.getLabel());
                deduped.put(key, option(key, label.isEmpty() ? key : label));
            }
        }

        if (deduped.isEmpty()) {
            return new ArrayList<>(DEFAULT_CATEGORIES);
        }
        return new ArrayList<>(deduped.values());
    }

    public Set<String> allowedKeys() {
        return normalizedCategories().stream().map(CategoryOption::getKey).collect(Collectors.toSet());
    }

    private static CategoryOption option(String key, String label) {
        CategoryOption option = new CategoryOption();
        option.setKey(key);
        option.setLabel(label);
        return option;
    }

    private static String safe(String value) {
        return value == null ? "" : value.trim();
    }

    public static class CategoryOption {
        private String key;
        private String label;

        public String getKey() {
            return key;
        }

        public void setKey(String key) {
            this.key = key;
        }

        public String getLabel() {
            return label;
        }

        public void setLabel(String label) {
            this.label = label;
        }
    }
}
