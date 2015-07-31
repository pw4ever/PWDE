#
# Setup the portable development environment (PDevEnv) on the target machine.
# 
# Maintainer: Wei Peng <wei.peng@intel.com>
# Latest update: 20150730
#

[CmdletBinding(
SupportsShouldProcess=$True
)]
param(
    [Parameter(
    HelpMessage="Destination path.",
    Mandatory
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
    HelpMessage="Create shortcuts."
    )
    ]
    [switch]
    $CreateShortcuts,

    [Parameter(
    HelpMessage="Create context menu entries."
    )
    ]
    [switch]
    $CreateContextMenuEntries
)

function main
{
    ensure-dir $Destination
    
    $Destination=$(Resolve-Path $Destination)

    if (!$SkipUnzipping) {
        $ZipSource=$(Resolve-Path $ZipSource)
        unzip-files "$ZipSource" "$Destination"
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
                        Invoke-Expression "$src\7za.exe -o$dest -y x $zipfile" > $NULL
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
$prefix=$(Split-Path "$initscript" -Parent)
@"
# For app that looks for HOME, e.g., Emacs, Vim
`$env:HOME="$prefix"
`$env:PWDE_HOME="$prefix"

`$env:JAVA_HOME="$prefix\jdk"
`$env:_JAVA_OPTIONS+=" -Duser.home=$prefix"

`$env:LEIN_HOME="$prefix\.lein"
`$env:LEIN_JAVA_CMD="$prefix\jdk\bin\java.exe"

`$env:M2_HOME="$prefix\apache-maven"
`$env:GRADLE_HOME="$prefix\gradle"

`$env:EDITOR="$prefix\vim\gvim.exe"

% {
`$path=`$env:PATH
@(
"$prefix"
"$prefix\bin"
"$prefix\jdk\bin"
"$prefix\.lein\bin"
"$prefix\emacs\bin"
"$prefix\vim"
"$prefix\MinGW\bin"
"$prefix\Git"
"$prefix\Git\cmd"
"$prefix\Git\bin"
"$prefix\global\bin"
"$prefix\ctags"
"$prefix\putty"
"$prefix\SysinternalsSuite"
"$prefix\ConEmuPack"
"$prefix\VirtuaWin"
"$prefix\firefox"
"$prefix\apache-maven\bin"
"$prefix\gradle\bin"
) | % {
`$p=`$_
if (!`$("`$path" | Select-String -Pattern "`$p" -SimpleMatch)) {    
    `$env:PATH="`$p;`$env:PATH"
}
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
setx HOME "$prefix"
setx PWDE_HOME "$prefix"

setx JAVA_HOME "$prefix\jdk"
setx _JAVA_OPTIONS $([String]::Join(" ", @($env:_JAVA_OPTIONS, "-Duser.home=$prefix")))

setx LEIN_HOME "$prefix\.lein"
setx LEIN_JAVA_CMD "$prefix\jdk\bin\java.exe"

setx M2_HOME "$prefix\apache-maven"
setx GRADLE_HOME "$prefix\gradle"

setx EDITOR "$prefix\vim\gvim.exe"
    
setx PATH $([String]::Join(";", `
@(
"$prefix"
"$prefix\bin"
"$prefix\jdk\bin"
"$prefix\.lein\bin"
"$prefix\emacs\bin"
"$prefix\vim"
"$prefix\MinGW\bin"
"$prefix\Git"
"$prefix\Git\cmd"
"$prefix\Git\bin"
"$prefix\global\bin"
"$prefix\ctags"
"$prefix\putty"
"$prefix\SysinternalsSuite"
"$prefix\ConEmuPack"
"$prefix\VirtuaWin"
"$prefix\firefox"
"$prefix\apache-maven\bin"
"$prefix\gradle\bin"
"$env:PATH"
)))
}

function create-shortcuts ($prefix) {
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

        @("$prefix\emacs\bin\runemacs - admin.exe", "$env:USERPROFILE\Desktop\emacs-admin.lnk"),
        @("$prefix\emacs\bin\runemacs - user.exe", "$env:USERPROFILE\Desktop\emacs-user.lnk"),

        @("$prefix\vim\gvim.exe", "$env:USERPROFILE\Desktop\GVim.lnk"),

        @("$prefix\firefox\firefox.exe", "$env:USERPROFILE\Desktop\FireFox.lnk"),

        $NULL
    ) | % {        
        if ($_) {
            $src, $shortcut, $hotkey = $_
	    Write-Host "Shortcut: $src => $shortcut"
            cs "$src" "$shortcut" $(if ($hotkey) {$hotkey} else {$NULL})
        }
    }
}

function create-contextmenuentries ($prefix) {
    # https://gallery.technet.microsoft.com/scriptcenter/Script-to-add-an-item-to-f523f1f3
    # http://www.howtogeek.com/107965/how-to-add-any-application-shortcut-to-windows-explorers-context-menu/

    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

    # Directory Context Menu
    @(
        @("Open in ConEmu", "`"$prefix\ConEmuPack\ConEmu64.exe`" /cmd {PowerShell}"),
        @("Open in ConEmu (Admin)", "`"$prefix\ConEmuPack\ConEmu64.exe`" /cmd {PowerShell (Admin)}"),
        @("Open in Emacs", "`"$prefix\emacs\bin\runemacs - user.exe`""),
        @("Open in Emacs (Admin)", "`"$prefix\emacs\bin\runemacs - admin.exe`""),
        $NULL
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
        @("Edit with Emacs", "`"$prefix\emacs\bin\runemacs - user.exe`" %1"),
        @("Edit with Emacs (Admin)", "`"$prefix\emacs\bin\runemacs - admin.exe`" %1"),
        @("Edit with Vim", "`"$prefix\vim\gvim.exe`" %1"),
        $NULL
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