# GoAccess para Gibbersound - Guía de uso

## Introducción

Este documento describe cómo utilizar el script `goaccess-report.sh` y el CronJob automatizado para analizar los logs de Nginx en el clúster Kubernetes de Gibbersound. Estas herramientas proporcionan una interfaz sencilla para acceder a las funcionalidades de GoAccess sin necesidad de instalar software adicional en tu máquina local.

## ¿Qué es GoAccess?

[GoAccess](https://goaccess.io/) es un analizador de logs web en tiempo real que proporciona estadísticas visuales rápidas sobre el tráfico web. Puede procesar logs de varios formatos, incluyendo los logs de Nginx que utiliza Gibbersound.

## Prerrequisitos

- Acceso al clúster Kubernetes donde está desplegado Gibbersound
- `kubectl` configurado correctamente para comunicarse con el clúster
- Permisos para crear pods en el namespace `gibbersound`

## Componentes del sistema

### Script interactivo
- `goaccess-report.sh`: Script principal para interactuar con GoAccess de forma manual
- `logreader-pod.yaml`: Definición del pod temporal que se utiliza para ejecutar GoAccess

### Generación automática
- `goaccess-cronjob.yaml`: CronJob que genera automáticamente informes de GoAccess cada 30 minutos

## Generación automática de informes

El CronJob `goaccess-reporter` está configurado para generar automáticamente un informe actualizado cada 30 minutos. Estos informes están disponibles directamente en:

```
https://gibbersound.com/stats/report.html
```

No es necesario ejecutar ningún comando manual para acceder a esta información, que siempre estará disponible y actualizada periódicamente.

### Configuración del CronJob

El CronJob está configurado con las siguientes características:

- **Frecuencia**: Se ejecuta cada 30 minutos
- **Concurrencia**: No permite ejecuciones simultáneas (evita conflictos)
- **Historial**: Mantiene un registro de los últimos 3 jobs exitosos y 1 fallido
- **Persistencia**: Utiliza el mismo PVC que Nginx para acceder a los logs

Para aplicar o modificar el CronJob:

```bash
kubectl apply -f k8s/goaccess-cronjob.yaml
```

Para verificar el estado del CronJob:

```bash
kubectl get cronjobs -n gibbersound
```

Para ver los últimos jobs ejecutados:

```bash
kubectl get jobs -n gibbersound
```

## Uso del script manual

Si necesitas generar informes bajo demanda o usar la interfaz interactiva de GoAccess, puedes utilizar el script manual.

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

Este informe se actualiza por dos vías:
- Automáticamente cada 30 minutos a través del CronJob
- Manualmente cuando ejecutas la opción 2 del script

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

Los logs se almacenan en un PersistentVolumeClaim de Kubernetes, lo que garantiza que los datos no se pierdan y estén disponibles tanto para el CronJob automático como para el script manual.

## Personalización

### Modificar la frecuencia del CronJob

Si deseas cambiar la frecuencia de generación de informes, edita el campo `schedule` en el archivo `goaccess-cronjob.yaml`. La configuración utiliza el formato estándar de cron:

```yaml
schedule: "*/30 * * * *"  # Cambiar según necesidades
```

### Formato de logs

Los scripts están configurados para trabajar con el formato COMBINED de Nginx. Si cambias el formato de tus logs, modifica el parámetro `--log-format` en las funciones correspondientes.

## Solución de problemas

### El CronJob no genera informes

Verifica que:
1. El CronJob está activo: `kubectl get cronjobs -n gibbersound`
2. Revisa los logs del último job: `kubectl logs job/<nombre-del-job> -n gibbersound`
3. El PVC está correctamente montado y accesible

### No se muestra el informe HTML en la web

Comprueba que:
1. El directorio `/var/log/nginx/stats` existe en el pod del frontend
2. El archivo `report.html` existe en ese directorio
3. La configuración de Nginx incluye la ubicación `/stats/`
4. No hay problemas de permisos en los archivos

## Ejemplos de uso

### Acceso directo al informe

Simplemente visita `https://gibbersound.com/stats/report.html` en tu navegador para ver el último informe generado automáticamente.

### Análisis manual bajo demanda

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