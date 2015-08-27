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
$download=[System.IO.Path]::Combine($dir, "00download")

@(
"setuptools-16.0-py2.py3-none-any.whl",
"pip-7.1.2-py2.py3-none-any.whl",
"Pygments-2.0.2-py2-none-any.whl"
) | % {    
    Write-Host "$python -m pip install -I `"$download\$_`""
    Invoke-Expression "$python -m pip install -I `"$download\$_`""
}

}


main
