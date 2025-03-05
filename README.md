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

## Tecnologías utilizadas

- **Frontend**: HTML5, CSS3, JavaScript
- **Backend**: Python 3.12 con Flask
- **Comunicación de audio**: Biblioteca ggwave.js
- **Estilos**: CSS personalizado con variables para fácil personalización
- **Iconos**: Material Design Icons

## Estructura del proyecto

```
gibbertalk/
├── app.py                 # Aplicación principal de Flask
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

4. Ejecuta la aplicación:
   ```bash
   python app.py
   ```

5. Abre tu navegador y visita `http://localhost:5001`

## Uso

1. Escribe un mensaje en el área de texto
2. Haz clic en el botón "Send"
3. La aplicación convertirá tu mensaje en una señal de audio
4. Otros dispositivos con GibberSound pueden capturar y decodificar esta señal

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
