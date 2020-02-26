$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$RepoPath = Split-Path -Path $ScriptPath -Parent

# Extend the module path to include this repository
$Env:PSModulePath += ";$RepoPath\modules"

# Import modules and scripts
Import-Module project-helpers
Import-Module posh-git

. "$RepoPath\aliases\all.ps1"
. "$RepoPath\aliases\base64.ps1"
. "$RepoPath\aliases\clipboard.ps1"
. "$RepoPath\aliases\hyper-v.ps1"
. "$RepoPath\aliases\js.ps1"
