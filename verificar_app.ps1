# Definir colores para mejor visualización
$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow

Write-Host "Verificando si la aplicación Python está en ejecución..." -ForegroundColor $Yellow

# Verificar procesos usando el puerto 5001
$procesos = Get-NetTCPConnection -LocalPort 5001 -State Listen -ErrorAction SilentlyContinue

if ($null -eq $procesos) {
    Write-Host "? El puerto 5001 está libre. La aplicación no está en ejecución." -ForegroundColor $Green
    Write-Host "Puedes iniciar la aplicación con: " -NoNewline
    Write-Host "python app.py" -ForegroundColor $Yellow
}
else {
    Write-Host "? El puerto 5001 está ocupado. Detalles:" -ForegroundColor $Red
    
    # Obtener información detallada de los procesos
    foreach ($proceso in $procesos) {
        $processInfo = Get-Process -Id $proceso.OwningProcess
        Write-Host "`nProceso encontrado:" -ForegroundColor $Yellow
        Write-Host "PID: $($processInfo.Id)"
        Write-Host "Nombre: $($processInfo.ProcessName)"
        Write-Host "Ruta: $($processInfo.Path)"
    }
    
    Write-Host "`nOpciones:" -ForegroundColor $Yellow
    Write-Host "1. Para detener estos procesos, ejecuta: " -NoNewline
    Write-Host "Stop-Process -Id $($procesos.OwningProcess)" -ForegroundColor $Yellow
    Write-Host "2. Para reiniciar la aplicación después: " -NoNewline
    Write-Host "python app.py" -ForegroundColor $Yellow
}

Write-Host "`nInformación adicional:" -ForegroundColor $Yellow
Write-Host "- Ruta de la aplicación: $($PWD)\app.py"
Write-Host "- Endpoint de salud: http://localhost:5001/api/health"
