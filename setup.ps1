#
# Maintainer: Wei Peng <wei.peng@intel.com>
# Latest update: 20151218
#

<#
.SYNOPSIS
  Setup the Portable Windows Development Environment (PWDE) on the target machine.
.PARAMETER DownloadFromUpstream
  Download setup from the upstream repository. Useful when no local download exists.
.PARAMETER UpstreamURLPrefix
  Upstream URL Prefix (default: https://github.com/pw4ever/PWDE/releases/download/latest).
.PARAMETER PkgList
  List of packages to downloading/extraction. No need to specify unless to select a subset.
.PARAMETER ExcludePkg
  List of packages to be excluded from downloading/extraction.
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
    )]
    [switch]
    $DownloadFromUpstream,

    [Parameter(
    )]
    [String]
    $UpstreamURLPrefix="https://github.com/pw4ever/PWDE/releases/download/latest",

    # ls *.zip | % { write-host "`"$(basename $_ .zip)`","}
    [Parameter(
    )]
    [String[]]
    $PkgList=`
@(
"apache-maven",
"atom",
"Audacity",
"bin",
"ConEmuPack",
"config",
#"ctags",
"Documents",
"emacs",
"evince",
"ffmpeg",
"firefox",
"GIMP",
"Git",
"global",
"go",
"gradle",
"jdk",
"leiningen",
"m2",
"msys64",
#"Python27",
"R",
"SysinternalsSuite",
"VcXsrv",
"vim",
"VirtuaWin",
"vlc",
"WinKit"
),

    [Parameter(
    )]
    [String[]]
    $ExcludePkg,

    [Parameter(
    )]
    [switch]
    $DownloadOnly,

    [Parameter(
    )]
    $Destination,

    [Parameter(
    )]
    $ZipSource=$PSScriptRoot,

    [Parameter(
    )
    ]
    [switch]
    $SkipUnzipping,

    [Parameter(
    )
    ]
    [switch]
    $UpdatePSProfile,

    [Parameter(
    )
    ]
    [switch]
    $UpdateUserEnvironment,

    [Parameter(
    )
    ]
    [switch]
    $CreateShortcuts,

    [Parameter(
    )
    ]
    [switch]
    $CreateContextMenuEntries
)

if ($ExcludePkg) {
    $ExcludePkg=$($ExcludePkg | % { $_.ToUpper() })
}

$PkgList=$($PkgList | ? { ! $($_.ToUpper() -in $ExcludePkg) })

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
        unzip-files "$ZipSource" "$Destination" $PkgList
    }

    # extra setup beyond unzipping
    & {
        & "$PSScriptRoot\scripts\global.ps1" -Destination $Destination -PkgList $PkgList
        #& "$PSScriptRoot\scripts\python27.ps1" -Destination $Destination -PkgList $PkgList
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

function unzip-files ($src, $dest, $pkglist) {
    $jobs=@()
    $pkglist = $pkglist | % { "$_.zip" }
    ls "$src/*.zip" | % {
        # Unzip $_ only if it is in $pkglist
        if ($pkglist -like $_.Name) {
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
    }
    if ($jobs) {
        Wait-Job -Job $jobs | Out-Null
    }
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
#`$env:TERM="xterm"

`$env:JAVA_HOME="$("$prefix\jdk".Replace("\", "/"))"
`$env:_JAVA_OPTIONS="-Duser.home=`"$prefix`" "+`$env:_JAVA_OPTIONS

`$env:LEIN_HOME="$("$prefix\.lein".Replace("\", "/"))"
`$env:LEIN_JAVA_CMD="$("$prefix\jdk\bin\java.exe".Replace("\", "/"))"

`$env:GOROOT="$("$prefix\go".Replace("\", "/"))"
`$env:GOPATH="$([System.Environment]::GetFolderPath("MyDocuments").Replace("\", "/"))"

#`$env:PYTHONHOME="$("$prefix\Python27".Replace("\", "/"))"
#`$env:PYTHONPATH="$("$prefix\Python27\Lib\site-packages;$prefix\Python27\Lib".Replace("\", "/"))"

`$env:M2_HOME="$("$prefix\apache-maven".Replace("\", "/"))"
`$env:GRADLE_HOME="$("$prefix\gradle".Replace("\", "/"))"

