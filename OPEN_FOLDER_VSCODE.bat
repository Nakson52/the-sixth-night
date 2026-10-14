@echo off
cd /d "%~dp0"
where code >nul 2>nul
if errorlevel 1 (
  echo VS Code command not found in PATH.
  echo Open VS Code ^> File ^> Open Folder and select this folder.
  start "" "%~dp0"
  pause
) else (
  code "%~dp0"
)
