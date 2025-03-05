#!/bin/bash
set -e

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Solicitar el dominio si no está configurado
configure_domain() {
    echo -e "${YELLOW}Configurando dominio para el Ingress...${NC}"
    read -p "Introduce el dominio principal (ej: gibbersound.com): " DOMAIN
    
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}No se ha especificado un dominio. Usando 'gibbersound.com' como ejemplo.${NC}"
        DOMAIN="gibbersound.com"
    fi
    
    # Detectar el sistema operativo para usar la versión correcta de sed
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS usa una sintaxis diferente para sed
        sed -i '' "s/gibbersound.com/$DOMAIN/g" k8s/ingress.yaml
        sed -i '' "s/www.gibbersound.com/www.$DOMAIN/g" k8s/ingress.yaml
    else
        # Linux y otros sistemas
        sed -i "s/gibbersound.com/$DOMAIN/g" k8s/ingress.yaml
        sed -i "s/www.gibbersound.com/www.$DOMAIN/g" k8s/ingress.yaml
    fi
    
    echo -e "${GREEN}Dominio configurado: $DOMAIN${NC}"
}

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

echo -e "${YELLOW}Despliegue completo de GibberSound en Kubernetes${NC}"
echo -e "${YELLOW}Este script realizará un despliegue completo de la aplicación.${NC}"
echo -e "${YELLOW}Si solo deseas construir y actualizar imágenes, usa el script build-images.sh${NC}"
echo -e ""

# Verificar que app.py existe
if [ ! -f app.py ]; then
    echo -e "${RED}Error: El archivo app.py no existe en la raíz del proyecto.${NC}"
    echo -e "${YELLOW}Creando un archivo app.py básico con un endpoint de health check...${NC}"
    cat > app.py << 'EOF'
from flask import Flask, render_template, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/health')
def health_check():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
EOF
    echo -e "${GREEN}Archivo app.py creado.${NC}"
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

# Actualizar los archivos de deployment con la nueva versión
update_deployment_files

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
fi

echo -e "${YELLOW}¿Deseas desplegar la aplicación en Kubernetes? (s/n)${NC}"
read respuesta

if [[ $respuesta == "s" || $respuesta == "S" ]]; then
    # Configurar dominio para el Ingress
    configure_domain
    
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
    
    echo -e "${GREEN}Configurando Ingress...${NC}"
    kubectl apply -f k8s/ingress.yaml

    echo -e "${YELLOW}Verificando despliegue...${NC}"
    kubectl get pods -n gibbersound -l app=gibbersound
    kubectl get services -n gibbersound -l app=gibbersound
    kubectl get ingress -n gibbersound

    echo -e "${GREEN}¡Despliegue completado!${NC}"
    echo -e "${YELLOW}Para acceder a la aplicación, configura los siguientes registros DNS:${NC}"
    echo -e "  - Tipo A: $DOMAIN -> IP del nodo master de k3s"
    echo -e "  - Tipo A: www.$DOMAIN -> IP del nodo master de k3s"
    echo -e "${YELLOW}Si usas CloudFlare, activa el proxy para obtener HTTPS automáticamente.${NC}"
else
    echo -e "${GREEN}Proceso finalizado. Puedes desplegar manualmente cuando estés listo.${NC}"
fi 