package com.example.pdfaudio.service;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;

@Service
public class TextToSpeechService {

    @Value("${tts.voice.rate:0}")
    private int speechRate;

    @Value("${tts.voice.volume:100}")
    private int volume;

    public String convertTextToWav(String text, String fileName) throws IOException {
        return convertTextToWav(text, fileName, "default");
    }

    public String convertTextToWav(String text, String fileName, String voiceType) throws IOException {
        try {
            // Try Windows SAPI first (best quality on Windows)
            if (System.getProperty("os.name").toLowerCase().contains("windows")) {
                return generateWindowsSAPIAudio(text, fileName, voiceType);
            } else {
                // Fallback to other methods for non-Windows systems
                return generateLinuxTTSAudio(text, fileName);
            }
        } catch (Exception e) {
            throw new IOException("Failed to convert text to speech: " + e.getMessage(), e);
        }
    }

    /**
     * Uses Windows Speech API (SAPI) via PowerShell for high-quality human speech
     */
    private String generateWindowsSAPIAudio(String text, String fileName, String voiceType) throws IOException {
        try {
            // Create output directory
            Path audioDir = Paths.get("audio-files");
            if (!Files.exists(audioDir)) {
                Files.createDirectories(audioDir);
            }

            String outputPath = audioDir.resolve(fileName + ".wav").toString();
            
            // Clean text for PowerShell (escape special characters)
            String cleanText = text.replace("\"", "'")
                                 .replace("`", "")
                                 .replace("$", "")
                                 .replace(";", ",")
                                 .trim();

            // Build PowerShell command for Windows Speech API
            StringBuilder psScript = new StringBuilder();
            psScript.append("Add-Type -AssemblyName System.Speech; ");
            psScript.append("$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer; ");
            
            // Configure voice based on type
            if ("female".equalsIgnoreCase(voiceType)) {
                psScript.append("$synth.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Female); ");
            } else if ("male".equalsIgnoreCase(voiceType)) {
                psScript.append("$synth.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Male); ");
            }
            
            // Set speech rate and volume
            psScript.append(String.format("$synth.Rate = %d; ", speechRate));
            psScript.append(String.format("$synth.Volume = %d; ", volume));
            
            // Set output to WAV file
            psScript.append(String.format("$synth.SetOutputToWaveFile('%s'); ", outputPath.replace("\\", "\\\\")));
            psScript.append(String.format("$synth.Speak('%s'); ", cleanText));
            psScript.append("$synth.SetOutputToDefaultAudioDevice(); ");
            psScript.append("$synth.Dispose();");

            // Execute PowerShell command
            ProcessBuilder processBuilder = new ProcessBuilder(
                "powershell.exe", 
                "-Command", 
                psScript.toString()
            );
            
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();
            
            // Wait for completion with timeout
            boolean finished = process.waitFor(30, TimeUnit.SECONDS);
            
            if (!finished) {
                process.destroyForcibly();
                throw new IOException("TTS process timed out");
            }
            
            int exitCode = process.exitValue();
            if (exitCode != 0) {
                // Read error output
                BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                StringBuilder error = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    error.append(line).append("\n");
                }
                throw new IOException("PowerShell TTS failed with exit code " + exitCode + ": " + error.toString());
            }
            
            // Verify file was created
            File outputFile = new File(outputPath);
            if (!outputFile.exists() || outputFile.length() == 0) {
                throw new IOException("Audio file was not generated successfully");
            }
            
            return outputPath;
            
        } catch (Exception e) {
            throw new IOException("Error generating Windows SAPI audio: " + e.getMessage(), e);
        }
    }

    /**
     * Fallback TTS for Linux/Mac systems using espeak or festival
     */
    private String generateLinuxTTSAudio(String text, String fileName) throws IOException {
        try {
            // Create output directory
            Path audioDir = Paths.get("audio-files");
            if (!Files.exists(audioDir)) {
                Files.createDirectories(audioDir);
            }

            String outputPath = audioDir.resolve(fileName + ".wav").toString();
            
            // Try espeak first (more common)
            ProcessBuilder processBuilder = new ProcessBuilder(
                "espeak", 
                "-w", outputPath,
                "-s", "150", // Speed (words per minute)
                "-p", "50",  // Pitch
                text
            );
            
            try {
                Process process = processBuilder.start();
                boolean finished = process.waitFor(30, TimeUnit.SECONDS);
                
                if (finished && process.exitValue() == 0) {
                    return outputPath;
                }
            } catch (Exception e) {
                // espeak not available, try festival
            }
            
            // Try festival as fallback
            processBuilder = new ProcessBuilder(
                "text2wave", 
                "-o", outputPath
            );
            
            Process process = processBuilder.start();
            
            // Send text to festival
            try (OutputStreamWriter writer = new OutputStreamWriter(process.getOutputStream())) {
                writer.write(text);
                writer.flush();
            }
            
            boolean finished = process.waitFor(30, TimeUnit.SECONDS);
            
            if (!finished || process.exitValue() != 0) {
                throw new IOException("TTS generation failed on Linux/Mac system");
            }
            
            return outputPath;
            
        } catch (Exception e) {
            throw new IOException("Error generating Linux TTS audio: " + e.getMessage(), e);
        }
    }

    /**
     * Get available voices for the current system
     */
    public String[] getAvailableVoices() {
        if (System.getProperty("os.name").toLowerCase().contains("windows")) {
            try {
                ProcessBuilder processBuilder = new ProcessBuilder(
                    "powershell.exe", 
                    "-Command", 
                    "Add-Type -AssemblyName System.Speech; " +
                    "$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer; " +
                    "$synth.GetInstalledVoices() | ForEach-Object { $_.VoiceInfo.Name }"
                );
                
                Process process = processBuilder.start();
                BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                
                java.util.List<String> voices = new java.util.ArrayList<>();
                String line;
                while ((line = reader.readLine()) != null) {
                    voices.add(line.trim());
                }
                
                return voices.toArray(new String[0]);
                
            } catch (Exception e) {
                return new String[]{"Default", "Male", "Female"};
            }
        } else {
            return new String[]{"Default", "espeak", "festival"};
        }
    }
}
