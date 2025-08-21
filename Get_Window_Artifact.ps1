$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$artifactPath = Join-Path $scriptDirectory "All_Artifacts"


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