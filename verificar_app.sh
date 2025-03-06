#!/bin/bash

# Colores para mejor visualización
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Verificando si la aplicación Python está en ejecución...${NC}"

# Verificar procesos usando el puerto 5001
PROCESOS=$(lsof -i :5001 | grep LISTEN)

if [ -z "$PROCESOS" ]; then
    echo -e "${GREEN}✓ El puerto 5001 está libre. La aplicación no está en ejecución.${NC}"
    echo -e "Puedes iniciar la aplicación con: ${YELLOW}python app.py${NC}"
else
    echo -e "${RED}✗ El puerto 5001 está ocupado. Detalles:${NC}"
    echo "$PROCESOS"
    
    # Extraer PIDs
    PIDS=$(echo "$PROCESOS" | awk '{print $2}' | sort -u)
    
    echo -e "\n${YELLOW}Procesos encontrados:${NC}"
    for PID in $PIDS; do
        ps -p $PID -o pid,ppid,command
    done
    
    echo -e "\n${YELLOW}Opciones:${NC}"
    echo -e "1. Para detener todos estos procesos: ${YELLOW}kill $PIDS${NC}"
    echo -e "2. Para reiniciar la aplicación después: ${YELLOW}python app.py${NC}"
fi

echo -e "\n${YELLOW}Información adicional:${NC}"
echo -e "- Ruta de la aplicación: $(pwd)/app.py"
echo -e "- Endpoint de salud: http://localhost:5001/api/health" 