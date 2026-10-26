
package com.sarthak.documentapi.service;

import com.sarthak.documentapi.dto.DocumentResponse;
import com.sarthak.documentapi.entity.Document;
import com.sarthak.documentapi.entity.User;
import com.sarthak.documentapi.repository.DocumentRepository;
import com.sarthak.documentapi.repository.UserRepository;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Service
public class DocumentService {

    private final DocumentRepository documentRepository;
    private final UserRepository userRepository;
    private final Path storageDirectory;

    public DocumentService(
            DocumentRepository documentRepository,
            UserRepository userRepository,
            @Value("${app.storage.location:uploads}") String storageLocation
    ) {
        this.documentRepository = documentRepository;
        this.userRepository = userRepository;
        this.storageDirectory = Paths.get(storageLocation)
                .toAbsolutePath()
                .normalize();
    }

    private User getUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED, "User not found"
                ));
    }

    @Transactional
    public DocumentResponse upload(String email, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Please select a non-empty file"
            );
        }

        User user = getUser(email);

        String originalName = file.getOriginalFilename();
        if (originalName == null || originalName.isBlank()) {
            originalName = "uploaded-file";
        }

        // Strip any directory components from the supplied filename.
        originalName = originalName.replace('\\', '/');
        originalName = originalName.substring(
                originalName.lastIndexOf('/') + 1
        );

        String contentType = file.getContentType();
        if (contentType == null || contentType.isBlank()) {
            contentType = "application/octet-stream";
        }

        // Generate a unique disk filename; never trust the client's path.
        String diskName = UUID.randomUUID().toString();
        String extension = "";

        int dot = originalName.lastIndexOf('.');
        if (dot > 0 && dot < originalName.length() - 1) {
            extension = originalName.substring(dot);
        }
        diskName += extension;

        Path destination = storageDirectory.resolve(diskName).normalize();

        if (!destination.startsWith(storageDirectory)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Invalid file path"
            );
        }

        try {
            Files.createDirectories(storageDirectory);
            file.transferTo(destination);

            Document document = new Document();
            document.setFileName(originalName);
            document.setStoragePath(destination.toString());
            document.setContentType(contentType);
            document.setFileSize(file.getSize());
            document.setUser(user);

            Document saved = documentRepository.save(document);
            return toResponse(saved);

        } catch (IOException | RuntimeException exception) {
            try {
                Files.deleteIfExists(destination);
            } catch (IOException ignored) {
                // Preserve the original failure.
            }

            if (exception instanceof ResponseStatusException responseException) {
                throw responseException;
            }

            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Could not store the uploaded file"
            );
        }
    }

    @Transactional(readOnly = true)
    public List<DocumentResponse> listDocuments(String email) {
        User user = getUser(email);

        return documentRepository.findAllByUser_Id(user.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public void deleteDocument(String email, Long documentId) {
        User user = getUser(email);

        Document document = documentRepository
                .findByIdAndUser_Id(documentId, user.getId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Document not found"
                ));

        try {
            Files.deleteIfExists(Paths.get(document.getStoragePath()));
        } catch (IOException exception) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Could not delete the stored file"
            );
        }

        documentRepository.delete(document);
    }

    private DocumentResponse toResponse(Document document) {
        return new DocumentResponse(
                document.getId(),
                document.getFileName(),
                document.getContentType(),
                document.getFileSize(),
                document.getUploadedAt()
        );
    }
}
