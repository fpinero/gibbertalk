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

echo -e "${YELLOW}Construyendo imágenes Docker para GibberSound...${NC}"

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
    app.run(host='0.0.0.0', port=5000)
EOF
    echo -e "${GREEN}Archivo app.py creado.${NC}"
fi

# Construir imagen del backend
echo -e "${GREEN}Construyendo imagen del backend localmente...${NC}"
docker build -t fpinero/gibbersound-backend:latest -f k8s/Dockerfile.backend --platform linux/arm64 .

# Construir imagen del frontend
echo -e "${GREEN}Construyendo imagen del frontend localmente...${NC}"
docker build -t fpinero/gibbersound-frontend:latest -f k8s/Dockerfile.frontend --platform linux/arm64 .

echo -e "${YELLOW}Imágenes construidas localmente.${NC}"
echo -e "${YELLOW}Para subir las imágenes a DockerHub, sigue estos pasos:${NC}"
echo -e "  1. ${GREEN}docker login${NC}"
echo -e "  2. ${GREEN}docker push fpinero/gibbersound-backend:latest${NC}"
echo -e "  3. ${GREEN}docker push fpinero/gibbersound-frontend:latest${NC}"

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

    echo -e "${YELLOW}¿Deseas reiniciar los deployments para forzar la actualización de las imágenes? (s/n)${NC}"
    read reiniciar
    
    if [[ $reiniciar == "s" || $reiniciar == "S" ]]; then
        echo -e "${GREEN}Reiniciando deployments...${NC}"
        kubectl rollout restart deployment -n gibbersound gibbersound-backend
        kubectl rollout restart deployment -n gibbersound gibbersound-frontend
    fi

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