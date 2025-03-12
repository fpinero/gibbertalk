# Definir colores para mejor visualizaci�n
$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow

Write-Host "Verificando si la aplicaci�n Python est� en ejecuci�n..." -ForegroundColor $Yellow

# Verificar procesos usando el puerto 5001
$procesos = Get-NetTCPConnection -LocalPort 5001 -State Listen -ErrorAction SilentlyContinue

if ($null -eq $procesos) {
    Write-Host "? El puerto 5001 est� libre. La aplicaci�n no est� en ejecuci�n." -ForegroundColor $Green
    Write-Host "Puedes iniciar la aplicaci�n con: " -NoNewline
    Write-Host "python app.py" -ForegroundColor $Yellow
}
else {
    Write-Host "? El puerto 5001 est� ocupado. Detalles:" -ForegroundColor $Red
    
    # Obtener informaci�n detallada de los procesos
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
    Write-Host "2. Para reiniciar la aplicaci�n despu�s: " -NoNewline
    Write-Host "python app.py" -ForegroundColor $Yellow
}

Write-Host "`nInformaci�n adicional:" -ForegroundColor $Yellow
Write-Host "- Ruta de la aplicaci�n: $($PWD)\app.py"
Write-Host "- Endpoint de salud: http://localhost:5001/api/health"
