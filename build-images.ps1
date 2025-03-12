# PowerShell script to build Docker images
# Equivalent to build-images.sh but for Windows PowerShell

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"

# Function to get version
function Get-ImageVersion {
    # Check if version file exists
    if (Test-Path "VERSION") {
        $currentVersion = Get-Content "VERSION"
        Write-Host "Current version: $currentVersion" -ForegroundColor $Yellow
    }
    else {
        $currentVersion = "0.1.0"
        Write-Host "No version file found. Suggested initial version: $currentVersion" -ForegroundColor $Yellow
    }
    
    $version = Read-Host "Enter version for images (e.g., 1.0.0) [$currentVersion]"
    
    if ([string]::IsNullOrEmpty($version)) {
        $version = $currentVersion
    }
    
    # Save version for future reference
    $version | Out-File -FilePath "VERSION" -NoNewline
    Write-Host "Version set: $version" -ForegroundColor $Green
    
    return $version
}

# Function to update deployment files
function Update-DeploymentFiles {
    param (
        [string]$version
    )
    
    Write-Host "Updating deployment files with version $version..." -ForegroundColor $Yellow
    
    # Update backend deployment file
    if (Test-Path "k8s/backend-deployment.yaml") {
        $content = Get-Content "k8s/backend-deployment.yaml" -Raw
        $updatedContent = $content -replace "fpinero/gibbersound-backend:.*", "fpinero/gibbersound-backend:$version"
        $updatedContent | Out-File "k8s/backend-deployment.yaml" -NoNewline
    }
    else {
        Write-Host "Warning: k8s/backend-deployment.yaml not found" -ForegroundColor $Red
    }
    
    # Update frontend deployment file
    if (Test-Path "k8s/frontend-deployment.yaml") {
        $content = Get-Content "k8s/frontend-deployment.yaml" -Raw
        $updatedContent = $content -replace "fpinero/gibbersound-frontend:.*", "fpinero/gibbersound-frontend:$version"
        $updatedContent | Out-File "k8s/frontend-deployment.yaml" -NoNewline
    }
    else {
        Write-Host "Warning: k8s/frontend-deployment.yaml not found" -ForegroundColor $Red
    }
    
    Write-Host "Deployment files updated successfully." -ForegroundColor $Green
}

# Function to update version in HTML file
function Update-VersionInHtml {
    param (
        [string]$version
    )
    
    Write-Host "Updating version in index.html file..." -ForegroundColor $Yellow
    
    # Check if index.html exists
    if (-not (Test-Path "templates/index.html")) {
        Write-Host "Error: templates/index.html file does not exist." -ForegroundColor $Red
        return
    }
    
    # Read the file content
    $content = Get-Content "templates/index.html" -Raw
    
    # Replace any "Proof of Concept vX.X.X" pattern with "Proof of Concept" first
    $content = $content -replace "Proof of Concept v\d+\.\d+\.\d+", "Proof of Concept"
    
    # Then add the new version
    $content = $content -replace "Proof of Concept", "Proof of Concept v$version"
    
    # Write the updated content back to the file
    $content | Out-File "templates/index.html" -NoNewline
    
    Write-Host "Version updated in index.html successfully." -ForegroundColor $Green
}

# Check if app.py exists
if (-not (Test-Path "app.py")) {
    Write-Host "Error: app.py file does not exist in the project root." -ForegroundColor $Red
    exit 1
}

# Get version for images
$version = Get-ImageVersion

# Update version in HTML file
Update-VersionInHtml -version $version

Write-Host "Building Docker images for GibberSound version $version..." -ForegroundColor $Yellow

# Build backend image
Write-Host "Building backend image..." -ForegroundColor $Green
docker build -t fpinero/gibbersound-backend:$version -f k8s/Dockerfile.backend --platform linux/arm64 .
# Also tag as latest for compatibility
docker tag fpinero/gibbersound-backend:$version fpinero/gibbersound-backend:latest

# Build frontend image
Write-Host "Building frontend image..." -ForegroundColor $Green
docker build -t fpinero/gibbersound-frontend:$version -f k8s/Dockerfile.frontend --platform linux/arm64 .
# Also tag as latest for compatibility
docker tag fpinero/gibbersound-frontend:$version fpinero/gibbersound-frontend:latest

Write-Host "Images built locally." -ForegroundColor $Yellow

# Ask if images should be pushed to DockerHub
Write-Host "Do you want to push the images to DockerHub? (y/n)" -ForegroundColor $Yellow
$response = Read-Host

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "Logging in to DockerHub..." -ForegroundColor $Green
    docker login
    
    Write-Host "Pushing backend image version $version..." -ForegroundColor $Green
    docker push fpinero/gibbersound-backend:$version
    docker push fpinero/gibbersound-backend:latest
    
    Write-Host "Pushing frontend image version $version..." -ForegroundColor $Green
    docker push fpinero/gibbersound-frontend:$version
    docker push fpinero/gibbersound-frontend:latest
    
    Write-Host "Images successfully pushed to DockerHub." -ForegroundColor $Green
}
else {
    Write-Host "Images will not be pushed to DockerHub." -ForegroundColor $Yellow
}

# Update deployment files with the new version
Update-DeploymentFiles -version $version

# Ask if Kubernetes deployments should be updated
Write-Host "Do you want to update the Kubernetes deployments? (y/n)" -ForegroundColor $Yellow
$response = Read-Host

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "Applying changes to deployments..." -ForegroundColor $Green
    kubectl apply -f k8s/backend-deployment.yaml
    kubectl apply -f k8s/frontend-deployment.yaml
    
    Write-Host "Restarting deployments to force image update..." -ForegroundColor $Green
    kubectl rollout restart deployment -n gibbersound gibbersound-backend
    kubectl rollout restart deployment -n gibbersound gibbersound-frontend
    
    Write-Host "Checking pod status..." -ForegroundColor $Yellow
    kubectl get pods -n gibbersound -l app=gibbersound
    
    Write-Host "Update completed!" -ForegroundColor $Green
}
else {
    Write-Host "Kubernetes deployments will not be updated." -ForegroundColor $Yellow
    Write-Host "To apply changes manually, run:" -ForegroundColor $Green
    Write-Host "  kubectl apply -f k8s/backend-deployment.yaml"
    Write-Host "  kubectl apply -f k8s/frontend-deployment.yaml"
    Write-Host "  kubectl rollout restart deployment -n gibbersound gibbersound-backend"
    Write-Host "  kubectl rollout restart deployment -n gibbersound gibbersound-frontend"
}

Write-Host "Process completed. Images built with version $version." -ForegroundColor $Green 