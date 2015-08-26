# 
# Maintainer: Wei Peng <wei.peng@intel.com>
# Latest update: 20150825
#

<#
.SYNOPSIS
  Setup the Portable Windows Development Environment (PWDE) on the target machine.
.PARAMETER DownloadFromUpstream
  Download setup from the upstream repository. Useful when no local download exists.
.PARAMETER UpstreamURLPrefix
  Upstream URL Prefix (default: https://github.com/pw4ever/PWDE/releases/download/latest).
.PARAMETER PkgList
  List of ZIP packages to download/extract. No need to specify unless to select a subset.
.PARAMETER DownloadOnly
  Stop after downloading.
.PARAMETER Destination
  Destination path.
.PARAMETER ZipSource
  Zip source path (default to `$PSScriptRoot).
.PARAMETER SkipUnzipping
  Skip the time-consuming unzipping.
.PARAMETER UpdatePSProfile
  Make settings persistent by sourcing "init.ps1" in PoSH profile.
.PARAMETER UpdateUserEnvironment
  Make settings persistent in user environment.
.PARAMETER CreateShortcuts
  Create Desktop shortcuts.
.PARAMETER CreateContextMenuEntries
  Create context menu entries (requires Admin privilege).
#>

[CmdletBinding(
SupportsShouldProcess=$True,
# named argument required to prevent accidental unzipping
PositionalBinding=$False
)]
param(
    [Parameter(
    HelpMessage="Download setup from upstream repository to ZipSource. Useful when no local download exists."    
    )]
    [switch]
    $DownloadFromUpstream,

    [Parameter(
    HelpMessage="Upstream URL Prefix (default: https://github.com/pw4ever/PWDE/releases/download/latest)."    
    )]
    [String]
    $UpstreamURLPrefix="https://github.com/pw4ever/PWDE/releases/download/latest",

    # ls *.zip | % { write-host "`"$(basename $_ .zip)`","}
    [Parameter(
    HelpMessage="List of ZIP packages to download/extract. No need to specify unless to select a subset."    
    )]
    [String[]]
    $PkgList=`
@(
"apache-maven",
"bin",
"ConEmuPack",
"config",
"Documents",
"emacs",
"evince",
"firefox",
"GIMP",
"gradle",
"jdk",
"leiningen",
"m2",
"msys64",
"R",
"SysinternalsSuite",
"vim",
"VirtuaWin",
"vlc"
),

    [Parameter(
    HelpMessage="Stop after downloading."    
    )]
    [switch]
    $DownloadOnly,

    [Parameter(
    HelpMessage="Destination path."    
    )]
    $Destination,

    [Parameter(
    HelpMessage="Zip source path (default to `$PSScriptRoot)."
    )]
    $ZipSource=$PSScriptRoot,

    [Parameter(
    HelpMessage="Skip the time-consuming unzipping."
    )
    ]
    [switch]
    $SkipUnzipping,

    [Parameter(
    HelpMessage="Make settings persistent in PoSH Profile."
    )
    ]
    [switch]
    $UpdatePSProfile,

    [Parameter(
    HelpMessage="Make settings persistent in user environment."
    )
    ]
    [switch]
    $UpdateUserEnvironment,

    [Parameter(
    HelpMessage="Create Desktop shortcuts to common utilities."
    )
    ]
    [switch]
    $CreateShortcuts,

    [Parameter(
    HelpMessage="Create context menu entries (requires Admin privilege)."
    )
    ]
    [switch]
    $CreateContextMenuEntries
)

