#!/bin/bash
set -e

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Construyendo imágenes Docker para GibberSound...${NC}"

# Construir imagen del backend
echo -e "${GREEN}Construyendo imagen del backend...${NC}"
docker build -t gibbersound-backend:latest -f k8s/Dockerfile.backend --platform linux/arm64 .

# Construir imagen del frontend
echo -e "${GREEN}Construyendo imagen del frontend...${NC}"
docker build -t gibbersound-frontend:latest -f k8s/Dockerfile.frontend --platform linux/arm64 .

echo -e "${YELLOW}Desplegando en Kubernetes...${NC}"

# Aplicar manifiestos de Kubernetes
echo -e "${GREEN}Desplegando backend...${NC}"
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

echo -e "${GREEN}Desplegando frontend...${NC}"
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

echo -e "${YELLOW}Verificando despliegue...${NC}"
kubectl get pods -l app=gibbersound
kubectl get services -l app=gibbersound

echo -e "${GREEN}¡Despliegue completado!${NC}"
echo -e "Para acceder a la aplicación, utiliza la IP externa del servicio frontend:"
kubectl get service gibbersound-frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo 