# Gestión de la Aplicación Python

Este documento explica cómo gestionar la aplicación Python de GibberTalk utilizando los scripts proporcionados.

## Scripts disponibles

### 1. `start_app.sh`

Script principal para iniciar la aplicación en modo producción utilizando gunicorn. Características:
- Verifica la presencia de la variable de entorno DEEPSEEK_API_KEY
- Instala automáticamente las dependencias necesarias
- Inicia gunicorn con 4 workers para mejor rendimiento y estabilidad
- Configura timeout adecuado para manejar solicitudes a la API de DeepSeek

```bash
./start_app.sh
```

### 2. `gestionar_app.sh`

Un script completo con un menú interactivo que permite gestionar todos los aspectos de la aplicación:

```bash
./gestionar_app.sh
```

#### Opciones disponibles:

1. **Verificar estado de la aplicación**: Muestra si la aplicación está en ejecución y detalles sobre los procesos.
2. **Detener la aplicación**: Detiene todos los procesos relacionados con la aplicación (incluidos gunicorn y workers).
3. **Iniciar la aplicación**: Inicia la aplicación utilizando `start_app.sh` con gunicorn.
4. **Reiniciar la aplicación**: Combina las operaciones de detener e iniciar en un solo paso.
5. **Verificar estado de salud de la API**: Comprueba si la API está respondiendo correctamente.
6. **Ver logs de la aplicación**: Proporciona varias opciones para ver y analizar los logs.
7. **Salir**: Cierra el script de gestión.

### 3. `verificar_app.sh`

Un script simple que verifica si la aplicación está en ejecución y muestra información sobre los procesos que están usando el puerto 5001.

```bash
./verificar_app.sh
```

## Mejoras en la gestión de procesos

El script `gestionar_app.sh` ha sido mejorado para gestionar correctamente los procesos de gunicorn:

- **Detección de procesos**: Identifica tanto procesos por nombre (gunicorn) como por puerto (5001)
- **Detención controlada**: Intenta primero una terminación normal antes de recurrir a kill -9
- **Verificación post-acción**: Comprueba que las acciones de inicio/detención se hayan completado correctamente
- **Gestión de permisos**: Verifica y asigna permisos de ejecución a los scripts automáticamente

## Características mejoradas para visualización de logs

El sistema de logs ahora ofrece más opciones interactivas:

- **Ver más líneas**: Permite especificar el número exacto de líneas a mostrar
- **Seguimiento en tiempo real**: Muestra los logs a medida que se generan (tail -f)
- **Búsqueda de errores**: Filtra automáticamente los logs para mostrar solo errores y excepciones
- **Navegación mejorada**: Integración con comandos como `less` para mejor visualización

## Guía de uso diario

### Al comenzar tu día de trabajo:

1. Abre una terminal en la carpeta del proyecto
2. Activa el entorno virtual si es necesario:
   ```bash
   source venv/bin/activate
   ```
3. Ejecuta el script de gestión:
   ```bash
   ./gestionar_app.sh
   ```
4. Selecciona la opción 1 para verificar si la aplicación ya está en ejecución
5. Si no está en ejecución, selecciona la opción 3 para iniciarla
6. Si necesitas reiniciarla, puedes usar directamente la opción 4 (reiniciar)
7. Verifica que la aplicación esté funcionando correctamente con la opción 5 (estado de salud)

### Durante el desarrollo:

- Usa la opción 6 para revisar los logs cuando necesites depurar problemas
- La opción de seguimiento en tiempo real (opción 2 dentro del menú de logs) es especialmente útil mientras trabajas
- Si haces cambios en el código, usa la opción 4 para reiniciar la aplicación y aplicarlos

### Al finalizar tu día de trabajo:

Si deseas detener la aplicación:
1. Ejecuta el script de gestión:
   ```bash
   ./gestionar_app.sh
   ```
2. Selecciona la opción 2 para detener la aplicación

## Solución de problemas comunes

### La aplicación no se detiene con el comando normal

El script ahora intenta identificar y mostrar todos los procesos relacionados con la aplicación, incluyendo procesos de gunicorn. Si la terminación normal falla:

1. El script ahora te preguntará si deseas forzar la terminación
2. Selecciona "s" para utilizar kill -9 en los procesos restantes

### El puerto 5001 sigue ocupado después de detener la aplicación

El script mejorado ahora detecta y gestiona mejor esta situación. Si persiste, verifica manualmente:

```bash
lsof -i :5001
```

### La aplicación no inicia correctamente

Ahora puedes usar las opciones mejoradas de visualización de logs para diagnosticar el problema:

1. Inicia el script de gestión: `./gestionar_app.sh`
2. Selecciona la opción 6 para ver los logs
3. Usa la opción 3 dentro del menú de logs para buscar específicamente errores

### La variable de entorno DEEPSEEK_API_KEY no está configurada

El script `start_app.sh` verifica esta variable y muestra un mensaje claro si no está configurada. Para solucionarlo:

```bash
export DEEPSEEK_API_KEY='tu-api-key'
```

Para hacerla permanente, añádela a tu archivo `~/.bashrc` o `~/.zshrc` según el shell que uses.

### Problemas con gunicorn

Si gunicorn no está instalado, el script `start_app.sh` detectará esta situación e intentará instalarlo automáticamente.

## Notas sobre gunicorn vs servidor de desarrollo

La aplicación ahora utiliza gunicorn en lugar del servidor de desarrollo de Flask para entornos de producción, lo que proporciona:

- Mayor estabilidad y rendimiento
- Capacidad para manejar múltiples solicitudes simultáneas
- Mejor gestión de recursos
- Reinicio automático en caso de errores

Para desarrollo, puedes seguir usando `python app.py`, que activará el modo de desarrollo con recarga automática. 