`$env:R_HOME="$("$prefix\R".Replace("\", "/"))"

& {
    `$path=`$env:PATH
    @(
        "$prefix",
        "$prefix\bin",
        "$prefix\jdk\bin",
        "$prefix\gradle\bin",
        "$prefix\.lein\bin",
        "$prefix\Debuggers\x64",
        "$prefix\Windows Performance Toolkit",
        "$prefix\go\bin",
        $([IO.Path]::Combine([System.Environment]::GetFolderPath("MyDocuments"), "bin")),
        "$prefix\Git",
        "$prefix\Git\bin",
        #"$prefix\Python27",
        #"$prefix\Python27\Scripts",
        "$prefix\global\bin",
        #"$prefix\ctags",
        "$prefix\vim",
        "$prefix\SysinternalsSuite",
        "$prefix\ConEmuPack",
        "$prefix\VirtuaWin",
        "$prefix\firefox",
        "$prefix\evince\bin",
        "$prefix\Audacity",
        "$prefix\apache-maven\bin",
        "$prefix\vlc",
        "$prefix\ffmpeg\bin",
        "$prefix\R\bin\x64",
        "$prefix\GIMP\bin",
        "$prefix\VcXsrv\bin",
        "$prefix\atom\bin",
        "$prefix\atom\app-1.3.2",
        "$prefix\msys64\usr\bin",
        "$prefix\msys64\mingw64\bin",
        "$prefix\msys64\opt\bin"
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

    $path=$([String]::Join([IO.Path]::PathSeparator, `
                            @(
                            "$prefix",
                            "$prefix\bin",
                            "$prefix\jdk\bin",
                            "$prefix\gradle\bin",
                            "$prefix\.lein\bin",
                            "$prefix\Debuggers\x64",
                            "$prefix\Windows Performance Toolkit",
                            "$prefix\go\bin",
                            [IO.Path]::Combine([System.Environment]::GetFolderPath("MyDocuments"), "bin"),
                            "$prefix\Git",
                            "$prefix\Git\bin",
                            #"$prefix\Python27",
                            #"$prefix\Python27\Scripts",
                            "$prefix\global\bin",
                            #"$prefix\ctags",
                            "$prefix\vim",
                            "$prefix\SysinternalsSuite",
                            "$prefix\ConEmuPack",
                            "$prefix\VirtuaWin",
                            "$prefix\firefox",
                            "$prefix\evince\bin",
                            "$prefix\Audacity",
                            "$prefix\apache-maven\bin",
                            "$prefix\vlc",
                            "$prefix\ffmpeg\bin",
                            "$prefix\R\bin\x64",
                            "$prefix\GIMP\bin",
                            "$prefix\VcXsrv\bin",
                            "$prefix\atom\bin",
                            "$prefix\atom\app-1.3.2",
                            "$prefix\msys64\usr\bin",
                            "$prefix\msys64\mingw64\bin",
                            "$prefix\msys64\opt\bin",
                            "$env:PWDE_PERSISTENT_PATH"
                            )))


    @(
        @("HOME", $("$prefix".Replace("\", "/"))),
        @("PWDE_HOME", $prefix),

        @("EDITOR", $("$prefix\vim\gvim.exe".Replace("\", "/"))),
        @("ALTERNATE_EDITOR", $("$prefix\msys64\mingw64\bin\runemacs.exe".Replace("\", "/"))),
        @("PAGER", $("$prefix\msys64\usr\bin\less.exe".Replace("\", "/"))),
        #@("TERM", "xterm"),

        @("JAVA_HOME", $("$prefix\jdk".Replace("\", "/"))),
        @("_JAVA_OPTIONS", "-Duser.home=`"$prefix`" $env:PWDE_JAVA_OPTIONS"),
        @("LEIN_HOME", $("$prefix\.lein".Replace("\", "/"))),
        @("LEIN_JAVA_CMD", $("$prefix\jdk\bin\java.exe".Replace("\", "/"))),
        @("GOROOT", $("$prefix\go".Replace("\", "/"))),
        @("GOPATH", [System.Environment]::GetFolderPath("MyDocuments").Replace("\", "/")),
        #@("PYTHONHOME", $("$prefix\Python27".Replace("\", "/"))),
        #@("PYTHONPATH", $("$prefix\Python27\Lib\site-packages;$prefix\Python27\Lib".Replace("\", "/"))),
        @("M2_HOME", $("$prefix\apache-maven".Replace("\", "/"))),
        @("GRADLE_HOME", $("$prefix\gradle".Replace("\", "/"))),
        @("R_HOME", $("$prefix\R".Replace("\", "/"))),
        @("PATH_BAK", $env:PATH),
        @("PATH", $path)
    ) | % {
        if ($_) {
            $var, $val, $tar = $_
            Write-Host "Setting environment variable: |$var|=|$val|"
            Set-Content Env:\"$var" "$val"
            [Environment]::SetEnvironmentVariable($var, $val, [System.EnvironmentVariableTarget]::Process)
            [Environment]::SetEnvironmentVariable($var, $val, $(if ($tar) {$tar} else {[EnvironmentVariableTarget]::User}))
        }
    }

    # Change the current PATH
    $newpath=$([String]::Join(
                    [IO.Path]::PathSeparator, `
                    @(
                      [Environment]::GetEnvironmentVariable("PATH",
                                                            [EnvironmentVariableTarget]::Machine),
                      $path
                    )))
    Write-Host "Fixing current environment variable: |PATH|=|$newpath|."
    [Environment]::SetEnvironmentVariable("PATH", $newpath, [System.EnvironmentVariableTarget]::Process)
}

function create-shortcuts ($prefix) {
    $prefix=$(Resolve-Path "$prefix").Path.TrimEnd("\")

    function create-shortcuts-internal ([String]$src, [String]$shortcut, [String]$argument, [String]$hotkey) {
        # http://stackoverflow.com/a/9701907
        $sh = New-Object -ComObject WScript.Shell
        $s = $sh.CreateShortcut($shortcut)
        $s.TargetPath = $src
        if (![String]::IsNullOrEmpty($argument)) {
            $s.Arguments = $argument
        }
        if (![String]::IsNullOrEmpty($hotkey)) {
            $s.HotKey = $hotkey
        }
        $s.WorkingDirectory = $prefix
        $s.Save()
    }

    @(
        @("$prefix", "$env:USERPROFILE\Desktop\PWDE.lnk"),

        @("$prefix\SysinternalsSuite\procexp.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ProcExp.lnk"),

        @("$prefix\VcXsrv\xlaunch.exe", "$env:USERPROFILE\Desktop\XLaunch.lnk", "-run $prefix\VcXsrv\config.xlaunch"),
        @("$prefix\VcXsrv\xlaunch.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\XLaunch.lnk", "-run $prefix\VcXsrv\config.xlaunch"),

        @("$prefix\ConEmuPack\ConEmu64.exe", "$env:USERPROFILE\Desktop\ConEmu64.lnk", $NULL, "CTRL+ALT+q"),
        @("$prefix\ConEmuPack\ConEmu64.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ConEmu64.lnk"),

        @("$prefix\VirtuaWin\VirtuaWin.exe", "$env:USERPROFILE\Desktop\VirtuaWin.lnk"),
        @("$prefix\VirtuaWin\VirtuaWin.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\VirtuaWin.lnk"),

        @("$prefix\msys64\mingw64\bin\emacsclientw.exe", "$env:USERPROFILE\Desktop\Emacs.lnk", "-c -a `"$prefix\msys64\mingw64\bin\runemacs.exe`""),
        @("$prefix\msys64\mingw64\bin\runemacs.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\EmacsServer.lnk", "--eval `"(server-start)`""),

        @("$prefix\vim\gvim.exe", "$env:USERPROFILE\Desktop\GVim.lnk"),

        @("$prefix\R\bin\x64\Rgui.exe", "$env:USERPROFILE\Desktop\RGui x64.lnk"),

        @("$prefix\GIMP\bin\gimp-2.8.exe", "$env:USERPROFILE\Desktop\GIMP-2.8.lnk"),

        @("$prefix\atom\app-1.3.2\atom.exe", "$env:USERPROFILE\Desktop\Atom.lnk"),

        @("$prefix\firefox\firefox.exe", "$env:USERPROFILE\Desktop\FireFox.lnk")
    ) | % {
        if ($_) {
            $src, $shortcut, $argument, $hotkey = $_
          if (Test-Path "$src") {
              Write-Host "Shortcut: $src Arguments:`"$args`" Shortcut:`"$hotkey`" => $shortcut"
              create-shortcuts-internal $src $shortcut $argument $hotkey
            }
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
        @("Open in ConEmu", "`"$prefix\ConEmuPack\ConEmu64.exe`" /cmd {PowerShell}", "$prefix\ConEmuPack\ConEmu64.exe"),
        @("Open in ConEmu (Admin)", "`"$prefix\ConEmuPack\ConEmu64.exe`" /cmd {PowerShell (Admin)}", "$prefix\ConEmuPack\ConEmu64.exe"),
        @("Open in Emacs", "`"$prefix\msys64\mingw64\bin\emacsclientw.exe`" -c -a `"$prefix\msys64\mingw64\bin\runemacs.exe`"", "$prefix\msys64\mingw64\bin\emacsclientw.exe"),
        @("Open in Emacs (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\msys64\mingw64\bin\runemacs.exe`"", "$prefix\msys64\mingw64\bin\runemacs.exe"),
        @("Open with Vim", "`"$prefix\vim\gvim.exe`"", "$prefix\vim\gvim.exe"),
        @("Open with Vim (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\vim\gvim.exe`"", "$prefix\vim\gvim.exe"),
        @("Open with Atom", "`"$prefix\atom\app-1.3.2\atom.exe`"", "$prefix\atom\app-1.3.2\atom.exe"),
        @("Open with Atom (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\atom\app-1.3.2\atom.exe`"", "$prefix\atom\app-1.3.2\atom.exe"),
        $NULL
    ) | % {
        if ($_) {
            $name, $value, $testpath = $_
            # either $testpath is $null, or $testpath must exists.
            if (!$testpath -or $(Test-Path "$testpath")) {
                Write-Host "Directory Context Menu: $name => $value"
                $regpath = "HKCR:\Directory\Background\shell\$name"
                New-Item -Path "$regpath\Command" -Force | Out-Null
                Set-ItemProperty -Path "$regpath" -Name "(Default)" -Value "$name"
                Set-ItemProperty -Path "$regpath\Command" -Name "(Default)" -Value "$value"
            }
        }
    }

    # All File Type Context Menu
    pushd -LiteralPath "HKCR:\*\shell"
    @(
        @("Edit with Emacs", "`"$prefix\msys64\mingw64\bin\emacsclientw.exe`" -c -a `"$prefix\msys64\mingw64\bin\runemacs.exe`" `"%1`"", "$prefix\msys64\mingw64\bin\emacsclientw.exe"),
        @("Edit with Emacs (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\msys64\mingw64\bin\runemacs.exe`" `"%1`"", "$prefix\msys64\mingw64\bin\runemacs.exe"),
        @("Edit with Vim", "`"$prefix\vim\gvim.exe`" `"%1`"", "$prefix\vim\gvim.exe"),
        @("Edit with Vim (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\vim\gvim.exe`" `"%1`"", "$prefix\vim\gvim.exe"),
        @("Open with Atom", "`"$prefix\atom\app-1.3.2\atom.exe`" `"%1`"", "$prefix\atom\app-1.3.2\atom.exe"),
        @("Open with Atom (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\atom\app-1.3.2\atom.exe`" `"%1`"", "$prefix\atom\app-1.3.2\atom.exe"),
        $NULL
    ) | % {
        if ($_) {
            $name, $value, $testpath = $_
            if (!$testpath -or $(Test-Path "$testpath")) {
                Write-Host "All File Type Context Menu: $name => $value"
                $regpath = "$name"
                New-Item -Path "$regpath\Command" -Force | Out-Null
                Set-ItemProperty -Path "$regpath" -Name "(Default)" -Value "$name"
                Set-ItemProperty -Path "$regpath\Command" -Name "(Default)" -Value "$value"
            }
        }
    }
    popd

    Remove-PSDrive -Name HKCR
}

main
