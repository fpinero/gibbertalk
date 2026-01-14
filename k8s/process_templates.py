#!/usr/bin/env python3

import os
from pathlib import Path

def process_template():
    # Crear el directorio build si no existe
    os.makedirs('build', exist_ok=True)
    
    # Procesar todos los archivos HTML en templates/
    templates_dir = Path('templates')
    html_files = list(templates_dir.glob('*.html'))
    
    if not html_files:
        print("No se encontraron archivos HTML en templates/")
        return
    
    print(f"Procesando {len(html_files)} archivo(s) HTML...")
    
    for html_file in html_files:
        # Leer la plantilla
        with open(html_file, 'r') as f:
            content = f.read()
        
        # Reemplazar las expresiones de Flask con rutas estáticas
        content = content.replace("{{ url_for('static', filename='", "/static/")
        content = content.replace("') }}", "")
        
        # Guardar el archivo procesado con el mismo nombre
        output_file = Path('build') / html_file.name
        with open(output_file, 'w') as f:
            f.write(content)
        
        print(f"  ✓ Procesado: {html_file.name} -> {output_file}")
    
    print(f"\n¡{len(html_files)} archivo(s) HTML procesado(s) correctamente!")

if __name__ == '__main__':
    process_template() 