$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$artifactPath = Join-Path $scriptDirectory "All_Artifacts"

$basicInfoPath = Join-Path $artifactPath "BasicInfo"
if (!(Test-Path $basicInfoPath)) {
    New-Item -Path $basicInfoPath -ItemType Directory | Out-Null
}

try {
    Get-Date | Out-File -FilePath (Join-Path $basicInfoPath "Get-Date.txt") -Encoding UTF8
} catch {
    "Error collecting system time: $_" | Out-File -FilePath (Join-Path $basicInfoPath "Get-Date_error.txt") -Encoding UTF8
}

try {
    Get-LocalUser | Out-File -FilePath (Join-Path $basicInfoPath "Get-LocalUser.txt") -Encoding UTF8
} catch {
    "Error collecting local user info: $_" | Out-File -FilePath (Join-Path $basicInfoPath "Get-LocalUser_error.txt") -Encoding UTF8
}

try {
    net user | Out-File -FilePath (Join-Path $basicInfoPath "net_user.txt") -Encoding UTF8
} catch {
    "Error collecting net user info: $_" | Out-File -FilePath (Join-Path $basicInfoPath "net_user_error.txt") -Encoding UTF8
}

try {
    Get-LocalGroupMember -Group "Administrators" | Out-File -FilePath (Join-Path $basicInfoPath "Get-LocalGroupMember_Administrators.txt") -Encoding UTF8
} catch {
    "Error collecting administrators group info: $_" | Out-File -FilePath (Join-Path $basicInfoPath "Get-LocalGroupMember_Administrators_error.txt") -Encoding UTF8
}

try {
    Get-CimInstance -ClassName Win32_StartupCommand | Out-File -FilePath (Join-Path $basicInfoPath "Get-StartupCommand.txt") -Encoding UTF8
} catch {
    "Error collecting startup commands: $_" | Out-File -FilePath (Join-Path $basicInfoPath "Get-StartupCommand_error.txt") -Encoding UTF8
}

try {
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Out-File -FilePath (Join-Path $basicInfoPath "HKLM_Run.txt") -Encoding UTF8
} catch {
    "Error collecting HKLM Run registry: $_" | Out-File -FilePath (Join-Path $basicInfoPath "HKLM_Run_error.txt") -Encoding UTF8
}

try {
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Out-File -FilePath (Join-Path $basicInfoPath "HKCU_Run.txt") -Encoding UTF8
} catch {
    "Error collecting HKCU Run registry: $_" | Out-File -FilePath (Join-Path $basicInfoPath "HKCU_Run_error.txt") -Encoding UTF8
}

$pcInfoPath = Join-Path $artifactPath "PCInfo"
if (!(Test-Path $pcInfoPath)) {
    New-Item -Path $pcInfoPath -ItemType Directory | Out-Null
}

try {
    Get-ComputerInfo | Out-File -FilePath (Join-Path $pcInfoPath "Get-ComputerInfo.txt") -Encoding UTF8
} catch {
    "Error collecting OS info: $_" | Out-File -FilePath (Join-Path $pcInfoPath "Get-ComputerInfo_error.txt") -Encoding UTF8
}

try {
    systeminfo | Out-File -FilePath (Join-Path $pcInfoPath "systeminfo.txt") -Encoding UTF8
} catch {
    "Error collecting systeminfo: $_" | Out-File -FilePath (Join-Path $pcInfoPath "systeminfo_error.txt") -Encoding UTF8
}

try {
    Get-PnpDevice | Out-File -FilePath (Join-Path $pcInfoPath "Get-PnpDevice.txt") -Encoding UTF8
} catch {
    "Error collecting device info: $_" | Out-File -FilePath (Join-Path $pcInfoPath "Get-PnpDevice_error.txt") -Encoding UTF8
}

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