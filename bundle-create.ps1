## ---------------------------
##
## Script name: bundle-create.ps1
##
## Purpose of script: Creates Starbundle ZIP files for the purpose of adding files to IntelliSTAR 2-based devices.
##
## Author: physicsprop
##
## Date Created: 03-22-2023
##
## ---------------------------
##
## Notes: Can only create "<Add..>" changes. "<Delete..." actions are too destructive to automate.   
##
## ---------------------------

function Get-TargetBundleInformation {
    $script:arrlst = @((Get-ChildItem -File -Recurse -Path '.\input').FullName)
    #begin user interaction
    Write-Output "Please specify the type of bundle to create."
    Write-Output "1. Changeset (viz assets)`n2. Managed (i2 products/flavors)"
    $script:bundletype = Read-Host
    
    if (([string]::IsNullOrEmpty($script:bundletype))) {
        Write-Output "No option was selected. Exiting..."
        break
    }

    Write-Output "Please specify bundle target."
    Write-Output "1. Any Domestic_Universe (I2HD/I2XD)`n2. Any Domestic_SD_Universe (I2JR)`n3. Specific Headend ID`n4. Any STAR type"
    $script:bundletarget = Read-Host

    if (([string]::IsNullOrEmpty($script:bundletarget))) {
        Write-Output "There was no response, assuming option 4.`n"
        $script:bundletarget = "4"
    }
    

    if ($script:bundletarget -like "3") {
        Write-Output "Please specify Headend ID to apply changes to."
        $script:bundleheadend = Read-Host
        $script:headend = "heId='$script:bundleheadend'"
    }


    Write-Output "Please specify version string. This will be used by the I2 to determine if files need to be replaced or updated when a bundle is processed."
    $script:version = Read-Host
    
    Write-Output "Running checks and setting variables..."

    if ($script:bundletype -like 1) {
        $script:type = "Changeset"
    }
    elseif ($script:bundletype -like 2) {
        $script:type = "Managed"
    }
    
    if ($script:bundletarget -like 1) {
        $script:target = 'starFlags="Domestic_Universe"'
    }
    elseif ($script:bundletarget -like 2) {
        $script:target = 'starFlags="Domestic_SD_Universe"'
    }
    else {
        $script:target = ''
    }

    Write-Output "Going to create a $script:type bundle containing $((Get-ChildItem -File -Recurse -Path '.\input' | Measure-Object).count) files."
    if ($script:bundletarget -like 3) {
        Write-Output "This bundle will only apply to I2 Headend ID $script:bundleheadend"
    } elseif ($script:bundletarget -like 1) {
        "This bundle will only apply to Domestic_Universe (I2XD/HD) units."
    } elseif ($script:bundletarget -like 2) {
        "This bundle will only apply to Domestic_SD_Universe (I2JR) units."
    } elseif ($script:bundletarget -like 4) {
        "This bundle will only apply to any unit."
    }
    Write-Output "The output file will be named StarBundle-$script:type-$script:version.zip and will be stored in the output folder."
    Write-Output "Ready to commit!"
    Write-Output "Press enter to commit bundle."
    Read-Host
}

function Prepare-TargetBundleFolder {
    try {
        Write-Output "Preparing target folder."
        mkdir ".\output\StarBundle-$script:type-$script:version\MetaData" 
    }
    catch {
        Write-Error "FATAL: Unable to create output folder."
        break
    }
}


function Start-TargetBundleManifest {
    $script:date = Get-Date -Format "MM/dd/yyyy"
    Write-Output "Writing manifest header."
    "<StarBundle>" | Out-File -FilePath ".\output\StarBundle-$script:type-$script:version\MetaData\manifest.xml"
    "<Version>$script:version</Version>" | Out-File -Append -FilePath ".\output\StarBundle-$script:type-$script:version\MetaData\manifest.xml"
    "<ApplyDate>$script:date</ApplyDate>" | Out-File -Append -FilePath ".\output\StarBundle-$script:type-$script:version\MetaData\manifest.xml"
    "<Type>$script:type</Type>" | Out-File -Append -FilePath ".\output\StarBundle-$script:type-$script:version\MetaData\manifest.xml"
    "<FileActions>" | Out-File -Append -FilePath ".\output\StarBundle-$script:type-$script:version\MetaData\manifest.xml"
}


function Commit-FilesToTargetBundle {
    Write-Output "Preparing to commit files to target StarBundle."
    foreach ($script:file in $script:arrlst) {
        $script:relpath = $script:file -replace '.*input'
        $script:relpath = $script:relpath.substring(1)
        $script:GUID = New-Guid
        try {
            Write-Output "Commiting $script:relpath to bundle."
            Copy-Item $script:file .\output\StarBundle-$script:type-$script:version\$script:GUID
            "<Add src='$script:GUID' dest='$script:relpath' version='$script:version' $script:target $script:headend />" | Out-File -Append -FilePath ".\output\StarBundle-$script:type-$script:version\MetaData\manifest.xml"
        }
        catch {
            Write-Error "Unable to commit $script:relpath to bundle. This file will be skipped."
        }
    }
}

function Finalize-TargetBundle {
    Write-Output "Committing final manifest."
    "</FileActions>" | Out-File -Append -FilePath ".\output\StarBundle-$script:type-$script:version\MetaData\manifest.xml"
    "</StarBundle>" | Out-File -Append -FilePath ".\output\StarBundle-$script:type-$script:version\MetaData\manifest.xml"
    try {
        Write-Output "Committing StarBundle to ZIP file."
        Compress-Archive -Path ".\output\StarBundle-$script:type-$script:version\*" -DestinationPath ".\output\StarBundle-$script:type-$script:version.zip"
    }
    catch {
        Write-Error "Unable to commit bundle to ZIP file."
    }
}

#Runtime

Write-Output "Intellistar 2 Bundle Creation Tool"
Write-Output "Written by Skylar Gray for OpenTelecom"
Write-Output "Version 24.3.2`n`n`n"

Get-TargetBundleInformation
Prepare-TargetBundleFolder
Start-TargetBundleManifest
Commit-FilesToTargetBundle
Finalize-TargetBundle

Clear-Variable arrlst 
Clear-Variable type
Clear-Variable file
Clear-Variable version
Clear-Variable headend
