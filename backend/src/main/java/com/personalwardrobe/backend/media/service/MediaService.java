package com.personalwardrobe.backend.media.service;

import com.personalwardrobe.backend.auth.security.SecurityUtils;
import com.personalwardrobe.backend.common.exception.NotFoundException;
import com.personalwardrobe.backend.common.util.IdGenerator;
import com.personalwardrobe.backend.common.web.DeleteResponse;
import com.personalwardrobe.backend.media.dto.MediaResponse;
import com.personalwardrobe.backend.media.entity.MediaEntity;
import com.personalwardrobe.backend.media.repository.MediaRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.Instant;

@Service
public class MediaService {

    private final MediaRepository mediaRepository;
    private final LocalFileStorageService localFileStorageService;
    private final String mediaBaseUrl;

    public MediaService(MediaRepository mediaRepository,
                        LocalFileStorageService localFileStorageService,
                        @Value("${app.media.base-url}") String mediaBaseUrl) {
        this.mediaRepository = mediaRepository;
        this.localFileStorageService = localFileStorageService;
        this.mediaBaseUrl = mediaBaseUrl;
    }

    @Transactional
    public MediaResponse upload(MultipartFile file) {
        String userId = SecurityUtils.currentUserId();
        String mediaId = IdGenerator.newId("media");

        LocalFileStorageService.StoredMediaFile storedFile = localFileStorageService.store(mediaId, file);

        MediaEntity entity = new MediaEntity();
        entity.setId(mediaId);
        entity.setUserId(userId);
        entity.setUrl(buildMediaUrl(storedFile.filename()));
        entity.setContentType(storedFile.contentType());
        entity.setSize(storedFile.size());
        entity.setWidth(storedFile.width());
        entity.setHeight(storedFile.height());
        entity.setThumbnailUrl(null);

        return toResponse(mediaRepository.save(entity));
    }

    @Transactional(readOnly = true)
    public MediaResponse getById(String id) {
        String userId = SecurityUtils.currentUserId();
        MediaEntity entity = mediaRepository.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new NotFoundException("Media not found."));
        return toResponse(entity);
    }

    @Transactional
    public DeleteResponse delete(String id) {
        String userId = SecurityUtils.currentUserId();
        MediaEntity entity = mediaRepository.findByIdAndUserIdAndDeletedAtIsNull(id, userId)
            .orElseThrow(() -> new NotFoundException("Media not found."));

        Instant now = Instant.now();
        entity.setDeletedAt(now);
        entity.setUpdatedAt(now);
        mediaRepository.save(entity);
        return new DeleteResponse(entity.getId(), now);
    }

    private String buildMediaUrl(String filename) {
        if (mediaBaseUrl.endsWith("/")) {
            return mediaBaseUrl + filename;
        }
        return mediaBaseUrl + "/" + filename;
    }

    private MediaResponse toResponse(MediaEntity entity) {
        MediaResponse response = new MediaResponse();
        response.setId(entity.getId());
        response.setUrl(entity.getUrl());
        response.setContentType(entity.getContentType());
        response.setSize(entity.getSize());
        response.setWidth(entity.getWidth());
        response.setHeight(entity.getHeight());
        response.setThumbnailUrl(entity.getThumbnailUrl());
        response.setCreatedAt(entity.getCreatedAt());
        response.setUpdatedAt(entity.getUpdatedAt());
        return response;
    }
}
