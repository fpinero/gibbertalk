#!/bin/bash

# Cargar variables de entorno si existe un archivo .env
if [ -f .env ]; then
    source .env
fi

# Verificar que la variable DEEPSEEK_API_KEY está configurada
if [ -z "$DEEPSEEK_API_KEY" ]; then
    echo "Error: La variable de entorno DEEPSEEK_API_KEY no está configurada."
    echo "Por favor, configúrela con: export DEEPSEEK_API_KEY='tu-api-key'"
    exit 1
fi

# Establecer variables de entorno para Flask
export FLASK_ENV=production
export FLASK_APP=app.py

# Asegurarse de que los paquetes requeridos están instalados
pip install -r requirements.txt > /dev/null 2>&1

# Comprobar si gunicorn está instalado
if ! command -v gunicorn &> /dev/null; then
    echo "Gunicorn no está instalado. Instalándolo..."
    pip install gunicorn > /dev/null 2>&1
fi

# Iniciar gunicorn con 4 trabajadores
# Ajustar el número de trabajadores según la capacidad del servidor
echo "Iniciando la aplicación con gunicorn..."
exec gunicorn --bind 0.0.0.0:5001 --workers 4 --timeout 120 app:app 