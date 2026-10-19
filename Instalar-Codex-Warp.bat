@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Instalador ChatGPT Codex para Warp

echo ==============================================================================
echo     Iniciando Asistente de Integracion: ChatGPT Codex en Warp Terminal
echo ==============================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Instalar-Codex-Warp.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] El instalador finalizo con codigo de salida: %ERRORLEVEL%
)

echo.
echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
