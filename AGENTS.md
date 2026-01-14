# AGENTS.md

This file provides guidance for agentic coding agents working on GibberSound.
Este archivo proporciona orientación para agentes de codificación que trabajan en GibberSound.

---

## Build/Lint/Test Commands / Comandos de Construcción/Lint/Pruebas

### Development / Desarrollo
```bash
# Install dependencies / Instalar dependencias
pip install -r requirements.txt

# Start development server (port 5001) / Iniciar servidor de desarrollo (puerto 5001)
python app.py

# Interactive management script (start/stop/restart/logs) / Script de gestión interactivo
./gestionar_app.sh

# Health check / Verificación de salud
curl http://localhost:5001/api/health

# Test DeepSeek API / Probar API de DeepSeek
python test_deepseek.py
```

### Production / Producción
```bash
# Start with gunicorn (4 workers, 120s timeout) / Iniciar con gunicorn
./start_app.sh

# Required environment variables / Variables de entorno requeridas
export FLASK_ENV=production
export DEEPSEEK_API_KEY='your-api-key'
```

### Docker/Kubernetes Deployment / Despliegue Docker/Kubernetes
```bash
# Build images with versioning (automates dockerhub push and k8s updates)
# Construir imágenes con versionado (automatiza push a dockerhub y actualizaciones k8s)
./k8s/build-images.sh

# Full deployment with domain configuration / Despliegue completo con configuración de dominio
./k8s/deploy.sh

# Manual Kubernetes commands / Comandos manuales de Kubernetes
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress.yaml

# Verify deployment / Verificar despliegue
kubectl get pods -n gibbersound -l app=gibbersound
kubectl get services -n gibbersound
kubectl get ingress -n gibbersound

# View logs / Ver registros
kubectl logs -n gibbersound -l app=gibbersound,tier=backend
kubectl logs -n gibbersound -l app=gibbersound,tier=frontend

# Restart deployments / Reiniciar deployments
kubectl rollout restart deployment -n gibbersound gibbersound-backend
kubectl rollout restart deployment -n gibbersound gibbersound-backend
```

---

## Code Style Guidelines / Guías de Estilo de Código

### Python (Backend) / Python (Backend)
- **Import order**: stdlib → third-party → local
- **Naming**: snake_case for variables/functions, SCREAMING_SNAKE_CASE for constants
- **Error handling**: Use specific exception types (httpx.HTTPStatusError, httpx.RequestError)
- **Logging**: Print statements for debugging
- **Flask**: Port 5001 (note: conflicts with macOS AirPlay Receiver)
- **CORS**: Configured for: gibbersound.com, www.gibbersound.com, localhost:5000, localhost:5001
- **Environment**: FLASK_ENV=production, DEEPSEEK_API_KEY required
- **Timeout**: httpx.Client(timeout=30.0), gunicorn --timeout 120
- **Sample rate**: 48000 Hz for audio context

### JavaScript (Frontend) / JavaScript (Frontend)
- **Naming**: camelCase for variables and functions
- **Async**: Use async/await with proper error handling (try/catch)
- **Event tracking**: Google Analytics with `trackEvent(category, action, label)`
- **Fallback mechanism**: localhost:5001 fallback in development mode only
- **Audio**: Use AudioContext with sample rate 48000 Hz
- **Visualization**: Analyser with fftSize 256, requestAnimationFrame for rendering
- **State management**: Global variables for audio context, ggwave instance, analyzer

### CSS (Styling) / CSS (Estilos)
- **Theming**: CSS variables for light/dark modes (--primary-color, --background-color, etc.)
- **Responsive**: Mobile-first with media queries (@media max-width: 768px, 480px)
- **Layouts**: Flexbox for structure
- **Transitions**: 0.3s ease for smooth color/theme changes
- **Variables**: All colors, spacing, shadows defined in :root
- **Dark mode**: [data-theme="dark"] selector for theme-specific overrides

### HTML (Templates) / HTML (Plantillas)
- **Templating**: Flask/Jinja2 with `{{ url_for('static', filename='...') }}`
- **Semantic**: HTML5 elements (header, main, footer)
- **Icons**: Material Design Icons from Google Fonts
- **Analytics**: Google Analytics gtag tracking enabled
- **Fonts**: Roboto font family
- **Manifest**: site.webmanifest for PWA support

### General Conventions / Convenciones Generales
- **Bilingual**: Spanish comments and logs, English for user-facing strings
- **Formatting**: No auto-formatting tools configured - maintain existing style
- **Docker**: Target platform linux/arm64
- **Versioning**: Semantic versioning stored in VERSION file, auto-updates in deployments
- **DockerHub**: Images tagged with version and `latest` (fpinero/gibbersound-backend, fpinero/gibbersound-frontend)
- **Kubernetes**: Namespace: gibbersound, Ingress with Traefik
- **Audio library**: ggwave.js for text-to-audio encoding
- **AI API**: DeepSeek API for chat completions (deepseek-chat model)
- **Nginx**: Frontend served via nginx:alpine with custom configuration

---

## Important Notes / Notas Importantes

- **Port 5001**: Used for all services; conflicts with macOS AirPlay Receiver on port 5000
- **No linting/formatters configured**: Maintain consistent style with existing code
- **No test framework configured**: Use manual testing with test_deepseek.py
- **Secrets**: k8s/deepseek-secret.yaml excluded from .gitignore - never commit API keys
- **Logs**: App logs saved to app.log, use ./gestionar_app.sh option 6 to view
- **Process management**: Use ./gestionar_app.sh for start/stop/restart operations
- **Gunicorn**: Production server uses 4 workers with 120s timeout
- **Health check**: Endpoint /api/health always returns {"status": "healthy"}
- **CORS headers**: Explicit CORS configuration for all /api/* routes
- **Analytics**: Google Analytics tracking ID: G-NNZ4JG3GRZ
- **Current version**: v0.3.2 (stored in VERSION file)
