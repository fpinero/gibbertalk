# Sistema de Autenticación - GibberTalk

## Implementación Completada

Se ha implementado un sistema de autenticación con contraseña dinámica para proteger el acceso a la aplicación y evitar el uso indiscriminado de la API de DeepSeek.

## Características

- **Contraseña dinámica**: La contraseña cambia periódicamente
- **Sesión de 24 horas**: Una vez autenticado, la sesión expira después de 24 horas de inactividad
- **Protección de API**: El endpoint `/api/chat` requiere autenticación

## Cómo Probar en Windows

### 1. Instalar dependencias

```cmd
pip install -r requirements.txt
```

### 2. Configurar variables de entorno

```cmd
set DEEPSEEK_API_KEY=tu-api-key-de-deepseek
set FLASK_SECRET_KEY=tu-secret-key-para-sesiones-usa-algo-seguro
```

### 3. Iniciar el servidor

```cmd
python app.py
```

El servidor iniciará en `http://localhost:5001`

### 4. Probar el flujo de autenticación

1. Abre `http://localhost:5001` en tu navegador
2. Serás redirigido a la página de login
3. Ingresa la contraseña válida actual
4. Si la contraseña es correcta, accederás a la aplicación principal
5. Si es incorrecta, verás un mensaje de error

### 5. Probar protección del endpoint API

```cmd
curl http://localhost:5001/api/chat -X POST -H "Content-Type: application/json" -d "{\"message\": \"test\"}"
```

Deberías recibir: `{"error": "Unauthorized"}` (401)

## Archivos Modificados/Creados

### Modificados

- **app.py**: Añadido sistema de autenticación
  - Nuevas importaciones: `session`, `redirect`, `url_for`, `datetime`, `timedelta`, `pytz`
  - Configuración de `app.secret_key` y sesiones permanentes
  - Función `get_valid_password()` para generar contraseña válida
  - Endpoint `/api/verify-password` para validar contraseña
  - Endpoint `/login` para página de login
  - Endpoint `/logout` para cerrar sesión
  - Protección de `/` y `/api/chat`

- **requirements.txt**: Añadido `pytz>=2023.3`

- **AGENTS.md**: Añadida sección Security/Seguridad (deliberadamente vaga)

### Creados

- **templates/login.html**: Página de login
  - Diseño consistente con el resto de la aplicación
  - Formulario de contraseña (4 dígitos)
  - Mensajes de error/success
  - Integración con tema claro/oscuro

- **static/js/login.js**: Lógica de login
  - Validación de contraseña
  - Envío al endpoint `/api/verify-password`
  - Redirección tras login exitoso
  - Mensajes de error genéricos

- **probar_autenticacion.bat**: Script de prueba para Windows

## Notas Técnicas

- **Expiración**: 24 horas de inactividad
- **Storage**: Sesiones almacenadas en el servidor (Flask sessions)
- **CORS**: No afecta al sistema de autenticación
