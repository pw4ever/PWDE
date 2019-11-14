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
  $cmd=(Get-Command cmder -ErrorAction SilentlyContinue).path
  if (![String]::IsNullOrWhiteSpace($cmd)) {
    $config_src = "$PSScriptRoot\cmder_1pengw.xml"
    $config_dst = "$(Split-Path $cmd)\vendor\conemu-maximus5\ConEmu.xml"

    if ((Test-Path $config_src -PathType Leaf)) {
      Copy-Item -Path $config_src -Destination $config_dst -Verbose
    }
  }
}

main