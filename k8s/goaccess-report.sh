#!/bin/bash

# Script para acceder a GoAccess en el pod logreader
# Autor: Claude 3.7
# Fecha: Marzo 2024

# Colores para mejorar la experiencia
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para verificar si el pod logreader existe
check_pod() {
  echo -e "${BLUE}Verificando si el pod logreader existe...${NC}"
  if ! kubectl get pod logreader -n gibbersound &> /dev/null; then
    echo -e "${RED}El pod logreader no existe. Creándolo...${NC}"
    kubectl apply -f k8s/logreader-pod.yaml
    
    # Esperar a que el pod esté listo
    echo -e "${YELLOW}Esperando a que el pod esté listo...${NC}"
    kubectl wait --for=condition=Ready pod/logreader -n gibbersound --timeout=60s
    
    if [ $? -ne 0 ]; then
      echo -e "${RED}Error: No se pudo iniciar el pod logreader.${NC}"
      exit 1
    fi
  fi
  
  echo -e "${GREEN}Pod logreader está listo.${NC}"
}

# Función para conectarse a GoAccess interactivamente
open_interactive() {
  echo -e "${BLUE}Abriendo GoAccess en modo interactivo...${NC}"
  echo -e "${YELLOW}Para salir de GoAccess, presiona q${NC}"
  kubectl exec -it logreader -n gibbersound -- sh -c "goaccess -f /logs/access.log --log-format=COMBINED"
}

# Función para generar un informe HTML con timestamp
generate_report() {
  # Crear timestamp
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  REPORT_NAME="report_${TIMESTAMP}.html"
  
  echo -e "${BLUE}Generando informe HTML: ${REPORT_NAME}...${NC}"
  
  # Generar el informe en el pod
  kubectl exec -it logreader -n gibbersound -- sh -c "goaccess -f /logs/access.log --log-format=COMBINED -o /logs/\"${REPORT_NAME}\""
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error al generar el informe.${NC}"
    return 1
  fi
  
  # Copiar el informe a la máquina local
  echo -e "${BLUE}Copiando el informe a la máquina local...${NC}"
  kubectl cp gibbersound/logreader:/logs/"${REPORT_NAME}" ./"${REPORT_NAME}"
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error al copiar el informe.${NC}"
    return 1
  fi
  
  echo -e "${GREEN}Informe generado correctamente: ${REPORT_NAME}${NC}"
  
  # Preguntar si quiere abrir el informe
  read -p "¿Deseas abrir el informe ahora? (s/n): " OPEN_REPORT
  if [[ "$OPEN_REPORT" =~ ^[Ss]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      open ./"${REPORT_NAME}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      xdg-open ./"${REPORT_NAME}"
    else
      echo -e "${YELLOW}No se pudo detectar el sistema operativo para abrir el archivo automáticamente.${NC}"
      echo -e "${YELLOW}Por favor, abre manualmente el archivo: ${REPORT_NAME}${NC}"
    fi
  fi
}

# Función principal
main() {
  clear
  echo -e "${BLUE}==================================================${NC}"
  echo -e "${BLUE}      Gestor de Logs GoAccess para Gibbersound     ${NC}"
  echo -e "${BLUE}==================================================${NC}"
  
  # Verificar si el pod existe
  check_pod
  
  # Mostrar opciones
  echo -e "\nSelecciona una opción:"
  echo -e "${GREEN}1)${NC} Abrir GoAccess en modo interactivo"
  echo -e "${GREEN}2)${NC} Generar informe HTML con timestamp"
  echo -e "${GREEN}3)${NC} Salir"
  
  read -p "Opción [1-3]: " OPTION
  
  case $OPTION in
    1)
      open_interactive
      ;;
    2)
      generate_report
      ;;
    3)
      echo -e "${BLUE}Saliendo...${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Opción inválida.${NC}"
      ;;
  esac
}

# Ejecutar la función principal
main 