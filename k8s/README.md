# Despliegue de GibberSound en Kubernetes

Este directorio contiene los archivos necesarios para desplegar GibberSound en un clúster de Kubernetes con nodos ARM.

## Estructura de archivos

- `Dockerfile.backend`: Dockerfile para construir la imagen del backend (Python 3.12)
- `Dockerfile.frontend`: Dockerfile para construir la imagen del frontend (Nginx)
- `nginx.conf`: Configuración de Nginx para el frontend
- `backend-deployment.yaml`: Manifiesto de Kubernetes para el deployment del backend
- `backend-service.yaml`: Manifiesto de Kubernetes para el servicio del backend
- `frontend-deployment.yaml`: Manifiesto de Kubernetes para el deployment del frontend
- `frontend-service.yaml`: Manifiesto de Kubernetes para el servicio del frontend
- `deploy.sh`: Script para facilitar la construcción y despliegue

## Requisitos previos

- Docker instalado y configurado
- kubectl instalado y configurado para conectarse a tu clúster de Kubernetes
- Un clúster de Kubernetes con nodos ARM64

## Pasos para el despliegue

1. Asegúrate de que tienes acceso a tu clúster de Kubernetes:
   ```bash
   kubectl cluster-info
   ```

2. Haz ejecutable el script de despliegue:
   ```bash
   chmod +x k8s/deploy.sh
   ```

3. Ejecuta el script de despliegue:
   ```bash
   ./k8s/deploy.sh
   ```

4. Verifica que los pods estén funcionando correctamente:
   ```bash
   kubectl get pods -l app=gibbersound
   ```

5. Obtén la IP externa para acceder a la aplicación:
   ```bash
   kubectl get service gibbersound-frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```

## Personalización

Si necesitas personalizar la configuración, puedes modificar los siguientes archivos:

- Para cambiar la configuración de Nginx: `nginx.conf`
- Para ajustar los recursos asignados a los pods: edita los campos `resources` en los archivos de deployment
- Para cambiar el número de réplicas: edita el campo `replicas` en los archivos de deployment

## Solución de problemas

Si encuentras problemas durante el despliegue, puedes verificar los logs de los pods:

```bash
kubectl logs -l app=gibbersound,tier=backend
kubectl logs -l app=gibbersound,tier=frontend
```

Para reiniciar los deployments:

```bash
kubectl rollout restart deployment gibbersound-backend
kubectl rollout restart deployment gibbersound-frontend
``` 