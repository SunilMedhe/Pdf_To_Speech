package com.example.pdfaudio.service;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.logging.Logger;
import java.util.logging.Level;

@Service
public class PdfTextExtractionService {

    private static final Logger logger = Logger.getLogger(PdfTextExtractionService.class.getName());

    public String extractTextFromPdf(MultipartFile pdfFile) throws IOException {
        logger.info("Starting PDF text extraction for file: " + pdfFile.getOriginalFilename());
        
        try (InputStream inputStream = pdfFile.getInputStream();
             PDDocument document = Loader.loadPDF(inputStream.readAllBytes())) {
            
            logger.info("PDF document loaded successfully, extracting text...");
            PDFTextStripper pdfStripper = new PDFTextStripper();
            String extractedText = pdfStripper.getText(document);
            
            logger.info("Text extraction completed. Length: " + extractedText.length() + " characters");
            return extractedText;
            
        } catch (IOException e) {
            logger.log(Level.SEVERE, "Error extracting text from PDF: " + e.getMessage(), e);
            throw new IOException("Failed to extract text from PDF: " + e.getMessage(), e);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error during PDF processing: " + e.getMessage(), e);
            throw new IOException("Unexpected error processing PDF: " + e.getMessage(), e);
        }
    }
}