function main
{
    if ($DownloadFromUpstream) {
        ensure-dir $ZipSource
        download-upstream $UpstreamURLPrefix $ZipSource $PkgList
    }

    if ($DownloadOnly) {
        return
    }
    elseif (! $Destination) {
        Write-Error "Need Destination if not DownloadOnly"
        return
    }

    ensure-dir $Destination    
    $Destination=$(Resolve-Path $Destination)

    if (!$SkipUnzipping) {
        $ZipSource=$(Resolve-Path $ZipSource)
        unzip-files "$ZipSource" "$Destination"
    }
    
    # extra setup beyond unzipping
    & {
        .\scripts\global.ps1 -Destination $Destination -PkgList $PkgList
    }    

    $initscript = [IO.Path]::Combine($Destination, "init.ps1")
    init $initscript

    if ($UpdatePSProfile) {
        update-psprofile $initscript
    }

    if ($UpdateUserEnvironment) {        
        update-userenv $Destination
    }

    if ($CreateShortcuts) {
        create-shortcuts $Destination
    }

    if ($CreateContextMenuEntries) {
        create-contextmenuentries $Destination
    }
}

function download-upstream ($srcprefix, $destprefix, $pkgs) {
    # http://stackoverflow.com/a/28704050
    $wc = New-Object Net.WebClient

    $list = @("7za.exe") + @($pkgs | % {"$_.zip"})

    foreach ($item in $list) {
        $src="$srcprefix/$item"
        $dest="$destprefix/$item"

        $wc.DownloadFile($src, $dest)
        Write-Host "$src downloaded to $dest."        
    }
}

function ensure-dir ($dir) {
    if (!$(Test-Path $dir)) {
        mkdir $dir -Force > $NULL
        Write-Host "$dir created."
    }
}

function unzip-files ($src, $dest) {
    $jobs=@()
    ls "$src/*.zip" | % {
        $name=$_.FullName
        Write-Host "Unzipping $name."
        # Start background jobs for unzipping
        $jobs+=$(Start-Job -ScriptBlock {
                    param($name, $dest, $src)

                    function unzip ($zipfile, $dest, $src) {
                        #ensure-dir $dest
                        #[IO.Compression.ZipFile]::ExtractToDirectory($zipfle, $dest)
                        Invoke-Expression "$src\7za.exe x -o`"$dest`" -y -- `"$zipfile`"" # > $NULL
                    }

                    unzip "$name" "$dest" "$src"
                    Write-Host "$name unzipped."
                    } `
                    -ArgumentList "$name", "$dest", "$src"
                    )        
    }
    Wait-Job -Job $jobs
}

function init ($initscript) {
New-Item -Path "$initscript" -Force -ItemType File > $NULL
$initscript=$(Resolve-Path "$initscript")
$prefix=$(Split-Path "$initscript" -Parent).TrimEnd("\")
@"
# For app that looks for HOME, e.g., Emacs, Vim
`$env:HOME="$("$prefix".Replace("\", "/"))"
`$env:PWDE_HOME="$prefix"

`$env:EDITOR="$("$prefix\vim\gvim.exe".Replace("\", "/"))"
`$env:PAGER="$("$prefix\msys64\usr\bin\less.exe".Replace("\", "/"))"
`$env:TERM="xterm"

`$env:JAVA_HOME="$("$prefix\jdk".Replace("\", "/"))"
`$env:_JAVA_OPTIONS="-Duser.home=`"$prefix`" "+`$env:_JAVA_OPTIONS

`$env:LEIN_HOME="$("$prefix\.lein".Replace("\", "/"))"
`$env:LEIN_JAVA_CMD="$("$prefix\jdk\bin\java.exe".Replace("\", "/"))"

`$env:M2_HOME="$("$prefix\apache-maven".Replace("\", "/"))"
`$env:GRADLE_HOME="$("$prefix\gradle".Replace("\", "/"))"

`$env:R_HOME="$("$prefix\R".Replace("\", "/"))"

& {
    `$path=`$env:PATH
    @(      
        "$prefix",
        "$prefix\bin",
        "$prefix\jdk\bin",
        "$prefix\msys64\usr\bin",
        "$prefix\msys64\mingw64\bin",
        "$prefix\msys64\opt\bin",
        "$prefix\gradle\bin",
        "$prefix\.lein\bin",
        "$prefix\vim",
        "$prefix\SysinternalsSuite",
        "$prefix\ConEmuPack",
        "$prefix\VirtuaWin",
        "$prefix\firefox",
        "$prefix\evince\bin",
        "$prefix\apache-maven\bin",
        "$prefix\vlc",
        "$prefix\R\bin\x64",
        "$prefix\GIMP\bin"
    ) | % {
        `$p=`$_
        if (!`$("`$path" | Select-String -Pattern "`$p" -SimpleMatch)) {    
            `$env:PATH="`$p;`$env:PATH"
        }
    }

    if (`$env:PWDE_PERSISTENT_PATH) {
        `$env:PATH+=";`$env:PWDE_PERSISTENT_PATH"
    }
}
"@ | Set-Content -Path "$initscript" -Force

Write-Host "$initscript created."
}

