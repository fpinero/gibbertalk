@echo off
REM Script para activar el entorno virtual e iniciar GibberTalk en Windows

echo ========================================
echo GibberTalk - Entorno Virtual
echo ========================================
echo.

REM Verificar si existe .venv
if not exist ".venv" (
    echo [1/3] Creando entorno virtual...
    python -m venv .venv
    if %errorlevel% neq 0 (
        echo ERROR: No se pudo crear el entorno virtual
        pause
        exit /b 1
    )
    echo OK: Entorno virtual creado
    echo.
)

echo [2/3] Activando entorno virtual...
call .venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo ERROR: No se pudo activar el entorno virtual
    pause
    exit /b 1
)
echo OK: Entorno virtual activado
echo.

echo [3/3] Verificando dependencias...
python -m py_compile app.py
if %errorlevel% neq 0 (
    echo ERROR: Sintaxis incorrecta en app.py
    pause
    exit /b 1
)

REM Verificar si pytz está instalado
python -c "import pytz" 2>nul
if %errorlevel% neq 0 (
    echo Instalando dependencias...
    pip install -r requirements.txt
    if %errorlevel% neq 0 (
        echo ERROR: No se pudieron instalar las dependencias
        pause
        exit /b 1
    )
    echo OK: Dependencias instaladas
) else (
    echo OK: Dependencias ya instaladas
)
echo.

echo ========================================
echo Entorno listo para usar!
echo ========================================
echo.
echo Para iniciar la aplicacion, ejecuta:
echo   iniciar_app.bat
echo.
echo O manualmente:
echo   1. Activar: .venv\Scripts\activate.bat
echo   2. Iniciar: python app.py
echo.
pause
