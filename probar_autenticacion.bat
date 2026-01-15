@echo off
REM Script de prueba para el sistema de autenticación en Windows
REM Requiere: python, pip y las dependencias instaladas

echo ========================================
echo Prueba del Sistema de Autenticacion
echo GibberTalk - Login con Password Dinamico
echo ========================================
echo.

echo [1/4] Verificando dependencias...
python -m py_compile app.py
if %errorlevel% neq 0 (
    echo ERROR: Sintaxis incorrecta en app.py
    pause
    exit /b 1
)
echo OK: Sintaxis de app.py correcta
echo.

echo [2/4] Verificando archivos creados...
if not exist "templates\login.html" (
    echo ERROR: No existe templates\login.html
    pause
    exit /b 1
)
echo OK: templates\login.html existe

if not exist "static\js\login.js" (
    echo ERROR: No existe static\js\login.js
    pause
    exit /b 1
)
echo OK: static\js\login.js existe
echo.

echo [3/4] Verificando dependencia pytz...
python -c "import pytz; print('OK: pytz instalado, version:', pytz.__version__)"
if %errorlevel% neq 0 (
    echo ERROR: pytz no esta instalado
    echo Instalar con: pip install pytz
    pause
    exit /b 1
)
echo.

echo [4/4] Preparando entorno para iniciar servidor...
echo Para iniciar el servidor en Windows, ejecuta:
echo   set DEEPSEEK_API_KEY=tu-api-key-aqui
echo   set FLASK_SECRET_KEY=tu-secret-key-aqui
echo   python app.py
echo.
 echo Para probar la autenticacion:
 echo   1. El servidor iniciara en http://localhost:5001
 echo   2. Al acceder, sera redirigido a /login
 echo   3. Ingresa la password de acceso (cambia periodicamente)
 echo.
echo ========================================
echo Verificacion completada exitosamente!
echo ========================================
pause
