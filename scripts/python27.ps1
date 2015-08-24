<#
.SYNOPSIS
  Setup the Portable Windows Development Environment (PWDE) on the target machine.
.PARAMETER PkgList
  List of ZIP packages to download/extract. No need to specify unless to select a subset.
.PARAMETER Destination
  Destination path.
#>

[CmdletBinding(
SupportsShouldProcess=$True,
# named argument required to prevent accidental unzipping
PositionalBinding=$False
)]
param(
    # ls *.zip | % { write-host "`"$(basename $_ .zip)`","}
    [Parameter(
    HelpMessage="List of ZIP packages to download/extract. No need to specify unless to select a subset."    
    )]
    [String[]]
    $PkgList,

    [Parameter(
    HelpMessage="Destination path.",
    Mandatory=$True
    )]
    $Destination
)

function ensure-dir ($dir) {
    if (!$(Test-Path $dir)) {
        mkdir $dir -Force > $NULL
        Write-Host "$dir created."
    }
}

function main
{

    ensure-dir $Destination    
    $Destination=$(Resolve-Path $Destination)
    
    if ("Python27" -in $PkgList) {
        work $Destination
    }    
}


function work ($prefix) {
$prefix=$(Resolve-Path "$prefix")

$dir=[System.IO.Path]::Combine($prefix, "Python27")
$python=[System.IO.Path]::Combine($dir, "python")
$cache=[System.IO.Path]::Combine($dir, "cache")

@(
    "$python -m pip install --upgrade --force-reinstall --cache-dir $cache setuptools==16.0"
    "$python -m pip install --upgrade --force-reinstall --cache-dir $cache pip==7.1.2"
    "$python -m pip install --upgrade --force-reinstall --cache-dir $cache pygments==1.6"
) | % {
    Write-Host $_
    Invoke-Expression $_
}

}


main
