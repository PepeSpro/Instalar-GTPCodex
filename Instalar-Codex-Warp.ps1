#Requires -Version 5.1
<#
.SYNOPSIS
    Asistente interactivo y portable para integrar OpenAI ChatGPT Codex en Warp Terminal.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Instalador de ChatGPT Codex para Warp Terminal"

function Show-Header {
    Clear-Host
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "          ASISTENTE DE INTEGRACIÓN: CHATGPT CODEX EN WARP TERMINAL             " -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " Este programa verifica, descarga y configura todo lo necesario para usar       " -ForegroundColor Gray
    Write-Host " el agente OpenAI Codex dentro de tu terminal Warp en Windows de forma nativa.   " -ForegroundColor Gray
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step ([string]$step, [string]$message) {
    Write-Host "[$step] " -NoNewline -ForegroundColor Yellow
    Write-Host $message -ForegroundColor White
}

function Write-Success ([string]$message) {
    Write-Host "  [OK] " -NoNewline -ForegroundColor Green
    Write-Host $message -ForegroundColor White
}

function Write-Info ([string]$message) {
    Write-Host "  [i] " -NoNewline -ForegroundColor Cyan
    Write-Host $message -ForegroundColor Gray
}

function Write-Warn ([string]$message) {
    Write-Host "  [!] " -NoNewline -ForegroundColor Yellow
    Write-Host $message -ForegroundColor Yellow
}

function Write-ErrorMsg ([string]$message) {
    Write-Host "  [X] " -NoNewline -ForegroundColor Red
    Write-Host $message -ForegroundColor Red
}

function Refresh-EnvPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:PATH = "$userPath;$machinePath"
}

Show-Header

# ------------------------------------------------------------------------------
# PASO 1: Comprobar instalación de Warp Terminal
# ------------------------------------------------------------------------------
Write-Step "1/5" "Comprobando Warp Terminal..."
$warpPaths = @(
    "C:\Program Files\Warp\warp.exe",
    "$env:LOCALAPPDATA\Programs\Warp\warp.exe",
    "$env:ProgramFiles\Warp\warp.exe"
)

$warpExe = $null
foreach ($p in $warpPaths) {
    if (Test-Path $p) {
        $warpExe = $p
        break
    }
}

if (-not $warpExe) {
    $warpCmd = Get-Command warp -ErrorAction SilentlyContinue
    if ($warpCmd) { $warpExe = $warpCmd.Source }
}

if ($warpExe) {
    Write-Success "Warp Terminal encontrado en: $warpExe"
} else {
    Write-Warn "Warp Terminal no se encuentra instalado en las rutas habituales."
    $instalarWarp = Read-Host "¿Deseas descargar e instalar Warp Terminal ahora mediante winget? (S/N) [Por defecto: S]"
    if ($instalarWarp -eq "" -or $instalarWarp -imatch "^(s|y|si|yes)$") {
        Write-Info "Descargando e instalando Warp..."
        winget install Warp.Warp --silent --accept-package-agreements --accept-source-agreements
        Refresh-EnvPath
        if (Test-Path "C:\Program Files\Warp\warp.exe") {
            $warpExe = "C:\Program Files\Warp\warp.exe"
            Write-Success "Warp Terminal instalado con éxito."
        } else {
            Write-Warn "La instalación finalizó. Puedes descargarlo manualmente desde: https://www.warp.dev"
        }
    } else {
        Write-Info "Omitiendo instalación de Warp. Asegúrate de instalarlo desde https://www.warp.dev"
    }
}
Write-Host ""

# ------------------------------------------------------------------------------
# PASO 2: Comprobar Node.js y npm
# ------------------------------------------------------------------------------
Write-Step "2/5" "Comprobando entorno Node.js y npm..."
Refresh-EnvPath
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue

if (-not $nodeCmd) {
    Write-Warn "Node.js no está instalado o no está en el PATH."
    $instalarNode = Read-Host "¿Deseas instalar Node.js LTS automáticamente con winget? (S/N) [Por defecto: S]"
    if ($instalarNode -eq "" -or $instalarNode -imatch "^(s|y|si|yes)$") {
        Write-Info "Instalando Node.js LTS..."
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements
        Refresh-EnvPath
        $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    }
}

if ($nodeCmd) {
    $nodeVer = & node --version
    Write-Success "Node.js detectado: $nodeVer"
} else {
    Write-ErrorMsg "No se pudo detectar Node.js. Por favor instálalo desde https://nodejs.org"
    Write-Host "Presiona cualquier tecla para salir..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Configurar ExecutionPolicy de PowerShell para el usuario actual para evitar errores con npm.ps1 / codex.ps1
$currPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currPolicy -in @("Undefined", "Restricted")) {
    Write-Info "Ajustando directiva de ejecución de scripts de PowerShell (CurrentUser -> RemoteSigned)..."
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue
}
Write-Host ""

# ------------------------------------------------------------------------------
# PASO 3: Instalar o actualizar OpenAI Codex CLI (@openai/codex)
# ------------------------------------------------------------------------------
Write-Step "3/5" "Comprobando OpenAI Codex CLI..."
$codexCmd = Get-Command codex -ErrorAction SilentlyContinue

if ($codexCmd) {
    try {
        $codexVer = & codex.cmd --version
        Write-Success "Codex CLI ya está instalado: $codexVer"
    } catch {
        Write-Warn "Codex detectado pero se procederá a reinstalar/actualizar."
        $codexCmd = $null
    }
}

