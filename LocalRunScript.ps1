#
# Constants
#
$SONARQUBE_URL = [Environment]::GetEnvironmentVariable("SONARQUBE_URL")
$SONARQUBE_TOKEN = [Environment]::GetEnvironmentVariable("SONARQUBE_TOKEN")

# .NET Analysis parameters
$dotnetScannerParameterList = @(
    "/key:MonorepoExample_DotnetProject",
    "/name:""Monorepo Example: .NET Project""",
    "/v:1.0.0",
    "/d:sonar.host.url=$SONARQUBE_URL",
    "/d:sonar.login=$SONARQUBE_TOKEN",
    "/d:sonar.verbose=false"
    #"/d:sonar.pullrequest.key=2",
    #"/d:sonar.pullrequest.branch=lukas/test-pr",
    #"/d:sonar.pullrequest.base=main"
)

# CLI Analysis parameters
$cliScannerParameterList = @(
    "-D sonar.projectKey=MonorepoExample_PythonProject",
    "-D sonar.projectName=""Monorepo Example: Python Project""",
    "-D sonar.projectVersion=1.0.0"
    "-D sonar.host.url=$SONARQUBE_URL",
    "-D sonar.login=$SONARQUBE_TOKEN",
    "-D sonar.sources=./src",
    "-D sonar.exclusions=./src/MonorepoDotnetProject/**/*",
    "-D sonar.python.version=3"
    #"-D sonar.pullrequest.key=2",
    #"-D sonar.pullrequest.branch=lukas/test-pr",
    #"-D sonar.pullrequest.base=main"
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
dotnet sonarscanner end /d:sonar.login=$SONARQUBE_TOKEN

#
# Analyze the Python project
# SonarScanner CLI
#
$cliScannerParameters = [string]::Join(' ', $cliScannerParameterList)
$cliScannerCmd = "sonar-scanner $cliScannerParameters"
Invoke-Expression $cliScannerCmd