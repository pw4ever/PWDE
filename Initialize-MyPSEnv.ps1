# 
# Maintainer: Wei Peng <wei.peng@intel.com>
# Latest update: 20150825
#

function mypsenv-main
{
    if (!$(Test-Path "$Profile")) {
        Write-Host "Creating $Profile."
        New-Item -Path "$Profile" -ItemType File -Force > $NULL   
    }
    if ("$PSCommandPath" -ne "$Profile") {
        Write-Host "Populating $Profile."
        Get-Content "$PSCommandPath" | Add-Content "$Profile" -Force -Encoding UTF8
    }

    # PSReadline
    $module="PSReadline"
    Write-Host "Setting up module $module."
    Ensure-Module $module
    & {
       Set-PSReadlineOption -EditMode Emacs 
    }
}

function global:Ensure-Module ($module) {
    # Ensure $module is available
    if (!$(Get-Module $module) ) {
        # Ensure Install-Module is available
        if (!$(Get-Command Install-Module 2> $NULL)) {
            # If Install-Module is not availavle, install PSGet
            # See also: http://psget.net/
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
            (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
        }
        Install-Module $module
    }    
    Import-Module $module
}

mypsenv-main

Write-Host "Setting up aliases."
Set-Alias gh Get-Help -scope global
Remove-Item Alias:man -Force 2>&1 | Out-Null
Remove-Item Alias:wget -Force 2>&1 | Out-Null
Remove-Item Alias:curl -Force 2>&1 | Out-Null
Remove-Item Alias:diff -Force 2>&1 | Out-Null
Remove-Item Alias:h -Force 2>&1 | Out-Null
Remove-Item Alias:r -Force 2>&1 | Out-Null