package com.personalwardrobe.backend.media.controller;

import com.personalwardrobe.backend.common.web.DeleteResponse;
import com.personalwardrobe.backend.media.dto.MediaResponse;
import com.personalwardrobe.backend.media.service.MediaService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
public class MediaController {

    private final MediaService mediaService;

    public MediaController(MediaService mediaService) {
        this.mediaService = mediaService;
    }

    @PostMapping(value = "/media/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public MediaResponse upload(@RequestPart("file") MultipartFile file) {
        return mediaService.upload(file);
    }

    @GetMapping("/media/{id}")
    public MediaResponse getById(@PathVariable String id) {
        return mediaService.getById(id);
    }

    @DeleteMapping("/media/{id}")
    public DeleteResponse delete(@PathVariable String id) {
        return mediaService.delete(id);
    }
}
