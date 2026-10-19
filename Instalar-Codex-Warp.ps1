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
    Write-Host "          ASISTENTE DE INTEGRACION: CHATGPT CODEX EN WARP TERMINAL             " -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " Este programa verifica, descarga y configura todo lo necesario para usar       " -ForegroundColor Gray
    Write-Host " el agente OpenAI Codex dentro de tu terminal Warp en Windows de forma nativa.   " -ForegroundColor Gray
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step ($step, $message) {
    Write-Host "[$step] " -NoNewline -ForegroundColor Yellow
    Write-Host $message -ForegroundColor White
}

function Write-Success ($message) {
    Write-Host "  [OK] " -NoNewline -ForegroundColor Green
    Write-Host $message -ForegroundColor White
}

function Write-Info ($message) {
    Write-Host "  [i] " -NoNewline -ForegroundColor Cyan
    Write-Host $message -ForegroundColor Gray
}

function Write-Warn ($message) {
    Write-Host "  [!] " -NoNewline -ForegroundColor Yellow
    Write-Host $message -ForegroundColor Yellow
}

function Write-ErrorMsg ($message) {
    Write-Host "  [X] " -NoNewline -ForegroundColor Red
    Write-Host $message -ForegroundColor Red
}

function Refresh-EnvPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $npmPath = Join-Path $env:APPDATA 'npm'
    $env:PATH = "$npmPath;$userPath;$machinePath"
}

Show-Header

# ------------------------------------------------------------------------------
# PASO 1: Comprobar instalacion de Warp Terminal
# ------------------------------------------------------------------------------
Write-Step "1/5" "Comprobando Warp Terminal..."
$warpPaths = @(
    "C:\Program Files\Warp\warp.exe",
    (Join-Path $env:LOCALAPPDATA "Programs\Warp\warp.exe"),
    (Join-Path $env:ProgramFiles "Warp\warp.exe")
)

