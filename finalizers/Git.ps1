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
  $cmd=(Get-Command git -ErrorAction SilentlyContinue).path
  if (![String]::IsNullOrWhiteSpace($cmd)) {
    @(
        "config --global push.default upstream",
        "config --global diff.tool vimdiff",
        "config --global difftool.prompt false",
        "config --global merge.tool vimdiff",
        "config --global mergetool.prompt false",
        $NULL
    ) | ? { ![String]::IsNullOrWhiteSpace($_) } | % {
      $arg = $_
      $fullcmd = @"
& "$cmd" $arg
"@
      Write-Verbose $fullcmd
      Invoke-Expression $fullcmd
    }
  }
}

main