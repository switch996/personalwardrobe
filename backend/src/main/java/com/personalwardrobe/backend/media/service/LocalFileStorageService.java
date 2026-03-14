package com.personalwardrobe.backend.media.service;

import com.personalwardrobe.backend.common.exception.BadRequestException;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

@Service
public class LocalFileStorageService {

    private final Path storagePath;

    public LocalFileStorageService(@Value("${app.media.storage-path}") String storagePath) {
        this.storagePath = Path.of(storagePath).toAbsolutePath().normalize();
    }

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(storagePath);
        } catch (IOException ex) {
            throw new IllegalStateException("Failed to initialize media storage directory.", ex);
        }
    }

    public StoredMediaFile store(String mediaId, MultipartFile file) {
        if (file.isEmpty()) {
            throw new BadRequestException("BAD_REQUEST", "Uploaded file is empty.");
        }

        String extension = resolveExtension(file);
        String filename = mediaId + extension;
        Path targetPath = storagePath.resolve(filename).normalize();

        try (InputStream inputStream = file.getInputStream()) {
            Files.copy(inputStream, targetPath, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException ex) {
            throw new IllegalStateException("Failed to store media file.", ex);
        }

        Integer width = null;
        Integer height = null;
        try {
            BufferedImage bufferedImage = ImageIO.read(targetPath.toFile());
            if (bufferedImage != null) {
                width = bufferedImage.getWidth();
                height = bufferedImage.getHeight();
            }
        } catch (IOException ignored) {
        }

        String contentType = file.getContentType() == null ? "application/octet-stream" : file.getContentType();
        return new StoredMediaFile(filename, contentType, file.getSize(), width, height);
    }

    private String resolveExtension(MultipartFile file) {
        String originalName = file.getOriginalFilename();
        if (originalName != null) {
            int index = originalName.lastIndexOf('.');
            if (index >= 0 && index < originalName.length() - 1) {
                return originalName.substring(index);
            }
        }

        String contentType = file.getContentType();
        if ("image/jpeg".equals(contentType)) {
            return ".jpg";
        }
        if ("image/png".equals(contentType)) {
            return ".png";
        }
        if ("image/webp".equals(contentType)) {
            return ".webp";
        }
        return "";
    }

    public record StoredMediaFile(String filename, String contentType, long size, Integer width, Integer height) {
    }
}
