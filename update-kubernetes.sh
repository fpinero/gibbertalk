#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Actualizando configuración de Kubernetes para GibberSound...${NC}"

# Aplicar cambios en el ConfigMap de Nginx
echo -e "${GREEN}Actualizando ConfigMap de Nginx con soporte para /stats/...${NC}"
kubectl apply -f k8s/frontend-nginx-config.yaml

# Aplicar cambios en el Ingress
echo -e "${GREEN}Actualizando Ingress con rutas para API y stats...${NC}"
kubectl apply -f k8s/ingress.yaml

# Actualizar el deployment del frontend para usar el nuevo ConfigMap
echo -e "${GREEN}Actualizando deployment del frontend...${NC}"
kubectl apply -f k8s/frontend-deployment.yaml

# Reiniciar el deployment del backend para aplicar los cambios
echo -e "${GREEN}Reiniciando deployments para aplicar los cambios...${NC}"
kubectl rollout restart deployment -n gibbersound gibbersound-backend
kubectl rollout restart deployment -n gibbersound gibbersound-frontend

# Verificar el estado
echo -e "${YELLOW}Verificando estado de los pods...${NC}"
kubectl get pods -n gibbersound -l app=gibbersound

echo -e "${GREEN}Cambios aplicados correctamente.${NC}"
echo -e "${YELLOW}La aplicación estará disponible en unos minutos una vez que los pods se reinicien.${NC}"
echo -e "${YELLOW}Los reportes de estadísticas estarán disponibles en https://gibbersound.com/stats/report.html${NC}" 