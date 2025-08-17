@echo off
echo Starting PDF to Audio API...
echo.
echo Prerequisites:
echo - Java 17 or higher must be installed
echo - Maven must be installed
echo.

REM Check if Java is installed
java -version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 17 or higher from: https://openjdk.org/
    pause
    exit /b 1
)

REM Check if Maven is installed
mvn -version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Maven is not installed or not in PATH
    echo Please install Maven from: https://maven.apache.org/download.cgi
    pause
    exit /b 1
)

echo All prerequisites are met. Starting the application...
echo.
echo The API will be available at: http://localhost:8080
echo Use Ctrl+C to stop the server
echo.

mvn spring-boot:run
