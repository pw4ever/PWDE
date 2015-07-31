#
# Intel Windows Operating System (WOS) PowerShell (PS) suite.
# Initialize PowerShell environment.
# 
# Maintainer: Wei Peng <wei.peng@intel.com>
# Latest update: 20150717
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

    # Aliases
    Write-Host "Setting up aliases."
    & {
        Set-Alias gh Get-Help -scope global
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