function update-psprofile ($initscript) {
# Get the full path to $initscript.
$initscript=$(Resolve-Path $initscript).Path

if ($initscript -and !$(Get-Content $Profile | Select-String -Pattern "$initscript" -SimpleMatch)) {
@"
# Initialize the Portable Development Environment (PDevEnv).
. $initscript
"@ | Add-Content -Path $Profile -Force
}
 
Write-Host "$Profile will source $initscript."
}

function update-userenv ($prefix) {
    $prefix=$(Resolve-Path "$prefix").Path.TrimEnd("\")

    @(        
        @("HOME", $("$prefix".Replace("\", "/"))),
        @("PWDE_HOME", $prefix),

        @("EDITOR", $("$prefix\vim\gvim.exe".Replace("\", "/"))),
        @("PAGER", $("$prefix\msys64\usr\bin\less.exe".Replace("\", "/"))),
        @("TERM", "xterm"),

        @("JAVA_HOME", $("$prefix\jdk".Replace("\", "/"))),
        @("_JAVA_OPTIONS", "-Duser.home=`"$prefix`" $env:PWDE_JAVA_OPTIONS"),
        @("LEIN_HOME", $("$prefix\.lein".Replace("\", "/"))),
        @("LEIN_JAVA_CMD", $("$prefix\jdk\bin\java.exe".Replace("\", "/"))),
        @("M2_HOME", $("$prefix\apache-maven".Replace("\", "/"))),
        @("GRADLE_HOME", $("$prefix\gradle".Replace("\", "/"))),
        @("R_HOME", $("$prefix\R".Replace("\", "/"))),        
        @("PATH_BAK", $env:PATH),
        @("PATH", $([String]::Join([IO.Path]::PathSeparator, `
            @(            
            "$prefix",
            "$prefix\bin",
            "$prefix\jdk\bin",
            "$prefix\msys64\usr\bin",
            "$prefix\msys64\mingw64\bin",
            "$prefix\msys64\opt\bin",
            "$prefix\gradle\bin",
            "$prefix\.lein\bin",
            "$prefix\vim",
            "$prefix\SysinternalsSuite",
            "$prefix\ConEmuPack",
            "$prefix\VirtuaWin",
            "$prefix\firefox",
            "$prefix\evince\bin",
            "$prefix\apache-maven\bin",
            "$prefix\vlc",
            "$prefix\R\bin\x64",
            "$prefix\GIMP\bin",
            "$env:PWDE_PERSISTENT_PATH"
            ))))
    ) | % {
        if ($_) {
            $var, $val, $tar = $_
            Write-Host "Setting environment variable: |$var|=|$val|"
            [Environment]::SetEnvironmentVariable($var, $val, $(if ($tar) {$tar} else {[EnvironmentVariableTarget]::User}))
        }
    }
}

function create-shortcuts ($prefix) {
    $prefix=$(Resolve-Path "$prefix").Path.TrimEnd("\")

    function cs ([String]$src, [String]$shortcut, [String]$hotkey) {
        # http://stackoverflow.com/a/9701907
        $sh = New-Object -ComObject WScript.Shell
        $s = $sh.CreateShortcut($shortcut)
        $s.TargetPath = "$src"
        if ($hotkey) {
            $s.HotKey = "$hotkey"
        }
        # Relative working directory
        $s.WorkingDirectory = ""
        $s.Save()
    }

    @(        
        @("$prefix", "$env:USERPROFILE\Desktop\PWDE.lnk"),

        @("$prefix\ConEmuPack\ConEmu64.exe", "$env:USERPROFILE\Desktop\ConEmu64.lnk", "CTRL+ALT+q"),
        @("$prefix\ConEmuPack\ConEmu64.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ConEmu64.lnk"),

        @("$prefix\VirtuaWin\VirtuaWin.exe", "$env:USERPROFILE\Desktop\VirtuaWin.lnk"),
        @("$prefix\VirtuaWin\VirtuaWin.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\VirtuaWin.lnk"),

        @("$prefix\msys64\mingw64\bin\runemacs.exe", "$env:USERPROFILE\Desktop\Emacs.lnk"),        

        @("$prefix\vim\gvim.exe", "$env:USERPROFILE\Desktop\GVim.lnk"),

        @("$prefix\R\bin\x64\Rgui.exe", "$env:USERPROFILE\Desktop\RGui x64.lnk"),

        @("$prefix\GIMP\bin\gimp-2.8.exe", "$env:USERPROFILE\Desktop\GIMP-2.8.lnk"),

        @("$prefix\firefox\firefox.exe", "$env:USERPROFILE\Desktop\FireFox.lnk")        
    ) | % {        
        if ($_) {
            $src, $shortcut, $hotkey = $_
	        Write-Host "Shortcut: $src => $shortcut"
            cs "$src" "$shortcut" $(if ($hotkey) {$hotkey} else {$NULL})
        }
    }
}

function create-contextmenuentries ($prefix) {
    $prefix=$(Resolve-Path "$prefix").Path.TrimEnd("\")

    # https://gallery.technet.microsoft.com/scriptcenter/Script-to-add-an-item-to-f523f1f3
    # http://www.howtogeek.com/107965/how-to-add-any-application-shortcut-to-windows-explorers-context-menu/

    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

    # Directory Context Menu
    @(        
        @("Open in ConEmu", "`"$prefix\ConEmuPack\ConEmu64.exe`" /cmd {PowerShell}"),
        @("Open in ConEmu (Admin)", "`"$prefix\ConEmuPack\ConEmu64.exe`" /cmd {PowerShell (Admin)}"),
        @("Open in Emacs", "`"$prefix\msys64\mingw64\bin\runemacs.exe`"")        
    ) | % {        
        if ($_) {
            $name, $value = $_
	    Write-Host "Directory Context Menu: $name => $value"
            $regpath = "HKCR:\Directory\Background\shell\$name"
            New-Item -Path "$regpath\Command" -Force | Out-Null
            Set-ItemProperty -Path "$regpath" -Name "(Default)" -Value "$name"
            Set-ItemProperty -Path "$regpath\Command" -Name "(Default)" -Value "$value"
        }        
    }

    # All File Type Context Menu
    pushd -LiteralPath "HKCR:\*\shell"
    @(        
        @("Edit with Emacs", "`"$prefix\msys64\mingw64\bin\runemacs.exe`" %1"),        
        @("Edit with Vim", "`"$prefix\vim\gvim.exe`" %1")
    ) | % {        
        if ($_) {
            $name, $value = $_
	    Write-Host "All File Type Context Menu: $name => $value"	    
            $regpath = "$name"
            New-Item -Path "$regpath\Command" -Force | Out-Null
            Set-ItemProperty -Path "$regpath" -Name "(Default)" -Value "$name"
            Set-ItemProperty -Path "$regpath\Command" -Name "(Default)" -Value "$value"
        }        
    }
    popd

    Remove-PSDrive -Name HKCR
}

main
