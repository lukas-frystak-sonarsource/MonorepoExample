# MonorepoExample
This repository contains multiple projects. These projects need to be analyzed with different versions of the SonarScanner.

## Run analysis locally
Sonar analysis is triggered from the `LocalRunScript.ps1`. Analysis runs for both project types: .NET, and CLI. An analysis can be run locally against SonarQube or SonarCloud.

### The run script
```
LocalRunScript.ps1 [[-prId] <string>] [[-prBaseBranch] <string>] [-AnalyzeOnSonarCloud] [-PR] [-AnalysisDebugLog]
```

**Branch analysis with SonarQube**
```
.\LocalRunScript.ps1
```

**Branch analysis with SonarCloud**
```
.\LocalRunScript.ps1 -AnalyzeOnSonarCloud
```

**Pull Request analysis**
Pull request analysis can be run with SonarQube or SonarCloud, using the above mentioned switch.
```
.\LocalRunScript.ps1 -PR -prId <string> -prBaseBranch <string>
```
*Example:* Analyze pull request on SonarCloud. The pull request ID=1 and merges the branch under analysis into the main branch.
```
.\LocalRunScript.ps1 -AnalyzeOnSonarCloud -PR -prId 1 -prBaseBranch main
```
