# This script is called from inside an MSBuild task to download FFmpeg binaries:
# dotnet build -t:DownloadFFmpeg

param (
    [string]$platform,
    [string]$outputPath
)

$ErrorActionPreference = "Stop"

# Normalize platform identifier
$platform = $platform.ToLower().Replace("win-", "windows-")

# Download the archive
Write-Host "Downloading FFmpeg..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$http = New-Object System.Net.WebClient
try {
    $http.DownloadFile("https://github.com/Tyrrrz/FFmpegBin/releases/download/7.0/ffmpeg-$platform.zip", "$outputPath.zip")
} finally {
    $http.Dispose()
}

try {
    # Extract FFmpeg
    Add-Type -Assembly System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead("$outputPath.zip")
    try {
        $fileName = If ($platform.Contains("windows-")) { "ffmpeg.exe" } Else { "ffmpeg" }
        [IO.Compression.ZipFileExtensions]::ExtractToFile($zip.GetEntry($fileName), $outputPath)
    } finally {
        $zip.Dispose()
    }

    Write-Host "Done downloading FFmpeg."
} finally {
    # Clean up
    Remove-Item "$outputPath.zip" -Force
}