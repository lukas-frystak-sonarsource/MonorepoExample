# Powershell Config
$ErrorActionPreference = "Stop"

#
# Constants
#
$SONARQUBE_URL = [Environment]::GetEnvironmentVariable("SONARQUBE_URL")
$SONARQUBE_TOKEN = [Environment]::GetEnvironmentVariable("SONARQUBE_TOKEN")
$SONARCLOUD_URL = "https://sonarcloud.io"
$SONARCLOUD_TOKEN = [Environment]::GetEnvironmentVariable("SONARCLOUD_TOKEN")

$SONAR_URL = $SONARCLOUD_URL
$SONAR_TOKEN = $SONARCLOUD_TOKEN

# .NET Analysis parameters
$dotnetScannerParameterList = @(
    "/o:lukas-frystak-sonarsource",
    "/key:lukas-frystak-sonarsource_MonorepoExample_DotnetProject",
    #"/key:MonorepoExample_DotnetProject",
    #"/name:""Monorepo Example: .NET Project""",
    "/v:1.0.0",
    "/d:sonar.host.url=$SONAR_URL",
    "/d:sonar.login=$SONAR_TOKEN",
    "/d:sonar.verbose=false"
    "/d:sonar.pullrequest.key=3",
    "/d:sonar.pullrequest.branch=lukas/test-pr",
    "/d:sonar.pullrequest.base=main"
)

# CLI Analysis parameters
$cliScannerParameterList = @(
    #"-D sonar.projectKey=MonorepoExample_PythonProject",
    #"-D sonar.projectName=""Monorepo Example: Python Project""",
    "-D sonar.organization=lukas-frystak-sonarsource",
    "-D sonar.projectKey=lukas-frystak-sonarsource_MonorepoExample_PythonProject",
    "-D sonar.projectVersion=1.0.0"
    "-D sonar.host.url=$SONAR_URL",
    "-D sonar.login=$SONAR_TOKEN",
    "-D sonar.sources=./src",
    "-D sonar.exclusions=./src/MonorepoDotnetProject/**/*",
    "-D sonar.python.version=3"
    "-D sonar.pullrequest.key=3",
    "-D sonar.pullrequest.branch=lukas/test-pr",
    "-D sonar.pullrequest.base=main"
)

#
# Build and analyze the .NET project
# .NET build + SonarScanner for .NET
#

# Prepare .NET analysis
$dotnetScannerParameters = [string]::Join(' ', $dotnetScannerParameterList)
$beginCmd = "dotnet sonarscanner begin $dotnetScannerParameters"
Invoke-Expression $beginCmd

# .NET build and test
dotnet build './src/MonorepoDotnetProject/MonorepoDotnetProject.sln'
dotnet test './src/MonorepoDotnetProject/MonorepoDotnetProject.sln' --no-build

# Run .NET analysis
dotnet sonarscanner end /d:sonar.login=$SONAR_TOKEN

#
# Analyze the Python project
# SonarScanner CLI
#
$cliScannerParameters = [string]::Join(' ', $cliScannerParameterList)
$cliScannerCmd = "sonar-scanner $cliScannerParameters"
Invoke-Expression $cliScannerCmd