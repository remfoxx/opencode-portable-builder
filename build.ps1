
$ErrorActionPreference = "Stop"

function Convert-PngToIco {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PngPath,

        [Parameter(Mandatory = $true)]
        [string]$IcoPath
    )

    Add-Type -AssemblyName System.Drawing

    $Sizes = @(16, 24, 32, 48, 64, 128, 256)
    $SourceImage = $null
    $ImageData = [System.Collections.Generic.List[byte[]]]::new()

    try {
        $SourceImage = [System.Drawing.Image]::FromFile($PngPath)

        foreach ($Size in $Sizes) {

            $Bitmap = [System.Drawing.Bitmap]::new(
                $Size,
                $Size,
                [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
            )

            $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
            $MemoryStream = [System.IO.MemoryStream]::new()

            try {
                $Graphics.Clear([System.Drawing.Color]::Transparent)

                $Graphics.InterpolationMode =
                    [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

                $Graphics.SmoothingMode =
                    [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

                $Graphics.PixelOffsetMode =
                    [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

                $Scale = [Math]::Min(
                    ($Size * 0.86) / $SourceImage.Width,
                    ($Size * 0.86) / $SourceImage.Height
                )

                $Width = [int][Math]::Round($SourceImage.Width * $Scale)
                $Height = [int][Math]::Round($SourceImage.Height * $Scale)

                $X = [int](($Size - $Width) / 2)
                $Y = [int](($Size - $Height) / 2)

                $Graphics.DrawImage(
                    $SourceImage,
                    $X,
                    $Y,
                    $Width,
                    $Height
                )

                $Bitmap.Save(
                    $MemoryStream,
                    [System.Drawing.Imaging.ImageFormat]::Png
                )

                $ImageData.Add([byte[]]$MemoryStream.ToArray())
            }
            finally {
                $Graphics.Dispose()
                $Bitmap.Dispose()
                $MemoryStream.Dispose()
            }
        }

        $FileStream = [System.IO.File]::Create($IcoPath)
        $Writer = [System.IO.BinaryWriter]::new($FileStream)

        try {
            $Writer.Write([UInt16]0)
            $Writer.Write([UInt16]1)
            $Writer.Write([UInt16]$Sizes.Count)

            $Offset = 6 + (16 * $Sizes.Count)

            for ($i = 0; $i -lt $Sizes.Count; $i++) {

                $Size = $Sizes[$i]
                $Data = $ImageData[$i]

                $Dimension = if ($Size -eq 256) {
                    0
                }
                else {
                    $Size
                }

                $Writer.Write([byte]$Dimension)
                $Writer.Write([byte]$Dimension)
                $Writer.Write([byte]0)
                $Writer.Write([byte]0)
                $Writer.Write([UInt16]1)
                $Writer.Write([UInt16]32)
                $Writer.Write([UInt32]$Data.Length)
                $Writer.Write([UInt32]$Offset)

                $Offset += $Data.Length
            }

            foreach ($Data in $ImageData) {
                $Writer.Write($Data)
            }
        }
        finally {
            $Writer.Dispose()
            $FileStream.Dispose()
        }
    }
    finally {
        if ($SourceImage) {
            $SourceImage.Dispose()
        }
    }
}

try {

    $Source = $PSScriptRoot
    $Destination = Join-Path $Source "OpenCodePortable"
    $ScriptPath = $PSCommandPath

    $PackageRoot = Join-Path $Source "node_modules\@opencode\cli"

    $PackageJson = Join-Path $PackageRoot "package.json"

    $PackageBinary = Join-Path $PackageRoot `
        "node_modules\@opencode\cli-windows-x64\bin\opencode.exe"

    $TargetBinary = Join-Path $Destination `
        "App\OpenCode\opencode.exe"


    Write-Host "`n=== OpenCode Portable Builder ===" -ForegroundColor DarkYellow

    if (Test-Path -LiteralPath $Destination) {
        throw "OpenCodePortable already exists. Remove or rename it first"
    }

    if (-not $ScriptPath) {
        throw "Cannot determine script path. Save this script as a .ps1 file"
    }

    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm not found. Install Node.js or add npm to PATH"
    }

    Write-Host "`n[1/7] Downloading OpenCode via npm..." -ForegroundColor DarkYellow

    & npm install -g "@opencode/cli@latest" --prefix $Source

    if ($LASTEXITCODE -ne 0) {
        throw "npm installation failed. Exit code: $LASTEXITCODE"
    }

    Write-Host "npm installation completed" -ForegroundColor DarkGray

    Write-Host "`n[2/7] Reading OpenCode version..." -ForegroundColor DarkYellow

    if (-not (Test-Path -LiteralPath $PackageJson)) {
        throw "Package.json not found: $PackageJson"
    }

    $PackageInfo = Get-Content -LiteralPath $PackageJson -Raw |
        ConvertFrom-Json

    $DisplayVersion = [string]$PackageInfo.version

    if (-not $DisplayVersion) {
        throw "Cannot determine OpenCode version from package.json"
    }

    $VersionMatch = [regex]::Match(
        $DisplayVersion,
        '^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)'
    )

    if (-not $VersionMatch.Success) {
        throw "Unsupported version format: $DisplayVersion"
    }

    $PackageVersion = "{0}.{1}.{2}.0" -f `
        $VersionMatch.Groups["major"].Value,
        $VersionMatch.Groups["minor"].Value,
        $VersionMatch.Groups["patch"].Value

    Write-Host "Display version: $DisplayVersion" -ForegroundColor DarkGray
    Write-Host "Package version: $PackageVersion" -ForegroundColor DarkGray

    Write-Host "`n[3/7] Locating native Windows x64 binary..." -ForegroundColor DarkYellow

    if (-not (Test-Path -LiteralPath $PackageBinary)) {
        throw "Native Windows x64 binary not found: $PackageBinary"
    }

    Write-Host "Found: $PackageBinary" -ForegroundColor DarkGray

    Write-Host "`n[4/7] Creating PortableApps folder structure..." -ForegroundColor DarkYellow

    $Directories = @(
        "App\OpenCode",
        "App\AppInfo\Launcher",
        "Data\config\opencode",
        "Data\data\opencode",
        "Data\cache\opencode",
        "Data\state\opencode",
        "Other\Source"
    )

    New-Item -ItemType Directory -Path $Destination | Out-Null

    foreach ($Directory in $Directories) {
        New-Item -ItemType Directory `
            -Path (Join-Path $Destination $Directory) `
            -Force | Out-Null
    }

    Write-Host "`n[5/7] Copying OpenCode binary..." -ForegroundColor DarkYellow

    Copy-Item -LiteralPath $PackageBinary `
        -Destination $TargetBinary


    $LauncherConfig = @'
[Launch]
ProgramExecutable=OpenCode\opencode.exe
WorkingDirectory=%PAL:PortableAppsDir%

[Environment]
XDG_CONFIG_HOME=%PAL:DataDir%\config
XDG_DATA_HOME=%PAL:DataDir%\data
XDG_CACHE_HOME=%PAL:DataDir%\cache
XDG_STATE_HOME=%PAL:DataDir%\state

OPENCODE_DISABLE_AUTOUPDATE=true
'@

    $LauncherPath = Join-Path $Destination `
        "App\AppInfo\Launcher\OpenCodePortable.ini"

    [System.IO.File]::WriteAllText(
        $LauncherPath,
        $LauncherConfig,
        [System.Text.UTF8Encoding]::new($false)
    )

    $AppInfo = @"
[Format]
Type=PortableApps.comFormat
Version=3.9

[Details]
Name=OpenCode Portable
AppID=OpenCodePortable
Publisher=OpenCode
Homepage=https://opencode.ai/
Category=Development
Description=AI-powered coding agent for the terminal
Language=Multilingual

[License]
Shareable=true
OpenSource=true
Freeware=true
CommercialUse=true

[Version]
PackageVersion=$PackageVersion
DisplayVersion=$DisplayVersion

[Control]
Icons=1
Start=OpenCodePortable.exe
"@

    $AppInfoPath = Join-Path $Destination `
        "App\AppInfo\appinfo.ini"

    [System.IO.File]::WriteAllText(
        $AppInfoPath,
        $AppInfo,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "appinfo.ini created successfully" -ForegroundColor DarkGray

    Write-Host "`n[6/7] Creating OpenCode application icon..." -ForegroundColor DarkYellow

    $LogoUrl = "https://opencode.ai/brand/files/opencode-logo-dark.png"
    $IconPath = Join-Path $Destination "App\AppInfo\appicon.ico"
    $LogoPngPath = Join-Path $env:TEMP (
        "opencode-logo-dark-{0}.png" -f [guid]::NewGuid().ToString("N")
    )

    try {
        $PreviousProgressPreference = $ProgressPreference
        $ProgressPreference = "SilentlyContinue"

        try {
            Invoke-WebRequest `
                -Uri $LogoUrl `
                -OutFile $LogoPngPath `
                -UseBasicParsing `
                -ErrorAction Stop
        }
        finally {
            $ProgressPreference = $PreviousProgressPreference
        }

        Convert-PngToIco `
            -PngPath $LogoPngPath `
            -IcoPath $IconPath

        Write-Host "OpenCode application icon created" -ForegroundColor DarkGray
    }
    finally {
        if (Test-Path -LiteralPath $LogoPngPath) {
            Remove-Item -LiteralPath $LogoPngPath -Force
        }
    }

    Write-Host "`n[7/7] Verifying OpenCode Portable..." -ForegroundColor DarkYellow

    & $TargetBinary --version

    if ($LASTEXITCODE -ne 0) {
        throw "OpenCode binary verification failed"
    }

    if (-not (Test-Path -LiteralPath $AppInfoPath -PathType Leaf)) {
        throw "appinfo.ini verification failed."
    }

    if (-not (Test-Path -LiteralPath $LauncherPath -PathType Leaf)) {
        throw "Launcher configuration verification failed"
    }

    if (-not (Test-Path -LiteralPath $IconPath -PathType Leaf)) {
        throw "Application icon was not created: $IconPath"
    }

    Write-Host "`n=== BUILD SUCCESSFUL ===" -ForegroundColor Green

    Write-Host "`nCreated structure:" -ForegroundColor DarkYellow
    tree $Destination /F

    Write-Host "`nCleaning temporary installation files..." -ForegroundColor DarkYellow

    $Items = Get-ChildItem -LiteralPath $Source -Force

    foreach ($Item in $Items) {

        if ($Item.FullName -eq $Destination) {
            continue
        }

        if ($Item.FullName -eq $ScriptPath) {
            continue
        }

        Remove-Item -LiteralPath $Item.FullName -Recurse -Force

        Write-Host "Removed: $($Item.Name)" -ForegroundColor DarkGray
    }

    Write-Host "`nCleanup completed, OpenCode Portable is ready to build with PortableApps Launcher" -ForegroundColor Green

}
catch {
    Write-Host "`nBUILD FAILED: $_" -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"
