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
    Unzip packages
.PARAMETER UpdateUserEnvironment
    Make settings persistent in user environment.
.PARAMETER UpdateSystemPreference
    Update system preference, such as file association.
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
        "amazon-corretto-11.0.5.10.1-windows-x64",
        "amazon-corretto-8.232.09.1-windows-x64-jdk",
        "bin",
        "Documents",
        "emacs",
        "etwpackage",
        "evince",
        "global",
        "iasl",
        #"jdk",
        "jpdfbookmarks",
        "leiningen",
        "m2",
        "mupdf",
        "PAL",
        "pciutils",
        "PEBrowse64",
        "PEBrowsePro",
        "RWEverything",
        "vim",
        "Windows Kits",
        $NULL
    ),

    [Parameter(
    )]
    [String[]]
    $ExcludePkgList,

    [Parameter(
    )]
    [switch]
    $DownloadFromThirdParty,

    [Parameter(
    )]
    [switch]
    $ForceDownloadFromThirdParty,

    [Parameter(
    )]
    [System.Collections.Hashtable]
    $ThirdPartyPackages = @{
        "scala-2.13.1.msi" = "https://downloads.lightbend.com/scala/2.13.1/scala-2.13.1.msi";
        "evince-2.32.0.145.msi" = "https://github.com/pw4ever/PWDE/releases/download/latest/evince-2.32.0.145.msi";
        "youtube-dl.exe" = "https://yt-dl.org/latest/youtube-dl.exe";
        "amm.bat" = "https://github.com/lihaoyi/Ammonite/releases/download/1.8.1/2.13-1.8.1";
    },

    [Parameter(
    )]
    [switch]
    $InstallThirdPartyPackages,

    [Parameter(
    )]
    [String[]]
    $InstallThirdPartyPackagesList,

    [Parameter(
    )]
    [switch]
    $DownloadOnly,

    [Parameter(
    )]
    $Destination="C:\PWDE",

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
    $UpdateSystemPreference,

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
        #"aria2",
        "audacity",
        "audacity-lame",
        #"autohotkey",
        #"azure-cli",
        "beyondcompare",
        #"calibre",
        #"cmake",
        "cmder",
        #"conemu",
        #"ctags",
        #"curl",
        #"dependencywalker",
        "dotnetfx",
        #"doxygen.install",
        #"dropbox",
        "emacs",
        #"fbreader",
        "ffmpeg",
        "filetypesman",
        #"firefox",
        #"firezilla",
        #"ghc",
        #"gimp",
        "git",
        #"Git-Credential-Manager-for-Windows",
        "global",
        "golang",
        "GoogleChrome",
        "gpg4win",
        #"gradle",
        #"haskell-stack",
        #"inkscape",
        #"intellijidea-community",
        "ilmerge",
        #"jdk8",
        #"jdk11",
        "jq",
        #"kindle",
        "kitty",
        "lame",
        #"launchy",
        #"llvm",
        #"lyx",
        #"maven",
        #"miktex",
        #"microsoft-message-analyzer",
        "mpv",
        #"mremoteng",
        #"msys2",
        "mupdf",
        "nasm",
        #"negativescreen",
        "neovim",
        #"networkmonitor",
        #"nmap",
        #"nodejs",
        "nssm",
        "nuget.commandline",
        #"obs-studio",
        #"openjdk",
        #"openshot",
        #"openssh",
        "pandoc",
        "pdftk",
        "python2",
        "python3",
        "putty",
        "radare",
        #"rainmeter",
        "rclone",
        #"ripgrep",
        "r.project",
        #"rsat",
        "r.studio",
        #"ruby",
        #"rufus",
        "sbt",
        #"scriptcs",
        #"sharpkeys",
        #"strawberryperl",
        "sumatrapdf",
        "sysinternals",
        #"tigervnc",
        "tigervnc-viewer",
        "vim",
        "vcredist-all",
        "vcxsrv",
        #"VisualStudio2019Community",
        "VisualStudioCode",
        #"virtuawin",
        #"vlc",
        "wget",
        #"winpcap",
        #"winrar",
        "winscp",
        #"wireshark",
        "wmiexplorer",
        "xpdf-utils",
        #"youtube-dl",
        "zeal",
        "zulu",
        "zulu11",
        "zulu8",
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
    $FixMiscConfig,

    [Parameter(
    )]
    [switch]
    $FixAttrib,

    [Parameter(
    )]
    [switch]
    $FixReg

)
$script:version = "20191113-2"
Write-Verbose "Version: $script:version"
$script:contact = "Wei Peng <4pengw+PWDE@gmail.com>"
Write-Verbose "Contact: $script:contact"

