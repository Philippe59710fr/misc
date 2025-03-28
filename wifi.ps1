i.	Créez un fichier : nBoost10.ps1 :
$SSID = "nBoost10"
$Password = "stage0001"

# Supprimer l'ancien profil si existant
netsh wlan delete profile name=$SSID

# Créer un fichier XML temporaire
$xml = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$SSID</name>
    <SSIDConfig>
        <SSID>
            <name>$SSID</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$Password</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"@

# Activer le service de localisation
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy /v LetAppsAccessLocation /t REG_DWORD /d 1 /f
Set-Service lfsvc -StartupType Automatic
ReStart-Service lfsvc

# Sauvegarder le fichier temporaire
$xmlPath = "$env:TEMP\wifi.xml"
$xml | Out-File -Encoding UTF8 -FilePath $xmlPath

# Ajouter le profil Wi-Fi
netsh wlan add profile filename="$xmlPath"

# Se connecter au Wi-Fi
netsh wlan connect name="$SSID"