if (-not $codexCmd) {
    Write-Info "Instalando '@openai/codex' globalmente mediante npm..."
    cmd.exe /c "npm.cmd install -g @openai/codex"
    Refresh-EnvPath
    $codexCmd = Get-Command codex -ErrorAction SilentlyContinue
    if ($codexCmd) {
        $codexVer = & codex.cmd --version
        Write-Success "Codex CLI instalado correctamente: $codexVer"
    } else {
        Write-ErrorMsg "Hubo un inconveniente al instalar @openai/codex. Verifica tu conexión o permisos."
    }
}
Write-Host ""

# ------------------------------------------------------------------------------
# PASO 4: Instalar y habilitar el Plugin de Warp para Codex
# ------------------------------------------------------------------------------
Write-Step "4/5" "Configurando la integración de Warp para Codex (Plugin)..."
Write-Info "Registrando repositorio de plugins de Warp..."
cmd.exe /c "npx.cmd -y @openai/codex plugin marketplace add warpdotdev/codex-warp" 2>$null

Write-Info "Instalando plugin 'warp@codex-warp'..."
cmd.exe /c "npx.cmd -y @openai/codex plugin add warp@codex-warp" 2>$null

Write-Success "Integración de Warp activada:"
Write-Info "- Notificaciones nativas de agente en Warp cuando Codex requiera aprobación o termine tareas."
Write-Info "- Soporte para editor de prompts enriquecido (Ctrl+G) y panel de revisión de código."
Write-Info "- Detección automática de pestañas y herramientas en Warp."
Write-Host ""

# ------------------------------------------------------------------------------
# PASO 5: Autenticación con ChatGPT / OpenAI
# ------------------------------------------------------------------------------
Write-Step "5/5" "Configuración de Autenticación de ChatGPT Codex"
Write-Host "Selecciona cómo deseas conectar tu cuenta:" -ForegroundColor White
Write-Host "  [1] Iniciar sesión con cuenta de ChatGPT (Plus, Pro, Team o Enterprise - Vía navegador)" -ForegroundColor Green
Write-Host "  [2] Configurar una API Key de OpenAI (sk-...)" -ForegroundColor Yellow
Write-Host "  [3] Omitir por ahora (ya he iniciado sesión o lo haré más tarde)" -ForegroundColor Gray
Write-Host ""

$opcionAuth = Read-Host "Ingresa tu opción (1, 2 o 3) [Por defecto: 1]"
if ($opcionAuth -eq "" -or $opcionAuth -eq "1") {
    Write-Info "Abriendo el navegador para autenticarte con tu cuenta de ChatGPT..."
    Write-Host "Sigue las instrucciones que aparecerán en la ventana:" -ForegroundColor Cyan
    cmd.exe /c "codex.cmd login"
    Write-Success "Proceso de autenticación completado."
} elseif ($opcionAuth -eq "2") {
    $apiKey = Read-Host "Pega tu OpenAI API Key (sk-...)"
    if ($apiKey -and $apiKey.Trim().Length -gt 10) {
        $apiKeyClean = $apiKey.Trim()
        [System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $apiKeyClean, "User")
        $env:OPENAI_API_KEY = $apiKeyClean
        cmd.exe /c "echo $apiKeyClean | codex.cmd login --with-api-key"
        Write-Success "API Key guardada en variables de entorno del usuario y configurada en Codex."
    } else {
        Write-Warn "Clave no válida o vacía. Puedes configurarla después con 'codex login --with-api-key'."
    }
} else {
    Write-Info "Paso de autenticación omitido. Cuando quieras, ejecuta 'codex login' en Warp."
}
Write-Host ""

# ------------------------------------------------------------------------------
# RESUMEN Y FINALIZACIÓN
# ------------------------------------------------------------------------------
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "                   ¡CONFIGURACIÓN COMPLETADA CON ÉXITO!                         " -ForegroundColor White
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "¿Cómo usar ChatGPT Codex en Warp?" -ForegroundColor Cyan
Write-Host "  1. Abre Warp Terminal." -ForegroundColor White
Write-Host "  2. Navega a la carpeta de tu proyecto (ej: cd C:\mi-proyecto)." -ForegroundColor White
Write-Host "  3. Escribe 'codex' y presiona Enter." -ForegroundColor Yellow
Write-Host "  4. Codex comenzará a funcionar como tu agente de desarrollo." -ForegroundColor White
Write-Host "     - Pulsa Ctrl+G en Warp para abrir el editor de prompts ampliado." -ForegroundColor Gray
Write-Host "     - Recibirás notificaciones en Warp cuando Codex complete tareas." -ForegroundColor Gray
Write-Host ""

$lanzarWarp = Read-Host "¿Deseas abrir Warp Terminal ahora? (S/N) [Por defecto: S]"
if ($lanzarWarp -eq "" -or $lanzarWarp -imatch "^(s|y|si|yes)$") {
    if ($warpExe -and (Test-Path $warpExe)) {
        Write-Info "Iniciando Warp Terminal..."
        Start-Process $warpExe
    } else {
        Start-Process "warp" -ErrorAction SilentlyContinue
    }
}

Write-Host "¡Listo! Puedes volver a ejecutar este instalador en cualquier momento." -ForegroundColor Green
