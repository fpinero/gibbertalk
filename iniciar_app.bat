@echo off
REM Script para iniciar GibberTalk en Windows con entorno virtual

echo ========================================
echo Iniciando GibberTalk...
echo ========================================
echo.

REM Activar entorno virtual
if exist ".venv\Scripts\activate.bat" (
    call .venv\Scripts\activate.bat
) else (
    echo ERROR: No existe el entorno virtual
    echo Ejecuta setup_venv.bat primero
    pause
    exit /b 1
)

echo.
echo Variables de entorno cargadas desde tu perfil de PowerShell:
echo - DEEPSEEK_API_KEY: [CONFIGURADA]
echo - FLASK_SECRET_KEY: [CONFIGURADA]
echo.
echo El servidor se iniciara en: http://localhost:5001
echo La password de acceso cambia periodicamente
echo Presiona Ctrl+C para detener el servidor
echo.

REM Iniciar la aplicación
python app.py

pause
