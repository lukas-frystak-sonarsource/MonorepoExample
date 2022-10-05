[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $AnalyzeOnSonarCloud = $false,

    [Parameter()]
    [switch]
    $PR = $false,

    [Parameter()]
    [string]
    $prId = [string]::Empty,

    [Parameter()]
    [string]
    $prBaseBranch = [string]::Empty,

    [Parameter()]
    [switch]
    $AnalysisDebugLog = $false
)

class AnalysisParameter {
    [string]$PlatformType
    [string]$AnalysisType
    [string]$Value

    AnalysisParameter([string]$pType, [string]$aType, [string]$val) {
        $this.PlatformType = $pType
        $this.AnalysisType = $aType
        $this.Value = $val
    }
}

# Powershell Config
$ErrorActionPreference = "Stop"

###
### Constants
###
$SONARQUBE_URL = [Environment]::GetEnvironmentVariable("SONARQUBE_URL")
$SONARQUBE_TOKEN = [Environment]::GetEnvironmentVariable("SONARQUBE_TOKEN")
$SONARCLOUD_URL = "https://sonarcloud.io"
$SONARCLOUD_TOKEN = [Environment]::GetEnvironmentVariable("SONARCLOUD_TOKEN")

$SOLUTION = "./src/MonorepoDotnetProject/MonorepoDotnetProject.sln"
$coverageReportDirectory = ".\TestResults"
$coverageReportPath = "$coverageReportDirectory\dotCover.Output.html"
$testReportPath = ".\**\*.trx"
$mainBranchName = "main"
$branchName = git rev-parse --abbrev-ref HEAD

###
### Process flags and parameters
###
$BR = $false

if ($PR) {
    [boolean]$doExit = $false

    if ($prId -eq [string]::Empty) {
        Write-Warning "Provide pull request ID with the '-prId' parameter"
        $doExit = $true
    }
    if ($prBaseBranch -eq [string]::Empty) {
        Write-Warning "Provide pull request target (base) branch with the '-prBaseBranch' parameter"
        $doExit = $true
    }
    if ($doExit) {
        Exit 1
    }
}
else {
    if ($mainBranchName -ne $branchName) {
        Write-Host "Running branch analysis"
        $BR = $true
    }
}

if ($AnalyzeOnSonarCloud) {
    $SONAR_URL = $SONARCLOUD_URL
    $SONAR_TOKEN = $SONARCLOUD_TOKEN
}
else {
    $SONAR_URL = $SONARQUBE_URL
    $SONAR_TOKEN = $SONARQUBE_TOKEN
}

if ($AnalysisDebugLog) {
    $AnalysisDebugLogString = "true"
}
else {
    $AnalysisDebugLogString = "false"
}

# .NET Analysis parameters
$dotnetScannerParameterList = @(
    [AnalysisParameter]::new("SC", "--", "/o:lukas-frystak-sonarsource")
    [AnalysisParameter]::new("SC", "--", "/key:lukas-frystak-sonarsource_MonorepoExample_DotnetProject")
    [AnalysisParameter]::new("SQ", "--", "/key:MonorepoExample_DotnetProject")
    [AnalysisParameter]::new("SQ", "--", "/name:""Monorepo Example: .NET Project""")
    [AnalysisParameter]::new("--", "--", "/d:sonar.host.url=$SONAR_URL")
    [AnalysisParameter]::new("--", "--", "/d:sonar.login=$SONAR_TOKEN")
    [AnalysisParameter]::new("--", "--", "/v:1.0.0")
    [AnalysisParameter]::new("--", "--", "/d:sonar.cs.dotcover.reportsPaths=$coverageReportPath")
    [AnalysisParameter]::new("--", "--", "/d:sonar.cs.vstest.reportsPaths=$testReportPath")
    [AnalysisParameter]::new("--", "--", "/d:sonar.verbose=$AnalysisDebugLogString")
    [AnalysisParameter]::new("--", "BR", "/d:sonar.branch.name=$branchName")
    [AnalysisParameter]::new("--", "PR", "/d:sonar.pullrequest.key=$prId")
    [AnalysisParameter]::new("--", "PR", "/d:sonar.pullrequest.base=$prBaseBranch")
    [AnalysisParameter]::new("--", "PR", "/d:sonar.pullrequest.branch=$branchName")
)

