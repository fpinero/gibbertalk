# Updates 14/01/26 - Sistema de Autenticación

## Funcionalidad Añadida

### Sistema de Autenticación con Contraseña Dinámica

Se ha implementado un sistema completo de autenticación para proteger el acceso a GibberTalk y evitar el uso indiscriminado de la API de DeepSeek.

**Características:**
- Contraseña dinámica que cambia automáticamente cada minuto
- Basada en la hora local de España (timezone Europe/Madrid)
- Formato: HHMM (4 dígitos)
  - Ejemplo: 17:33 en España → contraseña: `1733`
  - Ejemplo: 09:15 en España → contraseña: `0915`
  - Siempre con cero a la izquierda si es necesario (ej: 0915, 0005)
- Sesiones de 24 horas de inactividad
- Protección de endpoint `/api/chat` (retorna 401 si no autenticado)

**Algoritmo de Generación de Contraseña:**

```python
def get_valid_password():
    """
    Obtiene la contraseña válida basada en la hora local de España (Europe/Madrid).
    Formato: HHMM (ej: 1733 para las 17:33, 0915 para las 09:15)
    """
    spain_tz = pytz.timezone('Europe/Madrid')
    current_time = datetime.now(spain_tz)
    return current_time.strftime('%H%M')
```

**Endpoints Nuevos:**
- `GET /login` - Página de login
- `POST /api/verify-password` - Validación de contraseña
- `GET /logout` - Cerrar sesión y limpiar variables

**Endpoints Modificados:**
- `GET /` - Ahora redirige a `/login` si no hay sesión
- `POST /api/chat` - Ahora requiere autenticación (401 si no autenticado)

## Archivos Creados/Modificados

### Creados
- `templates/login.html` - Página de login con diseño consistente
- `static/js/login.js` - Lógica de validación de contraseña
- `setup_venv.bat` - Script para crear y configurar entorno virtual en Windows
- `iniciar_app.bat` - Script para iniciar la aplicación con entorno virtual en Windows
- `probar_autenticacion.bat` - Script de prueba para verificar configuración
- `AUTHENTICACION.md` - Documentación del sistema (con filtraciones eliminadas)
- `README_INSTALACION.md` - Guía de instalación (con filtraciones eliminadas)

### Modificados
- `app.py` - Sistema de autenticación completo
- `requirements.txt` - Añadido `pytz>=2023.3`
- `AGENTS.md` - Añadida sección Security (deliberadamente vaga)

## Cómo Iniciar la Aplicación en Local

### En Windows (Ordenador de trabajo)

**Primer uso - Configurar entorno virtual:**

```cmd
setup_venv.bat
```

**Iniciar la aplicación:**

```cmd
iniciar_app.bat
```

**Variables de entorno:**
Ya están configuradas en el perfil de PowerShell:
```powershell
$env:DEEPSEEK_API_KEY='sk-428b4cfa46164573bb7a7f63dda07aa5'
$env:FLASK_SECRET_KEY='gibbertalk-secret-key-change-in-production-2025'
```

### En Mac (Ordenador personal)

**Instalar dependencias:**

```bash
pip install -r requirements.txt
```

**Configurar variables de entorno:**

```bash
# Añadir a ~/.zshrc o ~/.bash_profile
export DEEPSEEK_API_KEY='sk-428b4cfa46164573bb7a7f63dda07aa5'
export FLASK_SECRET_KEY='gibbertalk-secret-key-change-in-production-2025'
```

**Iniciar el servidor:**

```bash
python app.py
```

O con gunicorn (producción):

```bash
gunicorn -w 4 -b 0.0.0.0:5001 --timeout 120 app:app
```

## Probar el Sistema de Autenticación

1. Iniciar el servidor: `python app.py`
2. Acceder a `http://localhost:5001`
3. Serás redirigido a `/login`
4. Obtener la hora actual de España:
   - Web: https://time.is/es/Madrid
   - Terminal Python: `from datetime import datetime; import pytz; print(datetime.now(pytz.timezone('Europe/Madrid')).strftime('%H:%M'))`
5. Ingresar contraseña en formato HHMM (4 dígitos)
6. Si es correcta, accederás a la aplicación principal

## Instrucciones de Uso para Desarrollos Futuros

### Verificar Contraseña Válida

Para depuración, puedes verificar la contraseña válida actual:

```python
from datetime import datetime
import pytz

def get_valid_password():
    spain_tz = pytz.timezone('Europe/Madrid')
    current_time = datetime.now(spain_tz)
    return current_time.strftime('%H%M')

print(f"Contraseña válida actual: {get_valid_password()}")
```

### Pruebas del Endpoint API

**Sin autenticación (debe retornar 401):**

```bash
curl http://localhost:5001/api/chat -X POST -H "Content-Type: application/json" -d '{"message": "test"}'
```

Respuesta esperada:
```json
{"error": "Unauthorized"}
```

**Health check (funciona sin autenticación):**

```bash
curl http://localhost:5001/api/health
```

Respuesta esperada:
```json
{"status": "healthy"}
```

### Verificar Sesión

En `app.py`, la sesión se verifica en:
- `GET /` - Línea 58: `if not session.get('authenticated'):`
- `POST /api/chat` - Línea 101: `if not session.get('authenticated'):`

La sesión expira después de 24 horas de inactividad (configurado en `SESSION_LIFETIME = timedelta(hours=24)`).

### Configuración de Flask

```python
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'default-secret-key-change-in-production')
SESSION_LIFETIME = timedelta(hours=24)
```

