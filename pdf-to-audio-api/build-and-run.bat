@echo off
echo Building PDF to Audio API...
echo.

REM Check for Java installation
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 17 or higher from: https://openjdk.org/
    echo.
    echo Alternatively, download and install:
    echo - Oracle JDK: https://www.oracle.com/java/technologies/downloads/
    echo - OpenJDK: https://adoptium.net/
    echo - Microsoft OpenJDK: https://docs.microsoft.com/java/openjdk/
    echo.
    pause
    exit /b 1
)

echo Java installation found:
java -version
echo.

REM Try to use Maven if available
where mvn >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Maven found, using system Maven...
    mvn clean compile spring-boot:run
) else (
    echo Maven not found in PATH. Trying alternative methods...
    echo.
    
    REM Try Maven Wrapper
    if exist "mvnw.cmd" (
        echo Using Maven Wrapper...
        .\mvnw.cmd clean compile spring-boot:run
    ) else (
        echo No Maven Wrapper found.
        echo.
        echo Please install Maven or copy the Maven Wrapper files to this directory.
        echo.
        echo Install Maven:
        echo 1. Download Maven from: https://maven.apache.org/download.cgi
        echo 2. Extract to a folder (e.g., C:\apache-maven-3.9.5)
        echo 3. Add C:\apache-maven-3.9.5\bin to your PATH environment variable
        echo 4. Restart command prompt and try again
        echo.
        echo Or generate Maven Wrapper:
        echo 1. Install Maven first
        echo 2. Run: mvn wrapper:wrapper
        echo.
        pause
        exit /b 1
    )
)
