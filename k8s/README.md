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
- `build-images.sh`: Script para construir y actualizar imágenes con versionado
- `deploy.sh`: Script para el despliegue completo de la aplicación

## Requisitos previos

- Docker instalado y configurado
- kubectl instalado y configurado para conectarse a tu clúster de k3s
- Un clúster de k3s con nodos ARM64
- Cuenta en DockerHub (usuario: fpinero)
- Un dominio configurado para apuntar a la IP del nodo master de k3s

## Flujo de trabajo para el desarrollo y despliegue

### Opción 1: Construir y actualizar imágenes (uso diario)

Para el desarrollo continuo, cuando solo necesitas actualizar las imágenes con los últimos cambios:

```bash
chmod +x k8s/build-images.sh
./k8s/build-images.sh
```

Este script realizará las siguientes acciones:

1. Solicitará una versión para las imágenes (ej: 1.0.0)
2. Guardará la versión en un archivo `VERSION` para referencia futura
3. Construirá las imágenes con la versión especificada:
   - `fpinero/gibbersound-backend:x.x.x`
   - `fpinero/gibbersound-frontend:x.x.x`
4. También etiquetará las imágenes como `latest` para compatibilidad
5. Actualizará automáticamente los archivos de deployment para usar la versión específica
6. Opcionalmente subirá las imágenes a DockerHub
7. Opcionalmente aplicará los cambios en los deployments existentes en Kubernetes

### Opción 2: Despliegue completo (primera instalación)

Para un despliegue completo de la aplicación desde cero:

```bash
chmod +x k8s/deploy.sh
./k8s/deploy.sh
```

Este script realizará un despliegue completo:

1. Solicitará una versión para las imágenes
2. Construirá las imágenes con la versión especificada
3. Actualizará los archivos de deployment
4. Opcionalmente subirá las imágenes a DockerHub
5. Solicitará un dominio para configurar el Ingress
6. Desplegará todos los componentes en Kubernetes:
   - Namespace
   - Backend (deployment y servicio)
   - Frontend (deployment y servicio)
   - Ingress

## Gestión de versiones

El sistema ahora utiliza un enfoque de versionado semántico para las imágenes Docker:

- Las versiones se almacenan en un archivo `VERSION` en la raíz del proyecto
- Cada vez que ejecutas uno de los scripts, te sugerirá la versión actual como valor predeterminado
- Puedes incrementar la versión según sea necesario (ej: 1.0.0 → 1.0.1 para correcciones, 1.0.0 → 1.1.0 para nuevas características)
- Los archivos de deployment se actualizan automáticamente para usar la versión específica
- Se mantiene la compatibilidad con `latest` para sistemas existentes

## Despliegue manual en Kubernetes

Si prefieres desplegar manualmente después de construir las imágenes:

```bash
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

## Configuración DNS

Para que la aplicación sea accesible a través de tu dominio, necesitas configurar registros DNS:

1. Configura un registro A para `tudominio.com` que apunte a la IP del nodo master de k3s
2. Configura un registro A para `www.tudominio.com` que apunte a la misma IP

Si usas CloudFlare:
1. Activa el proxy (icono naranja) para obtener HTTPS automáticamente
2. No es necesario configurar Let's Encrypt, ya que CloudFlare proporciona el certificado SSL

## Verificar el despliegue

```bash
# Verificar que los pods están funcionando
kubectl get pods -n gibbersound -l app=gibbersound

# Verificar los servicios
kubectl get services -n gibbersound

# Verificar el Ingress
kubectl get ingress -n gibbersound
```

## Actualización de imágenes

Para actualizar las imágenes con una nueva versión:

```bash
# Usar el script de construcción de imágenes
./k8s/build-images.sh

# O manualmente:
# 1. Construir nuevas imágenes con una versión específica
docker build -t fpinero/gibbersound-backend:1.0.1 -f k8s/Dockerfile.backend .
docker build -t fpinero/gibbersound-frontend:1.0.1 -f k8s/Dockerfile.frontend .

# 2. Actualizar los archivos de deployment para usar la nueva versión
# Editar backend-deployment.yaml y frontend-deployment.yaml

# 3. Aplicar los cambios
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

# 4. Reiniciar los deployments para forzar la actualización
kubectl rollout restart deployment -n gibbersound gibbersound-backend
kubectl rollout restart deployment -n gibbersound gibbersound-frontend
```

## Personalización

Si necesitas personalizar la configuración, puedes modificar los siguientes archivos:

- Para cambiar la configuración de Nginx: `nginx.conf`
- Para ajustar los recursos asignados a los pods: edita los campos `resources` en los archivos de deployment
- Para cambiar el número de réplicas: edita el campo `replicas` en los archivos de deployment
- Para cambiar el dominio: edita el archivo `ingress.yaml` o usa el script `deploy.sh`

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