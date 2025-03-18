# GibberSound

![GibberSound Logo](static/favicon/favicon-32x32.png)

## Versión preliminar disponible

**¡Ya puedes probar GibberSound en línea!** Visita [https://gibbersound.com](https://gibbersound.com) para experimentar con la versión preliminar de la aplicación.

## Descripción

GibberSound es una aplicación web que utiliza el protocolo ggwave para convertir texto en señales de audio, similar a cómo los sistemas de IA se comunican entre sí. Esta aplicación permite a los usuarios enviar mensajes codificados a través de sonido, creando una forma única e innovadora de comunicación.

## Características

- Conversión de texto a señales de audio
- Interfaz de usuario moderna y responsive
- Comunicación basada en el protocolo ggwave
- Diseño minimalista y fácil de usar
- Integración con DeepSeek AI para responder preguntas de los usuarios
- Gestión robusta de errores y mecanismos de fallback
- Sistema de visualización de audio en tiempo real

## Tecnologías utilizadas

- **Frontend**: HTML5, CSS3, JavaScript
- **Backend**: Python 3.12 con Flask
- **Servidor de producción**: Gunicorn con múltiples workers
- **Comunicación de audio**: Biblioteca ggwave.js
- **IA**: API de DeepSeek para procesamiento de lenguaje natural
- **Estilos**: CSS personalizado con variables para fácil personalización
- **Iconos**: Material Design Icons

## Estructura del proyecto

```
gibbertalk/
├── app.py                 # Aplicación principal de Flask
├── start_app.sh           # Script para iniciar la aplicación con gunicorn
├── gestionar_app.sh       # Script para gestionar todos los aspectos de la aplicación
├── requirements.txt       # Dependencias de Python
├── static/                # Archivos estáticos
│   ├── css/               # Hojas de estilo
│   │   └── style.css      # Estilos principales
│   ├── favicon/           # Iconos de la aplicación
│   │   ├── favicon.ico
│   │   ├── favicon-16x16.png
│   │   ├── favicon-32x32.png
│   │   ├── apple-touch-icon.png
│   │   └── site.webmanifest
│   ├── sm/                # Source maps para JavaScript
│   └── js/                # Scripts de JavaScript
│       ├── ggwave.js      # Biblioteca para comunicación de audio
│       └── script.js      # Lógica principal de la aplicación
├── templates/             # Plantillas HTML
│   └── index.html         # Página principal
└── k8s/                   # Configuración para despliegue en Kubernetes (ver k8s/README.md)
```

## Instalación y ejecución local

### Requisitos previos

- Python 3.12 o superior
- pip (gestor de paquetes de Python)
- Gunicorn (para ejecución en modo producción)

### Pasos para la instalación

1. Clona este repositorio:
   ```bash
   git clone https://github.com/tu-usuario/gibbertalk.git
   cd gibbertalk
   ```

2. Crea un entorno virtual (opcional pero recomendado):
   ```bash
   python -m venv venv
   source venv/bin/activate  # En Windows: venv\Scripts\activate
   ```

3. Instala las dependencias:
   ```bash
   pip install -r requirements.txt
   ```

4. Configura la API KEY de DeepSeek:
   ```bash
   export DEEPSEEK_API_KEY='tu-api-key'
   ```

5. Ejecuta la aplicación (modo desarrollo):
   ```bash
   python app.py
   ```
   
   O en modo producción:
   ```bash
   ./start_app.sh
   ```

   También puedes usar el script de gestión para una experiencia más completa:
   ```bash
   ./gestionar_app.sh
   ```

6. Abre tu navegador y visita `http://localhost:5001`

## Gestión de la aplicación

GibberTalk incluye varios scripts para facilitar la gestión de la aplicación:

### Script `gestionar_app.sh`

Este script proporciona una interfaz completa para gestionar todos los aspectos de la aplicación:
- Verificar si la aplicación está en ejecución
- Iniciar la aplicación con gunicorn
- Detener la aplicación
- Reiniciar la aplicación
- Verificar el estado de salud de la API
- Ver y analizar los logs

Consulta [README_GESTION_APP.md](README_GESTION_APP.md) para más detalles.

### Script `start_app.sh`

Este script inicia la aplicación en modo producción usando gunicorn con múltiples workers para un mejor rendimiento y estabilidad.

## Características de resiliencia

GibberTalk incluye varias características para mejorar la resiliencia y robustez:

### Gestión de errores

- Verificación robusta del tipo de contenido en respuestas API
- Mensajes de error detallados con información de diagnóstico
- Captura y registro de excepciones para facilitar la depuración

### Mecanismo de fallback

La aplicación incluye un sistema de fallback para cuando el servidor principal no está disponible:
- Detección automática de problemas de conexión con el servidor
- Redirección transparente a un servidor local para pruebas y desarrollo
- Comprobación de salud de la API al iniciar

## Uso

1. Escribe un mensaje en el área de texto
2. Haz clic en el botón "Send"
3. La aplicación convertirá tu mensaje en una señal de audio
4. La respuesta de DeepSeek AI será recibida y también convertida en audio
5. Otros dispositivos con GibberSound pueden capturar y decodificar estas señales

## Contribución

Las contribuciones son bienvenidas. Para contribuir:

1. Haz un fork del repositorio
2. Crea una rama para tu característica (`git checkout -b feature/amazing-feature`)
3. Haz commit de tus cambios (`git commit -m 'Add some amazing feature'`)
4. Haz push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

## Despliegue

Para información sobre cómo desplegar la aplicación en Kubernetes, consulta la documentación en la carpeta [k8s](k8s/README.md).

## Contacto

Para cualquier consulta o comentario sobre la aplicación, puedes contactarnos en [gibbersoundapp@gmail.com](mailto:gibbersoundapp@gmail.com).

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles.

## Configuración de DeepSeek API en Kubernetes

Para utilizar la funcionalidad de DeepSeek API en el entorno de Kubernetes, sigue estos pasos:

1. **Genera el secreto con tu API KEY**:
   ```bash
   # Codifica tu API KEY en base64
   echo -n "tu-api-key-de-deepseek" | base64
   
   # Crea un archivo de secreto a partir de la plantilla
   cp k8s/deepseek-secret.template.yaml k8s/deepseek-secret.yaml
   
   # Edita el archivo y reemplaza BASE64_ENCODED_API_KEY_HERE con tu valor codificado
   nano k8s/deepseek-secret.yaml
   ```

2. **Aplica el secreto en Kubernetes**:
   ```bash
   kubectl apply -f k8s/deepseek-secret.yaml
   ```

3. **Actualiza el despliegue**:
   ```bash
   kubectl apply -f k8s/backend-deployment.yaml
   ```

⚠️ **IMPORTANTE**: El archivo `k8s/deepseek-secret.yaml` está incluido en `.gitignore` para evitar subir información sensible al repositorio. Nunca subas este archivo con tu API KEY real a Git.

---

© 2025 GibberSound - Proof of Concept
