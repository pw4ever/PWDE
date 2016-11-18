#
# Maintainer: Wei Peng <wei.peng@intel.com>
# Latest update: 20161118
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
"ClojureCLR",
"ConEmuPack",
"config",
"Documents",
"emacs",
"evince",
"ffmpeg",
#"firefox",
"GIMP",
"Git",
"global",
"go",
"gradle",
"iasl",
"jdk",
"Launchy",
"leiningen",
"m2",
"mRemoteNG",
"msys64",
"nodejs",
"nmap",
"PEBrowse64",
"PEBrowsePro",
"R",
"radare2",
"Recoll",
"RWEverything",
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
#`$env:TERM="xterm"

$(if ($pkglist -contains "vim") { @"
`$env:EDITOR="$("$prefix\vim\gvim.exe".Replace("\", "/"))"
"@ })
$(if ($pkglist -contains "msys64") { @"
`$env:PAGER="$("$prefix\msys64\usr\bin\less.exe".Replace("\", "/"))"
"@ })

$(if ($pkglist -contains "jdk") { @"
`$env:JAVA_HOME="$("$prefix\jdk".Replace("\", "/"))"
`$env:_JAVA_OPTIONS="-Duser.home=`"$prefix`" "+`$env:_JAVA_OPTIONS
`$env:LEIN_JAVA_CMD="$("$prefix\jdk\bin\java.exe".Replace("\", "/"))"
"@ })

$(if ($pkglist -contains "leiningen") { @"
`$env:LEIN_HOME="$("$prefix\.lein".Replace("\", "/"))"
"@ })

$(if ($pkglist -contains "go") { @"
`$env:GOROOT="$("$prefix\go".Replace("\", "/"))"
`$env:GOPATH="$([System.Environment]::GetFolderPath("MyDocuments").Replace("\", "/"))"
"@ })

$(if ($pkglist -contains "apache-maven") { @"
`$env:M2_HOME="$("$prefix\apache-maven".Replace("\", "/"))"
"@ })

$(if ($pkglist -contains "gradle") { @"
`$env:GRADLE_HOME="$("$prefix\gradle".Replace("\", "/"))"
"@ })

$(if ($pkglist -contains "R") { @"
`$env:R_HOME="$("$prefix\R".Replace("\", "/"))"
"@ })

& {
    `$path=`$env:PATH
    @(
        "$prefix",
$(if ($pkglist -contains "bin") { @"
        "$prefix\bin",
"@ })
$(if ($pkglist -contains "jdk") { @"
        "$prefix\jdk\bin",
"@ })
$(if ($pkglist -contains "gradle") { @"
        "$prefix\gradle\bin",
"@ })
$(if ($pkglist -contains "leiningen") { @"
        "$prefix\.lein\bin",
"@ })
$(if ($pkglist -contains "ClojureCLR") { @"
        "$prefix\ClojureCLR",
"@ })
$(if ($pkglist -contains "nodejs") { @"
        "$prefix\nodejs",
"@ })
$(if ($pkglist -contains "go") { @"
        "$prefix\go\bin",
"@ })
        "$([IO.Path]::Combine([System.Environment]::GetFolderPath("MyDocuments"), "bin"))",
$(if ($pkglist -contains "Git") { @"
        "$prefix\Git",
        "$prefix\Git\cmd",
"@ })
$(if ($pkglist -contains "global") { @"
        "$prefix\global\bin",
"@ })
$(if ($pkglist -contains "emacs") { @"
        "$prefix\emacs\bin",
"@ })
$(if ($pkglist -contains "vim") { @"
        "$prefix\vim",
"@ })
$(if ($pkglist -contains "nmap") { @"
        "$prefix\nmap",
"@ })
$(if ($pkglist -contains "SysinternalsSuite") { @"
        "$prefix\SysinternalsSuite",
"@ })
$(if ($pkglist -contains "WinKit") { @"
        "$prefix\WinKit\bin",
        "$prefix\WinKit\dbg",
        "$prefix\WinKit\tools",
        "$prefix\WinKit\wpt",
"@ })
$(if ($pkglist -contains "ConEmuPack") { @"
        "$prefix\ConEmuPack",
"@ })
$(if ($pkglist -contains "VirtuaWin") { @"
        "$prefix\VirtuaWin",
"@ })
$(if ($pkglist -contains "firefox") { @"
        "$prefix\firefox",
"@})
$(if ($pkglist -contains "evince") { @"
        "$prefix\evince\bin",
"@ })
$(if ($pkglist -contains "Audacity") { @"
        "$prefix\Audacity",
"@ })
$(if ($pkglist -contains "apache-maven") { @"
        "$prefix\apache-maven\bin",
"@ })
$(if ($pkglist -contains "vlc") { @"
        "$prefix\vlc",
"@ })
$(if ($pkglist -contains "ffmpeg") { @"
        "$prefix\ffmpeg\bin",
"@ })
$(if ($pkglist -contains "R") { @"
        "$prefix\R\bin\x64",
"@ })
$(if ($pkglist -contains "GIMP") { @"
        "$prefix\GIMP\bin",
"@ })
$(if ($pkglist -contains "VcXsrv") { @"
        "$prefix\VcXsrv\bin",
"@ })
$(if ($pkglist -contains "atom") { @"
        "$prefix\atom\bin",
        "$prefix\atom\app-1.3.2",

"@ })
$(if ($pkglist -contains "RWEverything") { @"
        "$prefix\RWEverything",
"@ })
$(if ($pkglist -contains "radare2") { @"
        "$prefix\radare2",
"@ })
$(if ($pkglist -contains "Launchy") { @"
        "$prefix\Launchy",
"@ })
$(if ($pkglist -contains "iasl") { @"
        "$prefix\iasl",
"@ })
$(if ($pkglist -contains "Recoll") { @"
        "$prefix\Recoll",
"@ })
$(if ($pkglist -contains "msys64") { @"
        "$prefix\msys64\usr\bin",
        "$prefix\msys64\mingw64\bin",
        "$prefix\msys64\opt\bin",
        "$prefix\msys64",
"@ })
$(if ($pkglist -contains "mRemoteNG") { @"
        "$prefix\mRemoteNG"
"@ })
$(if ($pkglist -contains "PEBrowse64") { @"
        "$prefix\PEBrowse64"
"@ })
$(if ($pkglist -contains "PEBrowsePro") { @"
        "$prefix\PEBrowsePro"
"@ })
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
                            $(@(
                            "$prefix",
$(if ($pkglist -contains "bin") {
                            "$prefix\bin"
} else { $NULL }),
$(if ($pkglist -contains "jdk") {
                            "$prefix\jdk\bin"
} else { $NULL }),
$(if ($pkglist -contains "gradle") {
                            "$prefix\gradle\bin"
} else { $NULL }),
$(if ($pkglist -contains "leiningen") {
                            "$prefix\.lein\bin"
} else { $NULL }),
$(if ($pkglist -contains "ClojureCLR") {
                            "$prefix\ClojureCLR"
} else { $NULL }),
$(if ($pkglist -contains "nodejs") {
                            "$prefix\nodejs"
} else { $NULL }),
$(if ($pkglist -contains "go") {
                            "$prefix\go\bin"
} else { $NULL }),
                            [IO.Path]::Combine([System.Environment]::GetFolderPath("MyDocuments"), "bin"),
$(if ($pkglist -contains "Git") {
    [String]::Join([IO.Path]::PathSeparator, `
    @(
                            "$prefix\Git",
                            "$prefix\Git\cmd"
    ))
} else { $NULL }),

$(if ($pkglist -contains "global") {
                            "$prefix\global\bin"
} else { $NULL }),
$(if ($pkglist -contains "emacs") {
                            "$prefix\emacs\bin"
} else { $NULL }),
$(if ($pkglist -contains "vim") {
                            "$prefix\vim"
} else { $NULL }),
$(if ($pkglist -contains "nmap") {
                            "$prefix\nmap"
} else { $NULL }),
$(if ($pkglist -contains "SysinternalsSuite") {
                            "$prefix\SysinternalsSuite"
} else { $NULL }),
$(if ($pkglist -contains "WinKit") {
    [String]::Join([IO.Path]::PathSeparator, `
    @(
                            "$prefix\WinKit\bin",
                            "$prefix\WinKit\dbg",
                            "$prefix\WinKit\tools",
                            "$prefix\WinKit\wpt"
    ))
} else { $NULL }),
$(if ($pkglist -contains "ConEmuPack") {
                            "$prefix\ConEmuPack"
} else { $NULL }),
$(if ($pkglist -contains "VirtuaWin") {
                            "$prefix\VirtuaWin"
} else { $NULL }),
$(if ($pkglist -contains "firefox") {
                            "$prefix\firefox"
} else { $NULL }),
$(if ($pkglist -contains "evince") {
                            "$prefix\evince\bin"
} else { $NULL }),
$(if ($pkglist -contains "Audacity") {
                            "$prefix\Audacity"
} else { $NULL }),
$(if ($pkglist -contains "apache-maven") {
                            "$prefix\apache-maven\bin"
} else { $NULL }),
$(if ($pkglist -contains "vlc") {
                            "$prefix\vlc"
} else { $NULL }),
$(if ($pkglist -contains "ffmpeg") {
                            "$prefix\ffmpeg\bin"
} else { $NULL }),
$(if ($pkglist -contains "R") {
                            "$prefix\R\bin\x64"
} else { $NULL }),
$(if ($pkglist -contains "GIMP") {
                            "$prefix\GIMP\bin"
} else { $NULL }),
$(if ($pkglist -contains "VcXsrv") {
                            "$prefix\VcXsrv\bin"
} else { $NULL }),
$(if ($pkglist -contains "atom") {
    [String]::Join([IO.Path]::PathSeparator, `
    @(
                            "$prefix\atom\bin",
                            "$prefix\atom\app-1.3.2"
    ))
} else { $NULL }),
$(if ($pkglist -contains "RWEverything") {
                            "$prefix\RWEverything"
} else { $NULL }),
$(if ($pkglist -contains "radare2") {
                            "$prefix\radare2"
} else { $NULL }),
$(if ($pkglist -contains "Launchy") {
                            "$prefix\Launchy"
} else { $NULL }),
$(if ($pkglist -contains "iasl") {
                            "$prefix\iasl"
} else { $NULL }),
$(if ($pkglist -contains "Recoll") {
                            "$prefix\Recoll"
} else { $NULL }),
$(if ($pkglist -contains "msys64") {
    [String]::Join([IO.Path]::PathSeparator, `
    @(
                            "$prefix\msys64\usr\bin",
                            "$prefix\msys64\mingw64\bin",
                            "$prefix\msys64\opt\bin",
                            "$prefix\msys64"
    ))
} else { $NULL }),
$(if ($pkglist -contains "mRemoteNG") {
                            "$prefix\mRemoteNG"
} else { $NULL }),
$(if ($pkglist -contains "PEBrowse64") {
                            "$prefix\PEBrowse64"
} else { $NULL }),
$(if ($pkglist -contains "PEBrowsePro") {
                            "$prefix\PEBrowsePro"
} else { $NULL }),
                            "$env:PWDE_PERSISTENT_PATH"
                            ) | ? {$_})))


    @(
        @("HOME", $("$prefix".Replace("\", "/"))),
        @("PWDE_HOME", $prefix),

$(if ($pkglist -contains "vim") {
        @("EDITOR", $("$prefix\vim\gvim.exe".Replace("\", "/")))
} else { $NULL }),

$(if ($pkglist -contains "emacs") {
        @("ALTERNATE_EDITOR", $("$prefix\emacs\bin\runemacs.exe".Replace("\", "/")))
} else { $NULL }),
$(if ($pkglist -contains "msys64") {
        @("PAGER", $("$prefix\msys64\usr\bin\less.exe".Replace("\", "/")))
} else { $NULL }),
        #@("TERM", "xterm"),
$(if ($pkglist -contains "jdk") {
        @("JAVA_HOME", $("$prefix\jdk".Replace("\", "/")))
} else { $NULL }),
$(if ($pkglist -contains "jdk") {
        @("_JAVA_OPTIONS", "-Duser.home=`"$prefix`" $env:PWDE_JAVA_OPTIONS")
} else { $NULL }),
$(if ($pkglist -contains "leiningen") {
        @("LEIN_HOME", $("$prefix\.lein".Replace("\", "/")))
} else { $NULL }),
$(if ($pkglist -contains "ClojureCLR") {
        @("CLOJURECLR_HOME", $("$prefix\ClojureCLR".Replace("\", "\")))
} else { $NULL }),
$(if ($pkglist -contains "jdk") {
        @("LEIN_JAVA_CMD", $("$prefix\jdk\bin\java.exe".Replace("\", "/")))
} else { $NULL }),
$(if ($pkglist -contains "go") {
        @("GOROOT", $("$prefix\go".Replace("\", "/")))
} else { $NULL }),
$(if ($pkglist -contains "go") {
        @("GOPATH", [System.Environment]::GetFolderPath("MyDocuments").Replace("\", "/"))
} else { $NULL }),
$(if ($pkglist -contains "apache-maven") {
        @("M2_HOME", $("$prefix\apache-maven".Replace("\", "/")))
} else { $NULL }),
$(if ($pkglist -contains "gradle") {
        @("GRADLE_HOME", $("$prefix\gradle".Replace("\", "/")))
} else { $NULL }),
$(if ($pkglist -contains "R") {
        @("R_HOME", $("$prefix\R".Replace("\", "/")))
} else { $NULL }),
        @("PATH_BAK", $env:PATH),
        @("PATH", $path),
        $NULL
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

    function create-shortcuts-internal ([String]$src, [String]$shortcut, [String]$argument, [String]$hotkey, [String]$workdir) {
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
        $s.WorkingDirectory = $(if (![String]::IsNullOrEmpty($workdir)) { $workdir } else { $prefix })
        $s.Save()
    }

    @(
        @("$prefix", "$env:USERPROFILE\Desktop\PWDE.lnk"),

$(if ($pkglist -contains "SysinternalsSuite") {
        @("$prefix\SysinternalsSuite\procexp.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ProcExp.lnk")
} else { $NULL }),

$(if ($pkglist -contains "bin") {
        @("$prefix\bin\NegativeScreen.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\NegativeScreen.lnk")
} else { $NULL }),


$(if ($pkglist -contains "Recoll") {
        @("$prefix\Recoll\recoll.exe", "$env:USERPROFILE\Desktop\Recoll.lnk")
} else { $NULL }),

$(if ($pkglist -contains "VcXsrv") {        
        @("$prefix\VcXsrv\xlaunch.exe", "$env:USERPROFILE\Desktop\XLaunch.lnk", "-run $prefix\VcXsrv\config.xlaunch")
} else { $NULL }),
$(if ($pkglist -contains "VcXsrv") {        
        @("$prefix\VcXsrv\xlaunch.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\XLaunch.lnk", "-run $prefix\VcXsrv\config.xlaunch")
} else { $NULL }),


$(if ($pkglist -contains "ConEmuPack") {        
        @("$prefix\ConEmuPack\ConEmu64.exe", "$env:USERPROFILE\Desktop\ConEmu64.lnk", $NULL, "CTRL+ALT+q")
} else { $NULL }),
$(if ($pkglist -contains "ConEmuPack") {        
        #@("$prefix\ConEmuPack\ConEmu64.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ConEmu64.lnk")
} else { $NULL }),


$(if ($pkglist -contains "Launchy") {        
        @("$prefix\Launchy\Launchy.exe", "$env:USERPROFILE\Desktop\Launchy.lnk")
} else { $NULL }),
$(if ($pkglist -contains "Launchy") {        
        @("$prefix\Launchy\Launchy.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Launchy.lnk")
} else { $NULL }),


$(if ($pkglist -contains "VirtuaWin") {        
        @("$prefix\VirtuaWin\VirtuaWin.exe", "$env:USERPROFILE\Desktop\VirtuaWin.lnk")
} else { $NULL }),

$(if ($pkglist -contains "VirtuaWin") {        
        @("$prefix\VirtuaWin\VirtuaWin.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\VirtuaWin.lnk")
} else { $NULL }),


$(if ($pkglist -contains "emacs") {        
        @("$prefix\emacs\bin\emacsclientw.exe", "$env:USERPROFILE\Desktop\Emacs.lnk", "-c -a `"$prefix\emacs\bin\runemacs.exe`"")
} else { $NULL }),

$(if ($pkglist -contains "emacs") {        
        @("$prefix\emacs\bin\runemacs.exe", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\EmacsServer.lnk", "--eval `"(server-start)`"")
} else { $NULL }),


$(if ($pkglist -contains "vim") {        
        @("$prefix\vim\gvim.exe", "$env:USERPROFILE\Desktop\GVim.lnk")
} else { $NULL }),


$(if ($pkglist -contains "RWEverything") {        
        @("$prefix\RWEverything\Rw.exe", "$env:USERPROFILE\Desktop\RWEverything.lnk")
} else { $NULL }),


$(if ($pkglist -contains "R") {        
        @("$prefix\R\bin\x64\Rgui.exe", "$env:USERPROFILE\Desktop\RGui x64.lnk")
} else { $NULL }),


$(if ($pkglist -contains "GIMP") {        
        @("$prefix\GIMP\bin\gimp-2.8.exe", "$env:USERPROFILE\Desktop\GIMP-2.8.lnk")
} else { $NULL }),


$(if ($pkglist -contains "atom") {        
        @("$prefix\atom\app-1.3.2\atom.exe", "$env:USERPROFILE\Desktop\Atom.lnk")
} else { $NULL }),


$(if ($pkglist -contains "mRemoteNG") {        
        @("$prefix\mRemoteNG\mRemoteNG.exe", "$env:USERPROFILE\Desktop\mRemoteNG.lnk")
} else { $NULL }),


$(if ($pkglist -contains "firefox") {        
        @("$prefix\firefox\firefox.exe", "$env:USERPROFILE\Desktop\FireFox.lnk")
} else { $NULL }),

    $NULL

    ) | % {
        if ($_) {
            $src, $shortcut, $argument, $hotkey, $workdir = $_
          if (Test-Path "$src") {
              Write-Host "Shortcut: $src Arguments:`"$args`" Shortcut:`"$hotkey`" => $shortcut"
              create-shortcuts-internal $src $shortcut $argument $hotkey $workdir
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
$(if ($pkglist -contains "ConEmuPack") {
        @("Open with ConEmu", "`"$prefix\ConEmuPack\ConEmu64.exe`" /cmd {PowerShell}", "$prefix\ConEmuPack\ConEmu64.exe")
} else { $NULL }),
$(if ($pkglist -contains "ConEmuPack") {
        @("Open with ConEmu (Admin)", "`"$prefix\ConEmuPack\ConEmu64.exe`" /cmd {PowerShell (Admin)}", "$prefix\ConEmuPack\ConEmu64.exe")
} else { $NULL }),
$(if ($pkglist -contains "emacs") {
        @("Open with Emacs", "`"$prefix\emacs\bin\emacsclientw.exe`" -c -a `"$prefix\emacs\bin\runemacs.exe`"", "$prefix\emacs\bin\emacsclientw.exe")
} else { $NULL }),
$(if ($pkglist -contains "emacs") {
        @("Open with Emacs (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\emacs\bin\runemacs.exe`"", "$prefix\emacs\bin\runemacs.exe")
} else { $NULL }),
$(if ($pkglist -contains "vim") {
        @("Open with Vim", "`"$prefix\vim\gvim.exe`"", "$prefix\vim\gvim.exe")
} else { $NULL }),
$(if ($pkglist -contains "vim") {
        @("Open with Vim (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\vim\gvim.exe`"", "$prefix\vim\gvim.exe")
} else { $NULL }),
#(if ($pkglist -contains "atom") {
#        @("Open with Atom", "`"$prefix\atom\app-1.3.2\atom.exe`"", "$prefix\atom\app-1.3.2\atom.exe")
#} else { $NULL }),
#$(if ($pkglist -contains "atom") {
#        @("Open with Atom (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\atom\app-1.3.2\atom.exe`"", "$prefix\atom\app-1.3.2\atom.exe")
#} else { $NULL }),
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
$(if ($pkglist -contains "emacs") {
        @("Edit with Emacs", "`"$prefix\emacs\bin\emacsclientw.exe`" -c -a `"$prefix\emacs\bin\runemacs.exe`" `"%1`"", "$prefix\emacs\bin\emacsclientw.exe")
} else { $NULL }),
$(if ($pkglist -contains "msys64") {
        @("Edit with Emacs (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\emacs\bin\runemacs.exe`" `"%1`"", "$prefix\emacs\bin\runemacs.exe")
} else { $NULL }),
$(if ($pkglist -contains "vim") {
        @("Edit with Vim", "`"$prefix\vim\gvim.exe`" `"%1`"", "$prefix\vim\gvim.exe")
} else { $NULL }),
$(if ($pkglist -contains "vim") {
        @("View with Vim", "`"$prefix\vim\gvim.exe`" -R `"%1`"", "$prefix\vim\gvim.exe")
} else { $NULL }),
$(if ($pkglist -contains "vim") {
        @("Edit with Vim (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\vim\gvim.exe`" `"%1`"", "$prefix\vim\gvim.exe")
} else { $NULL }),
#$(if ($pkglist -contains "atom") {
#        @("Edit with Atom", "`"$prefix\atom\app-1.3.2\atom.exe`" `"%1`"", "$prefix\atom\app-1.3.2\atom.exe")
#} else { $NULL }),
#$(if ($pkglist -contains "atom") {
#        @("Edit with Atom (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$prefix\atom\app-1.3.2\atom.exe`" `"%1`"", "$prefix\atom\app-1.3.2\atom.exe")
#} else { $NULL }),
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
