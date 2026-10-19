# Integración de ChatGPT Codex en Warp Terminal

Este paquete proporciona un instalador **100% portable y automatizado** para integrar el agente de código oficial de OpenAI (**ChatGPT Codex CLI**) dentro de **Warp Terminal** en Windows.

---

## 🚀 Cómo Usarlo

1. Haz doble clic en el archivo:
   ```text
   Instalar-Codex-Warp.bat
   ```
2. El asistente interactivo se encargará automáticamente de:
   - **Comprobar Warp Terminal:** Si no lo tienes, te ofrecerá descargarlo e instalarlo con un solo clic.
   - **Comprobar Node.js y npm:** Verifica la presencia de Node.js (v18+) e instala la versión LTS automáticamente si hace falta.
   - **Ajustar permisos de PowerShell:** Configura la directiva de ejecución (`RemoteSigned` en `CurrentUser`) para que los comandos globales de `codex` funcionen sin bloqueos.
   - **Instalar OpenAI Codex CLI:** Descarga e instala globalmente el paquete oficial `@openai/codex`.
   - **Instalar el Plugin de Warp para Codex (`warp@codex-warp`):** Conecta las capacidades de Warp (notificaciones nativas de agente, vertical tabs, revisión de código y atajos como `Ctrl+G`).
   - **Asistente de Autenticación:** Te permite elegir entre:
     - **Opción 1:** Iniciar sesión con tu cuenta de ChatGPT (Plus, Pro, Team o Enterprise) vía navegador.
     - **Opción 2:** Introducir tu clave de API de OpenAI (`sk-...`), la cual se guardará de forma persistente en las variables de entorno de tu usuario.
     - **Opción 3:** Omitir y autenticar más tarde.

---

## 💻 Cómo Trabajar con Codex en Warp

Una vez instalado, usarlo es tan sencillo como:

1. Abre **Warp Terminal**.
2. Navega al directorio de tu proyecto:
   ```powershell
   cd C:\ruta\a\tu\proyecto
   ```
3. Ejecuta el agente:
   ```powershell
   codex
   ```
4. Pídele al agente lo que necesitas en lenguaje natural (ej: *"crea una función para validar emails en utils.py"*).

### Atajos y funciones integradas en Warp:
- **`Ctrl + G`**: Abre el editor de prompts enriquecido de Warp para redactar instrucciones complejas o multilínea.
- **Notificaciones nativas**: Warp te notificará en el escritorio cuando Codex complete un trabajo largo o requiera tu aprobación.
- **Revisión de código**: Envía comentarios y feedback línea a línea directamente a Codex desde el panel de Warp.

---

## 📂 Archivos Incluidos

- [Instalar-Codex-Warp.bat](file:///C:/Users/iago_/Warp-ChatGPT-Codex/Instalar-Codex-Warp.bat): Lanzador universal compatible con doble clic.
- [Instalar-Codex-Warp.ps1](file:///C:/Users/iago_/Warp-ChatGPT-Codex/Instalar-Codex-Warp.ps1): Script modular de PowerShell con la lógica de verificación, descarga y configuración.
- [Iniciar-Codex-Warp.bat](file:///C:/Users/iago_/Warp-ChatGPT-Codex/Iniciar-Codex-Warp.bat): Acceso rápido para abrir Warp.
- [README.md](file:///C:/Users/iago_/Warp-ChatGPT-Codex/README.md): Esta guía de referencia.