if ($ExcludePkgList) {
    $ExcludePkgList = $($ExcludePkgList | % { $_.ToUpper() })
}

$PkgList = $($PkgList | ? { !([String]::IsNullOrWhiteSpace($_)) -and !$($_.ToUpper() -in $ExcludePkgList) })

$Wget = $(
    $tmp = [IO.Path]::Combine($PSScriptRoot, "helper", "wget.exe")
    if (Test-Path -Path $tmp -PathType Leaf) {
        $tmp
    } else {
        (Get-Command -Name "wget.exe" -ErrorAction SilentlyContinue).Path
    }
)

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

    if ($DownloadFromThirdParty) {
        $ThirdPartyPackages.Keys | % {
            $dst = [IO.Path]::Combine($ZipSource, $_)
            $src = $ThirdPartyPackages[$_]
            if (!(Test-Path -PathType Leaf -Path $dst) -or $ForceDownloadFromThirdParty) {
                try {
                    download-pkg -src $src -dst $dst
                } catch {
                    Write-Error "$src => $dst failed: $_."
                }
            } else {
                Write-Verbose "$dst already exists; skip."
            }
        }
    }

    if ($DownloadOnly) {
        return
    }

    if ($InstallThirdPartyPackages) {
        if (![String]::IsNullOrWhiteSpace($Destination)) {
            $dest_bin=[IO.Path]::Combine($Destination, "bin")
            ensure-dir $dest_bin
        }
        $ThirdPartyPackages.Keys | ? {
            Write-Verbose $_
            Write-Verbose ($InstallThirdPartyPackagesList -match $_).Count
            # ($InstallThirdPartyPackagesList.Count -le 0) is excluded
            ($NULL -eq $InstallThirdPartyPackagesList) -or `
                ($InstallThirdPartyPackagesList -contains $_)
         } | % {
            $pkg = $_
            if ($pkg -match "\.msi$") {
                $pkgpath = [IO.Path]::Combine($ZipSource, $pkg)
                if (Test-Path -Path $pkgpath -PathType Leaf) {
                    Write-Verbose "Installing $pkgpath."
                    Start-Process -FilePath msiexec.exe -Wait -ArgumentList @(
                        "/i",
                        "`"$pkgpath`"",
                        "/qb",
                        "/norestart"
                    )
                }
            } elseif ($pkg -match "\.(exe|bat|cmd)$") {
                $pkgpath = [IO.Path]::Combine($ZipSource, $pkg)
                if ((Test-Path -Path $pkgpath -PathType Leaf) -and (Test-Path -Path $dest_bin -PathType Container))
                {
                    Write-Verbose "Copying $pkgpath to $dest_bin."
                    Copy-Item -Path $pkgpath -Destination $dest_bin
                }
            }
        }
        $dest_bin=$NULL
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

    if ($UpdateSystemPreference) {
        update-syspref $Destination
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
        if ($FixMiscConfig) {
            @(
                "global",
                "gcmw",
                "Git",
                $NULL
            ) | ? { ![String]::IsNullOrWhiteSpace($_) } | % {
                $pkg = $_
                $path = "$PSScriptRoot\scripts\$pkg.ps1"
                if (($PkgList -contains $pkg) -and (Test-Path $path -PathType Leaf)) {
                    Write-Verbose "Running $path."
                    try {
                        & $path -Destination $Destination -PkgList $PkgList
                    } catch {}
                    Write-Verbose "Runned $path."
                }
            }
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

    try {
        if ($FixReg) {
            @(
                @("HKCU\Console", "VirtualTerminalLevel", "REG_DWORD", "1"),
                $NULL
            ) | ? { ![String]::IsNullOrWhiteSpace($_) } | % {
                $hk, $v, $t, $d = $_
                $cmd = @"
reg add "$hk" /v "$v" /t "$t" /d "$d" /f
"@
                Write-Verbose "$cmd"
                try {
                    Invoke-Expression $cmd
                } catch {}

            }
        }
    }
    catch {}

}

function download-pkg ($src, $dst) {
    $local:sp_old = [System.Net.ServicePointManager]::SecurityProtocol
    try {
        # https://stackoverflow.com/a/28333370
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        # http://stackoverflow.com/a/28704050
        $wc = New-Object Net.WebClient
        Write-Verbose "$src => $dst"
        $wc.DownloadFile($src, $dst)
    }
    finally {
        [System.Net.ServicePointManager]::SecurityProtocol = $local:sp_old
    }
}

function download-upstream ($srcprefix, $destprefix, $pkgs) {
    $local:sp_old = [System.Net.ServicePointManager]::SecurityProtocol

    try {
        # https://stackoverflow.com/a/28333370
        [System.Net.ServicePointManager]::SecurityProtocol = `
            [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        # http://stackoverflow.com/a/28704050
        $wc = New-Object Net.WebClient

        $list = @("7za.exe") + @($pkgs | % {"$_.zip"})

        foreach ($item in $list) {
            $src = "$srcprefix/$item"
            $dst = "$destprefix/$item"

            $wc.DownloadFile($src, $dst)
            Write-Verbose "$src downloaded to $dst."
        }
    }
    finally {
        [System.Net.ServicePointManager]::SecurityProtocol = $local:sp_old
    }
}

function ensure-dir ($dir) {
    if (!$(Test-Path $dir)) {
        mkdir $dir -Force > $NULL
        Write-Verbose "$dir created."
    }
}

function unzip-files ($src, $dst, $pkglist) {
    $jobs = @()
    $pkglist = $pkglist | % { "$_.zip" }
    ls "$src/*.zip" | % {
        # Unzip $_ only if it is in $pkglist
        if ($pkglist -like $_.Name) {
            $name = $_.FullName
            Write-Verbose "Unzipping $name."
            # Start background jobs for unzipping
            $jobs += $(Start-Job -ScriptBlock {
                    param($name, $dst, $src)

                    function unzip ($zipfile, $dst, $src) {
                        #ensure-dir $dst
                        #[IO.Compression.ZipFile]::ExtractToDirectory($zipfle, $dst)
                        Invoke-Expression "$src\7za.exe x -o`"$dst`" -y -- `"$zipfile`"" # > $NULL
                    }

                    unzip "$name" "$dst" "$src"
                    Write-Verbose "$name unzipped."
                } `
                    -ArgumentList "$name", "$dst", "$src"
            )
        }
    }
    if ($jobs) {
        Wait-Job -Job $jobs | Out-Null
    }
}

function update-userenv ($prefix) {
    $local:gopath = [IO.Path]::Combine([System.Environment]::GetFolderPath("MyDocuments"), "go")
    $local:gopathbin = [IO.Path]::Combine($local:gopath, "bin")

    $local:link_jdk = "$prefix\jdk"
    $local:target_jdk = "$prefix\jdk11.0.5_10"

    $local:link_vim = "$env:HOMEDRIVE\tools\Vim"
    $local:target_vim = $(
        Get-ChildItem -Path "${env:ProgramFiles(x86)}\vim\vim*" | `
            Select-Object -First 1 | `
            % {$_.FullName}
            )

    $local:link_bcomp = "$env:HOMEDRIVE\tools\BComp"
    $local:target_bcomp = $(
        Get-ChildItem -Path "${env:ProgramFiles}\Beyond Compare*" | `
            Select-Object -First 1 | `
            % {$_.FullName}
            )

    $local:link_sumatrapdf = "$env:HOMEDRIVE\tools\SumatraPDF"
    $local:target_sumatrapdf = "$env:ChocolateyInstall\lib\sumatrapdf.commandline\tools"

    $local:link_emacs = "$env:HOMEDRIVE\tools\Emacs"
    $local:link_emacsbin = "$local:link_emacs\bin"
    $local:target_emacs = "$env:ChocolateyInstall\lib\emacs\tools\emacs"

    $local:link_firefox = "$env:HOMEDRIVE\tools\firefox"
    $local:target_firefox = "$env:ProgramFiles\Mozilla Firefox"

    $local:link_chrome = "$env:HOMEDRIVE\tools\GoogleChrome"
    $local:target_chrome = "${env:ProgramFiles(x86)}\Google\Chrome\Application"

    $local:link_llvm = "$env:HOMEDRIVE\tools\LLVM"
    $local:target_llvm = "${env:ProgramFiles}\LLVM"

    $local:link_cmake = "$env:HOMEDRIVE\tools\CMake"
    $local:target_cmake = "${env:ProgramFiles}\CMake"

    # Ensure these folders exist.
    try {
        @(
            $local:gopathbin,
            $NULL
        ) | ? { ![String]::IsNullOrWhiteSpace($_) } | % {
            $path = $_
            try {
                if (!(Test-Path -Path $Path)) {
                    New-Item -Path $path -ItemType Directory -Force | Out-Null
                    Write-Verbose "Created directory $path."
                }
            } catch {}
        }
    } catch {}

    # Create these symlinks if possible.
    # The purpose of creating symlinks is to rid of paths that confuse *nix path logic in Git,
    # such as paths with spaces of parentheses.
    try {
        @(
            @($local:link_jdk, $local:target_jdk),
            @($local:link_vim, $local:target_vim),
            @($local:link_bcomp, $local:target_bcomp),
            @($local:link_sumatrapdf, $local:target_sumatrapdf),
            @($local:link_emacs, $local:target_emacs),
            @($local:link_firefox, $local:target_firefox),
            @($local:link_chrome, $local:target_chrome),
            @($local:link_llvm, $local:target_llvm),
            @($local:link_cmake, $local:target_cmake),
            $NULL
        ) | ? { ![String]::IsNullOrWhiteSpace($_) } | % {
            $link, $target = $_
            try {
                if (!([String]::IsNullOrWhiteSpace($target)) -and `
                        (Test-Path -Path $target -PathType Container) -and `
                        (
                            !(Test-Path -Path $link) -or
                            (
                                ((Get-Item -Path $link).Attributes -match "ReparsePoint") -and
                                # unfortunately, powershell *-item is agnostic to symlink.
                                # https://kristofmattei.be/2012/12/15/powershell-remove-item-and-symbolic-links/
                                $(cmd /c rmdir $link | Out-Null; $True)
                            )
                            ) # either not exist, or to overwrite an existing symlink.
                        )
                {
                    $path = Split-Path -Path $link
                    if (!(Test-Path -Path $path -PathType Container)) {
                        New-Item -Path $path -ItemType Directory -Force | Out-Null
                        Write-Verbose "Created directory $path."
                    }
                    cmd /c mklink /d "$link" "$target"
                    Write-Verbose "Created directory link $link to $target."
                }
            } catch {}
        }
    } catch {}

    $local:tmp = @(
                    @(
                    "$prefix",
                    $local:link_emacsbin,
                    $local:link_vim,
                    $local:link_jdk,
                    $local:link_bcomp,
                    $local:link_sumatrapdf,
                    $local:link_firefox,
                    $local:link_chrome,
                    "$local:link_llvm\bin",
                    "$local:link_cmake\bin",
                    "$env:HOMEDRIVE\tools\neovim\Neovim\bin",
                    "$prefix\bin",
                    "$prefix\pciutils",
                    "$prefix\gradle\bin",
                    "$prefix\.lein\bin",
                    "$prefix\ClojureCLR",
                    "$prefix\nodejs",
                    "$prefix\go\bin",
                    "$prefix\gopath\bin",
                    $local:gopathbin,
                    "$prefix\Git",
                    "$prefix\Git\cmd",
                    "$prefix\global\bin",
                    "$prefix\emacs\bin",
                    "$prefix\vim",
                    "$prefix\nmap",
                    "$prefix\SysinternalsSuite",
                    "$prefix\PAL",
                    "$prefix\Windows Kits\10\Debuggers\x64",
                    "$prefix\Windows Kits\10\Tools\x64",
                    "$prefix\Windows Kits\10\Windows Performance Toolkit",
                    $NULL) + `
                    @(
                        Get-ChildItem "$prefix\Windows Kits\10\bin\*\x64" | % { $_.FullName } | Sort-Object -Descending
                    ) + @(
                    "$prefix\etwpackage\bin",
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
                    "$prefix\mupdf",
                    $NULL
                    )
                ) | ? {
                    !([String]::IsNullOrWhiteSpace($_)) -and `
                    (Test-Path $_ -PathType Container -ErrorAction SilentlyContinue) -and `
                    !([Environment]::GetEnvironmentVariable(
                        "PATH", [System.EnvironmentVariableTarget]::User
                        ) -match [Regex]::Escape($_) ) -and `
                    $true
                }
    $path = if (![String]::IsNullOrWhiteSpace($local:tmp)) {
        [String]::Join([IO.Path]::PathSeparator,
        $(
            @(
                $local:tmp,
                $env:PWDE_PERSISTENT_PATH,
                $NULL
            ) | ? { ![String]::IsNullOrWhiteSpace($_) }
        ))
    }

    $local:tmp = @(
                "$prefix\jdk\bin",
                $NULL
            ) | ? {
                !([String]::IsNullOrWhiteSpace($_)) -and `
                (Test-Path $_ -PathType Container -ErrorAction SilentlyContinue) -and `
                !([Environment]::GetEnvironmentVariable(
                    "PATH", [System.EnvironmentVariableTarget]::Machine
                    ) -match [Regex]::Escape($_) ) -and `
                $true
            }
    $syspath = if (![String]::IsNullOrWhiteSpace($local:tmp)) {
        [String]::Join([IO.Path]::PathSeparator, $local:tmp)
    }

    @(
        "PATH",
        "HOME",
        "EDITOR",
        "ALTERNATE_EDITOR",
        $NULL
    ) | ? { ![String]::IsNullOrWhiteSpace($_) } | % {
        $name = $_
        $bakname = "${name}_BACKUP"
        foreach ($env in @(
                [System.EnvironmentVariableTarget]::Machine,
                [System.EnvironmentVariableTarget]::Process,
                [System.EnvironmentVariableTarget]::User
            )) {
            $local:cur = [System.Environment]::GetEnvironmentVariable($name, $env)
            $local:curbak = [System.Environment]::GetEnvironmentVariable($bakname, $env)
            if (
                (![String]::IsNullOrWhiteSpace($local:cur)) -and `
                ($local:curbak -ne $local:cur)
            ) {
                Write-Verbose "Backing up environment variable $name to $bakname in $env."
                try {
                    [Environment]::SetEnvironmentVariable(
                        $bakname,
                        [Environment]::GetEnvironmentVariable($name, $env),
                        $env
                    )
                }
                catch { }
            }
            else {
                Write-Verbose "$name has already been backed up to $bakname in $env."
            }
        }
    }

    @(
        @("PATH",
            $([String]::Join([IO.Path]::PathSeparator, $(@(
                        $syspath,
                        [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine),
                        $NULL
                    ) | ? { ![String]::IsNullOrWhiteSpace($_) })
                    )),
            @(
                [System.EnvironmentVariableTarget]::Machine
            )),
        @("PATH",
            $([String]::Join([IO.Path]::PathSeparator, $(@(
                        $path,
                        [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User),
                        $NULL
                    ) | ? { ![String]::IsNullOrWhiteSpace($_) })
                    )),
            @(
                [System.EnvironmentVariableTarget]::User
            )),
        @("PATH",
            $([String]::Join([IO.Path]::PathSeparator, $(@(
                        # combine previous 2 settings
                        [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User),
                        [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine),
                        $NULL
                    ) | ? { ![String]::IsNullOrWhiteSpace($_) })
                    )),
            @(
                [System.EnvironmentVariableTarget]::Process
            )),
        $NULL
    ) | ? { ! ([String]::IsNullOrWhiteSpace($_)) } | % {
        $var, $val, $targets = $_

        foreach ($target in $targets) {
            if ([System.Environment]::GetEnvironmentVariable($var, $target) -ne $val) {
                Write-Verbose "Setting environment variable: |$var|=|$val| in $target."
                [Environment]::SetEnvironmentVariable($var, $val, $target)
            } else {
                Write-Verbose "$var has already been set correctly in $target."
            }
        }
    }

    @(
        @("HOME", $("$prefix".Replace("\", "/"))),
        @("PWDE_HOME", $prefix.Replace("\", "/")),

        $(if ($target = (gcm nvim-qt.exe -ErrorAction SilentlyContinue).path) {
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
            <#
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "jdk", "bin", "javac.exe")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("JAVA_HOME", "$prefix\jdk".Replace("\", "/"))
            }
            else { $NULL }),
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "jdk", "bin", "javac.exe")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("_JAVA_OPTIONS", "-Duser.home=`"$prefix`" $env:PWDE_JAVA_OPTIONS")
            }
            else { $NULL }),
            #>
        $(if (Test-Path ([IO.Path]::Combine("$prefix", ".lein", "bin", "lein.bat")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("LEIN_HOME", "$prefix\.lein".Replace("\", "/"))
            }
            else { $NULL }),
            <#
        $(if (Test-Path ([IO.Path]::Combine("$prefix", "jdk", "bin", "java.exe")) -PathType Leaf -ErrorAction SilentlyContinue) {
                @("LEIN_JAVA_CMD", "$prefix\jdk\bin\java.exe".Replace("\", "/"))
            }
            else { $NULL }),
            #>
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
        @(
            [System.EnvironmentVariableTarget]::Process,
            $(if ([String]::IsNullOrWhiteSpace($tar)) {
                [System.EnvironmentVariableTarget]::User
            } else { $tar })
        ) | % {
            $target = $_
            if ([System.Environment]::GetEnvironmentVariable($var, $target) -ne $val) {
                Write-Verbose "Setting environment variable: |$var|=|$val| in $target."
                [Environment]::SetEnvironmentVariable($var, $val, $target)
            }
            else {
                Write-Verbose "$var has already been set correctly in $target."
            }
        }
    }
}

function update-syspref ($prefix) {
    # Update file type association
    @(
        @(
            @(".pdf", ".epub", ".cbz", ".xps", ".oxps"), "MuPDF", $(
                $exe="mupdf-gl.exe"
                $path=(Get-Command -Name $exe -ErrorAction SilentlyContinue).path
                if ($path) { $path } else {
                    $path=[IO.Path]::Combine($prefix, "mupdf", $exe)
                    if (Test-Path -Path $path -PathType Leaf -ErrorAction SilentlyContinue) { $path }
                }),
            "`"%1`""
        ),
        $NULL
    ) | ? { ![String]::IsNullOrWhiteSpace($_) } | % {
        $exts, $filetype, $exe, $param = $_
        if ((![String]::IsNullOrWhiteSpace($exe)) -and `
            (Test-Path -Path $exe -PathType Leaf -ErrorAction SilentlyContinue))
        {
            foreach ($ext in $exts) {
                # https://stackoverflow.com/a/46839692
                # https://ss64.com/ps/stop-parsing.html
                invoke-Expression @"
cmd /c --% assoc $ext=$filetype
cmd /c --% ftype $filetype="$exe" $param
"@
            }
        }
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


        $(if ($target = (gcm nvim-qt.exe -ErrorAction SilentlyContinue).path) {
                @($target, "$desktop\NeoVim.lnk")
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
                Write-Verbose "Shortcut: $src Arguments:`"$args`" Hotkey:`"$hotkey`" => $shortcut"
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
                Write-Verbose "Shortcut: $src Arguments:`"$args`" Hotkey:`"$hotkey`" => $shortcut"
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
        $(if ($target = (gcm "nvim-qt.exe" -ErrorAction SilentlyContinue).path) {
                @("Open with Vim", "`"$target`"", "$target")
            }
            else { $NULL }),
        $(if ($target = (gcm "nvim-qt.exe" -ErrorAction SilentlyContinue).path) {
                @("Open with Vim (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$target`"", "$target")
            }
            else { $NULL }),
        $NULL
    ) | % {
        if ($_) {
            $name, $value, $testpath = $_
            # either $testpath is $null, or $testpath must exists.
            if (!$testpath -or $(Test-Path "$testpath")) {
                Write-Verbose "Directory Context Menu: $name => $value"
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
        $(if ($target = (gcm "nvim-qt.exe" -ErrorAction SilentlyContinue).path) {
                @("Edit with Vim", "`"$target`" `"%1`"", "$target")
            }
            else { $NULL }),
        $(if ($target = (gcm "gvim.exe" -ErrorAction SilentlyContinue).path) {
                @("View with Vim", "`"$target`" -R `"%1`"", "$target")
            }
            else { $NULL }),
        $(if ($target = (gcm "nvim-qt.exe" -ErrorAction SilentlyContinue).path) {
                @("Edit with Vim (Admin)", "`"powershell.exe`" -windowstyle hidden -noninteractive -noprofile -nologo -command start-process -verb runas -wait `"$target`" `"%1`"", "$target")
            }
            else { $NULL }),
        $NULL
    ) | % {
        if ($_) {
            $name, $value, $testpath = $_
            if (!$testpath -or $(Test-Path "$testpath")) {
                Write-Verbose "All File Type Context Menu: $name => $value"
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