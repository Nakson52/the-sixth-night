@echo off
cd /d "%~dp0"
echo WARNING: Game code sync will REPLACE sources of matching named scripts in Studio.
echo FIRST save a .rbxl backup. Disable all Chapter1_FirstBeat scripts.
choice /m "Have you already done a backup and disabled legacy scripts"
if errorlevel 2 exit /b 0
where rojo >nul 2>nul
if errorlevel 1 (
  echo Rojo CLI not found. Use VS Code Rojo menu and choose game.project.json.
  pause
  exit /b 1
)
rojo serve game.project.json
pause
