package com.example.pdfaudio.controller;


import com.example.pdfaudio.service.FileStorageService;
import com.example.pdfaudio.service.PdfTextExtractionService;
import com.example.pdfaudio.service.TextSummarizationService;
import com.example.pdfaudio.service.TextToSpeechService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/pdf-to-audio")
@CrossOrigin(origins = "*")
public class PdfToAudioController {

    @Autowired
    private PdfTextExtractionService pdfTextExtractionService;

    @Autowired
    private TextSummarizationService textSummarizationService;

    @Autowired
    private TextToSpeechService textToSpeechService;

    @Autowired
    private FileStorageService fileStorageService;

    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadPdfAndConvertToAudio(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "voiceType", defaultValue = "default") String voiceType) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Validate input
            if (file.isEmpty()) {
                return createErrorResponse("File is empty", HttpStatus.BAD_REQUEST);
            }

            if (!file.getContentType().equals("application/pdf")) {
                return createErrorResponse("File must be a PDF", HttpStatus.BAD_REQUEST);
            }

            // Ensure audio directory exists
            fileStorageService.ensureAudioDirectoryExists();

            // Step 1: Extract text from PDF
            String extractedText = pdfTextExtractionService.extractTextFromPdf(file);
            
            if (extractedText.trim().isEmpty()) {
                return createErrorResponse("No text found in PDF", HttpStatus.BAD_REQUEST);
            }

            // Step 2: Generate summary
            String summary = textSummarizationService.generateSummary(extractedText);

            // Step 3: Generate unique filename
            String fileName = fileStorageService.generateUniqueFileName(file.getOriginalFilename());

            // Step 4: Convert summary to audio with selected voice
            String audioFilePath = textToSpeechService.convertTextToWav(summary, fileName, voiceType);
            
            response.put("voiceType", voiceType);

            // Step 5: Cleanup old files (keep only 10 most recent)
            fileStorageService.cleanupOldFiles(10);

            // Prepare successful response
            response.put("success", true);
            response.put("message", "PDF successfully converted to audio");
            response.put("originalFileName", file.getOriginalFilename());
            response.put("audioFileName", fileName + ".wav");
            response.put("audioFilePath", audioFilePath);
            response.put("summary", summary);
            response.put("extractedTextLength", extractedText.length());
            response.put("summaryLength", summary.length());
            response.put("audioFileSize", fileStorageService.getFileSize(audioFilePath));

            return ResponseEntity.ok(response);

        } catch (IOException e) {
            return createErrorResponse("Error processing PDF: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            return createErrorResponse("Unexpected error: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/download/{fileName}")
    public ResponseEntity<Resource> downloadAudioFile(@PathVariable String fileName) {
        try {
            String filePath = fileStorageService.getAudioFilesDirectory() + "/" + fileName;
            
            if (!fileStorageService.fileExists(filePath)) {
                return ResponseEntity.notFound().build();
            }

            Resource resource = new FileSystemResource(filePath);
            
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType("audio/wav"))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                    .body(resource);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/voices")
    public ResponseEntity<Map<String, Object>> getAvailableVoices() {
        try {
            String[] voices = textToSpeechService.getAvailableVoices();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("voices", voices);
            response.put("defaultVoices", new String[]{"default", "male", "female"});
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return createErrorResponse("Error retrieving voices: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "PDF to Audio API");
        response.put("version", "1.0.0");
        return ResponseEntity.ok(response);
    }

    private ResponseEntity<Map<String, Object>> createErrorResponse(String message, HttpStatus status) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("error", message);
        errorResponse.put("status", status.value());
        return ResponseEntity.status(status).body(errorResponse);
    }
}
