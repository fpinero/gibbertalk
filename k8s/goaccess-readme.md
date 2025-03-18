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

2. **Generar informe HTML con timestamp**: Esta opción genera un informe HTML estático con todas las estadísticas de los logs. El archivo se guarda con un timestamp único para evitar sobrescribir informes anteriores.

3. **Salir**: Cierra el script.

## Modo interactivo

El modo interactivo proporciona una interfaz de terminal para navegar por los datos de logs en tiempo real.

![Modo Interactivo](https://goaccess.io/images/goaccess-dark.png)

### Navegación en modo interactivo

- Utiliza las teclas de flecha ↑ y ↓ para desplazarte por los menús
- Presiona Enter para seleccionar un elemento
- Presiona F1-F12 para ver diferentes paneles
- Presiona q para salir

## Reportes HTML

Los reportes HTML generados ofrecen una visualización completa y detallada de todos los datos de acceso, incluyendo:

- Estadísticas generales
- Visitantes únicos
- Solicitudes por hora/día
- Páginas más visitadas
- Códigos de respuesta HTTP
- Navegadores y sistemas operativos
- Referrers
- Y mucho más

El informe se guarda localmente con un nombre que incluye la fecha y hora de generación (por ejemplo, `report_20240318_160235.html`).

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

### No se muestra el informe HTML

Comprueba que:
1. El pod tiene acceso a los logs
2. La ruta a los logs es correcta
3. Tienes permisos para copiar archivos desde el pod

## Ejemplos de uso

### Análisis diario del tráfico web

```bash
# Ejecutar el script
./k8s/goaccess-report.sh
# Seleccionar la opción 2 para generar un informe HTML
# Abrir el informe generado
```

### Investigación de errores en tiempo real

```bash
# Ejecutar el script
./k8s/goaccess-report.sh
# Seleccionar la opción 1 para el modo interactivo
# Navegar a la sección de códigos de error (4xx, 5xx)
```

## Información adicional

Para más detalles sobre GoAccess y sus capacidades, visita la [documentación oficial de GoAccess](https://goaccess.io/man). 