#!/bin/bash
set -e

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para obtener la versión
get_version() {
    # Verificar si existe un archivo de versión
    if [ -f "VERSION" ]; then
        CURRENT_VERSION=$(cat VERSION)
        echo -e "${YELLOW}Versión actual: ${CURRENT_VERSION}${NC}"
    else
        CURRENT_VERSION="0.1.0"
        echo -e "${YELLOW}No se encontró archivo de versión. Versión inicial sugerida: ${CURRENT_VERSION}${NC}"
    fi
    
    read -p "Introduce la versión para las imágenes (ej: 1.0.0) [${CURRENT_VERSION}]: " VERSION
    
    if [ -z "$VERSION" ]; then
        VERSION=$CURRENT_VERSION
    fi
    
    # Guardar la versión para futuras referencias
    echo $VERSION > VERSION
    echo -e "${GREEN}Versión configurada: ${VERSION}${NC}"
}

# Función para actualizar los archivos de deployment
update_deployment_files() {
    echo -e "${YELLOW}Actualizando archivos de deployment con la versión ${VERSION}...${NC}"
    
    # Detectar el sistema operativo para usar la versión correcta de sed
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS usa una sintaxis diferente para sed
        sed -i '' "s|fpinero/gibbersound-backend:.*|fpinero/gibbersound-backend:${VERSION}|g" k8s/backend-deployment.yaml
        sed -i '' "s|fpinero/gibbersound-frontend:.*|fpinero/gibbersound-frontend:${VERSION}|g" k8s/frontend-deployment.yaml
    else
        # Linux y otros sistemas
        sed -i "s|fpinero/gibbersound-backend:.*|fpinero/gibbersound-backend:${VERSION}|g" k8s/backend-deployment.yaml
        sed -i "s|fpinero/gibbersound-frontend:.*|fpinero/gibbersound-frontend:${VERSION}|g" k8s/frontend-deployment.yaml
    fi
    
    echo -e "${GREEN}Archivos de deployment actualizados correctamente.${NC}"
}

# Función para actualizar la versión en el archivo index.html
update_version_in_html() {
    echo -e "${YELLOW}Actualizando versión en el archivo index.html...${NC}"
    
    # Verificar que el archivo index.html existe
    if [ ! -f "templates/index.html" ]; then
        echo -e "${RED}Error: El archivo templates/index.html no existe.${NC}"
        return
    fi
    
    # Detectar el sistema operativo para usar la versión correcta de sed
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS usa una sintaxis diferente para sed
        # Reemplazar cualquier patrón "Proof of Concept vX.X.X" por "Proof of Concept" primero
        sed -i '' -E 's/Proof of Concept v[0-9]+\.[0-9]+\.[0-9]+/Proof of Concept/g' templates/index.html
        # Luego añadir la nueva versión
        sed -i '' "s/Proof of Concept/Proof of Concept v${VERSION}/g" templates/index.html
    else
        # Linux y otros sistemas
        # Reemplazar cualquier patrón "Proof of Concept vX.X.X" por "Proof of Concept" primero
        sed -i -E 's/Proof of Concept v[0-9]+\.[0-9]+\.[0-9]+/Proof of Concept/g' templates/index.html
        # Luego añadir la nueva versión
        sed -i "s/Proof of Concept/Proof of Concept v${VERSION}/g" templates/index.html
    fi
    
    echo -e "${GREEN}Versión actualizada en index.html correctamente.${NC}"
}

# Verificar que app.py existe
if [ ! -f app.py ]; then
    echo -e "${RED}Error: El archivo app.py no existe en la raíz del proyecto.${NC}"
    exit 1
fi

# Obtener la versión para las imágenes
get_version

# Actualizar la versión en el archivo index.html
update_version_in_html

echo -e "${YELLOW}Construyendo imágenes Docker para GibberSound versión ${VERSION}...${NC}"

# Construir imagen del backend
echo -e "${GREEN}Construyendo imagen del backend...${NC}"
docker build -t fpinero/gibbersound-backend:${VERSION} -f k8s/Dockerfile.backend --platform linux/arm64 .
# También tagear como latest para compatibilidad
docker tag fpinero/gibbersound-backend:${VERSION} fpinero/gibbersound-backend:latest

# Construir imagen del frontend
echo -e "${GREEN}Construyendo imagen del frontend...${NC}"
docker build -t fpinero/gibbersound-frontend:${VERSION} -f k8s/Dockerfile.frontend --platform linux/arm64 .
# También tagear como latest para compatibilidad
docker tag fpinero/gibbersound-frontend:${VERSION} fpinero/gibbersound-frontend:latest

echo -e "${YELLOW}Imágenes construidas localmente.${NC}"

# Preguntar si se desea subir las imágenes a DockerHub
echo -e "${YELLOW}¿Deseas subir las imágenes a DockerHub? (s/n)${NC}"
read respuesta

if [[ $respuesta == "s" || $respuesta == "S" ]]; then
    echo -e "${GREEN}Iniciando sesión en DockerHub...${NC}"
    docker login
    
    echo -e "${GREEN}Subiendo imagen del backend versión ${VERSION}...${NC}"
    docker push fpinero/gibbersound-backend:${VERSION}
    docker push fpinero/gibbersound-backend:latest
    
    echo -e "${GREEN}Subiendo imagen del frontend versión ${VERSION}...${NC}"
    docker push fpinero/gibbersound-frontend:${VERSION}
    docker push fpinero/gibbersound-frontend:latest
    
    echo -e "${GREEN}Imágenes subidas correctamente a DockerHub.${NC}"
else
    echo -e "${YELLOW}No se subirán las imágenes a DockerHub.${NC}"
fi

# Actualizar los archivos de deployment con la nueva versión
update_deployment_files

# Preguntar si se desea actualizar los deployments en Kubernetes
echo -e "${YELLOW}¿Deseas actualizar los deployments en Kubernetes? (s/n)${NC}"
read respuesta

if [[ $respuesta == "s" || $respuesta == "S" ]]; then
    echo -e "${GREEN}Aplicando cambios en los deployments...${NC}"
    kubectl apply -f k8s/backend-deployment.yaml
    kubectl apply -f k8s/frontend-deployment.yaml
    
    echo -e "${GREEN}Reiniciando deployments para forzar la actualización de las imágenes...${NC}"
    kubectl rollout restart deployment -n gibbersound gibbersound-backend
    kubectl rollout restart deployment -n gibbersound gibbersound-frontend
    
    echo -e "${YELLOW}Verificando estado de los pods...${NC}"
    kubectl get pods -n gibbersound -l app=gibbersound
    
    echo -e "${GREEN}¡Actualización completada!${NC}"
else
    echo -e "${YELLOW}No se actualizarán los deployments en Kubernetes.${NC}"
    echo -e "${GREEN}Para aplicar los cambios manualmente, ejecuta:${NC}"
    echo -e "  kubectl apply -f k8s/backend-deployment.yaml"
    echo -e "  kubectl apply -f k8s/frontend-deployment.yaml"
    echo -e "  kubectl rollout restart deployment -n gibbersound gibbersound-backend"
    echo -e "  kubectl rollout restart deployment -n gibbersound gibbersound-frontend"
fi

echo -e "${GREEN}Proceso finalizado. Imágenes construidas con la versión ${VERSION}.${NC}" 