# GoAccess para Gibbersound - Guía de uso

## Introducción

Este documento describe cómo utilizar el script `goaccess-report.sh` para analizar los logs de Nginx en el clúster Kubernetes de Gibbersound. El script proporciona una interfaz sencilla para acceder a las funcionalidades de GoAccess sin necesidad de instalar software adicional en tu máquina local.

## ¿Qué es GoAccess?

[GoAccess](https://goaccess.io/) es un analizador de logs web en tiempo real que proporciona estadísticas visuales rápidas sobre el tráfico web. Puede procesar logs de varios formatos, incluyendo los logs de Nginx que utiliza Gibbersound.

## Prerrequisitos

- Acceso al clúster Kubernetes donde está desplegado Gibbersound
- `kubectl` configurado correctamente para comunicarse con el clúster
- Permisos para crear pods en el namespace `gibbersound`

## Instalación

No se requiere instalación específica. El script utiliza un pod temporal con Alpine Linux que instala GoAccess automáticamente.

## Estructura de archivos

- `goaccess-report.sh`: Script principal para interactuar con GoAccess
- `logreader-pod.yaml`: Definición del pod temporal que se utiliza para ejecutar GoAccess

## Uso del script

### Ejecutar el script

```bash
./k8s/goaccess-report.sh
```

### Opciones disponibles

El script presenta un menú con las siguientes opciones:

1. **Abrir GoAccess en modo interactivo**: Esta opción lanza una interfaz interactiva de GoAccess en la terminal, permitiéndote explorar los logs en tiempo real.

2. **Generar informe HTML con timestamp**: Esta opción genera dos informes HTML:
   - Un informe local con timestamp que se descarga a tu máquina
   - Un informe fijo que se guarda en el servidor y es accesible vía web
   
   Además, te dará la opción de abrir el informe local, el informe web, ambos o ninguno.

3. **Abrir último informe web**: Esta opción abre directamente el último informe web generado sin necesidad de generar uno nuevo.

4. **Salir**: Cierra el script.

## Modo interactivo

El modo interactivo proporciona una interfaz de terminal para navegar por los datos de logs en tiempo real.

![Modo Interactivo](https://goaccess.io/images/goaccess-dark.png)

### Navegación en modo interactivo

- Utiliza las teclas de flecha ↑ y ↓ para desplazarte por los menús
- Presiona Enter para seleccionar un elemento
- Presiona F1-F12 para ver diferentes paneles
- Presiona q para salir

## Reportes HTML

### Informe local con timestamp

El informe local se guarda en tu máquina con un nombre que incluye la fecha y hora de generación (por ejemplo, `report_20240318_160235.html`).

### Informe accesible vía web

El informe web está siempre disponible en la siguiente URL:

```
https://gibbersound.com/stats/report.html
```

Este informe se sobrescribe cada vez que ejecutas la opción 2 del script, por lo que siempre muestra la información más reciente.

El script te ofrece la opción de abrir este informe directamente en tu navegador.

## Características de los informes

Los reportes HTML generados ofrecen una visualización completa y detallada de todos los datos de acceso, incluyendo:

- Estadísticas generales
- Visitantes únicos
- Solicitudes por hora/día
- Páginas más visitadas
- Códigos de respuesta HTTP
- Navegadores y sistemas operativos
- Referrers
- Y mucho más

## Persistencia de datos

El pod `logreader` se mantiene después de cerrar el script, lo que permite ejecutar el script múltiples veces sin tener que reinstalar GoAccess. Los logs se almacenan en un PersistentVolumeClaim de Kubernetes, lo que garantiza que los datos no se pierdan.

## Personalización

### Formato de logs

El script está configurado para trabajar con el formato COMBINED de Nginx. Si cambias el formato de tus logs, modifica el parámetro `--log-format` en las funciones `open_interactive` y `generate_report` del script.

### Ubicación de los logs

Si la ubicación de los logs cambia, actualiza la ruta en las mismas funciones mencionadas anteriormente.

## Solución de problemas

### El pod no se crea correctamente

Verifica que:
1. Tienes permisos para crear pods en el namespace `gibbersound`
2. El PVC `nginx-logs-pvc` existe y está correctamente configurado
3. No hay recursos limitados que impidan la creación del pod

### No se muestra el informe HTML en la web

Comprueba que:
1. El directorio `/var/log/nginx/stats` existe en el pod del frontend
2. El archivo `report.html` existe en ese directorio
3. La configuración de Nginx incluye la ubicación `/stats/`
4. No hay problemas de permisos en los archivos

## Ejemplos de uso

### Análisis diario del tráfico web

```bash
# Ejecutar el script
./k8s/goaccess-report.sh
# Seleccionar la opción 2 para generar informes HTML
# Seleccionar la opción 2 o 3 para abrir el informe web
```

### Acceso rápido al último informe

```bash
# Ejecutar el script
./k8s/goaccess-report.sh
# Seleccionar la opción 3 para abrir directamente el último informe web
```

### Investigación de errores en tiempo real

```bash
# Ejecutar el script
./k8s/goaccess-report.sh
# Seleccionar la opción 1 para el modo interactivo
# Navegar a la sección de códigos de error (4xx, 5xx)
```

### Compartir estadísticas con el equipo

Simplemente comparte la URL `https://gibbersound.com/stats/report.html` con los miembros del equipo.

## Información adicional

Para más detalles sobre GoAccess y sus capacidades, visita la [documentación oficial de GoAccess](https://goaccess.io/man). 