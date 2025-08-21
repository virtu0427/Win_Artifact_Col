$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$artifactPath = Join-Path $scriptDirectory "Registry_Artifacts"

<#
$registryHives = @(
    "HKLM\SAM",
    "HKLM\SYSTEM",
    "HKLM\SOFTWARE",
    "HKCU"
)

$artifactPath = Join-Path $scriptDirectory "Registry_Artifacts"
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