$warpExe = $null
foreach ($p in $warpPaths) {
    if (Test-Path -LiteralPath $p) {
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
            Write-Success "Warp Terminal instalado con exito."
        } else {
            Write-Warn "La instalacion finalizo. Si no se inicio, puedes descargarlo de: https://www.warp.dev"
        }
    } else {
        Write-Info "Omitiendo instalacion de Warp. Asegurate de instalarlo desde https://www.warp.dev"
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
    Write-Warn "Node.js no esta instalado o no esta en el PATH."
    $instalarNode = Read-Host "¿Deseas instalar Node.js LTS automaticamente con winget? (S/N) [Por defecto: S]"
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
    Write-ErrorMsg "No se pudo detectar Node.js. Por favor instalalo desde https://nodejs.org"
    Write-Host "Presiona cualquier tecla para salir..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Configurar directiva de ejecucion de scripts para evitar bloqueos en PowerShell y Warp
Write-Info "Configurando compatibilidad de scripts en PowerShell para Windows..."
try {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -Confirm:$false -ErrorAction SilentlyContinue
    Write-Success "Directiva de ejecucion configurada (RemoteSigned para CurrentUser)."
} catch {
    Write-Warn "Nota sobre directiva: continuaremos usando lanzadores directos de comandos."
}

# Configurar alias en el perfil de PowerShell para invocar directamente codex.cmd sin restricciones
try {
    $profileDir = Split-Path $PROFILE
    if (-not (Test-Path -LiteralPath $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    $aliasSnippet = "`n# Integracion de ChatGPT Codex para Warp`nSet-Alias -Name codex -Value codex.cmd -Scope Global -ErrorAction SilentlyContinue`n"
    if (-not (Test-Path -LiteralPath $PROFILE)) {
        Set-Content -LiteralPath $PROFILE -Value $aliasSnippet -Encoding UTF8
    } else {
        $pContent = Get-Content -LiteralPath $PROFILE -Raw
        if ($pContent -notlike "*codex.cmd*") {
            Add-Content -LiteralPath $PROFILE -Value $aliasSnippet -Encoding UTF8
        }
    }
    Write-Success "Alias de comando 'codex' configurado en tu perfil de PowerShell."
} catch {
    Write-Info "Perfil de PowerShell omitido (no critico)."
}
Write-Host ""

# ------------------------------------------------------------------------------
# PASO 3: Instalar o actualizar OpenAI Codex CLI (@openai/codex)
# ------------------------------------------------------------------------------
Write-Step "3/5" "Comprobando OpenAI Codex CLI..."
Refresh-EnvPath
$codexInstalled = $false
try {
    $codexVer = & cmd.exe /c "codex.cmd --version" 2>$null
    if ($codexVer -match "codex") {
        $codexInstalled = $true
        Write-Success "Codex CLI ya esta instalado: $codexVer"
    }
} catch {
    $codexInstalled = $false
}

if (-not $codexInstalled) {
    Write-Info "Instalando '@openai/codex' globalmente mediante npm..."
    cmd.exe /c "npm.cmd install -g @openai/codex"
    Refresh-EnvPath
    try {
        $codexVer = & cmd.exe /c "codex.cmd --version" 2>$null
        Write-Success "Codex CLI instalado correctamente: $codexVer"
    } catch {
        Write-Warn "No se pudo verificar la version instalada. Asegurate de que npm funcione correctamente."
    }
}
Write-Host ""

# ------------------------------------------------------------------------------
# PASO 4: Instalar y habilitar el Plugin de Warp para Codex
# ------------------------------------------------------------------------------
Write-Step "4/5" "Configurando la integracion de Warp para Codex (Plugin)..."
Write-Info "Registrando repositorio de plugins de Warp..."
cmd.exe /c "npx.cmd -y @openai/codex plugin marketplace add warpdotdev/codex-warp" 2>$null

Write-Info "Instalando y activando plugin 'warp@codex-warp'..."
cmd.exe /c "npx.cmd -y @openai/codex plugin add warp@codex-warp" 2>$null

Write-Success "Integracion nativa de Warp activada:"
Write-Info "- Notificaciones de agente en Warp cuando Codex requiera aprobacion o termine tareas."
Write-Info "- Soporte para editor de prompts enriquecido (Ctrl+G) y panel de revision de codigo."
Write-Info "- Deteccion automatica de sesiones y pestañas verticales en Warp."
Write-Host ""

# ------------------------------------------------------------------------------
# PASO 5: Autenticacion con ChatGPT / OpenAI
# ------------------------------------------------------------------------------
Write-Step "5/5" "Configuracion de Autenticacion de ChatGPT Codex"
Write-Host "Selecciona como deseas conectar tu cuenta:" -ForegroundColor White
Write-Host "  [1] Iniciar sesion con cuenta de ChatGPT (Plus, Pro, Team o Enterprise - Via navegador)" -ForegroundColor Green
Write-Host "  [2] Configurar una API Key de OpenAI (sk-...)" -ForegroundColor Yellow
Write-Host "  [3] Omitir por ahora (ya he iniciado sesion o lo hare mas tarde)" -ForegroundColor Gray
Write-Host ""

$opcionAuth = Read-Host "Ingresa tu opcion (1, 2 o 3) [Por defecto: 1]"
if ($opcionAuth -eq "" -or $opcionAuth -eq "1") {
    Write-Info "Abriendo el navegador para autenticarte con tu cuenta de ChatGPT..."
    Write-Host "Sigue las instrucciones que apareceran en pantalla:" -ForegroundColor Cyan
    cmd.exe /c "codex.cmd login"
    Write-Success "Proceso de autenticacion completado."
} elseif ($opcionAuth -eq "2") {
    $apiKey = Read-Host "Pega tu OpenAI API Key (sk-...)"
    if ($apiKey -and $apiKey.Trim().Length -gt 10) {
        $apiKeyClean = $apiKey.Trim()
        [System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $apiKeyClean, "User")
        $env:OPENAI_API_KEY = $apiKeyClean
        cmd.exe /c "echo $apiKeyClean | codex.cmd login --with-api-key"
        Write-Success "API Key guardada en variables de entorno del usuario y configurada en Codex."
    } else {
        Write-Warn "Clave no valida o vacia. Puedes configurarla despues con 'codex login --with-api-key'."
    }
} else {
    Write-Info "Paso de autenticacion omitido. Cuando quieras, ejecuta 'codex login' en Warp."
}
Write-Host ""

# ------------------------------------------------------------------------------
# RESUMEN Y FINALIZACION
# ------------------------------------------------------------------------------
Write-Host "================================================================================" -ForegroundColor Green
Write-Host "                   CONFIGURACION COMPLETADA CON EXITO                           " -ForegroundColor White
Write-Host "================================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "¿Como usar ChatGPT Codex en Warp?" -ForegroundColor Cyan
Write-Host "  1. Abre Warp Terminal." -ForegroundColor White
Write-Host "  2. Navega a la carpeta de tu proyecto (ej: cd C:\mi-proyecto)." -ForegroundColor White
Write-Host "  3. Escribe 'codex' y presiona Enter." -ForegroundColor Yellow
Write-Host "  4. Codex comenzara a funcionar como tu agente de desarrollo." -ForegroundColor White
Write-Host "     - Pulsa Ctrl+G en Warp para abrir el editor de prompts ampliado." -ForegroundColor Gray
Write-Host "     - Recibiras notificaciones en Warp cuando Codex complete tareas." -ForegroundColor Gray
Write-Host ""

$lanzarWarp = Read-Host "¿Deseas abrir Warp Terminal ahora? (S/N) [Por defecto: S]"
if ($lanzarWarp -eq "" -or $lanzarWarp -imatch "^(s|y|si|yes)$") {
    if ($warpExe -and (Test-Path -LiteralPath $warpExe)) {
        Write-Info "Iniciando Warp Terminal..."
        Start-Process $warpExe
    } else {
        Start-Process "warp" -ErrorAction SilentlyContinue
    }
}

Write-Host "Listo. Puedes volver a ejecutar este instalador en cualquier momento." -ForegroundColor Green
