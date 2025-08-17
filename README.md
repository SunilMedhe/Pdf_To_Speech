PDF to Audio API
A simple Java Spring Boot API that converts PDF documents to audio summaries.

Features
Upload PDF files
Extract text from PDFs using Apache PDFBox
Generate text summaries using a frequency-based algorithm
Convert summaries to human-like speech using Windows SAPI
Multiple voice options: Male, Female, and system default voices
High-quality WAV audio files with natural speech
Download generated audio files
Automatic cleanup of old audio files
Cross-platform TTS support (Windows SAPI, Linux espeak/festival)
API Endpoints
1. Upload and Convert PDF
POST /api/pdf-to-audio/upload

Upload a PDF file and get an audio summary.

Request:

Method: POST
Content-Type: multipart/form-data
Parameter: file (PDF file)
Optional Parameter: voiceType (default, male, female)
Response:

{
  "success": true,
  "message": "PDF successfully converted to audio",
  "originalFileName": "document.pdf",
  "audioFileName": "document_20240817_142030.wav",
  "audioFilePath": "audio-files/document_20240817_142030.wav",
  "summary": "Generated summary text...",
  "extractedTextLength": 1500,
  "summaryLength": 250,
  "audioFileSize": 45632
}
2. Download Audio File
GET /api/pdf-to-audio/download/{fileName}

Download a generated audio file.

Request:

Method: GET
URL Parameter: fileName (name of the audio file)
Response:

Content-Type: audio/wav
File download
3. Get Available Voices
GET /api/pdf-to-audio/voices

Get list of available voices on the system.

Response:

{
  "success": true,
  "voices": ["Microsoft David Desktop", "Microsoft Zira Desktop"],
  "defaultVoices": ["default", "male", "female"]
}
4. Health Check
GET /api/pdf-to-audio/health

Check if the API is running.

Response:

{
  "status": "UP",
  "service": "PDF to Audio API",
  "version": "1.0.0"
}
Running the Application
Ensure you have Java 17 or higher installed
Navigate to the project directory
Run the application:
./mvnw spring-boot:run
Or on Windows:

mvnw.cmd spring-boot:run
The API will be available at http://localhost:8080

Web Interface
Once the application is running, you can access the beautiful web interface at: http://localhost:8080

The web UI features:

🎨 Modern, responsive design
📁 Drag & drop PDF upload
📊 Progress bar with loading animation
📈 Statistics display (text length, summary length, file size)
📥 One-click audio file download
📱 Mobile-friendly responsive layout
✅ Real-time validation and error handling
Testing with cURL
Upload a PDF:
curl -X POST -F "file=@your-document.pdf" http://localhost:8080/api/pdf-to-audio/upload
Download audio file:
curl -O http://localhost:8080/api/pdf-to-audio/download/document_20240817_142030.wav
Health check:
curl http://localhost:8080/api/pdf-to-audio/health
Notes
Maximum file size: 10MB
Only PDF files are supported
Audio files are automatically cleaned up (keeps only 10 most recent files)
Generated audio files now use human-like speech with Windows SAPI
Available voices: Microsoft David (Male), Microsoft Zira (Female)
Voice selection supported via voiceType parameter
Cross-platform support: Windows (SAPI), Linux/Mac (espeak/festival)
For production use, consider integrating with cloud TTS services like Google Text-to-Speech API or Amazon Polly
File Structure
pdf-to-audio-api/
├── src/main/java/com/example/pdfaudio/
│   ├── PdfToAudioApiApplication.java
│   ├── controller/
│   │   └── PdfToAudioController.java
│   └── service/
│       ├── FileStorageService.java
│       ├── PdfTextExtractionService.java                                                                                
│       ├── TextSummarizationService.java
│       └── TextToSpeechService.java
├── src/main/resources/
│   └── application.properties
├── audio-files/          # Generated audio files stored here
└── pom.xml
