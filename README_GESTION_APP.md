# Gestión de la Aplicación Python

Este documento explica cómo gestionar la aplicación Python de GibberTalk utilizando los scripts proporcionados.

## Scripts disponibles

### 1. `verificar_app.sh`

Un script simple que verifica si la aplicación está en ejecución y muestra información sobre los procesos que están usando el puerto 5001.

```bash
./verificar_app.sh
```

### 2. `gestionar_app.sh`

Un script completo con un menú interactivo que permite:
- Verificar el estado de la aplicación
- Detener la aplicación
- Iniciar la aplicación
- Verificar el estado de salud de la API
- Ver los logs de la aplicación

```bash
./gestionar_app.sh
```

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
5. Si está en ejecución y necesitas reiniciarla:
   - Selecciona la opción 2 para detenerla
   - Selecciona la opción 3 para iniciarla nuevamente
6. Si no está en ejecución:
   - Selecciona la opción 3 para iniciarla
7. Verifica que la aplicación esté funcionando correctamente con la opción 4

### Al finalizar tu día de trabajo:

Si deseas detener la aplicación:
1. Ejecuta el script de gestión:
   ```bash
   ./gestionar_app.sh
   ```
2. Selecciona la opción 2 para detener la aplicación

## Solución de problemas comunes

### La aplicación no se detiene con el comando normal

Si la aplicación no se detiene con el comando normal `kill`, puedes usar:

```bash
kill -9 [PID]
```

Donde `[PID]` es el número de proceso que se muestra en la verificación.

### El puerto 5001 sigue ocupado después de detener la aplicación

Verifica si hay otros procesos usando el puerto:

```bash
lsof -i :5001
```

### La aplicación no inicia correctamente

Revisa los logs para ver si hay errores:

```bash
tail -n 50 app.log
```

### La variable de entorno DEEPSEEK_API_KEY no está configurada

Configura la variable de entorno con:

```bash
export DEEPSEEK_API_KEY='tu-api-key'
```

Para hacerla permanente, añádela a tu archivo `~/.bashrc` o `~/.zshrc` según el shell que uses. 