@echo off
title Half on Cloud - Obsidian Sync
cls
echo.
echo ================================================
echo   Half on Cloud Blog - Obsidian Sync
echo ================================================
echo.
echo This will sync your Obsidian notes to Hugo
echo Only files with Hugo front matter will be published
echo.

echo Scanning Obsidian vault...
powershell -ExecutionPolicy Bypass -File "sync-obsidian.ps1" -DryRun

echo.
set /p proceed="Proceed with sync? (y/n): "

if /i "%proceed%"=="y" (
    echo.
    echo Syncing files to Hugo...
    powershell -ExecutionPolicy Bypass -File "sync-obsidian.ps1"
    
    echo.
    set /p commit="Commit and push to GitHub for auto-deploy? (y/n): "
    
    if /i "%commit%"=="y" (
        echo.
        echo Publishing to GitHub...
        powershell -ExecutionPolicy Bypass -File "sync-obsidian.ps1" -AutoCommit
    )
) else (
    echo.
    echo Sync cancelled.
)

echo.
echo Press any key to exit...
pause >nul