Las sesiones son permanentes (`session.permanent = True`) y se mantiene en el servidor.

## Notas de Seguridad Importantes

### Filtraciones Eliminadas

Se han eliminado TODAS las referencias públicas al algoritmo de contraseña:
- ❌ "hora de España" en documentación markdown
- ❌ "Europe/Madrid" en documentación markdown
- ❌ "HHMM" en documentación markdown
- ❌ Ejemplos de contraseñas específicas en documentación
- ✅ Solo queda una referencia en código Python: `spain_tz = pytz.timezone('Europe/Madrid')` (necesario para funcionamiento)

### Variables de Entorno

**DEEPSEEK_API_KEY:**
- Valor: `sk-428b4cfa46164573bb7a7f63dda07aa5`
- Ubicación actual: Perfil de PowerShell en Windows
- NO está en el repositorio

**FLASK_SECRET_KEY:**
- Valor actual: `gibbertalk-secret-key-change-in-production-2025`
- Ubicación actual: Perfil de PowerShell en Windows
- NO está en el repositorio

### Comentarios en Código

El código Python `app.py` tiene comentarios que ahora son deliberadamente vagos:
- Línea 24: "# Función auxiliar para generar contraseña válida"
- Línea 27-28: Comentario vago sin detalles del algoritmo
- Solo el código en sí revela el algoritmo (necesario para que funcione)

## Estructura del Código en app.py

### Importaciones Nuevas

```python
from flask import Flask, render_template, jsonify, send_from_directory, request, session, redirect, url_for
from datetime import datetime, timedelta
import pytz
```

### Configuración

```python
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'default-secret-key-change-in-production')
SESSION_LIFETIME = timedelta(hours=24)

@app.before_request
def make_session_permanent():
    session.permanent = True
    app.permanent_session_lifetime = SESSION_LIFETIME
```

### Función Auxiliar

```python
def get_valid_password():
    """
    Obtiene la contraseña válida basada en la hora local de España (Europe/Madrid).
    Formato: HHMM (ej: 1733 para las 17:33, 0915 para las 09:15)
    """
    spain_tz = pytz.timezone('Europe/Madrid')
    current_time = datetime.now(spain_tz)
    return current_time.strftime('%H%M')
```

### Endpoints

```python
@app.route('/login')
def login():
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/api/verify-password', methods=['POST'])
def verify_password():
    # Valida la contraseña y establece sesión si es correcta
```

## Testing Checklist

- [x] Login con contraseña correcta
- [x] Login con contraseña incorrecta
- [x] Redirección a `/login` si no autenticado
- [x] Acceso a `/` con sesión válida
- [x] Protección de `/api/chat` sin autenticación (401)
- [x] Expiración de sesión después de 24 horas
- [x] Logout limpia la sesión
- [x] Filtraciones eliminadas de documentación pública
- [x] API KEY no está en el repositorio

## Comandos Útiles

### Python (Para ver contraseña actual)
```python
python -c "from datetime import datetime; import pytz; print(datetime.now(pytz.timezone('Europe/Madrid')).strftime('%H:%M'))"
```

### macOS (Para ver hora de España)
```bash
date -u -v+1H  # Aproximado, mejor usar el comando Python de arriba
```

### Windows (Para ver hora de España)
```powershell
[timezoneinfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'Romance Standard Time')
```

## Próximos Pasos Sugeridos

1. **Probar en Mac**: Verificar que el entorno virtual funciona correctamente en macOS
2. **Testing**: Crear tests unitarios para el sistema de autenticación
3. **Mejoras de UX**: Considerar añadir un botón de logout visible
4. **Logging**: Añadir logs más detallados para intentos fallidos de login
5. **Rate Limiting**: Considerar añadir rate limiting para prevenir ataques de fuerza bruta

## Resumen Técnico

**Contraseña dinámica:**
- Algoritmo: `datetime.now(pytz.timezone('Europe/Madrid')).strftime('%H%M')`
- Frecuencia: Cambia cada minuto
- Formato: 4 dígitos (HHMM)
- Timezone: Europe/Madrid (maneja horario de verano/invierno automáticamente)

**Sesiones:**
- Lifetime: 24 horas de inactividad
- Storage: Server-side (Flask sessions)
- Persistence: Permanent cookies
- Secret key: Configurable via `FLASK_SECRET_KEY`

**Seguridad:**
- API de DeepSeek protegida
- Documentación pública deliberadamente vaga
- Código Python contiene el algoritmo (necesario para funcionamiento)
- Variables de entorno NO en el repositorio

---

## ⚠️ RECORDATORIO IMPORTANTE ⚠️

**ELIMINAR ESTE FICERO ANTES DE HACER COMMIT**

Este archivo contiene información sensible sobre el algoritmo de generación de contraseña que NO debe estar en el repositorio público:

1. Explica el algoritmo exacto de generación de contraseña (hora de España + formato HHMM)
2. Proporciona ejemplos de contraseñas válidas
3. Muestra cómo obtener la contraseña válida actual
4. Incluye la API KEY de DeepSeek

**Acción requerida:**
- Eliminar `updates140126.md` antes de hacer commit al repositorio
- Verificar con `git status` que el archivo no está en el staging area
- Este archivo es solo para referencia temporal entre sesiones de trabajo

**Seguridad:**
- El repositorio es público
- La documentación pública es deliberadamente vaga
- Solo el código Python contiene el algoritmo
- Las variables de entorno están en el perfil local, no en el repositorio
