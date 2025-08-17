package com.example.pdfaudio.service;

import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class TextSummarizationService {

    public String generateSummary(String text) {
        if (StringUtils.isBlank(text)) {
            return "No content to summarize.";
        }

        // Clean and prepare text
        String cleanText = text.replaceAll("[^a-zA-Z0-9\\s.,!?]", "")
                              .replaceAll("\\s+", " ")
                              .trim();

        // Split into sentences
        String[] sentences = cleanText.split("[.!?]+");
        
        if (sentences.length <= 3) {
            return cleanText;
        }

        // Calculate word frequencies
        Map<String, Integer> wordFreq = calculateWordFrequency(cleanText.toLowerCase());

        // Score sentences based on word frequencies
        List<ScoredSentence> scoredSentences = new ArrayList<>();
        for (int i = 0; i < sentences.length; i++) {
            String sentence = sentences[i].trim();
            if (sentence.length() > 10) { // Ignore very short sentences
                double score = calculateSentenceScore(sentence.toLowerCase(), wordFreq);
                scoredSentences.add(new ScoredSentence(sentence, score, i));
            }
        }

        // Sort by score and select top sentences
        int summaryLength = Math.max(2, sentences.length / 4); // 25% of original
        List<ScoredSentence> topSentences = scoredSentences.stream()
                .sorted((s1, s2) -> Double.compare(s2.score, s1.score))
                .limit(summaryLength)
                .sorted(Comparator.comparingInt(s -> s.originalIndex))
                .collect(Collectors.toList());

        // Combine selected sentences
        String summary = topSentences.stream()
                .map(s -> s.sentence)
                .collect(Collectors.joining(". "));

        return summary + (summary.endsWith(".") ? "" : ".");
    }

    private Map<String, Integer> calculateWordFrequency(String text) {
        Map<String, Integer> wordFreq = new HashMap<>();
        String[] words = text.split("\\s+");
        
        Set<String> stopWords = Set.of("the", "a", "an", "and", "or", "but", "in", 
                "on", "at", "to", "for", "of", "with", "by", "is", "are", "was", 
                "were", "be", "been", "have", "has", "had", "do", "does", "did",
                "will", "would", "could", "should", "may", "might", "must", "can",
                "this", "that", "these", "those", "i", "you", "he", "she", "it",
                "we", "they", "me", "him", "her", "us", "them");

        for (String word : words) {
            word = word.replaceAll("[^a-zA-Z]", "").toLowerCase();
            if (word.length() > 2 && !stopWords.contains(word)) {
                wordFreq.put(word, wordFreq.getOrDefault(word, 0) + 1);
            }
        }
        return wordFreq;
    }

    private double calculateSentenceScore(String sentence, Map<String, Integer> wordFreq) {
        String[] words = sentence.split("\\s+");
        double score = 0;
        int validWords = 0;

        for (String word : words) {
            word = word.replaceAll("[^a-zA-Z]", "").toLowerCase();
            if (word.length() > 2 && wordFreq.containsKey(word)) {
                score += wordFreq.get(word);
                validWords++;
            }
        }

        return validWords > 0 ? score / validWords : 0;
    }

    private static class ScoredSentence {
        String sentence;
        double score;
        int originalIndex;

        ScoredSentence(String sentence, double score, int originalIndex) {
            this.sentence = sentence;
            this.score = score;
            this.originalIndex = originalIndex;
        }
    }
}
