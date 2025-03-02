#!/bin/bash
set -e

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Construyendo imágenes Docker para GibberSound...${NC}"

# Construir imagen del backend
echo -e "${GREEN}Construyendo imagen del backend localmente...${NC}"
docker build -t fpinero/gibbersound-backend:latest -f k8s/Dockerfile.backend --platform linux/arm64 .

# Construir imagen del frontend
echo -e "${GREEN}Construyendo imagen del frontend localmente...${NC}"
docker build -t fpinero/gibbersound-frontend:latest -f k8s/Dockerfile.frontend --platform linux/arm64 .

echo -e "${YELLOW}Imágenes construidas localmente.${NC}"
echo -e "${YELLOW}Para subir las imágenes a DockerHub, sigue los pasos en el README.md${NC}"

echo -e "${YELLOW}¿Deseas desplegar la aplicación en Kubernetes? (s/n)${NC}"
read respuesta

if [[ $respuesta == "s" || $respuesta == "S" ]]; then
    echo -e "${YELLOW}Desplegando en Kubernetes...${NC}"

    # Crear namespace si no existe
    echo -e "${GREEN}Creando namespace gibbersound...${NC}"
    kubectl apply -f k8s/namespace.yaml

    # Aplicar manifiestos de Kubernetes
    echo -e "${GREEN}Desplegando backend...${NC}"
    kubectl apply -f k8s/backend-deployment.yaml
    kubectl apply -f k8s/backend-service.yaml

    echo -e "${GREEN}Desplegando frontend...${NC}"
    kubectl apply -f k8s/frontend-deployment.yaml
    kubectl apply -f k8s/frontend-service.yaml

    echo -e "${YELLOW}Verificando despliegue...${NC}"
    kubectl get pods -n gibbersound -l app=gibbersound
    kubectl get services -n gibbersound -l app=gibbersound

    echo -e "${GREEN}¡Despliegue completado!${NC}"
    echo -e "Para acceder a la aplicación, utiliza la IP externa del servicio frontend:"
    kubectl get service -n gibbersound gibbersound-frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    echo
else
    echo -e "${GREEN}Proceso finalizado. Puedes desplegar manualmente cuando estés listo.${NC}"
fi 