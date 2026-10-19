@echo off
chcp 65001 >nul
title Iniciar ChatGPT Codex en Warp

:: Comprobar si Warp está instalado
set "WARP_EXE=C:\Program Files\Warp\warp.exe"
if not exist "%WARP_EXE%" (
    set "WARP_EXE=%LOCALAPPDATA%\Programs\Warp\warp.exe"
)

if exist "%WARP_EXE%" (
    echo Iniciando Warp Terminal...
    start "" "%WARP_EXE%"
) else (
    echo [INFO] Abriendo sesión interactiva de Codex en la consola actual...
    codex
)
