# Despliegue de GibberSound en Kubernetes

Este directorio contiene los archivos necesarios para desplegar GibberSound en un clúster de Kubernetes con nodos ARM.

## Estructura de archivos

- `Dockerfile.backend`: Dockerfile para construir la imagen del backend (Python 3.12)
- `Dockerfile.frontend`: Dockerfile para construir la imagen del frontend (Nginx)
- `nginx.conf`: Configuración de Nginx para el frontend
- `namespace.yaml`: Manifiesto para crear el namespace gibbersound
- `backend-deployment.yaml`: Manifiesto de Kubernetes para el deployment del backend
- `backend-service.yaml`: Manifiesto de Kubernetes para el servicio del backend
- `frontend-deployment.yaml`: Manifiesto de Kubernetes para el deployment del frontend
- `frontend-service.yaml`: Manifiesto de Kubernetes para el servicio del frontend
- `deploy.sh`: Script para facilitar la construcción y despliegue

## Requisitos previos

- Docker instalado y configurado
- kubectl instalado y configurado para conectarse a tu clúster de Kubernetes
- Un clúster de Kubernetes con nodos ARM64
- Cuenta en DockerHub (usuario: fpinero)

## Flujo de trabajo para el despliegue

### 1. Construcción de imágenes locales

Primero, construye las imágenes Docker localmente:

```bash
chmod +x k8s/deploy.sh
./k8s/deploy.sh
```

Este script construirá las imágenes localmente con los siguientes tags:
- `fpinero/gibbersound-backend:latest`
- `fpinero/gibbersound-frontend:latest`

### 2. Subir imágenes a DockerHub (manual)

Para subir las imágenes a DockerHub, sigue estos pasos manualmente:

```bash
# Iniciar sesión en DockerHub (solo necesitas hacerlo una vez)
docker login

# Subir las imágenes
docker push fpinero/gibbersound-backend:latest
docker push fpinero/gibbersound-frontend:latest
```

> **Nota**: Si prefieres usar una versión específica en lugar de `latest`, puedes etiquetar las imágenes antes de subirlas:
> ```bash
> docker tag fpinero/gibbersound-backend:latest fpinero/gibbersound-backend:1.0.0
> docker tag fpinero/gibbersound-frontend:latest fpinero/gibbersound-frontend:1.0.0
> docker push fpinero/gibbersound-backend:1.0.0
> docker push fpinero/gibbersound-frontend:1.0.0
> ```
> En ese caso, recuerda actualizar los archivos de deployment para usar la versión específica.

### 3. Desplegar en Kubernetes

Una vez que las imágenes estén disponibles en DockerHub, puedes desplegar la aplicación en Kubernetes:

```bash
# Si no has ejecutado el script deploy.sh o has respondido 'n' a la pregunta de despliegue

# Crear el namespace
kubectl apply -f k8s/namespace.yaml

# Desplegar los servicios y deployments
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

### 4. Verificar el despliegue

```bash
# Verificar que los pods están funcionando
kubectl get pods -n gibbersound -l app=gibbersound

# Obtener la IP externa para acceder a la aplicación
kubectl get service -n gibbersound gibbersound-frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Personalización

Si necesitas personalizar la configuración, puedes modificar los siguientes archivos:

- Para cambiar la configuración de Nginx: `nginx.conf`
- Para ajustar los recursos asignados a los pods: edita los campos `resources` en los archivos de deployment
- Para cambiar el número de réplicas: edita el campo `replicas` en los archivos de deployment
- Para usar una versión específica de las imágenes: edita el campo `image` en los archivos de deployment

## Solución de problemas

Si encuentras problemas durante el despliegue, puedes verificar los logs de los pods:

```bash
kubectl logs -n gibbersound -l app=gibbersound,tier=backend
kubectl logs -n gibbersound -l app=gibbersound,tier=frontend
```

Para reiniciar los deployments:

```bash
kubectl rollout restart deployment -n gibbersound gibbersound-backend
kubectl rollout restart deployment -n gibbersound gibbersound-frontend
``` 