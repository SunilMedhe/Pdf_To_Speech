package com.example.pdfaudio.service;

import org.apache.commons.io.FileUtils;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class FileStorageService {

    private final String audioFilesDirectory = "audio-files";

    public String generateUniqueFileName(String originalFileName) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String baseName = originalFileName.replaceAll("\\.[^.]+$", ""); // Remove extension
        return String.format("%s_%s", baseName, timestamp);
    }

    public boolean fileExists(String filePath) {
        return Files.exists(Paths.get(filePath));
    }

    public void ensureAudioDirectoryExists() throws IOException {
        Path audioDir = Paths.get(audioFilesDirectory);
        if (!Files.exists(audioDir)) {
            Files.createDirectories(audioDir);
        }
    }

    public String getAudioFilesDirectory() {
        return audioFilesDirectory;
    }

    public void deleteFile(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        if (Files.exists(path)) {
            Files.delete(path);
        }
    }

    public long getFileSize(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        if (Files.exists(path)) {
            return Files.size(path);
        }
        return 0;
    }

    public void cleanupOldFiles(int maxFiles) throws IOException {
        File audioDir = new File(audioFilesDirectory);
        if (!audioDir.exists()) {
            return;
        }

        File[] files = audioDir.listFiles((dir, name) -> name.endsWith(".wav"));
        if (files != null && files.length > maxFiles) {
            // Sort files by last modified date (oldest first)
            java.util.Arrays.sort(files, (f1, f2) -> Long.compare(f1.lastModified(), f2.lastModified()));
            
            // Delete oldest files to keep only maxFiles
            for (int i = 0; i < files.length - maxFiles; i++) {
                FileUtils.deleteQuietly(files[i]);
            }
        }
    }
}
