## ---------------------------
##
## Script name: bundle-http-deploy.ps1
##
## Purpose of script: Creates an I2 upgrade file that downloads a StarBundle from a web server and applies them to IntelliSTAR 2-based devices.
##
## Author: physicsprop
##
## Date Created: 03-24-2023
##
## ---------------------------

function Get-PendingBundleInfo {
    Write-Output "What is the URL that contains the bundle?"
    $script:url = Read-Host
    Write-Output "What is the version of this bundle that is to be installed?"
    $script:version = Read-Host
}

function Create-BundleInstaller {
    mkdir ./output/$script:version
    "<ProductInstall><Name>SBInstall</Name><Version>$script:version</Version><ApplyDate>1/1/0001 12:00:00 AM</ApplyDate><Updates/><Requires/><StopClient>false</StopClient></ProductInstall>" | Out-File ./output/$script:version/manifest.xml
    Copy-Item .\run-template.ps1 .\output\$script:version\run.ps1
    $file = (Get-Content .\output\$script:version\run.ps1) -as [Collections.ArrayList]
    $file.Insert(0, "$`downloadURI = '$script:url'")
    $file | Set-Content .\output\$script:version\run.ps1
    Compress-Archive -Path ".\output\$script:version\*" -DestinationPath ".\output\StarBundle-installer-$script:version.zip"
    Write-Output "Done!"
}

Get-PendingBundleInfo
Create-BundleInstaller
pause
