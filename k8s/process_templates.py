#!/usr/bin/env python3

import os

def process_template():
    # Leer la plantilla
    with open('templates/index.html', 'r') as f:
        content = f.read()
    
    # Reemplazar las expresiones de Flask con rutas estáticas
    content = content.replace("{{ url_for('static', filename='", "/static/")
    content = content.replace("') }}", "")
    
    # Crear el directorio build si no existe
    os.makedirs('build', exist_ok=True)
    
    # Guardar el archivo procesado
    with open('build/index.html', 'w') as f:
        f.write(content)

if __name__ == '__main__':
    process_template() 