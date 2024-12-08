
$userHome = $HOME

# VSCode settings
Copy-Item -Path "$userHome\AppData\Roaming\Code\User\settings.json" -Destination .\apps\vscode

# Powershell Profile
Copy-Item -Path "$PROFILE" -Destination .\apps\pwsh\Microsoft.PowerShell_profile.ps1
