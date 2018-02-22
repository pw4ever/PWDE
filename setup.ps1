<#
.SYNOPSIS
    Setup the Portable Windows Development Environment (PWDE) on the target machine.
.PARAMETER DownloadFromUpstream
    Download setup from the upstream repository. Useful when no local download exists.
.PARAMETER UpstreamURLPrefix
    Upstream URL Prefix (default: https://github.com/pw4ever/PWDE/releases/download/latest).
.PARAMETER PkgList
    List of packages to downloading/extraction. No need to specify unless to select a subset.
.PARAMETER ExcludePkgList
    List of packages to be excluded from downloading/extraction.
.PARAMETER DownloadOnly
    Stop after downloading.
.PARAMETER Destination
    Destination path.
.PARAMETER ZipSource
    Zip source path (default to `$PSScriptRoot).
.PARAMETER UnzipPkgs
    Unzip packages.
.PARAMETER UpdateUserEnvironment
    Make settings persistent in user environment.
.PARAMETER CreateShortcuts
    Create Desktop shortcuts.
.PARAMETER CreateStartupShortcuts
    Create startup shortcuts.
.PARAMETER CreateContextMenuEntries
    Create context menu entries (requires Admin privilege).
.PARAMETER CreateServices
    Create services (requires Admin privilege).
.PARAMETER InstallChocolatey
    Install Chocolatey (https://chocolatey.org/).
.PARAMETER InstallChocoPkgs
    Install Chocolatey packages.
.PARAMETER ChocoPkgs
    Array of Chocolatey packages to be installed.
.PARAMETER ForceInstallChocoPkgs
    Forcibly install ("--force") Chocolatey packages.
.PARAMETER InstallVSCodePkgs
    Install Visual Studio Code packages.
.PARAMETER VSCodePkgs
    Array of Visual Studio Code packages to be installed.
.PARAMETER FixAttrib
    Fix up file attrib at Destination.
#>

[CmdletBinding(
    SupportsShouldProcess = $True,
    # named argument required to prevent accidental unzipping
    PositionalBinding = $False
)]
param(
    [Parameter(
    )]
    [switch]
    $DownloadFromUpstream,

    [Parameter(
    )]
    [String]
    $UpstreamURLPrefix = "https://github.com/pw4ever/PWDE/releases/download/latest",

    # ls *.zip | % { write-host "`"$(basename $_ .zip)`","}
    [Parameter(
    )]
    [String[]]
    $PkgList = @(
        #"AutoHotkey",
        "bin",
        #"calibre",
        #"ConEmuPack",
        #"config",
        "Documents",
        "emacs",
        #"evince",
        #"gcmw",
        #"Git",
        "global",
        #"go",
        "iasl",
        "jdk",
        "jpdfbookmarks",
        "leiningen",
        "m2",
        #"msys64",
        #"nasm",
        "PEBrowse64",
        "PEBrowsePro",
        #"putty",
        #"radare2",
        "RWEverything",
        #"SysinternalsSuite",
        "vim",
        #"VirtuaWin",
        "WinKit",
        #"ynp-tools",
        $NULL
    ),

    [Parameter(
    )]
    [String[]]
    $ExcludePkgList,

    [Parameter(
    )]
    [switch]
    $DownloadOnly,

    [Parameter(
    )]
    $Destination,

    [Parameter(
    )]
    $ZipSource = $PSScriptRoot,

    [Parameter(
    )]
    [switch]
    $UnzipPkgs,

    [Parameter(
    )]
    [switch]
    $UpdateUserEnvironment,

    [Parameter(
    )]
    [switch]
    $CreateShortcuts,

    [Parameter(
    )]
    [switch]
    $CreateStartupShortcuts,

    [Parameter(
    )]
    [switch]
    $CreateContextMenuEntries,

    [Parameter(
    )]
    [switch]
    $CreateServices,

    [Parameter(
    )]
    [switch]
    $InstallChocolatey,

    [Parameter(
    )]
    [switch]
    $InstallChocoPkgs,

    [Parameter(
    )]
    $ChocoPkgs = @(
        "7zip",
        "ag",
        "aria2",
        "audacity",
        "autohotkey",
        "azure-cli",
        "beyondcompare",
        "calibre",
        "cmder",
        "conemu",
        "ctags",
        "dependencywalker",
        "dropbox",
        "emacs64",
        "ethminer",
        "evince",
        "fbreader",
        "ffmpeg",
        "firefox",
        "gimp",
        "git",
        "Git-Credential-Manager-for-Windows",
        "global",
        "golang",
        "GoogleChrome",
        "gradle",
        "haskell-stack",
        "intellijidea-community",
        "ilmerge",
        "jdk8",
        "jq",
        "kitty",
        "launchy",
        "maven",
        "mremoteng",
        "nasm",
        "negativescreen",
        "nmap",
        "nodejs",
        "nssm",
        "nuget.commandline",
        "obs-studio",
        "openssh",
        "pdftk"
        "python2",
        "python3",
        "putty",
        "radare",
        "r.project",
        "r.studio",
        "ruby",
        "rufus",
        "scriptcs",
        "sharpkeys",
        "strawberryperl",
        "sumatrapdf",
        "sysinternals",
        "tigervnc",
        "tigervnc-viewer",
        "tunnelier",
        "vim",
        "vcredist-all",
        "vcxsrv",
        "VisualStudio2017Community",
        "VisualStudioCode",
        "virtuawin",
        "vlc",
        "wget",
        "winpcap",
        "wireshark",
        "youtube-dl",
        "zeal.install",
        $NULL
    ),

    [Parameter(
    )]
    [switch]
    $ForceInstallChocoPkgs,

    [Parameter(
    )]
    [switch]
    $InstallVSCodePkgs,

    [Parameter(
    )]
    $VSCodePkgs = @(
        "bierner.markdown-preview-github-styles",
        "clptn.code-paredit",
        "codezombiech.gitignore",
        "DavidAnson.vscode-markdownlint",
        "dbaeumer.vscode-eslint",
        "EditorConfig.EditorConfig",
        "eg2.tslint",
        "hashhar.gitattributes",
        "jakob101.RelativePath",
        "jchannon.csharpextensions",
        "KnisterPeter.vscode-github",
        "mattn.OpenVim",
        "ms-vscode.csharp",
        "ms-vscode.PowerShell",
        "ms-vsts.team",
        "PeterJausovec.vscode-docker",
        "robertohuertasm.vscode-icons",
        "sandcastle.whitespace",
        "UCL.haskelly",
        "vscodevim.vim",
        $NULL
        ),

    [Parameter(
    )]
    [switch]
    $FixAttrib

)

$script:version = "20180222-1"
"Version: $script:version"
$script:contact = "Wei Peng <4pengw+PWDE@gmail.com>"
"Contact: $script:contact"

if ($ExcludePkgList) {
    $ExcludePkgList = $($ExcludePkgList | % { $_.ToUpper() })
}

$PkgList = $($PkgList | ? { !([String]::IsNullOrWhiteSpace($_)) -and !$($_.ToUpper() -in $ExcludePkgList) })

function main {
    if ($InstallChocolatey) {
        # https://chocolatey.org/install
        [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredential
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        [Environment]::SetEnvironmentVariable("PATH", "$ALLUSERSPROFILE\chocolatey\bin;$env:PATH", [EnvironmentVariableTarget]::Process)
    }

    $choco = (gcm choco.exe -ErrorAction SilentlyContinue).Path
    if ($InstallChocoPkgs -and $choco) {
        $ChocoPkgs | ? { -not [String]::IsNullOrWhiteSpace($_) } | % {
            $pkg = $_
            try { invoke-expression -Command "& ""$choco"" install $pkg -y$(if($ForceInstallChocoPkgs) { "f" })" } catch {}
        }
        try { refreshenv } catch {}
    }

    if ($InstallVSCodePkgs) {
        $local:tmp = $env:PATH
        try {
            if (!($env:PATH -match "Microsoft VS Code")) {
                $path = [IO.Path]::Combine($env:ProgramFiles, "Microsoft VS Code", "bin")
                if (Test-Path -Path $path -PathType Container) {
                    $env:PATH += ";$path"
                }
            }
            if ($(try {code --help | Select-String '(?i)visual\s*studio\s*code'} catch {$False})) {
                foreach ($ext in @(
                        $VSCodePkgs | ? { ![String]::IsNullOrWhiteSpace($_) }
                    )) {
                    code --install-extension "$ext"
                }
            }
        }
        finally {
            $env:PATH=$local:tmp
        }
    }

    if ($DownloadFromUpstream) {
        ensure-dir $ZipSource
        download-upstream $UpstreamURLPrefix $ZipSource $PkgList
    }

    if ($DownloadOnly) {
        return
    }

    if (![string]::IsNullOrWhiteSpace($Destination)) {
        ensure-dir $Destination
        $Destination = $(Resolve-Path $Destination).ProviderPath.TrimEnd("\")

        if ($UnzipPkgs) {
            $ZipSource = $(Resolve-Path $ZipSource).ProviderPath.TrimEnd("\")
            unzip-files $ZipSource $Destination $PkgList
        }
    }

    if ($UpdateUserEnvironment) {
        update-userenv $Destination
    }

    if ($CreateShortcuts) {
        create-shortcuts $Destination
    }

    if ($CreateStartupShortcuts) {
        create-startupshortcuts $Destination
    }

    if ($CreateContextMenuEntries) {
        create-contextmenuentries $Destination
    }

    if ($CreateServices) {
        create-services $Destination
    }

    # finalization
    try {
        if ($PkgList -contains "global") {
            $path = "$PSScriptRoot\scripts\global.ps1"
            Write-Verbose "Finalization: $path."
            & $path -Destination $Destination -PkgList $PkgList
        }
        if ($PkgList -contains "gcmw") {
            $path = "$PSScriptRoot\scripts\gcmw.ps1"
            Write-Verbose "Finalization: $path."
            & $path -Destination $Destination -PkgList $PkgList
        }
        if ($PkgList -contains "Git") {
            $path = "$PSScriptRoot\scripts\Git.ps1"
            Write-Verbose "Finalization: $path."
            & $path -Destination $Destination -PkgList $PkgList
        }
    }
    catch {}

    try {
        if ($FixAttrib) {
            Write-Verbose "Fixing up attrib: $Destination."
            # attrib: -Readonly, -Hidden
            $name = $Destination -replace "\\$", ""
            attrib.exe -R -H "$name" /S /D /L
        }
    }
    catch {}

}

function download-upstream ($srcprefix, $destprefix, $pkgs) {
    # http://stackoverflow.com/a/28704050
    $wc = New-Object Net.WebClient

    $list = @("7za.exe") + @($pkgs | % {"$_.zip"})

    foreach ($item in $list) {
        $src = "$srcprefix/$item"
        $dest = "$destprefix/$item"

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
    $jobs = @()
    $pkglist = $pkglist | % { "$_.zip" }
    ls "$src/*.zip" | % {
        # Unzip $_ only if it is in $pkglist
        if ($pkglist -like $_.Name) {
            $name = $_.FullName
            Write-Host "Unzipping $name."
            # Start background jobs for unzipping
            $jobs += $(Start-Job -ScriptBlock {
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

function update-userenv ($prefix) {
    $local:gopath = [IO.Path]::Combine([System.Environment]::GetFolderPath("MyDocuments"), "go", "bin")

    # Ensure these folders exist.
    try {
        @(
            $local:gopath,
            $NULL
        ) | ? { ![String]::IsNullOrWhiteSpace($_) } | % {
            New-Item -Path $local:gopath -ItemType Directory -Force | Out-Null
        }
    } catch {}

    $path = ([String]::Join([IO.Path]::PathSeparator, `
            (@(
                    "$prefix",
                    "$prefix\bin",
                    "$prefix\jdk\bin",
                    "$prefix\gradle\bin",
                    "$prefix\.lein\bin",
                    "$prefix\ClojureCLR",
                    "$prefix\nodejs",
                    "$prefix\go\bin",
                    "$prefix\gopath\bin",
                    $local:gopath,
                    "$prefix\Git",
                    "$prefix\Git\cmd",
                    "$prefix\global\bin",
                    "$prefix\emacs\bin",
                    "$prefix\vim",
                    "$prefix\nmap",
                    "$prefix\SysinternalsSuite",
                    "$prefix\WinKit\bin",
                    "$prefix\WinKit\dbg",
                    "$prefix\WinKit\tools",
                    "$prefix\WinKit\wpt"
                    "$prefix\ConEmuPack",
                    "$prefix\VirtuaWin",
                    "$prefix\Audacity",
                    "$prefix\evince\bin",
                    "$prefix\apache-maven\bin",
                    "$prefix\vlc",
                    "$prefix\ffmpeg\bin",
                    "$prefix\R\bin\x64",
                    "$prefix\GIMP\bin",
                    "$prefix\VcXsrv\bin",
                    "$prefix\RWEverything",
                    "$prefix\radare2",
                    "$prefix\iasl",
                    "$prefix\msys64\usr\bin",
                    "$prefix\msys64\mingw64\bin",
                    "$prefix\msys64\opt\bin",
                    "$prefix\msys64",
                    "$prefix\mRemoteNG",
                    "$prefix\PEBrowse64",
                    "$prefix\PEBrowsePro",
                    "$prefix\putty",
                    "$prefix\jpdfbookmarks",
                    "$prefix\nasm",
                    "$prefix\ynp-tools",
                    "$prefix\AutoHotkey\Compiler",
                    $NULL
                ) | ? { !([String]::IsNullOrWhiteSpace($_)) -and (Test-Path $_ -PathType Container -ErrorAction SilentlyContinue) })))
    $path += "$([IO.Path]::PathSeparator)$env:PWDE_PERSISTENT_PATH"

    @(
        @("PATH_BAK", $env:PATH),
        @("PATH", ([String]::Join([IO.Path]::PathSeparator, @(
                        [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine),
                        $path
                    )))),
        $NULL
    ) | ? { ! ([String]::IsNullOrWhiteSpace($_)) } | % {
        $var, $val, $tar = $_
        Write-Host "Setting environment variable: |$var|=|$val|"
        Set-Content Env:\"$var" "$val"
        [Environment]::SetEnvironmentVariable($var, $val, [System.EnvironmentVariableTarget]::Process)
        [Environment]::SetEnvironmentVariable($var, $val, $(if ($tar) {$tar} else {[EnvironmentVariableTarget]::User}))
    }

    @(
        @("HOME", $("$prefix".Replace("\", "/"))),
        @("PWDE_HOME", $prefix.Replace("\", "/")),

        $(if ($target = (gcm gvim.exe -ErrorAction SilentlyContinue).path) {
                @("EDITOR", $target.Replace("\", "/"))
            }
            else { $NULL }),

        $(if ($target = (gcm runemacs.exe -ErrorAction SilentlyContinue).path) {
                @("ALTERNATE_EDITOR", $target.Replace("\", "/"))
            }
            else { $NULL }),
        $(if ($target = (gcm less.exe -ErrorAction SilentlyContinue).path) {
                @("PAGER", $target.Replace("\", "/"))
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "jdk", "bin", "javac.exe")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("JAVA_HOME", "$prefix\jdk".Replace("\", "/"))
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "jdk", "bin", "javac.exe")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("_JAVA_OPTIONS", "-Duser.home=`"$prefix`" $env:PWDE_JAVA_OPTIONS")
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", ".lein", "bin", "lein.bat")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("LEIN_HOME", "$prefix\.lein".Replace("\", "/"))
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "jdk", "bin", "java.exe")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("LEIN_JAVA_CMD", "$prefix\jdk\bin\java.exe".Replace("\", "/"))
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "go", "bin", "go.exe")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("GOROOT", "$prefix\go".Replace("\", "/"))
            }
            else { $NULL }),
        $(if ((gcm go.exe -ErrorAction SilentlyContinue).path) {
                @("GOPATH", $local:gopath.Replace("\", "/"))
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "apache-maven", "bin", "mvn")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("M2_HOME", "$prefix\apache-maven".Replace("\", "/"))
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "gradle", "bin", "gradle")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("GRADLE_HOME", "$prefix\gradle".Replace("\", "/"))
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "R", "bin", "x64", "R.exe")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("R_HOME", "$prefix\R".Replace("\", "/"))
            }
            else { $NULL }),
        $NULL
    ) | ? { !([String]::IsNullOrWhiteSpace($_)) } | % {
        $var, $val, $tar = $_
        Write-Host "Setting environment variable: |$var|=|$val|"
        Set-Content Env:\"$var" "$val"
        [Environment]::SetEnvironmentVariable($var, $val, [System.EnvironmentVariableTarget]::Process)
        [Environment]::SetEnvironmentVariable($var, $val, $(if ($tar) {$tar} else {[EnvironmentVariableTarget]::User}))
    }
}

function create-shortcuts ($prefix) {
    $desktop = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
    $startup = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
    @(
        @("$prefix", "$desktop\PWDE.lnk"),


        $(if ($target = $(gcm negativescreen.exe -ErrorAction SilentlyContinue).path) {
                @($target, "$desktop\NegativeScreen.lnk", $NULL, $NULL, $NULL, $true)
            }
            else { $NULL }),


        $($cmd = "$prefix\VcXsrv\xlaunch.exe"; if (Test-Path $cmd -PathType Leaf -ErrorAction SilentlyContinue) {
                @($cmd, "$desktop\XLaunch.lnk", "-run $prefix\VcXsrv\config.xlaunch", $NULL, $NULL, $true)
            }
            else { $NULL }),


        $(if ($target = $(gcm conemu64.exe -ErrorAction SilentlyContinue).path) {
                @($target, "$desktop\ConEmu64.lnk", $NULL, "CTRL+ALT+q")
            }
            else { $NULL }),


        $(if ($target = (gcm "VirtuaWin" -ErrorAction SilentlyContinue).path) {
                @($target, "$desktop\VirtuaWin.lnk")
            }
            else { $NULL }),


        $(if (($ec = (gcm "emacsclientw.exe" -ErrorAction SilentlyContinue).path) -and ($re = (gcm "runemacs.exe" -ErrorAction SilentlyContinue).path)) {
                @($ec, "$desktop\Emacs.lnk", "-c -a `"$re`"")
            }
            else { $NULL }),


        $(if ($target = (gcm gvim.exe -ErrorAction SilentlyContinue).path) {
                @($target, "$desktop\GVim.lnk")
            }
            else { $NULL }),


        $(if ($target = (gcm Rw.exe -ErrorAction SilentlyContinue).path) {
                @($target, "$desktop\RWEverything.lnk", $NULL, $NULL, $NULL, $true)
            }
            else { $NULL }),


        $(if ($target = $(gcm procexp64.exe -ErrorAction SilentlyContinue).path) {
                @($target, "$desktop\procexp64.lnk", $NULL, $NULL, $NULL, $true)
            }
            else { $NULL }),


        $($cmd = "$prefix\bin\wm.exe"; if ((test-path $cmd -PathType Leaf -ErrorAction SilentlyContinue)) {
                @($cmd, "$desktop\wm.lnk", $NULL, $NULL, $NULL, $true)
            }
            else { $NULL }),


        $(if ($target = $(gcm bginfo.exe -ErrorAction SilentlyContinue).path) {
                & { copy-item "$PSScriptRoot\helper\black_text.bgi" "$prefix" -Force -ErrorAction SilentlyContinue | Out-Null }
                if (Test-Path "$prefix\black_text.bgi" -PathType Leaf -ErrorAction SilentlyContinue) {
                    @($target, "$desktop\bginfo.lnk", "`"$prefix\black_text.bgi`" /timer:0", $NULL, $NULL, $false)
                }
                else { $NULL }
            }
            else { $NULL }),


        $NULL

    ) | % {
        if ($_) {
            $src, $shortcut, $argument, $hotkey, $workdir, $admin = $_
            if (Test-Path "$src") {
                Write-Host "Shortcut: $src Arguments:`"$args`" Hotkey:`"$hotkey`" => $shortcut"
                create-shortcuts-internal -src $src -shortcut $shortcut -argument $argument `
                    -hotkey $hotkey -workdir $workdir -admin $admin
            }
        }
    }
}

function create-startupshortcuts ($prefix) {
    $desktop = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
    $startup = [Environment]::GetFolderPath([Environment+SpecialFolder]::Startup)
    @(

        <#
$(if ($target=$(gcm negativescreen.exe -ErrorAction SilentlyContinue).path) {
        @($target, "$startup\NegativeScreen.lnk", $NULL, $NULL, $NULL, $false)
} else { $NULL }),
#>

        $($cmd = "$prefix\VcXsrv\xlaunch.exe"; if (Test-Path $cmd -PathType Leaf -ErrorAction SilentlyContinue) {
                @($cmd, "$startup\XLaunch.lnk", "-run $prefix\VcXsrv\config.xlaunch", $NULL, $NULL, $false)
            }
            else { $NULL }),


        $(if ($re = (gcm "runemacs.exe" -ErrorAction SilentlyContinue).path) {
                @($re, "$startup\EmacsServer.lnk", "--eval `"(server-start)`"")
            }
            else { $NULL }),

        <#
$(if ($target=$(gcm PAGEANT.exe -ErrorAction SilentlyContinue).path) {
        @($target, "$startup\PAGEANT.lnk")
} else { $NULL }),
#>

        $(if ($target = $(gcm KAGEANT.exe -ErrorAction SilentlyContinue).path) {
                @($target, "$startup\KAGEANT.lnk")
            }
            else { $NULL }),

        <#
$(if ($target=$(gcm bginfo.exe -ErrorAction SilentlyContinue).path) {
        & { copy-item "$PSScriptRoot\helper\black_text.bgi" "$prefix" -Force -ErrorAction SilentlyContinue | Out-Null }
        if (Test-Path "$prefix\black_text.bgi" -PathType Leaf -ErrorAction SilentlyContinue) {
            @($target, "$startup\bginfo.lnk", "`"$prefix\black_text.bgi`" /timer:0", $NULL, $NULL, $false)
        } else { $NULL }
} else { $NULL }),
#>

        $NULL

    ) | % {
        if ($_) {
            $src, $shortcut, $argument, $hotkey, $workdir, $admin = $_
            if (Test-Path "$src") {
                Write-Host "Shortcut: $src Arguments:`"$args`" Hotkey:`"$hotkey`" => $shortcut"
                create-shortcuts-internal -src $src -shortcut $shortcut -argument $argument `
                    -hotkey $hotkey -workdir $workdir -admin $admin
            }
        }
    }
}

function create-shortcuts-internal ([String]$src, [String]$shortcut, [String]$argument, [String]$hotkey, [String]$workdir, $admin) {
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

    if ($admin) {
        # hack: https://blogs.msdn.microsoft.com/abhinaba/2013/04/02/c-code-for-creating-shortcuts-with-admin-privilege/
        $fs = New-Object IO.FileStream -ArgumentList $shortcut, ([IO.FileMode]::Open), ([IO.FileAccess]::ReadWrite)
        try {
            $fs.Seek(21, [IO.SeekOrigin]::Begin) | Out-Null
            $fs.WriteByte(0x22) | Out-Null
        }
        finally {
            $fs.Dispose() | Out-Null
        }
    }
}

function create-contextmenuentries ($prefix) {
    # https://gallery.technet.microsoft.com/scriptcenter/Script-to-add-an-item-to-f523f1f3
    # http://www.howtogeek.com/107965/how-to-add-any-application-shortcut-to-windows-explorers-context-menu/

    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

    # Directory Context Menu
    @(
        $(if ($target = (gcm "ConEmu64.exe" -ErrorAction SilentlyContinue).path) {
                @("Open with ConEmu", "`"$target`" /cmd {PowerShell}", $target)
            }
            else { $NULL }),
        $(if ($target = (gcm "ConEmu64.exe" -ErrorAction SilentlyContinue).path) {
                @("Open with ConEmu (Admin)", "`"$target`" /cmd {PowerShell (Admin)}", $target)
            }
            else { $NULL }),
        $(if (($ec = (gcm "emacsclientw.exe" -ErrorAction SilentlyContinue).path) -and ($re = (gcm "runemacs.exe" -ErrorAction SilentlyContinue).path)) {
                @("Open with Emacs", "`"$ec`" -c -a `"$re`"", "$ec")
            }
            else { $NULL }),
        $(if ($re = (gcm "runemacs.exe" -ErrorAction SilentlyContinue).path) {
                @("Open with Emacs (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$re`"", "$re")
            }
            else { $NULL }),
        $(if ($target = (gcm "gvim.exe" -ErrorAction SilentlyContinue).path) {
                @("Open with Vim", "`"$target`"", "$target")
            }
            else { $NULL }),
        $(if ($target = (gcm "gvim.exe" -ErrorAction SilentlyContinue).path) {
                @("Open with Vim (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$target`"", "$target")
            }
            else { $NULL }),
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
        $(if (($ec = (gcm "emacsclientw.exe" -ErrorAction SilentlyContinue).path) -and ($re = (gcm "runemacs.exe" -ErrorAction SilentlyContinue).path)) {
                @("Edit with Emacs", "`"$ec`" -c -a `"$re`" `"%1`"", "$re")
            }
            else { $NULL }),
        $(if ($re = (gcm "runemacs.exe" -ErrorAction SilentlyContinue).path) {
                @("Edit with Emacs (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$re`" `"%1`"", "$re")
            }
            else { $NULL }),
        $(if ($target = (gcm "gvim.exe" -ErrorAction SilentlyContinue).path) {
                @("Edit with Vim", "`"$target`" `"%1`"", "$target")
            }
            else { $NULL }),
        $(if ($target = (gcm "gvim.exe" -ErrorAction SilentlyContinue).path) {
                @("View with Vim", "`"$target`" -R `"%1`"", "$target")
            }
            else { $NULL }),
        $(if ($target = (gcm "gvim.exe" -ErrorAction SilentlyContinue).path) {
                @("Edit with Vim (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$target`" `"%1`"", "$target")
            }
            else { $NULL }),
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

function create-services ($prefix) {
    # https://gallery.technet.microsoft.com/scriptcenter/Script-to-add-an-item-to-f523f1f3
    # http://www.howtogeek.com/107965/how-to-add-any-application-shortcut-to-windows-explorers-context-menu/

    $nssm = [IO.Path]::Combine($PSScriptRoot, "helper", "nssm.exe")
    if (!(Test-Path $nssm -PathType Leaf)) { return } # proceed only if nssm is available

    @(
        <# # example # https://nssm.cc/commands
        @("PWDE_wm", "$prefix\bin\wm.exe", $NULL, @(
            @("reset", "ObjectName"),
            @("set", "Type SERVICE_INTERACTIVE_PROCESS"),
            $NULL
        )),
        #>
        $NULL
    ) | ? { $_ } | % {
        $name, $prog, $args, $settings = $_
        if (!([String]::IsNullOrWhiteSpace($name)) -and !([String]::IsNullOrWhiteSpace($prog)) -and (Test-Path $prog -PathType Leaf)) {
            Write-Verbose "Install Service $name ($prog)."
            Invoke-Expression "& `"$nssm`" install `"$name`" `"$prog`" $args"
            foreach ($setting in $settings) {
                if ($setting) {
                    $action, $param = $setting
                    Invoke-Expression "& `"$nssm`" $action `"$name`" $param"
                }
            }
        }
    }

}

try {
    pushd $env:SystemRoot
    main
} finally {
    popd
}