@echo off
chcp 65001 >nul
title Asistente de Instalación - ChatGPT Codex en Warp Terminal

:: Asegurar que nos situamos en la carpeta del script
cd /d "%~dp0"

echo ==============================================================================
echo     Iniciando Asistente de Integración: ChatGPT Codex en Warp Terminal
echo ==============================================================================
echo.

:: Ejecutar el script PowerShell con bypass de ejecución de scripts
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Instalar-Codex-Warp.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] El instalador finalizó con código de salida: %ERRORLEVEL%
)

echo.
echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
