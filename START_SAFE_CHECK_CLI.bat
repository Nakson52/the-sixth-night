@echo off
cd /d "%~dp0"
where rojo >nul 2>nul
if errorlevel 1 (
  echo Rojo CLI not installed or not in PATH.
  echo Use VS Code extension Rojo: Open Menu instead.
  pause
  exit /b 1
)
rojo serve default.project.json
pause
