# GibberTalk - Guía de Instalación y Uso

## Primer Uso - Configuración del Entorno Virtual

### 1. Crear y configurar el entorno virtual

En Windows, ejecuta:

```cmd
setup_venv.bat
```

Este script:
- Crea el entorno virtual `.venv` si no existe
- Activa el entorno virtual
- Instala todas las dependencias necesarias

### 2. Iniciar la aplicación

Una vez configurado el entorno virtual, ejecuta:

```cmd
iniciar_app.bat
```

El servidor se iniciará en `http://localhost:5001`

## Flujo de Autenticación

1. Accede a `http://localhost:5001`
2. Serás redirigido a la página de login
3. Ingresa la contraseña de acceso (cambia periódicamente)
4. Si la contraseña es correcta, accederás a la aplicación
5. La sesión expira después de 24 horas de inactividad

## Variables de Entorno

Las variables de entorno están configuradas en tu perfil de PowerShell (`$PROFILE`):

```powershell
$env:DEEPSEEK_API_KEY='tu-api-key-de-deepseek'
$env:FLASK_SECRET_KEY='tu-secret-key-para-sesiones'
```

**⚠️ IMPORTANTE**: Configura las variables de entorno en tu perfil de PowerShell antes de iniciar la aplicación.

## Notas de Seguridad

- La contraseña cambia periódicamente
- La sesión expira después de 24 horas de inactividad
- El endpoint `/api/chat` requiere autenticación (retorna 401 si no autenticado)

## Scripts Disponibles

- **setup_venv.bat**: Crea y configura el entorno virtual
- **iniciar_app.bat**: Inicia la aplicación con el entorno virtual
- **probar_autenticacion.bat**: Verifica que todo esté configurado correctamente

## Resumen de Archivos del Sistema de Autenticación

### Archivos Creados
- `templates/login.html` - Página de login
- `static/js/login.js` - Lógica de autenticación
- `setup_venv.bat` - Configuración del entorno virtual
- `iniciar_app.bat` - Inicio de la aplicación
- `probar_autenticacion.bat` - Script de prueba
- `AUTHENTICACION.md` - Documentación detallada

### Archivos Modificados
- `app.py` - Sistema de autenticación completo
- `requirements.txt` - Añadido `pytz>=2023.3`
- `AGENTS.md` - Añadida sección Security

## Problemas Comunes

### Error: "No se pudo activar el entorno virtual"
- Asegúrate de ejecutar `setup_venv.bat` primero
- Verifica que Python esté instalado: `python --version`

### Error: "La variable de entorno DEEPSEEK_API_KEY no está configurada"
- Verifica que las variables están en tu perfil de PowerShell
- Reinicia PowerShell para recargar el perfil

### Contraseña incorrecta
- Asegúrate de ingresar la contraseña válida actual
- Intenta de nuevo si cambió el periodo de validez

## Soporte

Para más información, consulta:
- `AUTHENTICACION.md` - Documentación completa del sistema de autenticación
- `AGENTS.md` - Guía para desarrolladores
- `README_GESTION_APP.md` - Gestión de la aplicación
