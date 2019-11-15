<#
.SYNOPSIS
  Portable Windows Development Environment (PWDE) finalizer.
.PARAMETER Destination
  Destination path.
#>

[CmdletBinding(
SupportsShouldProcess=$True,
PositionalBinding=$False
)]
param(
    [Parameter(
    HelpMessage="Destination path.",
    Mandatory=$True
    )]
    $Destination
)

function main
{
  $cmd=(Get-Command NegativeScreen.exe -ErrorAction SilentlyContinue).path
  if (![String]::IsNullOrWhiteSpace($cmd)) {
    $config_src = "$PSScriptRoot\negativescreen.conf"
    $config_dst = "${env:AppData}\NegativeScreen\"

    if ((Test-Path $config_src -PathType Leaf)) {
      if (!(Test-Path $config_dst -PathType Container)) { New-Item $config_dst -Force -ItemType Directory > $NULL }
      if (Test-Path $config_dst -PathType Container) {
        Copy-Item -Path $config_src -Destination $config_dst
      }
    }
  }
}

main