@echo off
echo Running PDF to Audio API without Maven...
echo.

set JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.16.8-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%

echo Java version:
java -version
echo.

echo Note: This project requires Maven for proper dependency management.
echo.
echo Quick Solutions:
echo.
echo 1. Download Maven manually:
echo    - Go to: https://maven.apache.org/download.cgi
echo    - Download apache-maven-3.9.5-bin.zip
echo    - Extract to C:\apache-maven-3.9.5
echo    - Add C:\apache-maven-3.9.5\bin to your PATH
echo.
echo 2. Use an IDE with built-in Maven:
echo    - IntelliJ IDEA Community (free)
echo    - Visual Studio Code with Java extensions
echo    - NetBeans
echo.
echo 3. Install Maven via Chocolatey:
echo    - Install Chocolatey: https://chocolatey.org/install
echo    - Run: choco install maven
echo.

REM Try to use existing compiled classes if available
if exist "target\classes\com\example\pdfaudio\PdfToAudioApiApplication.class" (
    echo Found compiled classes, attempting to run...
    echo.
    
    REM Set classpath for Spring Boot
    set CLASSPATH=target\classes;target\dependency\*
    
    REM Try to run the application
    java -cp "%CLASSPATH%" com.example.pdfaudio.PdfToAudioApiApplication
) else (
    echo No compiled classes found. Please install Maven first.
    echo.
)

pause
