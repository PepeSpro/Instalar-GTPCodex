# Integracion de ChatGPT Codex en Warp Terminal

Este paquete proporciona un instalador **100% portable y automatizado para Windows** para integrar el agente de codigo oficial de OpenAI (**ChatGPT Codex CLI**) dentro de **Warp Terminal**.

---

## 🚀 Como Usarlo en Windows

1. Haz doble clic en el archivo:
   ```text
   Instalar-Codex-Warp.bat
   ```
2. El asistente interactivo se encargara automaticamente de:
   - **Comprobar Warp Terminal:** Si no lo tienes, te ofrecera descargarlo e instalarlo con un solo clic.
   - **Comprobar Node.js y npm:** Verifica la presencia de Node.js (v18+) e instala la version LTS automaticamente si hace falta.
   - **Configurar compatibilidad en Windows:** Ajusta la directiva de PowerShell (`RemoteSigned`) y crea un alias de PowerShell para que puedas escribir `codex` directamente desde Warp sin bloqueos por politicas de ejecucion.
   - **Instalar OpenAI Codex CLI:** Descarga e instala globalmente el paquete oficial `@openai/codex`.
   - **Instalar el Plugin de Warp para Codex (`warp@codex-warp`):** Conecta las capacidades de Warp (notificaciones nativas de agente, vertical tabs, revision de codigo y atajos como `Ctrl+G`).
   - **Asistente de Autenticacion:** Te permite elegir entre:
     - **Opcion 1:** Iniciar sesion con tu cuenta de ChatGPT (Plus, Pro, Team o Enterprise) via navegador.
     - **Opcion 2:** Introducir tu clave de API de OpenAI (`sk-...`), la cual se guardara de forma persistente en las variables de entorno de tu usuario.
     - **Opcion 3:** Omitir y autenticar mas tarde.

---

## 💻 Como Trabajar con Codex en Warp

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
4. Pidele al agente lo que necesitas en lenguaje natural (ej: *"crea una funcion para validar emails en utils.py"*).

### Atajos y funciones integradas en Warp:
- **`Ctrl + G`**: Abre el editor de prompts enriquecido de Warp para redactar instrucciones complejas o multilinea.
- **Notificaciones nativas**: Warp te notificara en el escritorio cuando Codex complete un trabajo largo o requiera tu aprobacion.
- **Revision de codigo**: Envia comentarios y feedback linea a linea directamente a Codex desde el panel de Warp.

---

## 📂 Archivos Incluidos

- [Instalar-Codex-Warp.bat](file:///E:/GDrive/Instalador%20GTP%20Codex/Instalar-Codex-Warp.bat): Lanzador universal compatible con doble clic en Windows.
- [Instalar-Codex-Warp.ps1](file:///E:/GDrive/Instalador%20GTP%20Codex/Instalar-Codex-Warp.ps1): Script modular de PowerShell con la logica de instalacion y configuracion.
- [Iniciar-Codex-Warp.bat](file:///E:/GDrive/Instalador%20GTP%20Codex/Iniciar-Codex-Warp.bat): Acceso rapido para abrir Warp.
- [README.md](file:///E:/GDrive/Instalador%20GTP%20Codex/README.md): Esta guia de referencia.
