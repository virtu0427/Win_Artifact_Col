$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$artifactPath = Join-Path $scriptDirectory "All_Artifacts"

<#
$webArtifactPath = Join-Path $artifactPath "Web_Artifact"
if (!(Test-Path $webArtifactPath)) {
    New-Item -Path $webArtifactPath -ItemType Directory | Out-Null
}

$browserInfo = @(
    @{
        Name = "Chrome"
        UserDataPath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
        HistoryRelPath = "Default\History"
        CacheRelPath = "Default\Cache"
    },
    @{
        Name = "Edge"
        UserDataPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
        HistoryRelPath = "Default\History"
        CacheRelPath = "Default\Cache"
    }
)

foreach ($browser in $browserInfo) {
    $browserFolder = Join-Path $webArtifactPath $browser.Name
    if (!(Test-Path $browserFolder)) {
        New-Item -Path $browserFolder -ItemType Directory | Out-Null
    }

    $historySrc = Join-Path $browser.UserDataPath $browser.HistoryRelPath
    $historyDst = Join-Path $browserFolder "History"
    if (Test-Path $historySrc) {
        try {
            Copy-Item -Path $historySrc -Destination $historyDst -Force
        } catch {
            "Error copying history file for $($browser.Name): $_" | Out-File -FilePath (Join-Path $browserFolder "history_copy_error.txt") -Encoding UTF8
        }
    }

    $cacheSrc = Join-Path $browser.UserDataPath $browser.CacheRelPath
    $cacheDst = Join-Path $browserFolder "Cache"
    if (Test-Path $cacheSrc) {
        try {
            Copy-Item -Path $cacheSrc -Destination $cacheDst -Recurse -Force
        } catch {
            "Error copying cache folder for $($browser.Name): $_" | Out-File -FilePath (Join-Path $browserFolder "cache_copy_error.txt") -Encoding UTF8
        }
    }
}
#>

<#
$netInfoPath = Join-Path $artifactPath "NetInfo"
if (!(Test-Path $netInfoPath)) {
    New-Item -Path $netInfoPath -ItemType Directory | Out-Null
}

$netCommands = @{
    "ipconfig.txt"    = "ipconfig /all"
    "arp.txt"         = "arp -a"
    "route.txt"       = "route print"
    "netstat.txt"     = "netstat -ano"
    "hostname.txt"    = "hostname"
    "nslookup.txt"    = "nslookup localhost"
}

foreach ($file in $netCommands.Keys) {
    $cmd = $netCommands[$file]
    $outputFile = Join-Path $netInfoPath $file
    try {
        Invoke-Expression $cmd | Out-File -FilePath $outputFile -Encoding UTF8
    } catch {
        "Error running command: $cmd" | Out-File -FilePath $outputFile -Encoding UTF8
    }
}
#>


<#
$registryHives = @(
    "HKLM\SAM",
    "HKLM\SYSTEM",
    "HKLM\SOFTWARE",
    "HKCU"
)

$artifactPath = Join-Path $scriptDirectory "All_Artifacts"
if (!(Test-Path $artifactPath)) {
    New-Item -Path $artifactPath -ItemType Directory | Out-Null
}

foreach ($hive in $registryHives) {
    $hiveName = $hive -replace "HKLM\\|HKCU", ""
    $safeHiveName = $hiveName -replace "[\\\/:]", "_"
    if ($safeHiveName -eq "") { $safeHiveName = "HKCU" }
    $outputFile = Join-Path $artifactPath "$safeHiveName.reg"
    reg export $hive $outputFile /y | Out-Null
}
#>