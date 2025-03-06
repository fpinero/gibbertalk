#!/bin/bash

# Colores para mejor visualización
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Puerto de la aplicación
PUERTO=5001

# Función para verificar si la aplicación está en ejecución
verificar_app() {
    echo -e "${YELLOW}Verificando si la aplicación Python está en ejecución...${NC}"
    
    # Verificar procesos usando el puerto
    PROCESOS=$(lsof -i :$PUERTO | grep LISTEN)
    
    if [ -z "$PROCESOS" ]; then
        echo -e "${GREEN}✓ El puerto $PUERTO está libre. La aplicación no está en ejecución.${NC}"
        return 1
    else
        echo -e "${RED}✗ El puerto $PUERTO está ocupado. Detalles:${NC}"
        echo "$PROCESOS"
        
        # Extraer PIDs
        PIDS=$(echo "$PROCESOS" | awk '{print $2}' | sort -u)
        
        echo -e "\n${YELLOW}Procesos encontrados:${NC}"
        for PID in $PIDS; do
            ps -p $PID -o pid,ppid,command
        done
        
        return 0
    fi
}

# Función para detener la aplicación
detener_app() {
    verificar_app
    if [ $? -eq 0 ]; then
        echo -e "\n${YELLOW}Deteniendo la aplicación...${NC}"
        PIDS=$(lsof -i :$PUERTO | grep LISTEN | awk '{print $2}' | sort -u)
        
        # Confirmar antes de matar procesos
        echo -e "${RED}¿Estás seguro de que quieres detener estos procesos? (s/n)${NC}"
        read -r respuesta
        if [[ "$respuesta" =~ ^[Ss]$ ]]; then
            kill $PIDS
            echo -e "${GREEN}Procesos detenidos.${NC}"
            
            # Verificar si se detuvo correctamente
            sleep 1
            verificar_app
            if [ $? -eq 1 ]; then
                echo -e "${GREEN}✓ La aplicación se ha detenido correctamente.${NC}"
            else
                echo -e "${RED}✗ No se pudieron detener todos los procesos. Intenta con: ${YELLOW}kill -9 $PIDS${NC}"
            fi
        else
            echo -e "${YELLOW}Operación cancelada.${NC}"
        fi
    else
        echo -e "${YELLOW}No hay ninguna aplicación ejecutándose en el puerto $PUERTO.${NC}"
    fi
}

# Función para iniciar la aplicación
iniciar_app() {
    verificar_app
    if [ $? -eq 1 ]; then
        echo -e "\n${YELLOW}Iniciando la aplicación...${NC}"
        
        # Verificar si existe la variable de entorno DEEPSEEK_API_KEY
        if [ -z "$DEEPSEEK_API_KEY" ]; then
            echo -e "${RED}⚠️ La variable de entorno DEEPSEEK_API_KEY no está configurada.${NC}"
            echo -e "${YELLOW}Configúrala con: export DEEPSEEK_API_KEY='tu-api-key'${NC}"
            echo -e "${RED}¿Deseas continuar de todos modos? (s/n)${NC}"
            read -r respuesta
            if [[ ! "$respuesta" =~ ^[Ss]$ ]]; then
                echo -e "${YELLOW}Operación cancelada.${NC}"
                return
            fi
        fi
        
        # Iniciar la aplicación en segundo plano
        python app.py > app.log 2>&1 &
        PID=$!
        echo -e "${GREEN}✓ Aplicación iniciada con PID: $PID${NC}"
        echo -e "${YELLOW}Los logs se están guardando en: $(pwd)/app.log${NC}"
        
        # Esperar un momento y verificar si se inició correctamente
        sleep 2
        if ps -p $PID > /dev/null; then
            echo -e "${GREEN}✓ La aplicación se está ejecutando.${NC}"
            echo -e "${BLUE}Puedes acceder a ella en: http://localhost:$PUERTO${NC}"
            echo -e "${BLUE}Endpoint de salud: http://localhost:$PUERTO/api/health${NC}"
        else
            echo -e "${RED}✗ La aplicación no se pudo iniciar correctamente.${NC}"
            echo -e "${YELLOW}Revisa los logs en: $(pwd)/app.log${NC}"
        fi
    else
        echo -e "\n${RED}⚠️ Ya hay una aplicación ejecutándose en el puerto $PUERTO.${NC}"
        echo -e "${YELLOW}Detén la aplicación primero con la opción 2.${NC}"
    fi
}

# Función para verificar el estado de salud de la API
verificar_salud() {
    echo -e "${YELLOW}Verificando el estado de salud de la API...${NC}"
    
    # Intentar hacer una solicitud al endpoint de salud
    RESPUESTA=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PUERTO/api/health)
    
    if [ "$RESPUESTA" == "200" ]; then
        echo -e "${GREEN}✓ La API está funcionando correctamente (código $RESPUESTA).${NC}"
        
        # Mostrar la respuesta completa
        echo -e "${YELLOW}Respuesta del endpoint de salud:${NC}"
        curl -s http://localhost:$PUERTO/api/health | json_pp
    else
        echo -e "${RED}✗ La API no está respondiendo correctamente (código $RESPUESTA).${NC}"
        echo -e "${YELLOW}Verifica los logs o reinicia la aplicación.${NC}"
    fi
}

# Función para mostrar los logs
mostrar_logs() {
    if [ -f "app.log" ]; then
        echo -e "${YELLOW}Últimas 20 líneas de los logs:${NC}"
        tail -n 20 app.log
        
        echo -e "\n${YELLOW}Opciones:${NC}"
        echo -e "1. Para ver más líneas: ${BLUE}tail -n 50 app.log${NC}"
        echo -e "2. Para seguir los logs en tiempo real: ${BLUE}tail -f app.log${NC}"
    else
        echo -e "${RED}✗ No se encontró el archivo de logs (app.log).${NC}"
        echo -e "${YELLOW}Inicia la aplicación primero para generar logs.${NC}"
    fi
}

# Menú principal
while true; do
    echo -e "\n${BLUE}=== GESTOR DE LA APLICACIÓN PYTHON ===${NC}"
    echo -e "${YELLOW}1. Verificar estado de la aplicación${NC}"
    echo -e "${YELLOW}2. Detener la aplicación${NC}"
    echo -e "${YELLOW}3. Iniciar la aplicación${NC}"
    echo -e "${YELLOW}4. Verificar estado de salud de la API${NC}"
    echo -e "${YELLOW}5. Ver logs de la aplicación${NC}"
    echo -e "${YELLOW}6. Salir${NC}"
    
    echo -e "${BLUE}Selecciona una opción:${NC}"
    read -r opcion
    
    case $opcion in
        1) verificar_app ;;
        2) detener_app ;;
        3) iniciar_app ;;
        4) verificar_salud ;;
        5) mostrar_logs ;;
        6) echo -e "${GREEN}¡Hasta luego!${NC}"; exit 0 ;;
        *) echo -e "${RED}Opción inválida. Por favor, selecciona una opción válida.${NC}" ;;
    esac
    
    echo -e "\n${BLUE}Presiona Enter para continuar...${NC}"
    read
done 