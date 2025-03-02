# Despliegue de GibberSound en Kubernetes (k3s)

Este directorio contiene los archivos necesarios para desplegar GibberSound en un clúster de k3s con nodos ARM.

## Estructura de archivos

- `Dockerfile.backend`: Dockerfile para construir la imagen del backend (Python 3.12)
- `Dockerfile.frontend`: Dockerfile para construir la imagen del frontend (Nginx)
- `nginx.conf`: Configuración de Nginx para el frontend
- `namespace.yaml`: Manifiesto para crear el namespace gibbersound
- `backend-deployment.yaml`: Manifiesto de Kubernetes para el deployment del backend
- `backend-service.yaml`: Manifiesto de Kubernetes para el servicio del backend
- `frontend-deployment.yaml`: Manifiesto de Kubernetes para el deployment del frontend
- `frontend-service.yaml`: Manifiesto de Kubernetes para el servicio del frontend
- `ingress.yaml`: Manifiesto para configurar el Ingress con Traefik
- `deploy.sh`: Script para facilitar la construcción y despliegue

## Requisitos previos

- Docker instalado y configurado
- kubectl instalado y configurado para conectarse a tu clúster de k3s
- Un clúster de k3s con nodos ARM64
- Cuenta en DockerHub (usuario: fpinero)
- Un dominio configurado para apuntar a la IP del nodo master de k3s

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

### 3. Desplegar en Kubernetes (k3s)

Una vez que las imágenes estén disponibles en DockerHub, puedes desplegar la aplicación en k3s:

```bash
# Si no has ejecutado el script deploy.sh o has respondido 'n' a la pregunta de despliegue

# Crear el namespace
kubectl apply -f k8s/namespace.yaml

# Desplegar los servicios y deployments
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# Configurar el Ingress (asegúrate de editar el archivo para usar tu dominio)
kubectl apply -f k8s/ingress.yaml
```

### 4. Configuración DNS

Para que la aplicación sea accesible a través de tu dominio, necesitas configurar registros DNS:

1. Configura un registro A para `tudominio.com` que apunte a la IP del nodo master de k3s
2. Configura un registro A para `www.tudominio.com` que apunte a la misma IP

Si usas CloudFlare:
1. Activa el proxy (icono naranja) para obtener HTTPS automáticamente
2. No es necesario configurar Let's Encrypt, ya que CloudFlare proporciona el certificado SSL

### 5. Verificar el despliegue

```bash
# Verificar que los pods están funcionando
kubectl get pods -n gibbersound -l app=gibbersound

# Verificar los servicios
kubectl get services -n gibbersound

# Verificar el Ingress
kubectl get ingress -n gibbersound
```

## Personalización

Si necesitas personalizar la configuración, puedes modificar los siguientes archivos:

- Para cambiar la configuración de Nginx: `nginx.conf`
- Para ajustar los recursos asignados a los pods: edita los campos `resources` en los archivos de deployment
- Para cambiar el número de réplicas: edita el campo `replicas` en los archivos de deployment
- Para usar una versión específica de las imágenes: edita el campo `image` en los archivos de deployment
- Para cambiar el dominio: edita el archivo `ingress.yaml`

## Solución de problemas

Si encuentras problemas durante el despliegue, puedes verificar los logs de los pods:

```bash
kubectl logs -n gibbersound -l app=gibbersound,tier=backend
kubectl logs -n gibbersound -l app=gibbersound,tier=frontend
```

Para verificar el estado del Ingress:
```bash
kubectl describe ingress -n gibbersound gibbersound-ingress
```

Para reiniciar los deployments:
```bash
kubectl rollout restart deployment -n gibbersound gibbersound-backend
kubectl rollout restart deployment -n gibbersound gibbersound-frontend
``` 