@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Iniciar ChatGPT Codex en Warp

set "WARP_EXE=C:\Program Files\Warp\warp.exe"
if not exist "%WARP_EXE%" (
    set "WARP_EXE=%LOCALAPPDATA%\Programs\Warp\warp.exe"
)

if exist "%WARP_EXE%" (
    echo Iniciando Warp Terminal...
    start "" "%WARP_EXE%"
) else (
    echo [INFO] Abriendo sesion interactiva de Codex en la consola actual...
    call codex.cmd
)
