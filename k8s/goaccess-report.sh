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
  FIXED_REPORT_NAME="stats/report.html"
  WEB_URL="https://gibbersound.com/stats/report.html"
  
  echo -e "${BLUE}Generando informe HTML...${NC}"
  
  # Asegurarse de que el directorio stats existe
  kubectl exec -it logreader -n gibbersound -- sh -c "mkdir -p /logs/stats"
  
  # Generar el informe en el pod con timestamp
  echo -e "${BLUE}Generando informe con timestamp: ${REPORT_NAME}...${NC}"
  kubectl exec -it logreader -n gibbersound -- sh -c "goaccess -f /logs/access.log --log-format=COMBINED -o /logs/\"${REPORT_NAME}\""
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error al generar el informe con timestamp.${NC}"
    return 1
  fi
  
  # Generar el informe fijo para acceso web
  echo -e "${BLUE}Generando informe fijo para acceso web: ${FIXED_REPORT_NAME}...${NC}"
  kubectl exec -it logreader -n gibbersound -- sh -c "goaccess -f /logs/access.log --log-format=COMBINED -o /logs/\"${FIXED_REPORT_NAME}\""
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error al generar el informe fijo.${NC}"
    return 1
  fi
  
  # Copiar el informe con timestamp a la máquina local
  echo -e "${BLUE}Copiando el informe a la máquina local...${NC}"
  kubectl cp gibbersound/logreader:/logs/"${REPORT_NAME}" ./"${REPORT_NAME}"
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error al copiar el informe.${NC}"
    return 1
  fi
  
  echo -e "${GREEN}Informes generados correctamente:${NC}"
  echo -e "  - Local: ${REPORT_NAME}"
  echo -e "  - Web: ${WEB_URL}"
  
  # Preguntar sobre cómo ver los informes
  echo -e "\n${BLUE}¿Cómo deseas ver los informes?${NC}"
  echo -e "${GREEN}1)${NC} Abrir informe local"
  echo -e "${GREEN}2)${NC} Abrir informe web"
  echo -e "${GREEN}3)${NC} Abrir ambos informes"
  echo -e "${GREEN}4)${NC} No abrir ningún informe"
  
  read -p "Opción [1-4]: " VIEW_OPTION
  
  case $VIEW_OPTION in
    1)
      open_local_report
      ;;
    2)
      open_web_report
      ;;
    3)
      open_local_report
      open_web_report
      ;;
    4)
      echo -e "${BLUE}No se abrirá ningún informe.${NC}"
      ;;
    *)
      echo -e "${RED}Opción inválida. No se abrirá ningún informe.${NC}"
      ;;
  esac
}

# Función para abrir el informe local
open_local_report() {
  echo -e "${BLUE}Abriendo informe local...${NC}"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open ./"${REPORT_NAME}"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open ./"${REPORT_NAME}"
  else
    echo -e "${YELLOW}No se pudo detectar el sistema operativo para abrir el archivo automáticamente.${NC}"
    echo -e "${YELLOW}Por favor, abre manualmente el archivo: ${REPORT_NAME}${NC}"
  fi
}

# Función para abrir el informe web
open_web_report() {
  echo -e "${BLUE}Abriendo informe web...${NC}"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "${WEB_URL}"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open "${WEB_URL}"
  else
    echo -e "${YELLOW}No se pudo detectar el sistema operativo para abrir la URL automáticamente.${NC}"
    echo -e "${YELLOW}Por favor, visita: ${WEB_URL}${NC}"
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
  echo -e "${GREEN}3)${NC} Abrir último informe web"
  echo -e "${GREEN}4)${NC} Salir"
  
  read -p "Opción [1-4]: " OPTION
  
  case $OPTION in
    1)
      open_interactive
      ;;
    2)
      generate_report
      ;;
    3)
      WEB_URL="https://gibbersound.com/stats/report.html"
      open_web_report
      ;;
    4)
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