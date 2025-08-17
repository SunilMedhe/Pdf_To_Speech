@echo off
echo Fixing Eclipse WebView2 Issues...
echo.

echo Step 1: Downloading Microsoft Edge WebView2 Runtime...
echo Please download and install from: 
echo https://developer.microsoft.com/microsoft-edge/webview2/
echo.
echo OR run this PowerShell command as Administrator:
echo winget install Microsoft.EdgeWebView2Runtime
echo.

echo Step 2: Clear Eclipse workspace metadata...
if exist ".metadata\.plugins\org.eclipse.core.runtime\.settings" (
    echo Clearing Eclipse runtime settings...
    del /s /q ".metadata\.plugins\org.eclipse.core.runtime\.settings\*"
    echo Cleared Eclipse settings
) else (
    echo No Eclipse workspace metadata found in current directory
)

echo.
echo Step 3: Set Eclipse JVM arguments...
echo Add these lines to your eclipse.ini file:
echo -Dorg.eclipse.swt.browser.DefaultType=webkit
echo -Dorg.eclipse.swt.browser.UseWebKitGTK=true
echo.

echo Step 4: Alternative - Disable browser hover controls...
echo In Eclipse: Window ^> Preferences ^> General ^> Editors ^> Text Editors
echo Uncheck "Show information affordances"
echo.

pause