# CLI Analysis parameters
$cliScannerParameterList = @(
    [AnalysisParameter]::new("SQ", "--", "-D sonar.projectKey=MonorepoExample_PythonProject"),
    [AnalysisParameter]::new("SQ", "--", "-D sonar.projectName=""Monorepo Example: Python Project"""),
    [AnalysisParameter]::new("SC", "--", "-D sonar.organization=lukas-frystak-sonarsource"),
    [AnalysisParameter]::new("SC", "--", "-D sonar.projectKey=lukas-frystak-sonarsource_MonorepoExample_PythonProject"),
    [AnalysisParameter]::new("--", "--", "-D sonar.projectVersion=1.0.0"),
    [AnalysisParameter]::new("--", "--", "-D sonar.host.url=$SONAR_URL"),
    [AnalysisParameter]::new("--", "--", "-D sonar.login=$SONAR_TOKEN"),
    [AnalysisParameter]::new("--", "--", "-D sonar.sources=./src"),
    [AnalysisParameter]::new("--", "--", "-D sonar.exclusions=src/MonorepoDotnetProject/**/*"),
    [AnalysisParameter]::new("--", "--", "-D sonar.python.version=3"),
    [AnalysisParameter]::new("--", "PR", "-D sonar.pullrequest.key=$prId")
    [AnalysisParameter]::new("--", "PR", "-D sonar.pullrequest.branch=$branchName"),
    [AnalysisParameter]::new("--", "PR", "-D sonar.pullrequest.base=$prBaseBranch"),
    [AnalysisParameter]::new("--", "BR", "-D sonar.branch.name=$branchName")
)

# Filter the analysis parameters
if ($AnalyzeOnSonarCloud) {
    # Exclude parameters related to SonarQube
    $dotnetScannerParameterList = $dotnetScannerParameterList | Where-Object { $_.PlatformType -ne "SQ" }
    $cliScannerParameterList = $cliScannerParameterList | Where-Object { $_.PlatformType -ne "SQ" }
}
else {
    # Exclude parameters related to SonarCloud
    $dotnetScannerParameterList = $dotnetScannerParameterList | Where-Object { $_.PlatformType -ne "SC" }
    $cliScannerParameterList = $cliScannerParameterList | Where-Object { $_.PlatformType -ne "SC" }
}

if ($PR) {
    # Exclude only parameters related to Branch analysis
    $dotnetScannerParameterList = $dotnetScannerParameterList | Where-Object { $_.AnalysisType -ne "BR" }
    $cliScannerParameterList = $cliScannerParameterList | Where-Object { $_.AnalysisType -ne "BR" }
}
else {
    if ($BR) {
        # Exclude only parameters related to Pull Request analysis
        $dotnetScannerParameterList = $dotnetScannerParameterList | Where-Object { $_.AnalysisType -ne "PR" }
        $cliScannerParameterList = $cliScannerParameterList | Where-Object { $_.AnalysisType -ne "PR" }
    }
    else {
        # Exclude parameters related to branch analysis and pull request analysis
        # I.e., use only the generic parameters
        $dotnetScannerParameterList = $dotnetScannerParameterList | Where-Object { $_.AnalysisType -eq "--" }
        $cliScannerParameterList = $cliScannerParameterList | Where-Object { $_.AnalysisType -eq "--" }
    }
}

###
### Build and analyze the projects
###

# Prepare .NET analysis
$dotnetScannerParameters = [string]::Join(' ', $($dotnetScannerParameterList).Value)
$beginCmd = "dotnet sonarscanner begin $dotnetScannerParameters"
Invoke-Expression $beginCmd

# .NET build and test
dotnet build $SOLUTION --configuration Release
dotnet dotcover test $SOLUTION --no-build --configuration Release --dcReportType=html --dcOutput=$coverageReportPath --logger trx


# Run .NET analysis
dotnet sonarscanner end /d:sonar.login=$SONAR_TOKEN 3>&1 2>&1 > dotnet-analysis.log

# Analyze the Python project - SonarScanner CLI
$cliScannerParameters = [string]::Join(' ', $($cliScannerParameterList).Value)

# Append debug flag in debug mode
if ($AnalysisDebugLog){
    $cliScannerParameters = "$cliScannerParameters -X"
}

# Run CLI analysis
$cliScannerCmd = "sonar-scanner $cliScannerParameters"
Invoke-Expression $cliScannerCmd  3>&1 2>&1 > cli-analysis.log
