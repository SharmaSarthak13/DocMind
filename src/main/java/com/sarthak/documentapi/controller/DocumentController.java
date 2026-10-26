
package com.sarthak.documentapi.controller;

import com.sarthak.documentapi.dto.DocumentResponse;
import com.sarthak.documentapi.service.DocumentService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {

    private final DocumentService documentService;

    public DocumentController(DocumentService documentService) {
        this.documentService = documentService;
    }

    @PostMapping("/upload")
    public ResponseEntity<DocumentResponse> upload(
            @RequestParam("file") MultipartFile file,
            Authentication authentication
    ) {
        DocumentResponse response = documentService.upload(
                authentication.getName(), file
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<DocumentResponse>> listDocuments(
            Authentication authentication
    ) {
        return ResponseEntity.ok(
                documentService.listDocuments(authentication.getName())
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDocument(
            @PathVariable Long id,
            Authentication authentication
    ) {
        documentService.deleteDocument(authentication.getName(), id);
        return ResponseEntity.noContent().build();
    }
}
