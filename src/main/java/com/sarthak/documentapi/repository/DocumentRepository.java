
package com.sarthak.documentapi.repository;

import com.sarthak.documentapi.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DocumentRepository extends JpaRepository<Document, Long> {

    List<Document> findAllByUser_Id(Long userId);

    Optional<Document> findByIdAndUser_Id(Long id, Long userId);
}
